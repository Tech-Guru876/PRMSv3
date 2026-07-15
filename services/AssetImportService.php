<?php
/**
 * AssetImportService — idempotent Excel/CSV import of inventory assets.
 *
 * Duplicate detection order:
 *   1. Asset Code (primary unique identifier)
 *   2. Serial Number
 *   3. Reference Number
 *   4. Item Name + Make + Acquired Date
 *
 * Rows are processed inside a transaction per chunk with a SAVEPOINT per
 * row, so a failing row rolls back alone and the import continues.
 */

require_once __DIR__ . '/SpreadsheetReader.php';

class AssetImportService
{
    const CHUNK_SIZE = 250;

    /** Map of normalized spreadsheet header → canonical field key */
    const HEADER_MAP = [
        'assetcode'                => 'asset_code',
        'itemname'                 => 'item_name',
        'type'                     => 'asset_type',
        'make'                     => 'make',
        'reference'                => 'reference_number',
        'referencenumber'          => 'reference_number',
        'acquireddate'             => 'acquired_date',
        'department'               => 'department',
        'bos'                      => 'bos_value',
        'increase'                 => 'increase_value',
        'balance'                  => 'balance_value',
        'decrease'                 => 'decrease_value',
        'status'                   => 'status',
        'category'                 => 'category',
        'condition'                => 'condition',
        'description'              => 'description',
        'custodian'                => 'custodian',
        'deliverydate'             => 'delivery_date',
        'placedinservice'          => 'placed_in_service_date',
        'warrantyexpiration'       => 'warranty_expiration',
        'titledeednumber'          => 'title_deed_number',
        'address'                  => 'address',
        'serialnumber'             => 'serial_number',
        'revaluedcost'             => 'revalued_cost',
        'revalueddate'             => 'revalued_date',
        'accumulateddepreciation'  => 'accumulated_depreciation',
        'depreciationcharge'       => 'depreciation_charge',
        'carringvalue'             => 'carrying_value',
        'carryingvalue'            => 'carrying_value',
        'methodrateofdepreciation' => 'depreciation_method_rate',
        'methodandrateofdepreciation' => 'depreciation_method_rate',
        'impairment'               => 'impairment',
        'budgetcode'               => 'budget_code',
        'purchasedordonated'       => 'acquisition_method',
        'insuredvalue'             => 'insured_value',
        'forcedsalevalue'          => 'forced_sale_value',
        'disposaldate'             => 'disposal_date',
        'disposalamount'           => 'disposal_amount',
        'disposalauthorization'    => 'disposal_authorization',
        'disposalauthorisation'    => 'disposal_authorization',
        'disposed'                 => 'disposed',
        'attachments'              => 'attachments_note',
        'commentsremarks'          => 'comments',
        'comments'                 => 'comments',
        'remarks'                  => 'comments',
    ];

    const DATE_FIELDS = [
        'acquired_date', 'delivery_date', 'placed_in_service_date',
        'warranty_expiration', 'revalued_date', 'disposal_date',
    ];

    const NUMERIC_FIELDS = [
        'bos_value', 'increase_value', 'balance_value', 'decrease_value',
        'revalued_cost', 'accumulated_depreciation', 'depreciation_charge',
        'carrying_value', 'impairment', 'insured_value',
        'forced_sale_value', 'disposal_amount',
    ];

    /** Monetary fields that must not be negative (unless allow_negative) */
    const MONETARY_FIELDS = [
        'bos_value', 'balance_value', 'revalued_cost', 'accumulated_depreciation',
        'depreciation_charge', 'carrying_value', 'impairment', 'insured_value',
        'forced_sale_value', 'disposal_amount',
    ];

    /** @var PDO */
    private $pdo;
    /** @var int */
    private $userId;
    /** @var array */
    private $options;

    /** @var array Lookup caches keyed by normalized value */
    private $categoryCache   = [];
    private $assetTypeCache  = [];
    private $branchCache     = [];
    private $userCache       = [];
    private $defaultUomId    = null;

    /** @var array Existing-record indexes for duplicate detection */
    private $byAssetCode = [];   // normalized asset/item code → item_id
    private $bySerial    = [];   // normalized serial          → item_id
    private $byReference = [];   // normalized reference       → item_id
    private $byComposite = [];   // name|make|acquired_date    → item_id

    /** @var array Import errors: [row, asset_code, field, message] */
    private $errors = [];

    private $created = 0;
    private $updated = 0;
    private $skipped = 0;

