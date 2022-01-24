#!/bin/sh

set -e
echo "update-ubo-patch.sh"
echo

# Download the original assets.json from GitHub
echo "-> Downloading original assets.json"
assets=$(curl https://raw.githubusercontent.com/gorhill/uBlock/master/assets/assets.json)

# Overwrite the contentURL of assets.json so that uBO will always use the LW provided version
echo "-> Overwriting assets.json update location"
assets=$(echo "$assets" | jq 'del(.["assets.json"].cdnURLs) | .["assets.json"].contentURL = "chrome://browser/content/uBOAssets.json"')

# Enable some filter lists that are disabled by default
function enable_filter_list {
  echo "-> Enabling filter list \"$1\""
  assets=$(echo "$assets" | jq ".[\"$1\"].off = false")
}
enable_filter_list "curben-phishing"
enable_filter_list "adguard-spyware-url"

# Add some custom filter lists
function add_filter_list {
  echo "-> Adding custom filter list \"$1\""
  assets=$(echo "$assets" | jq ".[\"$1\"] = $2")
}
add_filter_list "LegitimateURLShortener" '{
  "content": "filters",
  "group": "privacy",
  "title": "Actually Legitimate URL Shortener Tool",
  "contentURL": "https://raw.githubusercontent.com/DandelionSprout/adfilt/master/LegitimateURLShortener.txt",
  "supportURL": "https://github.com/DandelionSprout/adfilt/discussions/163"
}'

# Write the resulting json into line 4 of the patchfile
echo "-> Updating custom-ubo-assets.patch"
sed -i "4c+$(echo "$assets" | jq -c)" patches/custom-ubo-assets.patch

echo
echo "Done!"
