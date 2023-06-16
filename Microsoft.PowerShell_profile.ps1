# Profile Configs

function parseConfigs ($path) {
  if (-not(test-path $path)) {
    return;
  }

  $configs = @{};
  $content = get-content $path;

  foreach ($line in $content) {
    $trimmedLine = $line.trim();

    if ($trimmedLine.startsWith(";") -or $trimmedLine -eq "") {
      continue;
    }

    $config, $configValue = $trimmedLine -split ":";
    $configs[$config.toUpper()] = $configValue.toUpper()
  }

  return $configs;
}

$configsPath = "$HOME/profile-configs.txt";
$configs = parseConfigs($configsPath);

# Paths

$paths = @(
  "C:\Program Files\Autohotkey"
);

foreach ($path in $paths) {
  $env:path = "$env:path;$path";
}

# Functions

function bugn () {
  $oldPath = (pwd).path;

  cd "C:\bugn\src";
  autohotkey Main.ahk;

  cd $oldPath;
}
