#
# Makefile for stemmer	-*-Makefile-*-
#  cree par Romaric Besancon (romaric@lia.di.epfl.ch) le  09/01/02 
#
# $Id$
#

CC       = gcc
CPPFLAGS = 
CFLAGS   = -Wall
LDFLAGS  = 
LDLIBS   = 
RM       = /bin/rm -f

TARGETS = stemmer-porter-fre stemmer-porter-eng stemmer-savoy1-fre stemmer-savoy2-fre

all:: $(TARGETS)
	@echo All done.

stemmer-porter-fre: stemmer-porter-fre.o porter_api.o porter_utilities.o porter_french_stem.o
	$(LINK.c) -o $@ stemmer-porter-fre.o porter_api.o porter_utilities.o porter_french_stem.o $(LDLIBS)

stemmer-porter-eng: stemmer-porter-eng.o porter_api.o porter_utilities.o porter_english_stem.o
	$(LINK.c) -o $@ stemmer-porter-eng.o porter_api.o porter_utilities.o porter_english_stem.o $(LDLIBS)

stemmer-savoy1-fre: stemmer-savoy1-fre.o
	$(LINK.cpp) -o $@ stemmer-savoy1-fre.o $(LDLIBS)

stemmer-savoy2-fre: stemmer-savoy2-fre.o
	$(LINK.cpp) -o $@ stemmer-savoy2-fre.o $(LDLIBS)

install: all
	install $(TARGETS) $(TP_MAI_HOME)/sources/bin

clean:
	-@$(RM) *.o $(TARGETS)
	@echo Cleaned.
