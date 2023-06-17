# Core Functions

function shouldIgnoreLine ($line) {
  return $trimmedLine.startsWith(";") -or $trimmedLine -eq "";
}

function isDirectory ($path) {
  return (get-item $path).PSIsContainer;
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

# Bookmarks

function parseBookmarks ($path) {
  if (-not(test-path $path)) {
    return;
  }

  $bookmarks = @{};
  $content = get-content $path;

  foreach ($line in $content) {
    $trimmedLine = $line.trim();

    if (shouldIgnoreLine($trimmedLine)) {
      continue;
    }

    $bookmark, $bookmarkValue = $trimmedLine -split ":=";
    $bookmarkValue = $bookmarkValue.replace("`$HOME", $HOME); # magic

    $bookmarks[$bookmark] = $bookmarkValue;
  }

  return $bookmarks;
}

$bookmarksPath = "$HOME/bookmarks.txt";
$bookmarks = parseBookmarks($bookmarksPath);
$b = $bookmarks;

# Modules

function parseModules ($path) {
  if (-not (test-path $path)) {
    return;
  }

  $modules = [System.Collections.ArrayList]@();
  $content = get-content $path;

  foreach ($line in $content) {
    $trimmedLine = $line.trim();

    if (shouldIgnoreLine($trimmedLine)) {
      continue;
    }

    $modules.add($trimmedLine);
  }

  return $modules;
}

$modulesPath = "$HOME/modules.txt";
$modules = parseModules($modulesPath);

foreach ($module in $modules) {
  Import-Module $module;
}

# Functions

function editor ($path) {
  if ($configs.USENVIM -eq "TRUE") {
    nvim $path;
    return;
  }

  vim $path;
}

function v {
  param (
    [string]$path,
    [boolean]$shouldChangeWorkingDirectory = $true
  )

  $isDirectory = isDirectory($path);

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

Please configure BUGNDIRECTORY at `$HOME\profile-configs.txt to use this command

e.g. (at `$HOME\profile-configs.txt)

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

# Chocolatey

# Please delete the other chocolatey snippet at the bottom of the
# file if you've installed chocolatey.

$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"

if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}
