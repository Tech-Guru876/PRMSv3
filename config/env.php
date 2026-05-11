<?php
/**
 * config/env.php
 *
 * Lightweight .env file loader.
 * Reads key=value pairs from the project root .env file and
 * populates $_ENV / getenv() so that db.php and app.php can use
 * environment variables whether running on shared hosting, a VPS,
 * or a container where variables are injected by the OS/orchestrator.
 *
 * Usage — call once at bootstrap time (already included by db.php / app.php):
 *   require_once __DIR__ . '/env.php';
 *   $host = env('DB_HOST', 'localhost');
 */

(function () {
    // Walk up the directory tree to find the .env file so that this
    // loader works regardless of document root placement.
    $root = dirname(__DIR__);
    $file = $root . '/.env';

    if (!is_file($file)) {
        return; // No .env — rely on OS-level environment variables
    }

    $lines = file($file, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);

    foreach ($lines as $line) {
        $line = trim($line);

        // Skip comments and blank lines
        if ($line === '' || $line[0] === '#') {
            continue;
        }

        // Only process valid KEY=VALUE pairs
        if (strpos($line, '=') === false) {
            continue;
        }

        [$key, $value] = explode('=', $line, 2);
        $key   = trim($key);
        $value = trim($value);

        // Strip surrounding quotes (single or double)
        if (
            strlen($value) >= 2 &&
            (
                ($value[0] === '"'  && $value[-1] === '"') ||
                ($value[0] === "'"  && $value[-1] === "'")
            )
        ) {
            $value = substr($value, 1, -1);
        }

        // Do not overwrite variables already set by the OS/container
        if (!array_key_exists($key, $_ENV) && getenv($key) === false) {
            putenv("$key=$value");
            $_ENV[$key]    = $value;
            $_SERVER[$key] = $value;
        }
    }
})();

/**
 * Retrieve an environment variable with an optional default.
 *
 * @param string $key     Variable name
 * @param mixed  $default Value returned when the variable is not set
 * @return mixed
 */
function env(string $key, mixed $default = null): mixed
{
    $val = $_ENV[$key] ?? getenv($key);
    return ($val !== false && $val !== null) ? $val : $default;
}
