<?php
$REQUIRE_PERMISSION = 'import_inventory_assets';
require_once $_SERVER['DOCUMENT_ROOT'] . '/config/page_guard.php';

header('Content-Type: text/csv; charset=utf-8');
header('Content-Disposition: attachment; filename="asset_import_template.csv"');

$headers = [
    'Asset Code', 'Item Name', 'Type', 'Make', 'Reference', 'Acquired Date',
    'Department', 'BOS', 'Increase', 'Balance', 'Decrease', 'Status',
    'Category', 'Condition', 'Description', 'Custodian', 'Delivery Date',
    'Placed-in-Service', 'Warranty Expiration', 'Title Deed Number', 'Address',
    'Serial Number', 'Revalued Cost', 'Revalued Date', 'Accumulated Depreciation',
    'Depreciation Charge', 'Carring Value', 'Method & Rate of Depreciation',
    'Impairment', 'Budget Code', 'Purchased or Donated', 'Insured Value',
    'Forced Sale Value', 'Disposal Date', 'Disposal Amount',
    'Disposal Authorization', 'Disposed', 'Attachments', 'Comments/Remarks',
];

$out = fopen('php://output', 'w');
// UTF-8 BOM so Excel opens the file correctly
fwrite($out, "\xEF\xBB\xBF");
fputcsv($out, $headers, ',', '"', '\\');
fputcsv($out, [
    'DGC-IT-0001', 'Dell Latitude 5440 Laptop', 'IT Equipment', 'Dell', 'PO-2024-015',
    '15/01/2024', 'Executive Branch', '250000.00', '', '250000.00', '', 'In Use',
    'IT Equipment', 'Good', '14-inch business laptop', 'John Brown', '20/01/2024',
    '01/02/2024', '15/01/2027', '', '', 'SN-ABC12345', '', '', '25000.00',
    '25000.00', '225000.00', 'Straight Line 10%', '', 'BUD-IT-01', 'Purchased',
    '250000.00', '', '', '', '', 'No', '', 'Example row — delete before importing',
], ',', '"', '\\');
fclose($out);
exit;
