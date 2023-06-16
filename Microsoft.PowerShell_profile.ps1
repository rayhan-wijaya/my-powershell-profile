# Core Functions

function shouldIgnoreLine ($line) {
  return $trimmedLine.startsWith(";") -or $trimmedLine -eq "";
}

# Profile Configs

function parseConfigs ($path) {
  if (-not(test-path $path)) {
    return;
  }

  $configs = @{};
  $content = get-content $path;

  foreach ($line in $content) {
    $trimmedLine = $line.trim();

    if (shouldIgnoreLine($trimmedLine)) {
      continue;
    }

    $config, $configValue = $trimmedLine -split ":=";
    $configs[$config.toUpper()] = $configValue.toUpper()
  }

  return $configs;
}

$configsPath = "$HOME/profile-configs.txt";
$configs = parseConfigs($configsPath);

# Paths

function parsePaths ($path) {
  if (-not(test-path $path)) {
    return;
  }

  $paths = [System.Collections.ArrayList]@();
  $content = get-content $path;

  foreach ($line in $content) {
    $trimmedLine = $line.trim();

    if (shouldIgnoreLine($trimmedLine)) {
      continue;
    }

    $paths.add($trimmedLine);
  }

  return $paths;
}

$pathsPath = "$HOME/paths.txt";
$paths = parsePaths($pathsPath);

foreach ($path in $paths) {
  $env:path = "$env:path;$path";
}

# Functions

function editor ($path) {
  if ($configs.USENVIM -eq "TRUE") {
    nvim $path;
    return;
  }

  vim $path;
}

function v ($path, $shouldChangeWorkingDirectory) {
  $isDirectory = $path -is [System.IO.DirectoryInfo];

  if (-not($isDirectory)) {
    editor $path;
    return;
  }

  if ($isDirectory -and $shouldChangeWorkingDirectory) {
    cd $path;
  }

  editor .;
}

function bugn () {
  if (-not($configs.BUGNDIRECTORY)) {
    $warning = @"

Please configure BUGNDIRECTORY at C:\profile-configs.txt to use this command

e.g. (at C:\profile-configs.txt)

``````
; Profile Configs
bugnDirectory:=C:\bugn
``````

"@

    echo $warning;

    return;
  }

  $oldPath = (pwd).path;

  cd "C:\bugn\src";
  autohotkey Main.ahk;

  cd $oldPath;
}
