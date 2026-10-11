$emacsDir = "$env:APPDATA\.emacs.d"

if (Test-Path -Path $emacsDir) { Remove-Item -Recurse -Force $emacsDir }

New-Item -ItemType Directory $emacsDir

New-Item -ItemType SymbolicLink -Path "$emacsDir\early-init.el" -Target "$(Get-Location)\early-init.el"
New-Item -ItemType SymbolicLink -Path "$emacsDir\init.el" -Target "$(Get-Location)\init.el"
New-Item -ItemType SymbolicLink -Path "$emacsDir\load-env-vars" -Target "$(Get-Location)\load-env-vars"

.\get-grammars.ps1

emacs.exe --no-init-file --load .\gen-env-file.el
