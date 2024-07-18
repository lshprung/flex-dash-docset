VERSION = 2.6.4
MANUAL_URL  = https://github.com/westes/flex/releases/download/v$(VERSION)/flex-$(VERSION).tar.gz
MANUAL_SRC = tmp/flex-$(VERSION)
MANUAL_FILE = $(MANUAL_SRC)/doc/flex.html

$(MANUAL_SRC): tmp
	curl -L -o $@.tar.gz $(MANUAL_URL)
	tar -x -z -f $@.tar.gz -C tmp

$(MANUAL_FILE): $(MANUAL_SRC)
	cd $(MANUAL_SRC) && ./configure && make html

$(DOCUMENTS_DIR): $(RESOURCES_DIR) $(MANUAL_FILE)
	mkdir -p $@
	cp -r $(MANUAL_FILE)/* $@

$(INDEX_FILE): $(SOURCE_DIR)/src/index-pages.sh $(SCRIPTS_DIR)/gnu/index-terms-colon.sh $(DOCUMENTS_DIR)
	rm -f $@
	$(SOURCE_DIR)/src/index-pages.sh $@ $(DOCUMENTS_DIR)/*.html
	$(SCRIPTS_DIR)/gnu/index-terms-colon.sh "Entry"    $@ $(DOCUMENTS_DIR)/Concept-Index.html
	$(SCRIPTS_DIR)/gnu/index-terms-colon.sh "Function" $@ $(DOCUMENTS_DIR)/Index-of-Functions-and-Macros.html
	$(SCRIPTS_DIR)/gnu/index-terms-colon.sh "Variable" $@ $(DOCUMENTS_DIR)/Index-of-Variables.html
	$(SCRIPTS_DIR)/gnu/index-terms-colon.sh "Type"     $@ $(DOCUMENTS_DIR)/Index-of-Data-Types.html
	$(SCRIPTS_DIR)/gnu/index-terms-colon.sh "Hook"     $@ $(DOCUMENTS_DIR)/Index-of-Hooks.html
	$(SCRIPTS_DIR)/gnu/index-terms-colon.sh "Option"   $@ $(DOCUMENTS_DIR)/Index-of-Scanner-Options.html
	sqlite3 "$@" "DELETE FROM searchIndex WHERE EXISTS (SELECT 1 FROM searchIndex s2 WHERE searchIndex.name = s2.name AND searchIndex.type = s2.type AND searchIndex.type = \"Option\" AND searchIndex.rowid > s2.rowid)" # Remove duplicates
