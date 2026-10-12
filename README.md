# Qakmacs

Another attempt at making emacs usable 🫩 .

# Pre-requisites

## Tools

A C compiler named `cc` is required to be available on the `$PATH` so that `treesit.el` can build its parsers,
either GCC or Clang should be fine on POSIX systems.
However, on Windows, a compiler that ignores the `-fPIC` flag is required (not Clang), for example, Mingw GCC:

```ps1
winget install --id MSYS2.MSYS2
C:\msys64\usr\bin\bash.exe -lc "pacman -Syyu --noconfirm"
# Just in-case msys2 restarts the first time and doesn't complete the upgrade
C:\msys64\usr\bin\bash.exe -lc "pacman -Syyu --noconfirm"
C:\msys64\usr\bin\bash.exe -lc "pacman -S --needed --noconfirm mingw-w64-ucrt-x86_64-gcc"
```

Alternatively (for Windows), you could bypass `M-x treesit-auto-install` entirely and just run the provided
[`.\get-parsers.ps1`](#get-parsersps1).
Similarly, on NixOS, you can include the following in your system config:

```nix
((emacsPackagesFor emacsPkgOfChoice).emacsWithPackages (epkgs: [ epkgs.treesit-grammars.with-all-grammars ]))
```

## Fonts

* Iosevka Term SS07 - Might be available in your package manager of choice, otherwise, you can find it
  [here](https://github.com/be5invis/Iosevka/releases/latest)
* IBM Plex Serif - The variable-width font (i.e., for prose)
* \[Linux only\] Symbola and Noto Color Emoji

# How to Setup

## Windows

```ps1
# Warning: Will nuke `~\AppData\Roaming\.emacs.d` if it already exists
.\emacs-windows-init.ps1
```

Then, open emacs and type `M-x treesit-auto-install` to automatically clone and compile an extensive list of tree-sitter parsers.

# Included Scripts

## `gen-env-file.ps1`

Intended to be run in your usual development shell, mostly exists due the nightmare that is the Visual Studio Dev Shell.
It firstly (if `C:\msys64` exists), updates msys2, installs `mingw-w64-ucrt-x86_64-gcc` and then temporarily appends
`C:\msys64\ucrt64\bin` to the path.
Then, using `gen-env-file.el`, it serialises the environment into an Emacs Lisp list and writes it to
`~/AppData/Roaming/.emacs.d/env.el`.
In the actual config, there is `load-env-vars/load-env-vars.el`, which reads the environment and loads it, making all of your
tools available within the editor.
These two files were taken nearly verbatim from this great article about solving a similar problem on MacOS (read it to learn more
about inspiration/decisions): https://roamingbytes.substack.com/p/emacs-on-macos-preserving-the-correct-environment-1735d2e8cb88.

## `get-parsers.ps1`

Grabs the latest `x86_64-pc-windows-msvc` parser bundle from https://github.com/kiennq/treesit-langs/releases and extracts them into
`~\AppData\Roaming\.emacs.d\tree-sitter`, `treesit.el` should then be able to read these automatically.

## `emacs-windows-init.el`

Nukes config dir, recreating it and symlinking `.el` files from the repo into it.
It then shells out to `gen-env-file.ps1`.

Wow this README needs a cleanup.
