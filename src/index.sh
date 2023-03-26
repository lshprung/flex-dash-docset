#!/usr/bin/env sh

DB_PATH="$1"
shift

create_table() {
	sqlite3 "$DB_PATH" "CREATE TABLE IF NOT EXISTS searchIndex(id INTEGER PRIMARY KEY, name TEXT, type TEXT, path TEXT);"
	sqlite3 "$DB_PATH" "CREATE UNIQUE INDEX IF NOT EXISTS anchor ON searchIndex (name, type, path);"
}


get_title() {
	FILE="$1"

	pup -p -f "$FILE" 'title text{}' | \
		sed 's/(Lexical Analysis With Flex.*)//' | \
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

insert() {
	NAME="$1"
	TYPE="$2"
	PAGE_PATH="$3"

	sqlite3 "$DB_PATH" "INSERT INTO searchIndex(name, type, path) VALUES (\"$NAME\",\"$TYPE\",\"$PAGE_PATH\");"
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
			insert "$PAGE_NAME" "$PAGE_TYPE" "$(basename "$1")"
		fi
		shift
	done
}

create_table
insert_pages "$@"
