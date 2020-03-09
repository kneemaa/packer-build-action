#!/bin/sh
set -e

# Set the working directory for the template
cd "${INPUT_WORKINGDIR:-.}"

# find template file
if [[ ! -f "$INPUT_TEMPLATEFILE" ]] && [[ $INPUT_TEMPLATEFILE != *.json ]]; then
    echo "${INPUT_TEMPLATEFILE} does not exit in the working directory (${INPUT_WORKINGDIR})"
    exit 1
fi

# find var file
if [[ ! -f "$INPUT_VARFILE" ]] && [[ $INPUT_VARFILE != *.json ]]; then
    echo "${INPUT_VARFILE} does not exit in the working directory (${INPUT_WORKINGDIR})"
    exit 1
fi

set +e
# Run packer build
BUILD_OUTPUT=$(sh -c "packer build -var-file=${INPUT_VARFILE} ${INPUT_TEMPLATEFILE}" 2>&1)
BUILD_SUCCESS=$?
echo "$BUILD_OUTPUT"

echo $BUILD_OUTPUT > output.txt

AMI_ID=$(tail -2 output.txt | head -2 | awk 'match($0, /ami-.*/) { print substr($0, RSTART, RLENGTH) }')
set -e

# Set Github actions output values
echo "##[set-output name=AMI_ID;]$AMI_ID"

exit $BUILD_SUCCESS
