/************************************************************************
 *
 * @file       stemmer-savoy2-fre.cpp
 * @author     besancon (besanconr@zoe.cea.fr)
 * @date       Wed May 25 2005
 * @version    $Id$
 *             
 * @brief      simple encapsulation of Jacques Savoy's French stemmer
 * 
 ***********************************************************************/

#include <string>
#include <iostream>
#include <fstream>
#include <cstdlib>

using namespace std;

string french_stemming(string& word);

string stemWord(string& word) {
  return french_stemming(word);
}

string stemLine(const string& line) {
  unsigned int offset(0);
  unsigned int space=line.find(' ',0);
  string stemmedLine("");
  while (space!=string::npos) {
    string word(line,offset,space-offset);
    stemmedLine+=stemWord(word)+' ';
    offset=space+1;
    space=line.find(' ',offset);
  }
  // last one
  string word(line,offset);
  stemmedLine+=stemWord(word);
  return stemmedLine;
}

int main(int argc, char** argv) {
  if (argc<2) {
    cerr << "need a file name as argument" << endl;
    exit(1);
  }

  ifstream file(argv[1]);
  if (! file.good()) {
    cerr << "cannot open file "<< argv[1] << endl;
    exit(1);
  }

  string line;
  while (file.good()) {
    line.clear();
    getline(file,line);
    if (!line.empty()) {
      cout << stemLine(line) << endl;
    }
  }

  return EXIT_SUCCESS;
}

//----------------------------------------------------------------------
// FrenchStemmerPlus by Jacques Savoy
//----------------------------------------------------------------------

string normfrenchword(string& word);
string removeAllFEAccent (string& word);
string removeDoublet(string& word);

