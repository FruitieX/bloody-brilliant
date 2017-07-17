#!/bin/bash

rm -rf dist

mkdir -p dist/temp
cp mintemplate_safe.html dist/temp/temp1.html
cd dist

echo ".js source filesizes (minified):"
echo "--------------------------------"
for file in $(ls ../src/*.js); do
  echo "$(basename $file): $(../node_modules/.bin/uglifyjs ../src/$file | wc -c)b"
done

echo -e "\n.glsl source filesizes (minified):"
echo "----------------------------------"
for file in $(ls ../src/*.glsl); do
  echo "$(basename $file): $(../node_modules/.bin/glslmin -m ../src/$file | wc -c)b"
done

echo -e "\nminifying identifiers in player.js..."
sed \
  -e 's/preFilter/pF/g' \
  -e 's/osc1env/E1/g' \
  -e 's/osc2env/E2/g' \
  -e 's/osc3env/E3/g' \
  -e 's/osc1/O1/g' \
  -e 's/osc2/O2/g' \
  -e 's/osc3/O3/g' \
  -e 's/panNode/pN/g' \
  -e 's/panLFO/pL/g' \
  -e 's/panAmt/pA/g' \
  -e 's/panFreq/pF/g' \
  -e 's/dlyAmt/dA/g' \
  -e 's/delayGain/dG/g' \
  -e 's/biquadFilter/bF/g' \
  -e 's/modulationGain/mG/g' \
\
  -e 's/drive/Dr/g' \
  -e 's/osc1t/T1/g' \
  -e 's/osc2t/T2/g' \
  -e 's/osc3t/T3/g' \
  -e 's/fxFilter/FF/g' \
  -e 's/fxFreq/Ff/g' \
  -e 's/lfoAmt/LA/g' \
  -e 's/lfoFreq/LF/g' \
  -e 's/fxLFO/FL/g' \
  -e 's/o1vol/V1/g' \
  -e 's/o1xenv/X1/g' \
  -e 's/o2vol/V2/g' \
  -e 's/o2xenv/X2/g' \
  -e 's/noiseVol/N/g' \
  -e 's/attack/At/g' \
  -e 's/sustain/Su/g' \
  -e 's/release/Re/g' \
  -e 's/oscLFO/oL/g' \
\
  -e 's/createNoiseOsc/CN/g' \
  -e 's/waveforms/W/g' \
  -e 's/initCol/iC/g' \
  -e 's/initTrack/iT/g' \
  -e 's/setParams/sP/g' \
  -e 's/setNotes/sN/g' \
  -e 's/mixer/M/g' \
  -e 's/song/S/g' \
  -e 's/lfo/L/g' \
  ../src/player.js > temp/player.js

# concat all js together
cat ../src/song.js temp/player.js ../src/index.js > temp/temp1.js

# vertex shader
echo "minifying vertex shader..."
../node_modules/.bin/glslmin ../src/vertex.glsl | node ../utils/findandreplace.js --template temp/temp1.js --find 'require("./vertex.glsl")' --surround '"' > temp/temp2.js

# fragment shader
echo "minifying fragment shader..."
../node_modules/.bin/glslmin -m ../src/fragment.glsl | node ../utils/findandreplace.js --template temp/temp2.js --find 'require("./fragment.glsl")' --surround '"' > temp/temp3.js

echo "uglifying..."

../node_modules/.bin/uglifyjs -V
../node_modules/.bin/uglifyjs temp/temp3.js -c -m \
> temp/temp4.js

echo "find and replace..."
sed \
  -e 's/osc1env/E1/g' \
  temp/temp4.js > temp/temp5.js

#  -e 's/100/1e2/g' \
#  -e 's/10/1e1/g' \
#  -e 's/3200/32e2/' \
#  -e 's/1800/18e2/' \

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
  --crushLengthFactor 2 \
  --crushCopiesFactor 3 | node ../utils/findandreplace.js --template temp/temp1.html --find '{{javascript}}' > temp/temp.html

cp temp/temp.html index.html

echo "wrote index.html ($(cat index.html | wc -c)b, $(($(cat index.html | wc -c)-4096))b over budget)"
