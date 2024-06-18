#!/usr/bin/env sh

# shellcheck source=../../../scripts/create_table.sh
. "$(dirname "$0")"/../../../scripts/create_table.sh
# shellcheck source=../../../scripts/insert.sh
. "$(dirname "$0")"/../../../scripts/insert.sh

DB_PATH="$1"
shift

get_title() {
	FILE="$1"

	pup -p -f "$FILE" 'title text{}' | \
		sed 's/ (Lexical Analysis With Flex.*)//' | \
		tr -d \\n | \
		sed 's/\"/\"\"/g'
}

get_type() {
	PAGE_NAME="$1"

	case "$PAGE_NAME" in
		option-*)
			echo "Option"
			;;
		*)
			echo "Guide"
	esac
}

insert_pages() {
	# Get title and insert into table for each html file
	while [ -n "$1" ]; do
		unset PAGE_NAME
		unset PAGE_TYPE
		PAGE_NAME="$(get_title "$1")"

		# determine type
		case "$PAGE_NAME" in
			option-*)
				PAGE_TYPE="Option"
				PAGE_NAME="$(echo "$PAGE_NAME" | sed 's/^option-//')"
				;;
			unnamed-* | deleteme* | ERASEME*)
				shift
				continue
				;;
			*)
				PAGE_TYPE="Guide"
		esac

		if [ -n "$PAGE_NAME" ]; then
			insert "$DB_PATH" "$PAGE_NAME" "$PAGE_TYPE" "$(basename "$1")"
		fi
		shift
	done
}

create_table "$DB_PATH"
insert_pages "$@"