string french_stemming (string& word)
{ 
int len = word.size()-1;

if (len > 4) {
   if (word[len]=='x') {
      if (word[len-1]=='u' && word[len-2]=='a' && word[len-3]!='e') {
         word[len-1]='l';  /*  chevaux -> cheval  */
         }                 /*  error :  travaux -> traval but not travail  */
      word.erase(len);      /*  anneaux -> anneau,  neveux -> neveu  */
      len--;               /*  error :  aulx -> aul but not ail (rare)  */
      }
   }                       /*  error :  yeux -> yeu but not oeil (rare)  */
if (len > 2) {
   if (word[len]=='x') {
      word.erase(len);      /*  peaux -> peau,  poux -> pou  */
      len--;               /*  error :  affreux -> affreu */
      }                    
   }

if (len > 2 && word[len]=='s') {  /*  remove final --s --> -- */
   word[len]='\0';
   len--;
   }

if (len > 8) {  /* --issement  -->   --ir */
      if (word[len]=='t'   && word[len-1]=='n' && word[len-2]=='e' && 
          word[len-3]=='m' && word[len-4]=='e' && word[len-5]=='s' && 
          word[len-6]=='s' && word[len-7]=='i') {
         word[len-6]='r';       /* investissement --> investir */
         word.erase(len-5);
      return(normfrenchword(word));
      }
   }

if (len > 7) {  /* ---issant  -->   ---ir */
      if (word[len]=='t'   && word[len-1]=='n' && word[len-2]=='a' && 
          word[len-3]=='s' && word[len-4]=='s' && word[len-5]=='i') {
         word[len-4]='r';     /* assourdissant --> assourdir */
         word.erase(len-3);
      return(normfrenchword(word));
      }
   }

if (len > 5) {    /* --ement  -->   --e */
      if (word[len]=='t'   && word[len-1]=='n' && word[len-2]=='e' && 
          word[len-3]=='m' && word[len-4]=='e') {
         word.erase(len-3);       /* pratiquement --> pratique */
         if (word[len-5]=='v' && word[len-6]=='i') {
            word[len-5]='f';     /* administrativement --> administratif */
            word.erase(len-4);
            }
      return(normfrenchword(word));
      }
   }

if (len > 10) {    /* ---ficatrice  -->   --fier */
      if (word[len]=='e'   && word[len-1]=='c' && word[len-2]=='i' && 
          word[len-3]=='r' && word[len-4]=='t' && word[len-5]=='a' &&
          word[len-6]=='c' && word[len-7]=='i' && word[len-8]=='f') {
         word[len-6]='e';
         word[len-5]='r';
         word.erase(len-4);   /* justificatrice --> justifier */
      return(normfrenchword(word));
      }
   }

if (len > 9) {    /* ---ficateur -->   --fier */
      if (word[len]=='r'   && word[len-1]=='u' && word[len-2]=='e' && 
          word[len-3]=='t' && word[len-4]=='a' && word[len-5]=='c' &&
          word[len-6]=='i' && word[len-7]=='f') {
         word[len-5]='e';
         word[len-4]='r';
         word.erase(len-3);   /* justificateur --> justifier */
      return(normfrenchword(word));
      }
   }

if (len > 8) {    /* ---catrice  -->   --quer */
      if (word[len]=='e'   && word[len-1]=='c' && word[len-2]=='i' && 
          word[len-3]=='r' && word[len-4]=='t' && word[len-5]=='a' &&
          word[len-6]=='c') {
         word[len-6]='q';
         word[len-5]='u';
         word[len-4]='e';
         word[len-3]='r';
         word.erase(len-2);   /* educatrice--> eduquer */
      return(normfrenchword(word));
      }
   }

if (len > 7) {    /* ---cateur -->   --quer */
      if (word[len]=='r'   && word[len-1]=='u' && word[len-2]=='e' && 
          word[len-3]=='t' && word[len-4]=='a' && word[len-5]=='c') {
         word[len-5]='q';
         word[len-4]='u';
         word[len-3]='e';
         word[len-2]='r';
         word.erase(len-1);   /* communicateur--> communiquer */
      return(normfrenchword(word));
      }
   }

if (len > 7) {    /* ---atrice  -->   --er */
      if (word[len]=='e'   && word[len-1]=='c' && word[len-2]=='i' && 
          word[len-3]=='r' && word[len-4]=='t' && word[len-5]=='a') {
         word[len-5]='e';
         word[len-4]='r';
         word.erase(len-3);   /* accompagnatrice--> accompagner */
      return(normfrenchword(word));
      }
   }

if (len > 6) {    /* ---ateur  -->   --er */
      if (word[len]=='r'   && word[len-1]=='u' && word[len-2]=='e' && 
          word[len-3]=='t' && word[len-4]=='a') {
         word[len-4]='e';
         word[len-3]='r';
         word.erase(len-2);   /* administrateur--> administrer */
      return(normfrenchword(word));
      }
   }

if (len > 5) {    /* --trice  -->   --teur */
      if (word[len]=='e'   && word[len-1]=='c' && word[len-2]=='i' && 
          word[len-3]=='r' && word[len-4]=='t') {
         word[len-3]='e';
         word[len-2]='u';
         word[len-1]='r';  /* productrice --> producteur */
         word.erase(len);   /* matrice --> mateur ? */
         len--;
      }
   }

if (len > 4) {    /* --ième  -->   -- */
      if (word[len]=='e' && word[len-1]=='m' && word[len-2]=='è' && 
          word[len-3]=='i') {
         word.erase(len-3);     
      return(normfrenchword(word));
      }
   }

if (len > 6) {    /* ---teuse  -->   ---ter */
      if (word[len]=='e'   && word[len-1]=='s' && word[len-2]=='u' && 
          word[len-3]=='e' && word[len-4]=='t') {
         word[len-2]='r';      
         word.erase(len-1);       /* acheteuse --> acheter */
      return(normfrenchword(word));
      }
   }

if (len > 5) {    /* ---teur  -->   ---ter */
      if (word[len]=='r'   && word[len-1]=='u' && word[len-2]=='e' && 
          word[len-3]=='t') {
         word[len-1]='r';      
         word.erase(len);       /* planteur --> planter */
      return(normfrenchword(word));
      }
   }

if (len > 4) {    /* --euse  -->   --eu- */
      if (word[len]=='e' && word[len-1]=='s' && word[len-2]=='u' && 
          word[len-3]=='e') {
         word.erase(len-1);       /* poreuse --> poreu-,  plieuse --> plieu- */
      return(normfrenchword(word));
      }
   }

if (len > 7) {    /* ------ère  -->   ------er */
      if (word[len]=='e' && word[len-1]=='r' && word[len-2]=='è') {
         word[len-2]='e';
         word[len-1]='r';
         word.erase(len);  /* bijoutière --> bijoutier,  caissière -> caissier */
      return(normfrenchword(word));
      }
   }

if (len > 6) {    /* -----ive  -->   -----if */
      if (word[len]=='e' && word[len-1]=='v' && word[len-2]=='i') {
         word[len-1]='f';   /* but not convive */
         word.erase(len);   /* abrasive --> abrasif */
      return(normfrenchword(word));
      }
   }

if (len > 3) {    /* folle or molle  -->   fou or mou */
      if (word[len]=='e' && word[len-1]=='l' && word[len-2]=='l' && 
          word[len-3]=='o' && (word[len-4]=='f' || word[len-4]=='m')) {
         word[len-2]='u';
         word.erase(len-1);  /* folle --> fou */
      return(normfrenchword(word));
      }
   }

if (len > 8) {    /* ----nnelle  -->   ----n */
      if (word[len]=='e'   && word[len-1]=='l' && word[len-2]=='l' && 
          word[len-3]=='e' && word[len-4]=='n' && word[len-5]=='n') {
         word.erase(len-4);  /* personnelle --> person */
      return(normfrenchword(word));
      }
   }

if (len > 8) {    /* ----nnel  -->   ----n */
      if (word[len]=='l'   && word[len-1]=='e' && word[len-2]=='n' && 
          word[len-3]=='n') {
         word.erase(len-2);  /* personnel --> person */
      return(normfrenchword(word));
      }
   }

if (len > 3) {    /* --ète  -->  et */
      if (word[len]=='e' && word[len-1]=='t' && word[len-2]=='è') {
         word[len-2]='e';  
         word.erase(len);  /* complète --> complet */
         len--;
      }
   }

if (len > 7) {    /* -----ique  -->   */
      if (word[len]=='e' && word[len-1]=='u' && word[len-2]=='q' && 
          word[len-3]=='i') {
         word.erase(len-3);  /* aromatique --> aromat */
         len = len-4;
      }
   }

if (len > 7) {    /* -----esse -->    */
      if (word[len]=='e' && word[len-1]=='s' && word[len-2]=='s' && 
          word[len-3]=='e') {
         word.erase(len-2);    /* faiblesse --> faible */
      return(normfrenchword(word));
      }
   }

if (len > 6) {    /* ---inage -->    */
      if (word[len]=='e' && word[len-1]=='g' && word[len-2]=='a' && 
          word[len-3]=='n' && word[len-4]=='i') {
         word.erase(len-2);  /* patinage --> patin */
      return(normfrenchword(word));
      }
   }

if (len > 8) {    /* ---isation -->   - */
      if (word[len]=='n'   && word[len-1]=='o' && word[len-2]=='i' && 
          word[len-3]=='t' && word[len-4]=='a' && word[len-5]=='s' && 
          word[len-6]=='i') {
         word.erase(len-6);     /* sonorisation --> sonor */
         if (len > 11 && word[len-7]=='l' && word[len-8]=='a' && word[len-9]=='u') 
            word[len-8]='e';  /* ritualisation --> rituel */
      return(normfrenchword(word));
      }
   }

if (len > 8) {    /* ---isateur -->   - */
      if (word[len]=='r'   && word[len-1]=='u' && word[len-2]=='e' && word[len-3]=='t' &&
          word[len-4]=='a' && word[len-5]=='s' && word[len-6]=='i') {
         word.erase(len-6);  /* colonisateur --> colon */
      return(normfrenchword(word));
      }
   }

if (len > 7) {    /* ----ation -->   - */
      if (word[len]=='n'   && word[len-1]=='o' && word[len-2]=='i' && 
          word[len-3]=='t' && word[len-4]=='a') {
         word.erase(len-4);  /* nomination --> nomin */
      return(normfrenchword(word));
      }
   }

if (len > 7) {    /* ----ition -->   - */
      if (word[len]=='n'   && word[len-1]=='o' && word[len-2]=='i' && 
          word[len-3]=='t' && word[len-4]=='i') {
         word.erase(len-4);  /* disposition --> dispos */
      return(normfrenchword(word));
      }
   }

/* various other suffix */
   return(normfrenchword(word));
}