    public function __construct(PDO $pdo, int $userId, array $options = [])
    {
        $this->pdo = $pdo;
        $this->userId = $userId;
        $this->options = array_merge([
            'update_existing'     => false,
            'auto_create_lookups' => true,
            'allow_negative'      => false,
            'date_format'         => 'dmy', // dd/mm/yyyy preferred over mm/dd/yyyy
        ], $options);
    }

    /**
     * Run the import. Returns a summary array:
     * [batch_id, total_rows, created, updated, skipped, errors(int), error_rows(array)]
     */
    public function import(string $filePath, string $fileName): array
    {
        $rows = SpreadsheetReader::read($filePath, $fileName);
        if (count($rows) < 2) {
            throw new RuntimeException('The file contains no data rows.');
        }

        $columnMap = $this->mapHeaders($rows[0]);
        if (!isset($columnMap['item_name']) && !isset($columnMap['asset_code'])) {
            throw new RuntimeException('Unrecognized file layout — could not find an "Asset Code" or "Item Name" column in the header row.');
        }

        $batchId = $this->createBatch($fileName, $filePath);

        $this->loadLookupCaches();
        $this->loadExistingIndexes();

        $dataRows = array_slice($rows, 1, null, true);
        $totalRows = 0;

        foreach (array_chunk($dataRows, self::CHUNK_SIZE, true) as $chunk) {
            $this->pdo->beginTransaction();
            try {
                foreach ($chunk as $idx => $cells) {
                    $rowNum = $idx + 1; // 1-based row number as seen in the spreadsheet
                    $record = $this->extractRecord($cells, $columnMap);
                    if ($record === null) {
                        continue; // fully blank row
                    }
                    $totalRows++;

                    try {
                        $this->processRow($rowNum, $record);
                    } catch (RowSkippedException $e) {
                        $this->skipped++;
                    } catch (Exception $e) {
                        $this->addError($rowNum, $record['asset_code'] ?? null, $e instanceof RowValidationException ? $e->field : null, $e->getMessage());
                    }
                }
                $this->pdo->commit();
            } catch (Exception $e) {
                if ($this->pdo->inTransaction()) $this->pdo->rollBack();
                throw $e;
            }
        }

        $this->finalizeBatch($batchId, $totalRows);

        $validationErrors = count(array_filter($this->errors, static function ($e) { return empty($e['is_skip']); }));

        return [
            'batch_id'   => $batchId,
            'total_rows' => $totalRows,
            'created'    => $this->created,
            'updated'    => $this->updated,
            'skipped'    => $this->skipped,
            'errors'     => $validationErrors,
            'error_rows' => $this->errors,
        ];
    }

    /* ═══════════════════ Header / record extraction ═══════════════════ */

    /** @return array<string,int> canonical field key → column index */
    private function mapHeaders(array $headerRow): array
    {
        $map = [];
        foreach ($headerRow as $i => $label) {
            $key = self::HEADER_MAP[self::normalizeHeader((string)$label)] ?? null;
            if ($key !== null && !isset($map[$key])) {
                $map[$key] = $i;
            }
        }
        return $map;
    }

    private static function normalizeHeader(string $label): string
    {
        return preg_replace('/[^a-z0-9]/', '', strtolower(trim($label)));
    }

    /** @return array<string,string>|null trimmed field values, or null for a blank row */
    private function extractRecord(array $cells, array $columnMap): ?array
    {
        $record = [];
        $hasData = false;
        foreach ($columnMap as $field => $col) {
            $value = trim((string)($cells[$col] ?? ''));
            $record[$field] = $value;
            if ($value !== '') $hasData = true;
        }
        return $hasData ? $record : null;
    }

    /* ═══════════════════ Row processing ═══════════════════ */

