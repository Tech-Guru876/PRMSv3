<?php
require_once __DIR__ . '/env.php';

$isProd = env('APP_ENV', 'prod') === 'prod';

ini_set('display_errors',         $isProd ? '0' : '1');
ini_set('display_startup_errors', $isProd ? '0' : '1');
error_reporting($isProd ? E_ALL & ~E_NOTICE & ~E_DEPRECATED : E_ALL);

$host   = env('DB_HOST', 'localhost');
$port   = (int) env('DB_PORT', 3306);
$dbname = env('DB_NAME', 'prms_ims');
$user   = env('DB_USER', 'prms_user');
$pass   = env('DB_PASS', '');

try {
    $pdo = new PDO(
        "mysql:host=$host;port=$port;dbname=$dbname;charset=utf8mb4",
        $user,
        $pass,
        [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
    );

    // Set MySQL/MariaDB timezone to America/Jamaica (UTC-5)
    // This ensures timestamps are stored and retrieved in the correct timezone
    $pdo->exec("SET SESSION time_zone = '-05:00'");

} catch (PDOException $e) {
    if (!$isProd) {
        die("Database connection failed: " . $e->getMessage());
    }
    die("Database connection failed.");
}
