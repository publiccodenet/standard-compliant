#!/bin/bash
# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2023 The Foundation for Public Code <info@publiccode.net>

set -e
set -o pipefail

SCRIPT_VERSION=0.0.1
DEFAULT_STANDARD_VERSION=0.7.1

# https://www.gnu.org/software/bash/manual/html_node/Arrays.html
APPROVER=()

# https://manpages.debian.org/stable/util-linux/getopt.1.en.html
OPTIONS=$(getopt -o 's:n:u:c:t:a:A:vVh' \
 --long 'standard-version:,name:,url:,commit:,tag:,assessment-url:,approver:,verbose,version,help' \
 -n "$0" -- "$@")

if [ $? -ne 0 ]; then
	echo 'Terminating...' >&2
	exit 1
fi

# Note the quotes around "$OPTIONS": they are essential!
eval set -- "$OPTIONS"
unset OPTIONS
while true; do
	case "$1" in
		'-s'|'--standard-version')
			STANDARD_VERSION="$2"
			shift 2
			continue
		;;
		'-n'|'--name')
			REPO_NAME="$2"
			shift 2
			continue
		;;
		'-u'|'--url')
			REPO_URL="$2"
			shift 2
			continue
		;;
		'-c'|'--commit')
			COMMIT_HASH="$2"
			shift 2
			continue
		;;
		'-t'|'--tag')
			COMMIT_TAG="$2"
			shift 2
			continue
		;;
		'-a'|'--assessment-url')
			ASSESSMENT_URL="$2"
			shift 2
			continue
		;;
		'-A'|'--approver')
			APPROVER+=( "$2" )
			shift 2
			continue
		;;
		'-v'|'--verbose')
			VERBOSE=1
			shift 1
			continue
		;;
		'-V'|'--version')
			VERSION_ASKED=1
			shift 1
			continue
		;;
		'-h'|'--help')
			HELP_ASKED=1
			shift 1
			continue
		;;
		'--')
			shift
			break
		;;
		*)
			echo 'Internal error!' >&2
			exit 1
		;;
	esac
done

function usage() {
	SCRIPT_NAME=$(basename $0)
	cat << EOF
$SCRIPT_NAME version $SCRIPT_VERSION

	Creates the files for registering a repository assessement.

OPTIONS:
	-s, --standard-version
		The version of the Standard for Public Code for which the
		assessment was performed.
		Defaults to: '$DEFAULT_STANDARD_VERSION'
	-n, --name
		The codebase name.
	-u, --url
		The URL to the repository.
	-c, --commit
		The commit hash or unique identifier.
	-t, --tag
		The primary tag or version identifier for the commit.
	-a, --assessment-url
		The URL to the assessment.
	-A, --approver
		Person who approved this assessement.
		This option may be provided multiple times.
	-v, --verbose
		Run in verbose mode.
	-V, --version
		Prints the script name and version ( $SCRIPT_VERSION ).
	-h, --help
		Prints this message.

EXAMPLE USAGE:
$0 \\
	--standard-version=0.5.0 \\
	--name="Governance Game" \\
	--url=https://github.com/publiccodenet/governance-game \\
	--commit=12f970cceb9351d8ffa810298bd039ddcdf6bac3 \\
	--tag=1.0.2 \\
	--assessment-url=https://github.com/publiccodenet/governance-game/blob/main/standard-for-public-code-assessment.md \\
	--approver="Eric Herman <eric@publiccode.net>" \\
	--approver="Jan Ainali <jan@publiccode.net>"
EOF
}

if [ "_${VERBOSE}_" != "__" ] && [ "$VERBOSE" -gt 0 ]; then
	set -x
else
	VERBOSE=0
fi

if [ "_${VERSION_ASKED}_" != "__" ]; then
	echo "$SCRIPT_NAME version $SCRIPT_VERSION"
	exit 0
fi