    private function processRow(int $rowNum, array $record): void
    {
        /* ── Validation: required fields ── */
        foreach (['item_name' => 'Item Name', 'category' => 'Category', 'asset_type' => 'Type', 'status' => 'Status'] as $field => $label) {
            if (($record[$field] ?? '') === '') {
                throw new RowValidationException($field, "$label is required.");
            }
        }

        /* ── Parse dates ── */
        $dates = [];
        foreach (self::DATE_FIELDS as $field) {
            $raw = $record[$field] ?? '';
            if ($raw === '') { $dates[$field] = null; continue; }
            $parsed = $this->parseDate($raw);
            if ($parsed === null) {
                throw new RowValidationException($field, "Invalid date value '$raw'.");
            }
            $dates[$field] = $parsed;
        }

        /* ── Parse numerics ── */
        $numbers = [];
        foreach (self::NUMERIC_FIELDS as $field) {
            $raw = $record[$field] ?? '';
            if ($raw === '') { $numbers[$field] = null; continue; }
            $parsed = $this->parseNumber($raw);
            if ($parsed === null) {
                throw new RowValidationException($field, "Invalid numeric value '$raw'.");
            }
            $numbers[$field] = $parsed;
        }

        if (!$this->options['allow_negative']) {
            foreach (self::MONETARY_FIELDS as $field) {
                if ($numbers[$field] !== null && $numbers[$field] < 0) {
                    throw new RowValidationException($field, 'Negative monetary values are not permitted.');
                }
            }
        }

        $disposed = $this->parseBool($record['disposed'] ?? '');
        if ($numbers['disposal_amount'] !== null && $numbers['disposal_amount'] != 0 && !$disposed) {
            throw new RowValidationException('disposal_amount', 'Disposal Amount is only allowed when Disposed = Yes.');
        }
        if ($dates['warranty_expiration'] !== null && $dates['acquired_date'] !== null
            && $dates['warranty_expiration'] < $dates['acquired_date']) {
            throw new RowValidationException('warranty_expiration', 'Warranty Expiration must be after the Acquired Date.');
        }

        /* ── Resolve lookups ── */
        $categoryId  = $this->resolveCategory($record['category']);
        $assetTypeId = $this->resolveAssetType($record['asset_type'], $record['category']);
        $branchId    = ($record['department'] ?? '') !== '' ? $this->resolveBranch($record['department']) : null;
        $custodianId = ($record['custodian'] ?? '') !== '' ? $this->resolveCustodian($record['custodian']) : null;

        /* ── Duplicate detection ── */
        $assetCode = $record['asset_code'] ?? '';
        $existingItemId = $this->findExisting($record);

        if ($existingItemId !== null && !$this->options['update_existing']) {
            $this->addError($rowNum, $assetCode ?: null, null,
                'Duplicate: asset already exists (skipped — enable "Update existing records" to update).', true);
            throw new RowSkippedException();
        }

        /* ── Write phase: roll back only this row on failure ── */
        $this->pdo->exec('SAVEPOINT row_sp');
        try {
            if ($existingItemId !== null) {
                $this->updateAsset($existingItemId, $record, $dates, $numbers, $disposed,
                                   $categoryId, $assetTypeId, $branchId, $custodianId);
                $this->pdo->exec('RELEASE SAVEPOINT row_sp');
                $this->updated++;
            } else {
                $itemId = $this->createAsset($record, $dates, $numbers, $disposed,
                                             $categoryId, $assetTypeId, $branchId, $custodianId);
                $this->pdo->exec('RELEASE SAVEPOINT row_sp');
                $this->indexNewRecord($itemId, $record, $dates);
                $this->created++;
            }
        } catch (Exception $e) {
            $this->pdo->exec('ROLLBACK TO SAVEPOINT row_sp');
            throw $e;
        }
    }

    /** @return int|null item_id of an existing matching asset */
    private function findExisting(array $record): ?int
    {
        $code = self::norm($record['asset_code'] ?? '');
        if ($code !== '') {
            return $this->byAssetCode[$code] ?? null;
        }
        $serial = self::norm($record['serial_number'] ?? '');
        if ($serial !== '' && isset($this->bySerial[$serial])) {
            return $this->bySerial[$serial];
        }
        $ref = self::norm($record['reference_number'] ?? '');
        if ($ref !== '' && isset($this->byReference[$ref])) {
            return $this->byReference[$ref];
        }
        $composite = $this->compositeKey($record['item_name'] ?? '', $record['make'] ?? '', $this->parseDate($record['acquired_date'] ?? ''));
        if ($composite !== null && isset($this->byComposite[$composite])) {
            return $this->byComposite[$composite];
        }
        return null;
    }

    private function compositeKey(string $name, string $make, ?string $acquiredDate): ?string
    {
        if (self::norm($name) === '') return null;
        return self::norm($name) . '|' . self::norm($make) . '|' . ($acquiredDate ?? '');
    }

