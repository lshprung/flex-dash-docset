#!/usr/bin/env sh

# shellcheck source=../../../scripts/create_table.sh
. "$(dirname "$0")"/../../../scripts/create_table.sh
# shellcheck source=../../../scripts/insert.sh
. "$(dirname "$0")"/../../../scripts/insert.sh

TYPE="$1"
shift
DB_PATH="$1"
shift

insert_index_terms() {
	# Get each term from an index page and insert
	while [ -n "$1" ]; do
		grep -Eo "<a href.*</a>:" "$1" | while read -r line; do
			insert_term "$line"
		done

		shift
	done
}

insert_term() {
	LINK="$1"
	NAME="$(echo "$LINK" | pup -p 'a text{}' | sed 's/\"\"//g' | tr -d \\n)"
	PAGE_PATH="$(echo "$LINK" | pup -p 'a attr{href}')"

	# DEBUG
	#echo "$NAME"
	#echo "$PAGE_PATH"
	#echo 

	insert "$DB_PATH" "$NAME" "$TYPE" "$PAGE_PATH"
}

create_table "$DB_PATH"
insert_index_terms "$@"
