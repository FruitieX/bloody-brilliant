@ECHO OFF

SET wd=%0
echo.
echo .js source filesizes:
echo --------------------------------
for %%F in ("src\*.js") do echo %%~nxF     %%~zF b
echo.
echo .glsl source filesizes:
echo --------------------------------
for %%F in ("src\*.glsl") do echo %%~nxF     %%~zF b
echo.

REM echo Minifying js...
for %%F in ("src\*.js") do (call .\node_modules\.bin\uglifyjs --ecma 6 %%F > dist\temp\%%~nF.min%%~xF)
echo Minified .js sizes:
echo --------------------------------
for %%F in ("dist\temp\*.js") do echo %%~nxF     %%~zF b
echo.

REM echo Minifying glsl...
for %%F in ("src\*.glsl") do (call .\node_modules\.bin\glslmin -m %%F > dist\temp\%%~nF.min%%~xF)
echo Minified .glsl sizes:
echo --------------------------------
for %%F in ("dist\temp\*.glsl") do echo %%~nxF     %%~zF b
echo.

REM go back to original working directory
cd %CD%


REM js src
REM uglifyjs ..\src\song.js ..\src\player.js ..\src\index.js | node ..\utils\findandreplace.js --template temp\temp1.html --find '{{javascript}}' > temp\temp2.html
REM crunch with regpack
REM echo "uglifying..."
REM uglifyjs ..\src\song.js ..\src\player.js ..\src\index.js -c  unsafe,unsafe_comps,unused,dead_code,drop_console,unsafe_math -m toplevel,eval  > temp\temp1.js

REM vertex shader
REM echo "minifying vertex shader..."
REM glslmin ..\src\vertex.glsl | node ..\utils\findandreplace.js --template temp\temp1.js --find 'require(".\vertex.glsl")' --surround '`' > temp\temp2.js

REM REM fragment shader
REM echo "minifying fragment shader..."
REM glslmin -m ..\src\fragment.glsl | node ..\utils\findandreplace.js --template temp\temp2.js --find 'require(".\fragment.glsl")' --surround '`' > temp\temp3.js

REM echo "running regpack..."
REM node ..\node_modules\.bin\regpack temp\temp3.js | node ..\utils\findandreplace.js --template temp\temp1.html --find '{{javascript}}' > temp\temp.html

REM cp temp\temp.html index.html

REM echo "wrote index.html ($(cat index.html | wc -c) bytes)"
