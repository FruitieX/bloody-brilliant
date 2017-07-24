#!/bin/bash

rm -rf dist

mkdir -p dist/temp
cp mintemplate.html dist/temp/temp1.html
cd dist

echo ".js source filesizes (minified):"
echo "--------------------------------"
for file in $(ls ../src/*.js); do
  echo "$(basename $file): $(../node_modules/.bin/uglifyjs --ecma 6 ../src/$file | wc -c)b"
done

echo -e "\n.glsl source filesizes (minified):"
echo "----------------------------------"
for file in $(ls ../src/*.glsl); do
  echo "$(basename $file): $(../node_modules/.bin/glslmin -m ../src/$file | wc -c)b"
done

# concat all js together
cat ../src/song.js ../src/index.js > temp/temp1.js

# vertex shader
echo "minifying vertex shader..."
../node_modules/.bin/glslmin ../src/vertex.glsl | node ../utils/findandreplace.js --template temp/temp1.js --find 'require("./vertex.glsl")' --surround '"' > temp/temp2.js

# fragment shader
echo "minifying fragment shader..."
../node_modules/.bin/glslmin -m ../src/fragment.glsl | node ../utils/findandreplace.js --template temp/temp2.js --find 'require("./fragment.glsl")' --surround '"' > temp/temp3.js

echo "uglifying..."

../node_modules/.bin/uglifyjs -V

# sequences=false is needed because otherwise uglifyjs might wrap
# g = c.getContext`webgl` in an if statement, which results in broken
# code after regpack does method hashing on the webgl context
../node_modules/.bin/uglifyjs --ecma 6 temp/temp3.js -c sequences=false -m \
> temp/temp4.js

# TODO: uglify-es doesn't understand object spread notation yet, so we do this awesome thing
# ahem, neither do browsers?
#  -e 's/Object.assign({o,e,l},a)/{...a,o,e,l}/g' \
echo "find and replace..."
sed \
  -e '' \
  temp/temp4.js > temp/temp5.js

echo "saving non-regpacked result in index_unpacked.html..."
cat temp/temp5.js | node ../utils/findandreplace.js --template temp/temp1.html --find '{{javascript}}' > index_unpacked.html

echo "wrote index_unpacked.html ($(cat index_unpacked.html | wc -c)b, $(($(cat index_unpacked.html | wc -c)-4096))b over budget)"

echo "running regpack..."
node ../node_modules/.bin/regpack temp/temp5.js \
  --useES6 \
  --hashWebGLContext \
  --hashAudioContext \
  --reassignVars \
  --varsNotReassigned [] \
  --crushTiebreakerFactor 1 \
  --crushGainFactor 1 \
  --crushLengthFactor 0 \
  --crushCopiesFactor 0 \
> temp/temp6.js

echo "injecting regpacked js into html template..."
cat temp/temp6.js | node ../utils/findandreplace.js --template temp/temp1.html --find '{{javascript}}' > index.html

echo "wrote index.html ($(cat index.html | wc -c)b, $(($(cat index.html | wc -c)-4096))b over budget)"
