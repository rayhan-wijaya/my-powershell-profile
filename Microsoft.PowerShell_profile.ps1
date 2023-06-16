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
