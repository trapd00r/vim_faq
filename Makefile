SCRIPT=$(wildcard plugin/*.vim)
FAQ="vim_faq.txt"
DOC=$(wildcard doc/*.txt)
PLUGIN=$(shell basename "$$PWD")
VERSION=$(shell sed -n '/Version:/{s/^[^0-9]*\([0-9]\+\)$$/\1/;p}' $(SCRIPT))


.PHONY: $(PLUGIN).vba README

all: generate release uninstall vimball install README

vimball: $(PLUGIN).vba

clean:
	find . -type f \( -name "*.vba" -o -name "*.orig" -o -name "*.~*" \
	-o -name ".VimballRecord" -o -name ".*.un~" -o -name "*.sw*" -o \
	-name tags \) -delete

dist-clean: clean

install:
	vim -N -c':so %' -c':q!' $(PLUGIN)-$(VERSION).vba

uninstall:
	vim -N -c':RmVimball' -c':q!' $(PLUGIN)-$(VERSION).vba

README:
	cp -f $(DOC) README

$(PLUGIN).vba:
	rm -f $(PLUGIN)-$(VERSION).vba
	vim -N -c 'ru! vimballPlugin.vim' -c ':call append("0", [ "$(SCRIPT)", "$(DOC)"])' -c '$$d' -c ":%MkVimball $(PLUGIN)-$(VERSION)  ." -c':q!'
	if [ -f $(PLUGIN)-$(VERSION).vba ]; then ln -f $(PLUGIN)-$(VERSION).vba $(PLUGIN).vba; fi
     
generate:
	vim -u NONE -U NONE -N -c ':so vim_faq.vim|:CreateVimFAQHelp|wq' ${FAQ}

release:
	vim -u NONE -U NONE -N -c ':$$s/Last updated on: \zs.*$$/\=strftime("%d %B %Y")/|wq' ${FAQ}
	vim -u NONE -U NONE -N -c '/^\" GetLatestVimScripts: /s/\d\+\s\ze:AutoInstall:/\=(submatch(0)+1)." "/|wq' ${SCRIPT}
	vim -u NONE -U NONE -N -c '/^" Last Change: /s/: \zs.*$$/\=strftime("%d %B %Y")/|wq' ${SCRIPT}
	vim -u NONE -U NONE -N -c '/^" Version:/s/\d\+/\=submatch(0)+1/|wq' ${SCRIPT}
	VERSION=$(shell sed -n '/Version:/{s/^.*\(\S\?\.\?\S\+\)$$/\1/;p}' $(SCRIPT))
