#!/bin/bash

set -e

# check argument
if [[ -z $1 || ! $1 =~ [[:digit:]]x[[:digit:]] ]]; then
  echo "ERROR: This script requires 1 argument, \"input dimension\" of the YOLO model."
  echo "The input dimension should be {width}x{height} such as 608x608 or 416x256.".
  exit 1
fi

if which python3 > /dev/null; then
  PYTHON=python3
else
  PYTHON=python
fi


pushd $(dirname $0)/raw > /dev/null

get_file()
{
  # do download only if the file does not exist
  if [[ -f $2 ]];  then
    echo Skipping $2
  else
    echo Downloading $2...
    python3 -m gdown.cli $1
  fi
}

echo "** Download dataset files"


# unzip image files (ignore CrowdHuman_test.zip for now)
echo "** Unzip dataset files"
mkdir train/
# for f in CrowdHuman_train01.zip CrowdHuman_train02.zip CrowdHuman_train03.zip ; do
#   unzip -n ${f} -d train/
# done
mv CrowdHuman_train01/Images/*.jpg train/
mv CrowdHuman_train02/Images/*.jpg train/
mv CrowdHuman_train03/Images/*.jpg train/

mkdir val/
# for f in CrowdHuman_val.zip ; do
#   unzip -n ${f} -d val/
# done
cp CrowdHuman_val/Images/*.jpg val/

echo "** Create the crowdhuman-$1/ directory and subdirectory"
rm -rf ../crowdhuman-$1/
mkdir ../crowdhuman-$1/
mkdir ../crowdhuman-$1/images/
mkdir ../crowdhuman-$1/images/train/
mkdir ../crowdhuman-$1/images/val/
echo "** Copy train images to crowdhuman-$1/"
mv train/*.jpg ../crowdhuman-$1/images/train/
echo "** Copy val images to crowdhuman-$1/"
mv val/*.jpg ../crowdhuman-$1/images/val/

# the crowdhuman/ subdirectory now contains all train/val jpg images

echo "** Generate yolo txt files"
cd ..
${PYTHON} gen_txts.py $1

popd > /dev/null

echo "** Done."
