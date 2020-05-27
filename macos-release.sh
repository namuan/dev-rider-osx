echo "MacOSX Release"

OUTPUT_FOLDER="./dist"
APP_PATH=${OUTPUT_FOLDER}/${APP_NAME}
ZIPPED_APP_NAME="${APP_NAME}.zip"

# Copy App file to output folder
rm -rf ${OUTPUT_FOLDER}
mkdir -vp ${OUTPUT_FOLDER}
mv ../dev-rider/dist/${APP_NAME} ${OUTPUT_FOLDER}

# Code Sign
echo "###### ${APP_NAME} Code Signing ###############"

for filename in $(find ${APP_PATH} -name "*.dylib"); do
    codesign -v -f -i ${IDENTITY} -s "$CERT_ID" $filename
done

for filename in $(find ${APP_PATH} -name "*.so"); do
    codesign -v -f -i ${IDENTITY} -s "$CERT_ID" $filename
done

for filename in $(find ${APP_PATH}/Contents/MacOS -name "Qt*"); do
    codesign -v -f -i ${IDENTITY} -s "$CERT_ID" $filename
done

for filename in $(ls ${APP_PATH}/Contents/MacOS/PyQt5/Qt/translations/*); do
    codesign -v -f -i ${IDENTITY} -s "$CERT_ID" $filename
done

codesign -v -f -s "$CERT_ID" ${APP_PATH}/Contents/MacOS/base_library.zip

echo "Signing python"
codesign -v -f -o runtime --timestamp --entitlements entitlements.plist -s "$CERT_ID" ${APP_PATH}/Contents/MacOS/python

echo "Signing app"
codesign -v -f -o runtime --timestamp --entitlements entitlements.plist -s "$CERT_ID" ${APP_PATH}/Contents/MacOS/app

echo "Signing ${APP_NAME}"
codesign -v -f -o runtime --timestamp --entitlements entitlements.plist -s "$CERT_ID" ${APP_PATH}


# Notarize
echo "###### Uploading file to notarize ###############"

cd ${OUTPUT_FOLDER}

echo "-> Making a copy from ${APP_NAME} to ${ZIPPED_APP_NAME}"
ditto -c -k --keepParent ${APP_NAME} ${ZIPPED_APP_NAME}

echo "-> Uploading file: ${ZIPPED_APP_NAME}"
xcrun altool --notarize-app -f ${ZIPPED_APP_NAME} --primary-bundle-id ${IDENTITY} -u ${USER} -p "@keychain:${KEYCHAIN}"

echo "-> Checking status"
xcrun altool --notarization-history 0 -u ${USER} -p "@keychain:${KEYCHAIN}"

echo "-> Check a single request"
echo xcrun altool --notarization-info uuid -u ${USER} -p "@keychain:${KEYCHAIN}"
