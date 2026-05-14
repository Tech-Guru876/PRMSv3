<?php
require_once __DIR__ . '/env.php';

$isProd = env('APP_ENV', 'prod') === 'prod';

ini_set('display_errors',         $isProd ? '0' : '1');
ini_set('display_startup_errors', $isProd ? '0' : '1');
error_reporting($isProd ? E_ALL & ~E_NOTICE & ~E_DEPRECATED : E_ALL);

$envFile = dirname(__DIR__) . '/.env';
if (!is_file($envFile)) {
    die('Required .env file not found.');
}

$requiredDbKeys = ['DB_HOST', 'DB_PORT', 'DB_NAME', 'DB_USER', 'DB_PASS'];
$missingDbKeys = [];
foreach ($requiredDbKeys as $key) {
    $value = env($key);
    if ($value === null || trim((string) $value) === '') {
        $missingDbKeys[] = $key;
    }
}

if (!empty($missingDbKeys)) {
    $missingMsg = 'Required database configuration missing in .env: ' . implode(', ', $missingDbKeys);
    error_log($missingMsg);
    die($isProd ? 'Required database configuration missing in .env.' : $missingMsg);
}

$host   = env('DB_HOST');
$port   = (int) env('DB_PORT');
$dbname = env('DB_NAME');
$user   = env('DB_USER');
$pass   = env('DB_PASS');

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
        error_log("DB connection error: " . $e->getMessage());
    }
    die("Database connection failed.");
}
