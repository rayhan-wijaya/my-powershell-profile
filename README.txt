my-powershell-profile

This is my powershell profile.

The cool thing about it is that paths can be added to $PATH by editing
$HOME/paths.txt, which will then be loaded by this profile. Configs can also be
written at $HOME/profile-configs.txt. Examples of configurations may be
"useNvim" or "bugnDirectory". The same thing can be said with bookmarks, which
can be used using $b. e.g. $b.projects, $b.yourDirectoryHere

An example of $HOME/profile-configs.txt:

```
; My Profile Configs

useNvim:=true
bugnDirectory:=C:\bugn
```

$HOME/paths.txt:

```
; PATHS. Which will be loaded into $env:path

C:\Program Files\AutoHotkey
<Your MikTex installation path>
<Your MuPDF installation path>
<...>
```

$HOME/bookmarks.txt:

```
; My Bookmarks

projects:=<Your home directory>/projects
profileDir:=<Your home directory>/Documents/WindowsPowershell
```

Usage: $b.projects, $b.profileDir
