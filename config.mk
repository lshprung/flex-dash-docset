DOCSET_NAME = Flex

DOCSET_DIR    = $(DOCSET_NAME).docset
CONTENTS_DIR  = $(DOCSET_DIR)/Contents
RESOURCES_DIR = $(CONTENTS_DIR)/Resources
DOCUMENTS_DIR = $(RESOURCES_DIR)/Documents

INFO_PLIST_FILE = $(CONTENTS_DIR)/Info.plist
INDEX_FILE      = $(RESOURCES_DIR)/docSet.dsidx
ICON_FILE       = $(DOCSET_DIR)/icon.png
ARCHIVE_FILE    = $(DOCSET_NAME).tgz

#SRC_ICON = src/icon.png

VERSION = 2.6.4
MANUAL_URL  = https://github.com/westes/flex/releases/download/v$(VERSION)/flex-$(VERSION).tar.gz
MANUAL_SRC = tmp/flex-$(VERSION)
MANUAL_FILE = $(MANUAL_SRC)/doc/flex.html

ERROR_DOCSET_NAME = $(error DOCSET_NAME is unset)
WARNING_MANUAL_URL = $(warning MANUAL_URL is unset)
ERROR_MANUAL_FILE = $(error MANUAL_FILE is unset)
.phony: err warn

ifndef DOCSET_NAME
err: ; $(ERROR_DOCSET_NAME)
endif

ifndef MANUAL_FILE
err: ; $(ERROR_MANUAL_FILE)
endif

ifndef MANUAL_URL
warn: 
	$(WARNING_MANUAL_URL)
	$(MAKE) all
endif

DOCSET = $(INFO_PLIST_FILE) $(INDEX_FILE)
ifdef SRC_ICON
DOCSET += $(ICON_FILE)
endif

all: $(DOCSET)

archive: $(ARCHIVE_FILE)

clean:
	rm -rf $(DOCSET_DIR) $(ARCHIVE_FILE)
ifneq (,$(wildcard $(MANUAL_SRC)))
	cd $(MANUAL_SRC) && make clean
endif

tmp:
	mkdir -p $@

$(ARCHIVE_FILE): $(DOCSET)
	tar --exclude='.DS_Store' -czf $@ $(DOCSET_DIR)

$(MANUAL_SRC): tmp
	curl -L -o $@.tar.gz $(MANUAL_URL)
	tar -x -z -f $@.tar.gz -C tmp

$(MANUAL_FILE): $(MANUAL_SRC)
	cd $(MANUAL_SRC) && ./configure && make html

$(DOCSET_DIR):
	mkdir -p $@

$(CONTENTS_DIR): $(DOCSET_DIR)
	mkdir -p $@

$(RESOURCES_DIR): $(CONTENTS_DIR)
	mkdir -p $@

$(DOCUMENTS_DIR): $(RESOURCES_DIR) $(MANUAL_FILE)
	mkdir -p $@
	cp -r $(MANUAL_FILE)/* $@

$(INFO_PLIST_FILE): src/Info.plist $(CONTENTS_DIR)
	cp src/Info.plist $@

$(INDEX_FILE): src/index-page.sh src/index-terms.sh $(DOCUMENTS_DIR)
	rm -f $@
	src/index-page.sh $@ $(DOCUMENTS_DIR)/*.html
	src/index-terms.sh "Entry" $@ $(DOCUMENTS_DIR)/Concept-Index.html
	src/index-terms.sh "Function" $@ $(DOCUMENTS_DIR)/Index-of-Functions-and-Macros.html
	src/index-terms.sh "Variable" $@ $(DOCUMENTS_DIR)/Index-of-Variables.html
	src/index-terms.sh "Type" $@ $(DOCUMENTS_DIR)/Index-of-Data-Types.html
	src/index-terms.sh "Hook" $@ $(DOCUMENTS_DIR)/Index-of-Hooks.html
	src/index-terms.sh "Option" $@ $(DOCUMENTS_DIR)/Index-of-Scanner-Options.html
	sqlite3 "$@" "DELETE FROM searchIndex WHERE EXISTS (SELECT 1 FROM searchIndex s2 WHERE searchIndex.name = s2.name AND searchIndex.type = s2.type AND searchIndex.type = \"Option\" AND searchIndex.rowid > s2.rowid)" # Remove duplicates

$(ICON_FILE): src/icon.png $(DOCSET_DIR)
	cp $(SRC_ICON) $@
