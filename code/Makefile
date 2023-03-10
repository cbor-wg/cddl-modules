OPEN=$(word 1, $(wildcard /usr/bin/xdg-open /usr/bin/open /bin/echo))
SOURCES?=${wildcard *.mdi}
TARGETS=${SOURCES:.mdi=.md}

all: $(TARGETS)

%.md: %.mdi cddlcmdi.rb
	ruby cddlcmdi.rb $< >$@.new
	mv $@.new $@

