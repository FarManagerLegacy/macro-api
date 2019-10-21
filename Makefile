SOURCE_EXT:=text
TARGET_EXT:=html bbcode native rst md

PANDOC:=pandoc/pandoc.exe

FLAGS:=--lua-filter=typo.lua #-f markdown-auto_identifiers
EXTRA_FLAGS:=--standalone

BBCODE:=bbcode.lua

CSS:=--css=styles/pandoc.css --css=styles/github.css --css=styles/dl_table.css
HTMLTEMPLATE:=--template=custom.html5
HTML:=$(CSS) $(HTMLTEMPLATE) --highlight-style=tango #or file

RM:=del
#RM:=cmd /cdel

#ifneq (,$(filter $(TARGET_EXT),$(SOURCE_EXT)))
#  $(error TARGET_EXT can't include SOURCE_EXT)
#else ifneq (1,$(words $(SOURCE_EXT)))
#  $(error SOURCE_EXT must be single ext)
#endif

SOURCES:=$(wildcard *.$(SOURCE_EXT))
NAMES:=$(basename $(SOURCES))

.PHONY: clean all $(TARGET_EXT)

$(TARGET_EXT): %: $(addsuffix .%,$(NAMES))
	
all: $(TARGET_EXT)

ALL_TARGETS:=$(addprefix *.,$(TARGET_EXT))
clean:
	$(info $(wildcard $(ALL_TARGETS)))
	@$(RM) $(ALL_TARGETS)

%.bbcode:: FLAGS += -t $(BBCODE)
%.bbcode:: EXTRA_FLAGS :=
%.html::   FLAGS += $(HTML)

%.md:: FLAGS += -t gfm

#$(addprefix %.,$(filter-out $(TARGET_EXT),bbcode)): %.$(SOURCE_EXT)

.SECONDEXPANSION: #https://www.gnu.org/software/make/manual/html_node/Secondary-Expansion.html#Secondary-Expansion
%:: $$(basename %).$(SOURCE_EXT) Makefile typo.lua
	$(info $@)
	@$(PANDOC) $(FLAGS) $(EXTRA_FLAGS) -o $@ $<

