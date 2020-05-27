echo "Upload Release on Github"

VERSION="$1"

mv dist/devrider.app.zip dist/devrider-macos-${VERSION}.zip
github-release upload --owner ${OWNER} --repo dev-rider-osx --tag "${VERSION}" --name "${VERSION}" --body "DevRider Release ${VERSION}" --prerelease=false dist/devrider-macos-${VERSION}.zip