@ECHO OFF

echo | set /p dummyvar=Purging current distribution files...
rm -rf dist
mkdir dist\temp
echo. Done!

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

REM concat all js together
cat src\index.js > dist\temp\js.js
REM .\node_modules\.bin\uglifyjs --ecma 6 dist\temp\all.js > dist\temp\all.min.js

echo | set /p dummyvar=Minifying vertex shader into js...
cat dist\temp\vertex.min.glsl | node utils\findandreplace.js --template dist\temp\js.js --find require(\"./vertex.glsl\") --surround '
REM > dist\temp\js_n_vertex.js
echo. Done

echo | set /p dummyvar=Minifying fragment shader js...
REM cat dist\temp\fragment.min.glsl | node utils\findandreplace.js --template dist\temp\js_n_vertex.js --find require(\"./fragment.glsl\") --surround ' > dist\temp\js_n_glsl.js
echo. Done

echo | set /p dummyvar=Uglifying...
REM call node_modules\.bin\uglifyjs --ecma 6 dist\temp\js_n_glsl.js -c sequences=false -m > dist\temp\all_ugly.js
echo. Done

echo | set /p dummyvar=Saving non-regpacked result in index_unpacked.html...
REM cat dist\temp\all_ugly.js | node utils\findandreplace.js --template mintemplate.html --find {{javascript}} > dist\index_unpacked.html
echo. Done


REM go back to original working directory
cd %CD%
