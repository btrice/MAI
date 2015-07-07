/************************************************************************
 *
 * @file       stemmer-savoy1-fre.cpp
 * @author     besancon (besanconr@zoe.cea.fr)
 * @date       Wed May 25 2005
 * @version    $Id$
 *             
 * @brief      simple encapsulation of Jacques Savoy's simple French stemmer
 * 
 ***********************************************************************/

#include <string>
#include <iostream>
#include <fstream>
#include <cstdlib>

using namespace std;

string remove_french_plural(string& word);

string stemWord(string& word) {
  return remove_french_plural(word);
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
// FrenchStemmer by Jacques Savoy
//----------------------------------------------------------------------
// simple french stemming function that removes plural
string  remove_french_plural (string& word)
{ 
int len = word.size()-1;

if (len > 4) {
   if (word[len]=='x') {
      if (word[len-1]=='u' && word[len-2]=='a') {
         word[len-1]='l';
         }
      word[len]='\0';
      return(word);
      }
      else {
         if (word[len]=='s')
            {word.erase(len);len--;}
         if (word[len]=='r')
            {word.erase(len);len--;}
         if (word[len]=='e')
            {word.erase(len);len--;}
         if (word[len]=='é')
            {word.erase(len);len--;}
         if (word[len] == word[len-1])
             word.erase(len);
         }  /* end else */
   } /* end if (len > 4) */ 
return(word);         
}

