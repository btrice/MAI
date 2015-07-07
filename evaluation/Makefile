#
# Makefile for 	-*-Makefile-*-
#  cree par Romaric Besancon (romaric.besancon@cea.fr) le  02/10/06 
#

SUBDIRS=trec_eval_7.3

all::
	@list='$(SUBDIRS)'; for subdir in $$list; do \
          echo "Making install in $$subdir"; \
	  cd $$subdir; make; cd ..; \
	done
	@echo Done

install: all
	install trec_eval_7.3/trec_eval $(TP_MAI_HOME)/sources/bin
	install *.pl $(TP_MAI_HOME)/sources/bin