string removeAllFEAccent (string& word)
{ 
int len = word.size()-1;
int i;

   for(i=len; i>=0; i--) {
      if (word[i] == 'â') {
         word[i] = 'a';
         }
      if (word[i] == 'à') {
         word[i] = 'a';
         }
      if (word[i] == 'á') {
         word[i] = 'a';
         }
      if (word[i] == 'ê') {
         word[i] = 'e';
         }
      if (word[i] == 'é') {
         word[i] = 'e';
         }
      if (word[i] == 'è') {
         word[i] = 'e';
         }
      if (word[i] == 'î') {
         word[i] = 'i';
         }
      if (word[i] == 'ù') {
         word[i] = 'u';
         }
      if (word[i] == 'û') {
         word[i] = 'u';
         }
      if (word[i] == 'ô') {
         word[i] = 'o';
         }
      if (word[i] == 'ç') {
         word[i] = 'c';
         }
      }
   return(word);
}

string removeDoublet(string& word)
{ 
int len = word.size()-1;
int i, position;
char currentChar;

if (len > 3) {
   currentChar = word[0];
   position = 1;
   while (word[position]) {
      if (currentChar == word[position]) {
         i = position-1;
         while (word[i] != '\0') {
            word[i] = word[i+1];
            i++;
            }
         }  /* end if */
         else {
            currentChar = word[position];
            position++;
              }
      }  /* end while */
   } /* end if len */
return(word);
}


string normfrenchword(string& word)
{ 
int len = word.size()-1;

   if (len > 3) {
      removeAllFEAccent(word); 
      removeDoublet(word);   
      len = word.size()-1;  
   }

   if (len > 3) {
      if (word[len]=='e' && word[len-1]=='i')
        {word.erase(len-1);len = len -2;}
   }
   if (len > 3) {
      if (word[len]=='r')
        {word.erase(len);len--;}
      if (word[len]=='e')
        {word.erase(len);len--;}
/*    if (word[len]=='é')  */
      if (word[len]=='e')
        {word.erase(len);len--;}
      if (word[len] == word[len-1])
         word.erase(len);
   }
return(word);         
}


