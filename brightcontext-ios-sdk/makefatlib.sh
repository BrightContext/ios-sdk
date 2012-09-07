# http://stackoverflow.com/questions/3520977/build-fat-static-library-device-simulator-using-xcode-and-sdk-4

TARGET_NAME=brightcontext-ios-sdk

DEVICE=iphoneos
SIMULATOR=iphonesimulator
FAT=universal
OUTPUT=build
LIBRARY_NAME=lib${TARGET_NAME}.a

for CONFIGURATION in Debug Release
do
	for sdk in ${DEVICE} ${SIMULATOR}
	do
	  xcodebuild -sdk ${sdk} -configuration ${CONFIGURATION} -target ${TARGET_NAME} -verbose

	  # bail if the build fails
	  if [[ $? -ne 0 ]]; then
	  	exit
	  fi
	done

	device_output=${OUTPUT}/${CONFIGURATION}-${DEVICE}
	simulator_output=${OUTPUT}/${CONFIGURATION}-${SIMULATOR}
	fatlib_output=${OUTPUT}/${CONFIGURATION}-${FAT}

	rm -rf "${fatlib_output}"
	mkdir -p "${fatlib_output}"
	lipo -create -output "${fatlib_output}/${LIBRARY_NAME}" "${device_output}/${LIBRARY_NAME}" "${simulator_output}/${LIBRARY_NAME}"

	headers_src="${device_output}/usr/local/include"
	headers_dest="${fatlib_output}/headers"
	mkdir -p "${headers_dest}"
	cp "${headers_src}"/* "${headers_dest}"
	
	if [[ "$1" == "zip" ]]; then
		pushd ${OUTPUT}
		zipfile=$2-${CONFIGURATION}.zip
		zip -r ${zipfile} ${CONFIGURATION}-${FAT}
		popd
	fi

done

open ${OUTPUT}
