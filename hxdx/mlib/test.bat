@echo off

:: Update files
copy mlib.lua "%USERPROFILE%\Documents\GitHub\telescope\"
copy spec.lua "%USERPROFILE%\Documents\GitHub\telescope\"

:: Run
cd "%USERPROFILE%\Documents\GitHub\telescope"
lua tsc -f spec.lua
pause

:: Cleanup
del mlib.lua
del spec.lua