<?php
/**
 * SpreadsheetReader — dependency-free reader for .xlsx and .csv files.
 *
 * Returns rows as arrays of string values. For .xlsx files, cells formatted
 * as dates keep their raw Excel serial number; date interpretation is left
 * to the consumer (see AssetImportService::parseDate()).
 */

class SpreadsheetReader
{
    /**
     * Read the first worksheet of an .xlsx or a .csv file.
     *
     * @return array<int, array<int, string>> zero-indexed rows of cell values
     * @throws RuntimeException when the file cannot be parsed
     */
    public static function read(string $filePath, string $originalName = ''): array
    {
        $name = $originalName !== '' ? $originalName : $filePath;
        $ext = strtolower(pathinfo($name, PATHINFO_EXTENSION));

        if ($ext === 'csv' || $ext === 'txt') {
            return self::readCsv($filePath);
        }
        if ($ext === 'xlsx' || $ext === 'xlsm') {
            return self::readXlsx($filePath);
        }
        // Try to sniff: xlsx files are ZIP archives ("PK")
        $fh = fopen($filePath, 'rb');
        $magic = $fh ? fread($fh, 2) : '';
        if ($fh) fclose($fh);
        if ($magic === 'PK') {
            return self::readXlsx($filePath);
        }
        if ($ext === 'xls') {
            throw new RuntimeException('Legacy .xls files are not supported. Please save the file as .xlsx or .csv and try again.');
        }
        return self::readCsv($filePath);
    }

    /** @return array<int, array<int, string>> */
    private static function readCsv(string $filePath): array
    {
        $fh = fopen($filePath, 'rb');
        if ($fh === false) {
            throw new RuntimeException('Unable to open uploaded file.');
        }
        $rows = [];
        while (($data = fgetcsv($fh, 0, ',', '"', '\\')) !== false) {
            // Strip UTF-8 BOM from the first cell of the first row
            if (empty($rows) && isset($data[0])) {
                $data[0] = preg_replace('/^\xEF\xBB\xBF/', '', (string)$data[0]);
            }
            $rows[] = array_map(static function ($v) {
                return $v === null ? '' : (string)$v;
            }, $data);
        }
        fclose($fh);
        return $rows;
    }

    /** @return array<int, array<int, string>> */
    private static function readXlsx(string $filePath): array
    {
        if (!class_exists('ZipArchive')) {
            throw new RuntimeException('PHP zip extension is required to read .xlsx files.');
        }
        $zip = new ZipArchive();
        if ($zip->open($filePath) !== true) {
            throw new RuntimeException('Unable to open .xlsx file — it may be corrupted.');
        }

        try {
            $sharedStrings = self::readSharedStrings($zip);
            $sheetPath = self::firstSheetPath($zip);
            $xml = $zip->getFromName($sheetPath);
            if ($xml === false) {
                throw new RuntimeException('Could not locate a worksheet inside the .xlsx file.');
            }
        } finally {
            $zip->close();
        }

        return self::parseSheet($xml, $sharedStrings);
    }

    /** @return string[] */
    private static function readSharedStrings(ZipArchive $zip): array
    {
        $xml = $zip->getFromName('xl/sharedStrings.xml');
        if ($xml === false) return [];

        $strings = [];
        $reader = new XMLReader();
        $reader->XML($xml);
        while ($reader->read()) {
            if ($reader->nodeType === XMLReader::ELEMENT && $reader->localName === 'si') {
                $node = $reader->expand();
                $strings[] = $node ? self::extractText($node) : '';
                $reader->next();
            }
        }
        $reader->close();
        return $strings;
    }

    /** Concatenate all t elements inside a si/is node (handles rich text runs). */
    private static function extractText(DOMNode $node): string
    {
        $text = '';
        foreach ($node->childNodes as $child) {
            if ($child->nodeType !== XML_ELEMENT_NODE) continue;
            /** @var DOMElement $child */
            if ($child->localName === 't') {
                $text .= $child->textContent;
            } elseif ($child->localName === 'r' || $child->localName === 'rPh') {
                if ($child->localName === 'r') {
                    $text .= self::extractText($child);
                }
            }
        }
        return $text;
    }

