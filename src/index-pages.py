#!/usr/bin/env python3

import os
import re
import sys

sys.path.append(os.path.join(os.path.dirname(__file__), "..", "..", "..", "scripts"))
from create_table import create_table
from get_title import get_title
from insert import insert

class Index_pages:
    def __init__(self, db_path):
        self.db_path = db_path
    
    def insert_page(self, html_path):
        page_name = get_title(html_path)
        page_name = re.sub(r'\s\(Lexical Analysis With Flex[^)]*\)', r'', page_name)

        page_type = "Guide"

        # determine type
        if re.search(r'option-.*', page_name):
            page_name = re.sub(r'^option-', r'', page_name)
            page_type = "Option"
        elif re.search(r'unnamed-.*', page_name) or re.search(r'deleteme.*', page_name) or re.search(r'ERASEME.*', page_name):
            return

        insert(self.db_path, page_name, page_type, os.path.basename(html_path))

if __name__ == '__main__':
    db_path = sys.argv[1]

    main = Index_pages(db_path)
    create_table(db_path)

    for html_path in sys.argv[2:]:
        main.insert_page(html_path)
