#!/usr/bin/env pwsh
rbenv shell 2.
ocra .\main.rb cards.db assets\onlinePurpleSquare.jpg --gemfile .\Gemfile --chdir-first --windows --dll ruby_builtin_dlls\libssp-0.dll --dll ruby_builtin_dlls\libgmp-10.dll --dll ruby_builtin_dlls\libgcc_s_seh-1.dll --dll ruby_builtin_dlls\libwinpthread-1.dll --dll libsqlite3-0.dll --output fluxx_v0.0.1.exe