    private static function firstSheetPath(ZipArchive $zip): string
    {
        // Resolve the first sheet through the workbook relationships
        $workbook = $zip->getFromName('xl/workbook.xml');
        $rels = $zip->getFromName('xl/_rels/workbook.xml.rels');
        if ($workbook !== false && $rels !== false) {
            $wbXml = @simplexml_load_string($workbook);
            $relXml = @simplexml_load_string($rels);
            if ($wbXml !== false && $relXml !== false && isset($wbXml->sheets->sheet[0])) {
                $sheet = $wbXml->sheets->sheet[0];
                $ridAttrs = $sheet->attributes('http://schemas.openxmlformats.org/officeDocument/2006/relationships');
                $rid = $ridAttrs ? (string)$ridAttrs['id'] : '';
                foreach ($relXml->Relationship as $rel) {
                    if ((string)$rel['Id'] === $rid) {
                        $target = (string)$rel['Target'];
                        $target = ltrim($target, '/');
                        if (strpos($target, 'xl/') !== 0) $target = 'xl/' . $target;
                        return $target;
                    }
                }
            }
        }
        return 'xl/worksheets/sheet1.xml';
    }

    /** @return array<int, array<int, string>> */
    private static function parseSheet(string $xml, array $sharedStrings): array
    {
        $rows = [];
        $reader = new XMLReader();
        $reader->XML($xml);
        $maxCols = 0;

        while ($reader->read()) {
            if ($reader->nodeType !== XMLReader::ELEMENT || $reader->localName !== 'row') continue;

            $rowIndex = (int)$reader->getAttribute('r');
            if ($rowIndex <= 0) $rowIndex = count($rows) + 1;

            $node = $reader->expand();
            if (!$node) { $reader->next(); continue; }

            $cells = [];
            foreach ($node->childNodes as $cell) {
                if ($cell->nodeType !== XML_ELEMENT_NODE || $cell->localName !== 'c') continue;
                /** @var DOMElement $cell */
                $refAttr = $cell->getAttribute('r');
                $colIndex = $refAttr !== '' ? self::columnIndex($refAttr) : count($cells);
                $cells[$colIndex] = self::cellValue($cell, $sharedStrings);
                if ($colIndex + 1 > $maxCols) $maxCols = $colIndex + 1;
            }

            // Fill row gaps so files with blank rows keep correct row numbers
            while (count($rows) < $rowIndex - 1) {
                $rows[] = [];
            }
            $rows[] = $cells;
            $reader->next();
        }
        $reader->close();

        // Normalize each row to a dense zero-indexed array
        $out = [];
        foreach ($rows as $cells) {
            $row = array_fill(0, $maxCols, '');
            foreach ($cells as $i => $v) {
                if ($i < $maxCols) $row[$i] = $v;
            }
            $out[] = $row;
        }
        return $out;
    }

    private static function cellValue(DOMElement $cell, array $sharedStrings): string
    {
        $type = $cell->getAttribute('t');

        if ($type === 'inlineStr') {
            foreach ($cell->childNodes as $child) {
                if ($child->nodeType === XML_ELEMENT_NODE && $child->localName === 'is') {
                    return self::extractText($child);
                }
            }
            return '';
        }

        $value = '';
        foreach ($cell->childNodes as $child) {
            if ($child->nodeType === XML_ELEMENT_NODE && $child->localName === 'v') {
                $value = $child->textContent;
                break;
            }
        }

        if ($type === 's') {
            $idx = (int)$value;
            return $sharedStrings[$idx] ?? '';
        }
        if ($type === 'b') {
            return $value === '1' ? 'TRUE' : 'FALSE';
        }
        if ($type === 'e') {
            return '';
        }
        return $value;
    }

    /** Convert an A1-style reference ("BC12") to a zero-based column index. */
    private static function columnIndex(string $cellRef): int
    {
        $letters = preg_replace('/[^A-Z]/', '', strtoupper($cellRef));
        $index = 0;
        $len = strlen($letters);
        for ($i = 0; $i < $len; $i++) {
            $index = $index * 26 + (ord($letters[$i]) - 64);
        }
        return max(0, $index - 1);
    }
}
