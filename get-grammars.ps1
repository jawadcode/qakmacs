$latestRelease = (Invoke-WebRequest -Uri "https://api.github.com/repos/kiennq/treesit-langs/releases" | ConvertFrom-Json)[0]
$versionName = $latestRelease.name
$downloadLink = ($latestRelease.assets | where { $_.name -eq "tree-sitter-grammars.x86_64-pc-windows-msvc.v$versionName.tar.gz" }).browser_download_url

$grammarsArchive = New-TemporaryFile
Invoke-WebRequest -Uri $downloadLink -OutFile $grammarsArchive

$tsDir = "$env:APPDATA\.emacs.d\tree-sitter"
if (Test-Path -Path $tsDir) { Remove-Item -Recurse -Force $tsDir }
New-Item -ItemType Directory $tsDir
tar -xvf $grammarsArchive -C $tsDir
