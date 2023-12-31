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

$configsPath = "$HOME/profile/configs.txt";
$configs = parseConfigs($configsPath);

# Environment Variables

function parseEnvVars ($path) {
    if (-not(test-path $path)) {
        return;
    }

    $envVars = @{};
    $content = get-content $path;

    foreach ($line in $content) {
        $trimmedLine = $line.trim();

        if (shouldIgnoreLine($trimmedLine)) {
            continue;
        }

        $envVar, $envVarValue = $trimmedLine -split ":=";
        $envVars[$envVar] = $envVarValue;
    }

    return $envVars;
}

$envVarsPath = "$HOME/profile/env-vars.txt";
$envVars = parseEnvVars($envVarsPath);

if ($envVars.count -gt 0) {
    $envVars.GetEnumerator() | Foreach-Object {
        $path = join-path "env:" $_.name;
        set-item $path $_.value;
    }
}

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

$pathsPath = "$HOME/profile/paths.txt";
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

$bookmarksPath = "$HOME/profile/bookmarks.txt";
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

$modulesPath = "$HOME/profile/modules.txt";
$modules = parseModules($modulesPath);

foreach ($module in $modules) {
    if ($module -eq 0) {
        continue;
    }

    Import-Module ($module);
}

# Aliases;

function parseAliases ($path) {
    if (-not (test-path $path)) {
        return;
    }

    $aliases = @{};
    $content = get-content $path;

    foreach ($line in $content) {
        $trimmedLine = $line.trim();

        if (shouldIgnoreLine($trimmedLine)) {
            continue;
        }

        $alias, $aliasValue = $line -split ":=";
        $aliases[$alias] = $aliasValue;
    }

    return $aliases;
}

$aliasesPath = "$HOME/profile/aliases.txt";
$aliases = parseAliases($aliasesPath);

if ($aliases.count -gt 0) {
    $aliases.GetEnumerator() | Foreach-Object {
        Set-Alias -name $_.name -Value $_.value;
    }
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
        [string]$path = ".",
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

function runAutohotkey ($argsToPass) {
    Invoke-Expression "$($configs.AUTOHOTKEYEXE) $argsToPass";
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

    cd (Join-Path -Path $configs.BUGNDIRECTORY -ChildPath "src");
    runAutohotkey Main.ahk;

    cd $oldPath;
}

function cbc {
    rm -r -fo ~\AppData\Roaming\bug.n\data;
}

function mkcd ($directory) {
    mkdir $directory;
    cd $directory;
}

$cachedProjects = New-Object System.Collections.Generic.HashSet[System.String];

function fp {
    $directory = ls -n "~/projects" | fzf;

    if (-not($directory)) {
        return;
    }

    $cachedProjects.Add($directory) | out-null;

    cd "~/projects/$directory";
}

function fpc {
    $directory = $cachedProjects | fzf;

    if (-not($directory)) {
        return;
    }

    cd "~/projects/$directory";
}

function fpv {
    fp -v;
}

function .. {
    cd ..;
}
