#!/bin/sh

# grabs a patch .zip from archive.org and saves it as a pk3
grab_patch()
{
	wget -nc -O ./pak$2.pk4 http://archive.org/download/hl_shareware_data/tfc/$1.zip
}

SCRPATH="$( cd "$( dirname $(readlink -nf $0) )" && pwd )"

if ! [ -x "$(command -v wget)" ]; then
	printf "Error: wget is not installed.\n" >&2
	exit 1
fi

cd "$SCRPATH"

echo "============================================================="
echo "Downloading data for Half-Life Patch 1.0.0.9"
echo "This patch data contained the original release of TFC."
echo "============================================================="
grab_patch 10081009 00_10081009

echo "============================================================="
echo "Downloading data for Half-Life Patch 1.0.1.0"
echo "============================================================="
grab_patch 10091010 01_10091010

echo "============================================================="
echo "Downloading data for Half-Life Patch 1.0.1.3"
echo "============================================================="
grab_patch 10101013 02_10101013

echo "============================================================="
echo "Downloading data for Half-Life Patch 1.0.1.5"
echo "============================================================="
grab_patch 10131015 03_10131015

echo "============================================================="
echo "Downloading data for Half-Life Patch 1.0.1.6"
echo "============================================================="
grab_patch 10151016 04_10151016

echo "============================================================="
echo "Downloading data for Half-Life Patch 1.1.0.0"
echo "============================================================="
grab_patch 10161100 05_10161100

echo "============================================================="
echo "Downloading data for Half-Life Patch 1.1.0.1"
echo "============================================================="
grab_patch 11001101 06_11001101

echo "============================================================="
echo "Downloading data for Half-Life Patch 1.1.0.4"
echo "============================================================="
grab_patch 11011104 07_11011104

echo "============================================================="
echo "Downloading data for Half-Life Patch 1.1.0.6"
echo "============================================================="
grab_patch 11041106 08_11041106

echo "============================================================="
echo "Downloading data for Half-Life Patch 1.1.0.8"
echo "============================================================="
grab_patch 11071108 09_11071108

echo "============================================================="
echo "Downloading data for Half-Life Patch 1.1.0.9"
echo "============================================================="
grab_patch 11081109 10_11081109

echo "============================================================="
echo "Downloading data for Half-Life Patch 1.1.1.0"
echo "============================================================="
grab_patch 11091110 11_11091110

echo "Completed transfer of packages."
