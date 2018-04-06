
flori js twim.flori
mv twim.js dist/twim.js
flori js background.flori
mv background.js dist/background.js
flori js twim_options.flori
mv twim_options.js dist/twim_options.js

cp twim_options.html dist/twim_options.html
cp manifest.json dist/manifest.json

cp images/icon-enable.png dist/icon-enable.png
cp images/icon-disable.png dist/icon-disable.png

cd dist
7z a -tzip ../twim.zip *
