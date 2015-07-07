#
# Makefile for 	-*-Makefile-*-
#  cree par Romaric Besancon (romaric.besancon@cea.fr) le  02/10/06 
#
# $Id$
#

SUBDIRS=stemmers tagger bin

all: install

install: 
	@list='$(SUBDIRS)'; for subdir in $$list; do \
          echo "Making install in $$subdir"; \
	  cd $$subdir; make install; cd ..; \
	done
