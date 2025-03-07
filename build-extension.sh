#!/bin/bash

# Détecter le système d'exploitation
if [[ "$(uname)" == "Darwin" ]]; then
    # macOS
    if ! command -v zip &> /dev/null; then
        echo "Installing zip"
        brew install zip
    fi

    if ! command -v jq &> /dev/null; then
        echo "Installing jq"
        brew install jq
    fi
else
    # Linux (Debian/Ubuntu)
    dpkg -s zip &> /dev/null
    if [ $? -ne 0 ]; then
        echo "Installing zip"
        sudo apt install zip
    fi

    dpkg -s jq &> /dev/null
    if [ $? -ne 0 ]; then
        echo "Installing jq"
        sudo apt install jq
    fi
fi

npm install
npm update

npx rollup -c rollup.config.js

cp package.json package.copy.json
jq 'del(.dependencies."single-file-cli")' package.copy.json > package.json
zip -r singlefile-extension-source.zip manifest.json package.json _locales src rollup*.js .eslintrc.js build-extension.sh
mv package.copy.json package.json

rm singlefile-extension-firefox.zip

cp src/core/bg/config.js config.copy.js
cp src/core/bg/companion.js companion.copy.js
sed -i "" 's/forceWebAuthFlow: false/forceWebAuthFlow: true/g' src/core/bg/config.js
sed -i "" 's/enabled: true/enabled: false/g' src/core/bg/companion.js
zip -r singlefile-extension-firefox.zip manifest.json lib _locales src
mv config.copy.js src/core/bg/config.js
mv companion.copy.js src/core/bg/companion.js