    private function indexNewRecord(int $itemId, array $record, array $dates): void
    {
        $code = self::norm($record['asset_code'] ?? '');
        if ($code !== '') $this->byAssetCode[$code] = $itemId;
        $serial = self::norm($record['serial_number'] ?? '');
        if ($serial !== '' && !isset($this->bySerial[$serial])) $this->bySerial[$serial] = $itemId;
        $ref = self::norm($record['reference_number'] ?? '');
        if ($ref !== '' && !isset($this->byReference[$ref])) $this->byReference[$ref] = $itemId;
        $composite = $this->compositeKey($record['item_name'] ?? '', $record['make'] ?? '', $dates['acquired_date'] ?? null);
        if ($composite !== null && !isset($this->byComposite[$composite])) $this->byComposite[$composite] = $itemId;
    }

    /* ═══════════════════ Create / update ═══════════════════ */

    private function createAsset(array $record, array $dates, array $numbers, bool $disposed,
                                 int $categoryId, int $assetTypeId, ?int $branchId, ?int $custodianId): int
    {
        $assetCode = trim($record['asset_code'] ?? '');
        $itemCode = $assetCode !== '' ? mb_substr($assetCode, 0, 50) : generateItemCode($this->pdo);

        $stmt = $this->pdo->prepare("
            INSERT INTO inv_items (
                item_code, item_name, description, category_id, uom_id,
                manufacturer, model, serial_number_flag,
                item_status, item_domain, asset_type_id, created_by
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'ASSET', ?, ?)
        ");
        $stmt->execute([
            $itemCode,
            mb_substr($record['item_name'], 0, 200),
            ($record['description'] ?? '') !== '' ? $record['description'] : null,
            $categoryId,
            $this->defaultUomId,
            ($record['make'] ?? '') !== '' ? mb_substr($record['make'], 0, 150) : null,
            null,
            ($record['serial_number'] ?? '') !== '' ? 1 : 0,
            $disposed ? 'DISPOSAL' : 'ACTIVE',
            $assetTypeId,
            $this->userId,
        ]);
        $itemId = (int)$this->pdo->lastInsertId();

        $this->insertAssetDetails($itemId, $record, $dates, $numbers, $disposed, $branchId, $custodianId);
        $this->upsertSerialRecord($itemId, $record, $dates, $disposed, $branchId, $custodianId);

        return $itemId;
    }

    private function updateAsset(int $itemId, array $record, array $dates, array $numbers, bool $disposed,
                                 int $categoryId, int $assetTypeId, ?int $branchId, ?int $custodianId): void
    {
        $stmt = $this->pdo->prepare("
            UPDATE inv_items SET
                item_name = ?, description = COALESCE(NULLIF(?, ''), description),
                category_id = ?, manufacturer = COALESCE(NULLIF(?, ''), manufacturer),
                serial_number_flag = GREATEST(serial_number_flag, ?),
                item_status = ?, item_domain = 'ASSET', asset_type_id = ?, updated_by = ?
            WHERE item_id = ?
        ");
        $stmt->execute([
            mb_substr($record['item_name'], 0, 200),
            $record['description'] ?? '',
            $categoryId,
            mb_substr($record['make'] ?? '', 0, 150),
            ($record['serial_number'] ?? '') !== '' ? 1 : 0,
            $disposed ? 'DISPOSAL' : 'ACTIVE',
            $assetTypeId,
            $this->userId,
            $itemId,
        ]);

        $this->pdo->prepare("DELETE FROM inv_asset_details WHERE item_id = ?")->execute([$itemId]);
        $this->insertAssetDetails($itemId, $record, $dates, $numbers, $disposed, $branchId, $custodianId);
        $this->upsertSerialRecord($itemId, $record, $dates, $disposed, $branchId, $custodianId);
    }

    private function insertAssetDetails(int $itemId, array $record, array $dates, array $numbers,
                                        bool $disposed, ?int $branchId, ?int $custodianId): void
    {
        $stmt = $this->pdo->prepare("
            INSERT INTO inv_asset_details (
                item_id, asset_code, reference_number, make, serial_number,
                acquired_date, department_branch_id, custodian_user_id, custodian_name,
                asset_status, asset_condition,
                bos_value, increase_value, balance_value, decrease_value,
                delivery_date, placed_in_service_date, warranty_expiration,
                title_deed_number, address,
                revalued_cost, revalued_date, accumulated_depreciation,
                depreciation_charge, carrying_value, depreciation_method_rate,
                impairment, budget_code, acquisition_method,
                insured_value, forced_sale_value,
                disposal_date, disposal_amount, disposal_authorization, is_disposed,
                attachments_note, comments
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ");
        $stmt->execute([
            $itemId,
            ($record['asset_code'] ?? '') !== '' ? mb_substr($record['asset_code'], 0, 50) : null,
            ($record['reference_number'] ?? '') !== '' ? mb_substr($record['reference_number'], 0, 100) : null,
            ($record['make'] ?? '') !== '' ? mb_substr($record['make'], 0, 150) : null,
            ($record['serial_number'] ?? '') !== '' ? mb_substr($record['serial_number'], 0, 100) : null,
            $dates['acquired_date'],
            $branchId,
            $custodianId,
            ($record['custodian'] ?? '') !== '' ? mb_substr($record['custodian'], 0, 150) : null,
            ($record['status'] ?? '') !== '' ? mb_substr($record['status'], 0, 100) : null,
            ($record['condition'] ?? '') !== '' ? mb_substr($record['condition'], 0, 100) : null,
            $numbers['bos_value'], $numbers['increase_value'], $numbers['balance_value'], $numbers['decrease_value'],
            $dates['delivery_date'], $dates['placed_in_service_date'], $dates['warranty_expiration'],
            ($record['title_deed_number'] ?? '') !== '' ? mb_substr($record['title_deed_number'], 0, 100) : null,
            ($record['address'] ?? '') !== '' ? mb_substr($record['address'], 0, 255) : null,
            $numbers['revalued_cost'], $dates['revalued_date'], $numbers['accumulated_depreciation'],
            $numbers['depreciation_charge'], $numbers['carrying_value'],
            ($record['depreciation_method_rate'] ?? '') !== '' ? mb_substr($record['depreciation_method_rate'], 0, 150) : null,
            $numbers['impairment'],
            ($record['budget_code'] ?? '') !== '' ? mb_substr($record['budget_code'], 0, 50) : null,
            ($record['acquisition_method'] ?? '') !== '' ? mb_substr($record['acquisition_method'], 0, 30) : null,
            $numbers['insured_value'], $numbers['forced_sale_value'],
            $dates['disposal_date'], $numbers['disposal_amount'],
            ($record['disposal_authorization'] ?? '') !== '' ? mb_substr($record['disposal_authorization'], 0, 150) : null,
            $disposed ? 1 : 0,
            ($record['attachments_note'] ?? '') !== '' ? $record['attachments_note'] : null,
            ($record['comments'] ?? '') !== '' ? $record['comments'] : null,
        ]);
    }

    /**
     * Maintain the asset lifecycle/assignment history record in
     * inv_serial_numbers when a serial number is present.
     */
    private function upsertSerialRecord(int $itemId, array $record, array $dates,
                                        bool $disposed, ?int $branchId, ?int $custodianId): void
    {
        $serial = trim($record['serial_number'] ?? '');
        if ($serial === '') return;
        $serial = mb_substr($serial, 0, 100);

        $lifecycle = $disposed ? 'DISPOSED' : (($custodianId || $branchId) ? 'ASSIGNED' : 'RECEIVED');

        $stmt = $this->pdo->prepare("SELECT serial_id FROM inv_serial_numbers WHERE item_id = ? AND serial_number = ?");
        $stmt->execute([$itemId, $serial]);
        $serialId = $stmt->fetchColumn();

        if ($serialId) {
            $upd = $this->pdo->prepare("
                UPDATE inv_serial_numbers SET
                    dgc_asset_number = COALESCE(NULLIF(?, ''), dgc_asset_number),
                    issued_to_user_id = ?, issued_to_department = ?,
                    lifecycle_status = ?, current_condition = COALESCE(NULLIF(?, ''), current_condition),
                    warranty_expiry_date = ?, disposal_date = ?, updated_by = ?
                WHERE serial_id = ?
            ");
            $upd->execute([
                mb_substr($record['asset_code'] ?? '', 0, 50),
                $custodianId, $branchId, $lifecycle,
                mb_substr($record['condition'] ?? '', 0, 50),
                $dates['warranty_expiration'], $dates['disposal_date'],
                $this->userId, $serialId,
            ]);
        } else {
            $ins = $this->pdo->prepare("
                INSERT INTO inv_serial_numbers (
                    item_id, serial_number, dgc_asset_number,
                    issued_to_user_id, issued_to_department,
                    lifecycle_status, condition_on_receipt, current_condition,
                    warranty_expiry_date, disposal_date, notes, created_by
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ");
            $ins->execute([
                $itemId, $serial,
                ($record['asset_code'] ?? '') !== '' ? mb_substr($record['asset_code'], 0, 50) : null,
                $custodianId, $branchId, $lifecycle,
                ($record['condition'] ?? '') !== '' ? mb_substr($record['condition'], 0, 50) : null,
                ($record['condition'] ?? '') !== '' ? mb_substr($record['condition'], 0, 50) : null,
                $dates['warranty_expiration'], $dates['disposal_date'],
                'Imported from asset register spreadsheet',
                $this->userId,
            ]);
        }
    }

    /* ═══════════════════ Lookup resolution (exact → ci → trimmed) ═══════════════════ */

    private function resolveCategory(string $name): int
    {
        $key = self::norm($name);
        if (isset($this->categoryCache[$key])) return $this->categoryCache[$key];

        if (!$this->options['auto_create_lookups']) {
            throw new RowValidationException('category', "Category '$name' does not exist.");
        }
        $code = $this->makeCode($name, 20);
        $stmt = $this->pdo->prepare("INSERT INTO inv_categories (category_name, category_code, description, is_active) VALUES (?, ?, 'Auto-created during asset import', 1)");
        $stmt->execute([mb_substr(trim($name), 0, 100), $code]);
        $id = (int)$this->pdo->lastInsertId();
        $this->categoryCache[$key] = $id;
        return $id;
    }

    private function resolveAssetType(string $name, string $categoryName): int
    {
        $key = self::norm($name);
        if (isset($this->assetTypeCache[$key])) return $this->assetTypeCache[$key];

        if (!$this->options['auto_create_lookups']) {
            throw new RowValidationException('asset_type', "Asset type '$name' does not exist.");
        }
        // Create the asset type so items keep their correct classification
        $code = $this->makeCode($name, 30);
        $stmt = $this->pdo->prepare("INSERT INTO asset_types (type_code, type_name, description, is_active) VALUES (?, ?, ?, 1)");
        $stmt->execute([$code, mb_substr(trim($name), 0, 100), 'Auto-created during asset import (category: ' . trim($categoryName) . ')']);
        $id = (int)$this->pdo->lastInsertId();
        $this->assetTypeCache[$key] = $id;
        return $id;
    }

    private function resolveBranch(string $name): int
    {
        $key = self::norm($name);
        if (isset($this->branchCache[$key])) return $this->branchCache[$key];

        if (!$this->options['auto_create_lookups']) {
            throw new RowValidationException('department', "Department '$name' does not exist.");
        }
        $stmt = $this->pdo->prepare("INSERT INTO branches (branch_name, is_active) VALUES (?, 1)");
        $stmt->execute([mb_substr(trim($name), 0, 100)]);
        $id = (int)$this->pdo->lastInsertId();
        $this->branchCache[$key] = $id;
        return $id;
    }

    /** Custodians must match existing users — never auto-created. */
    private function resolveCustodian(string $name): ?int
    {
        return $this->userCache[self::norm($name)] ?? null;
    }

    private function makeCode(string $name, int $maxLen): string
    {
        $base = strtoupper(preg_replace('/[^A-Za-z0-9]+/', '_', trim($name)));
        $base = trim(mb_substr($base, 0, $maxLen - 3), '_');
        if ($base === '') $base = 'IMP';
        $code = mb_substr($base, 0, $maxLen);
        $suffix = 1;
        $existing = array_merge(
            $this->columnValues("SELECT category_code FROM inv_categories"),
            $this->columnValues("SELECT type_code FROM asset_types")
        );
        $existingSet = array_flip(array_map('strtoupper', $existing));
        while (isset($existingSet[$code])) {
            $code = mb_substr($base, 0, $maxLen - strlen((string)$suffix) - 1) . '_' . $suffix;
            $suffix++;
        }
        return $code;
    }

    private function columnValues(string $sql): array
    {
        try {
            return $this->pdo->query($sql)->fetchAll(PDO::FETCH_COLUMN) ?: [];
        } catch (PDOException $e) {
            return [];
        }
    }

    /* ═══════════════════ Cache priming ═══════════════════ */

    private function loadLookupCaches(): void
    {
        foreach ($this->pdo->query("SELECT category_id, category_name, category_code FROM inv_categories") as $r) {
            $this->categoryCache[self::norm($r['category_name'])] = (int)$r['category_id'];
            $this->categoryCache[self::norm($r['category_code'])] = (int)$r['category_id'];
        }
        foreach ($this->pdo->query("SELECT asset_type_id, type_name, type_code FROM asset_types") as $r) {
            $this->assetTypeCache[self::norm($r['type_name'])] = (int)$r['asset_type_id'];
            $this->assetTypeCache[self::norm($r['type_code'])] = (int)$r['asset_type_id'];
            // Allow singular/plural leniency, e.g. "Vehicle" → "Vehicles"
            $singular = rtrim(self::norm($r['type_name']), 's');
            if ($singular !== '' && !isset($this->assetTypeCache[$singular])) {
                $this->assetTypeCache[$singular] = (int)$r['asset_type_id'];
            }
        }
        foreach ($this->pdo->query("SELECT branch_id, branch_name FROM branches") as $r) {
            $this->branchCache[self::norm($r['branch_name'])] = (int)$r['branch_id'];
        }
        foreach ($this->pdo->query("SELECT user_id, full_name, email FROM users") as $r) {
            $this->userCache[self::norm($r['full_name'])] = (int)$r['user_id'];
            if (!empty($r['email'])) $this->userCache[self::norm($r['email'])] = (int)$r['user_id'];
        }
        $this->defaultUomId = $this->pdo->query("SELECT uom_id FROM inv_units_of_measure WHERE uom_code = 'EA'")->fetchColumn();
        if (!$this->defaultUomId) {
            $this->defaultUomId = $this->pdo->query("SELECT uom_id FROM inv_units_of_measure ORDER BY uom_id LIMIT 1")->fetchColumn();
        }
        if (!$this->defaultUomId) {
            $this->pdo->exec("INSERT INTO inv_units_of_measure (uom_code, uom_name) VALUES ('EA', 'Each')");
            $this->defaultUomId = (int)$this->pdo->lastInsertId();
        }
        $this->defaultUomId = (int)$this->defaultUomId;
    }

    private function loadExistingIndexes(): void
    {
        // Asset codes: both explicit asset register codes and item codes
        foreach ($this->pdo->query("SELECT item_id, item_code FROM inv_items") as $r) {
            $this->byAssetCode[self::norm($r['item_code'])] = (int)$r['item_id'];
        }
        foreach ($this->pdo->query("SELECT item_id, asset_code, serial_number, reference_number FROM inv_asset_details") as $r) {
            if (!empty($r['asset_code']))       $this->byAssetCode[self::norm($r['asset_code'])] = (int)$r['item_id'];
            if (!empty($r['serial_number']))    $this->bySerial[self::norm($r['serial_number'])] = (int)$r['item_id'];
            if (!empty($r['reference_number'])) $this->byReference[self::norm($r['reference_number'])] = (int)$r['item_id'];
        }
        foreach ($this->pdo->query("SELECT item_id, serial_number FROM inv_serial_numbers") as $r) {
            $key = self::norm($r['serial_number']);
            if ($key !== '' && !isset($this->bySerial[$key])) $this->bySerial[$key] = (int)$r['item_id'];
        }
        foreach ($this->pdo->query("
                SELECT i.item_id, i.item_name, d.make, d.acquired_date
                FROM inv_items i JOIN inv_asset_details d ON d.item_id = i.item_id
            ") as $r) {
            $key = self::norm($r['item_name']) . '|' . self::norm($r['make'] ?? '') . '|' . ($r['acquired_date'] ?? '');
            if (!isset($this->byComposite[$key])) $this->byComposite[$key] = (int)$r['item_id'];
        }
    }

    /* ═══════════════════ Batch / errors ═══════════════════ */

    private function createBatch(string $fileName, string $filePath): int
    {
        $stmt = $this->pdo->prepare("
            INSERT INTO inv_import_batches (source_file_name, file_hash, imported_by, update_existing, auto_create_lookups)
            VALUES (?, ?, ?, ?, ?)
        ");
        $stmt->execute([
            mb_substr($fileName, 0, 255),
            is_readable($filePath) ? hash_file('sha256', $filePath) : null,
            $this->userId,
            $this->options['update_existing'] ? 1 : 0,
            $this->options['auto_create_lookups'] ? 1 : 0,
        ]);
        return (int)$this->pdo->lastInsertId();
    }

    private function finalizeBatch(int $batchId, int $totalRows): void
    {
        if (!empty($this->errors)) {
            $ins = $this->pdo->prepare("INSERT INTO inv_import_errors (batch_id, `row_number`, asset_code, field, message) VALUES (?, ?, ?, ?, ?)");
            $this->pdo->beginTransaction();
            foreach ($this->errors as $e) {
                $ins->execute([$batchId, $e['row'], $e['asset_code'], $e['field'], mb_substr($e['message'], 0, 500)]);
            }
            $this->pdo->commit();
        }

        $stmt = $this->pdo->prepare("
            UPDATE inv_import_batches
            SET total_rows = ?, created_count = ?, updated_count = ?, skipped_count = ?, error_count = ?,
                status = 'COMPLETED', completed_at = NOW()
            WHERE batch_id = ?
        ");
        $stmt->execute([
            $totalRows, $this->created, $this->updated, $this->skipped,
            count(array_filter($this->errors, static function ($e) { return empty($e['is_skip']); })),
            $batchId,
        ]);
    }

    private function addError(int $row, ?string $assetCode, ?string $field, string $message, bool $isSkip = false): void
    {
        $this->errors[] = [
            'row'        => $row,
            'asset_code' => $assetCode !== null && $assetCode !== '' ? $assetCode : null,
            'field'      => $field,
            'message'    => $message,
            'is_skip'    => $isSkip,
        ];
    }

    /* ═══════════════════ Value parsing helpers ═══════════════════ */

    /** Parse a spreadsheet date value into Y-m-d, or null when unparseable. */
    public function parseDate(string $value): ?string
    {
        $value = trim($value);
        if ($value === '' || strcasecmp($value, 'n/a') === 0) return null;

        // Excel serial date (raw numeric cell value from .xlsx)
        if (is_numeric($value)) {
            $serial = (float)$value;
            if ($serial >= 1 && $serial < 300000) {
                // Excel epoch 1899-12-30 (accounts for the 1900 leap-year bug)
                $ts = (int)round(($serial - 25569) * 86400);
                return gmdate('Y-m-d', $ts);
            }
            return null;
        }

        // ISO yyyy-mm-dd (optionally with time)
        if (preg_match('/^(\d{4})-(\d{1,2})-(\d{1,2})/', $value, $m)) {
            return checkdate((int)$m[2], (int)$m[3], (int)$m[1])
                ? sprintf('%04d-%02d-%02d', $m[1], $m[2], $m[3]) : null;
        }

        // dd/mm/yyyy or mm/dd/yyyy (also with - or . separators)
        if (preg_match('#^(\d{1,2})[/\-.](\d{1,2})[/\-.](\d{2,4})$#', $value, $m)) {
            $a = (int)$m[1]; $b = (int)$m[2]; $y = (int)$m[3];
            if ($y < 100) $y += ($y < 50 ? 2000 : 1900);

            if ($a > 12 && $b <= 12)      { $d = $a; $mo = $b; } // must be dd/mm
            elseif ($b > 12 && $a <= 12)  { $d = $b; $mo = $a; } // must be mm/dd
            elseif ($this->options['date_format'] === 'mdy') { $mo = $a; $d = $b; }
            else                          { $d = $a; $mo = $b; }

            return checkdate($mo, $d, $y) ? sprintf('%04d-%02d-%02d', $y, $mo, $d) : null;
        }

        // Textual formats, e.g. "15 Jan 2024", "Jan 15, 2024", "15-Jan-24"
        $ts = strtotime($value);
        return $ts !== false ? date('Y-m-d', $ts) : null;
    }

    /** Parse a monetary/numeric value; handles $, commas, parentheses. Null when invalid. */
    public function parseNumber(string $value): ?float
    {
        $value = trim($value);
        if ($value === '' || strcasecmp($value, 'n/a') === 0 || $value === '-') return null;

        $negative = false;
        if (preg_match('/^\((.*)\)$/', $value, $m)) { // (1,234.56) accounting negative
            $negative = true;
            $value = $m[1];
        }
        // Strip currency symbols, letters (e.g. "JMD"), commas and spaces
        $clean = preg_replace('/[^0-9.\-]/', '', str_replace(',', '', $value));
        if ($clean === '' || !is_numeric($clean)) return null;

        $number = (float)$clean;
        return $negative ? -abs($number) : $number;
    }

    private function parseBool(string $value): bool
    {
        return in_array(strtolower(trim($value)), ['yes', 'y', 'true', '1', 'disposed'], true);
    }

    private static function norm($value): string
    {
        return strtolower(trim((string)$value));
    }
}

/** Row failed validation; carries the offending field name. */
class RowValidationException extends Exception
{
    /** @var string|null */
    public $field;

    public function __construct(?string $field, string $message)
    {
        parent::__construct($message);
        $this->field = $field;
    }
}

/** Row intentionally skipped (duplicate with updates disabled). */
class RowSkippedException extends Exception
{
}