# if --help or if no params were given, then print usage without error
if [ "_${HELP_ASKED}_" != "__" ] ||
   [ "_${REPO_NAME}${REPO_URL}${COMMIT_HASH}${COMMIT_TAG}${ASSESSMENT_URL}${APPROVER}_" == "__" ]; then
	usage
	exit 0
fi

if [ "_${STANDARD_VERSION}_" == "__" ]; then
	STANDARD_VERSION="$DEFAULT_STANDARD_VERSION"
fi

if [ "_${REPO_NAME}_" == "__" ]; then
	echo "Required --name not specified."
	usage
	exit 1
fi

if [ "_${REPO_URL}_" == "__" ]; then
	echo "Required --url not specified."
	usage
	exit 1
fi

if [ "_${COMMIT_HASH}_" == "__" ]; then
	echo "Required --commit not specified."
	usage
	exit 1
fi

if [ "_${COMMIT_TAG}_" == "__" ]; then
	echo "Required --tag not specified."
	usage
	exit 1
fi
if [ "_${ASSESSMENT_URL}_" == "__" ]; then
	echo "Required --assessment-url not specified."
	usage
	exit 1
fi

if [ "_${APPROVER}_" == "__" ]; then
	echo "Required --approver not specified."
	usage
	exit 1
fi

if [ "$VERBOSE" -gt 0 ]; then
	echo "REPO_NAME=$REPO_NAME"
	echo "REPO_URL=$REPO_URL"
	echo "COMMIT_HASH=$COMMIT_HASH"
	echo "COMMIT_TAG=$COMMIT_TAG"
	echo "STANDARD_VERSION=$STANDARD_VERSION"
	echo "ASSESSMENT_URL=$ASSESSMENT_URL"
	echo "APPROVER=$APPROVER"
fi

# strip "https://"
DIR=$( echo $REPO_URL | sed -e 's@^http[s]*://@@' )
mkdir -pv $DIR

JSON_FILE=$DIR/${COMMIT_HASH}.json

cat > $JSON_FILE <<EOF
{
	"repository_name": "$REPO_NAME",
	"repository_url": "$REPO_URL",
	"commit_id": "$COMMIT_HASH",
	"commit_tag": "$COMMIT_TAG",
	"standard_version": "$STANDARD_VERSION",
	"assessment_url": "$ASSESSMENT_URL",
	"approved_by": [
EOF
LAST_IDX=$(( ${#APPROVER[@]} - 1 ))
# extract the keys
for i in "${!APPROVER[@]}"; do
	if [ $i -eq $LAST_IDX ]; then
		SEP=''
	else
		SEP=','
	fi
	echo -e "\t\t\"${APPROVER[$i]}\"$SEP" >> $JSON_FILE
done
cat >> $JSON_FILE <<EOF
	],
	"status": "compliant"
}
EOF

if [ "$VERBOSE" -gt 0 ]; then
	echo
	echo $JSON_FILE
	echo
	cat $JSON_FILE
	echo
fi

MD_FILE=$DIR/${COMMIT_HASH}.md

ASSESSMENT_FILE=$( basename $ASSESSMENT_URL )

cat > $MD_FILE <<EOF
---
# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2023 The Foundation for Public Code <info@publiccode.net>
---
# $REPO_NAME assessment to Standard for Public Code version $STANDARD_VERSION

[$REPO_NAME]($REPO_URL)

|------------|---------------|
| Tag        | $COMMIT_TAG |
| ID         | $COMMIT_HASH |
| Assessment | [$ASSESSMENT_FILE]($ASSESSMENT_URL) |
| Status     | compliant |

Approved by:
EOF
for i in "${!APPROVER[@]}"; do
	echo -e "* ${APPROVER[$i]}" >> $MD_FILE
done

if [ "$VERBOSE" -gt 0 ]; then
	echo
	echo $MD_FILE
	echo
	cat $MD_FILE
	echo
fi

ls -l $MD_FILE $JSON_FILE
script/make-compliance-badge.sh $DIR $COMMIT_HASH
