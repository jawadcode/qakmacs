if (Test-Path -Path "C:\msys64") {
    C:\msys64\usr\bin\bash.exe -lc "pacman -Syyu --noconfirm"
    # Just in-case msys2 restarts the first time and doesn't complete the upgrade
    C:\msys64\usr\bin\bash.exe -lc "pacman -Syyu --noconfirm"

    C:\msys64\usr\bin\bash.exe -lc "pacman -S --needed --noconfirm mingw-w64-ucrt-x86_64-gcc"

    $env:PATH += ";C:\msys64\ucrt64\bin"
}

emacs.exe --no-init-file --load .\gen-env-file.el
