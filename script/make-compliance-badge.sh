#!/bin/bash
# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2023 The Foundation for Public Code <info@publiccode.net>

# $ help set | grep "\-e"
#      -e  Exit immediately if a command exits with a non-zero status.
set -e

if [ "_${VERBOSE}_" == "__" ]; then VERBOSE=0; fi
if [ $VERBOSE -gt 0 ]; then
# $ help set | grep "\-x"
#      -x  Print commands and their arguments as they are executed.
	set -x
fi

REPO=$1
HASH=$2
if [ "_${REPO}_" == "__" ] || [ "_${HASH}_" == "__" ]; then
	echo "must specify a repository and hash"
	exit 1
fi

if [ "_${3}_" != "__" ]; then
	STD_VERSION=$3
else
	STD_VERSION=0.7.0
fi

SHORT_HASH=${HASH:0:10}

# strip "https://" if present
DIR=$( echo $REPO | sed -e 's@^http[s]*://@@' )

mkdir -pv $DIR

BADGE_LABEL="Standard for Public Code $STD_VERSION compliant"
BADGE_TEXT="$SHORT_HASH"
BADGE_COLOR_NAME="green"
BADGE_COLOR_CODE=":green"
BADGE_PATH=$DIR/$HASH.svg


if ! [ -e ./node_modules/.bin/badge ]; then
	npm install
fi
if [ $VERBOSE -gt 0 ]; then
	ls -l ./node_modules/.bin/badge
fi

rm -f $BADGE_PATH
cat > ${BADGE_PATH}.head.svg <<EOF
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!-- SPDX-License-Identifier: CC0-1.0 -->
<!-- SPDX-FileCopyrightText: 2023 The Foundation for Public Code <info@publiccode.net> -->
<!-- ${BADGE_PATH} -->
EOF

# create the body
./node_modules/.bin/badge \
	"${BADGE_LABEL}" \
	"${BADGE_TEXT}" \
	"${BADGE_COLOR_CODE}" \
	flat \
	> ${BADGE_PATH}.body.svg

# combine the unformatted contents
cat	${BADGE_PATH}.head.svg \
	${BADGE_PATH}.body.svg \
	> ${BADGE_PATH}.tmp.svg

# format for final output
xmllint --format ${BADGE_PATH}.tmp.svg \
	--output ${BADGE_PATH}

rm ${BADGE_PATH}.{tmp,head,body}.svg
ls -l ${BADGE_PATH}
