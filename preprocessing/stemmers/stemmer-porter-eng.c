/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/*                                                                           */
/*   Module        : stemmer.c                                          */
/*   Projet        :                                                         */
/*   Version       : $Id$ */
/*   Creation      : le 09/01/02 (par Romaric Besancon)                */
/*   Modifications : le 20/04/04 (avec nouvelle version de snowball)         */
/*   Description   : un stemmer multilingue avec les algos des programmes    */
/*                   en Snowball de Porter                                   */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
#define _STEMMER_C

/* ========================================================================= */
/*                   Includes                                                */
/* ========================================================================= */
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>  /* for isupper, tolower */

#include "porter_api.h"
#include "porter_english_stem.h"

/* ========================================================================= */
/*                   Defines                                                 */
/* ========================================================================= */

#define USAGE "Porter stemmer for French (snowball)\nusage : %s [-h] fichier\n"

/* ========================================================================= */
/*                   Declarations                                            */
/* ========================================================================= */
typedef enum {
  NONE,
  ENGLISH,
} Language;

/* EN GLOBAL, les parametres*/
struct {
  char file[100];        /* le fichier d'entree */
  char fileout[100];     /* le fichier de sortie */
  Language langue;       /* la langue du stemmer */
  int help;              /* mode aide */
} param={"","",ENGLISH,0};

void traite_arg(unsigned int argc, char *argv[])
{
  int i;
  for(i=1; i<argc; i++){
	if (!(strncmp(argv[i], "-h",2))) 
	  param.help=1;
	else if (!(strncmp(argv[i], "-o",2)))
	  strcpy(param.fileout, &argv[i][2]); 
	else if (!(strncmp(argv[i], "-",1))) {
	  fprintf(stderr, "unrecognized option %s\n", argv[i]);
	  fprintf(stderr, USAGE, argv[0]);
	  exit(1);
	}
        else if (strcmp(param.file,"")==0) {
          strcpy(param.file, argv[i]); 
	}
  }

/*    printf("langue=[%d]\n",param.langue); */
/*    printf("file=[%s]\n",param.file); */
}

/* les fonctions generiques qui redirigent sur les stemmers
   correspondant aux differentes langues */
struct SN_env * create_env(void) {
return english_create_env();
}

void close_env(struct SN_env * z) {
english_close_env(z); 
}

int stem(struct SN_env * z) {
return english_stem(z);
}


void stemfile(struct SN_env * z, FILE * FileIn, FILE * FileOut) {
#define INC 10
  int lim = INC;
  char * b = (char *) malloc(lim);
  unsigned int ch;
  int i;
  
  while(!feof(FileIn)) {
	ch = getc(FileIn);
	if (ch == EOF) { free(b); return; }
	i = 0;
	while(1) {
	  if (isspace(ch) || ch == EOF) break;
	  if (i == lim) {   
		char * q = (char *) malloc(lim + INC);
		memmove(q, b, lim);
		free(b); b = q;
		lim = lim + INC;
	  }
	  /* force lower case: */
	  if isupper(ch) ch = tolower(ch);
	  
	  b[i] = ch; i++;
	  ch = getc(FileIn);
	}
	
	SN_set_current(z, i, b);
	stem(z); 
	
	z->p[z->l] = 0;
	fprintf(FileOut, "%s%c", z->p, ch);
  }
}

/* ========================================================================= */
/*                                                                           */
/*                   M A I N                                                 */
/*                                                                           */
/* ========================================================================= */
int main(int argc, char *argv[])
{
  
  if (argc<2) {	fprintf(stderr, USAGE, argv[0]); exit(1); }
  traite_arg(argc,argv);
  if (param.help) { fprintf(stderr, USAGE , argv[0]); exit(1); }

  /* initialise the stemming process: */
  {   
	struct SN_env * z = create_env();
	FILE * FileIn;
	FILE * FileOut;
	FileIn = strcmp(param.file,"") ? fopen(param.file, "r") : stdin;
	if (FileIn == 0) { 
	  fprintf(stderr, "file %s not found\n", param.file); exit(1); }
	FileOut = strcmp(param.fileout,"") ? fopen(param.fileout, "w") : stdout;
	if (FileOut == 0) { 
	  fprintf(stderr, "file %s cannot be opened\n", param.fileout); exit(1); }
	stemfile(z, FileIn, FileOut);
	close_env(z);
  }
  
  return(0);
}

