#!/bin/sh
if [ -z "$4" ]; then
  echo "Vous devez mettre un premier argument en ou fr suivi de votre fichier xml et du fichier contenant les requetes suivi des champs  de la requetes qu'on veut reccuperer "
  echo "Utilisation :"
  echo "$0 en|fr [fichier xml a analyser ] [requetes] [n|t|d]"
  exit 0;
fi

if [ ! -e "$2" ]; then
  echo "$2 n'existe pas"
  echo "Vous devez mettre en argument le fichier xml"
  echo "Utilisation :"
  echo "$0 en|fr [fichier xml a analyser ][requetes] [n|t|d]"
  exit 0;
fi

if [ ! -e "$3" ]; then
  echo "$3 n'existe pas"
  echo "Vous devez mettre en argument le fichier contenant l'nsemble des requetes"
  echo "Utilisation :"
  echo "$0 en|fr [fichier xml a analyser ][requetes] [n|t|d]"
  exit 0;
fi

# Creation des fichiers si ils n'existent pas
if [ ! -e "../result/Formatage" ]; then
  mkdir -p ../result/Formatage
fi

if [ ! -e "../result/Tokenizer" ]; then
  mkdir -p ../result/Tokenizer
fi

if [ ! -e "../result/Tagger" ]; then
  mkdir -p ../result/Tagger
fi

if [ ! -e "../result/Article" ]; then
  mkdir -p ../result/Article
fi
if [ ! -e "../result/Index" ]; then
  mkdir -p ../result/Index
fi
if [ ! -e "../result/Stemmer" ]; then
  mkdir -p ../result/Stemmer
fi
if [ ! -e "../../evaluation/Results" ]; then
  mkdir -p ../../evaluation/Results
fi

nomCorpus=`echo "$2" | grep -o "[^/]*\.xml"`
nomArticle=`echo "$3" | grep -o "[^/]*\.xml"`

echo "$nomCorpus"

#Initialisation de l'environement
cd ../../../
source TP_MAI.env
cd sources/preprocessing/
#make install
cd programme
case $1 in
#./run.sh fr ../../../data/corpus/corpus.xml

#Pre-traitement des documents en francais

#./testrun.sh fr ../../../data/corpus/corpus.xml ../../../data/corpus/topics.xml 
fr)

                #pre-traitement de corpus 
  #En utilisant tagger en filtrant que les nom et adjectifs 
  echo " #####SCENARIO1##### "
  perl processFormatage.pl $2  
  echo "#####Application du tokenizer pour le corpus#####"
  tokenizer.pl ../result/Formatage/Content_$nomCorpus > ../result/Tokenizer/textTokenized.txt  
  echo "#####Application du tagger pour les corpus#####"
  tree-tagger-french ../result/Tokenizer/textTokenized.txt > ../result/Tagger/textTagger.txt
  echo "#####Reccuperation des noms et adjectives du corpus#####"
  perl DeleteInTag.pl ../result/Tagger/textTagger.txt  >../result/Tagger/TagDeleted.txt 
  perl taggerToText.pl ../result/Tagger/TagDeleted.txt  > ../result/Article/ArticleAnalysedC.txt

  echo "\#####Construction du fichier final#####"
  perl concat.pl ../result/Formatage/Titre_$nomCorpus ../result/Article/ArticleAnalysedC.txt > ../result/Article/final_$nomCorpus 
  
  #En utilisant le stemmer de savoy1
  echo "#####SCENARIO2#####"
  perl processFormatageStem.pl $2
  echo "#####Application du stemmer Savoy1 pour le corpus#####"
  stemmer-savoy1-fre ../result/Formatage/Content_Stem_$nomCorpus > ../result/Stemmer/stemmer_$nomCorpus
  perl concat.pl ../result/Formatage/Titre_$nomCorpus ../result/Stemmer/stemmer_$nomCorpus > ../result/Article/final_Stem_$nomCorpus 

                #pre-traitement des requetes
  #En utilisant tagger en filtrant que les nom et adjectifs
 
  echo "#####Reformater les requetes :reccuperation de tous les champs#####"
  reformat.pl -$4 $3  > ../result/Formatage/topics.xml

  perl processFormatage.pl  ../result/Formatage/topics.xml
  echo "#####Application de tokenizer pour les requetes#####"
  tokenizer.pl ../result/Formatage/Content_$nomArticle > ../result/Tokenizer/textTokenizedT.txt

  echo "#####Application du tagger pour les requetes#####"
  tree-tagger-french ../result/Tokenizer/textTokenizedT.txt > ../result/Tagger/textTaggerT.txt
  echo "#####Reccuperation des noms et adjectives des requetes#####"
  perl DeleteInTag.pl ../result/Tagger/textTaggerT.txt  >../result/Tagger/TagDeletedT.txt 
  perl taggerToText.pl ../result/Tagger/TagDeletedT.txt  > ../result/Article/TopicsAnalysed.txt
  echo "#####Construction du fichier final#####"
  perl concat.pl ../result/Formatage/Titre_$nomArticle ../result/Article/TopicsAnalysed.txt > ../result/Article/final_$nomArticle 

  #En utilisant le stemmer de savoy1

  echo "#####Application du stemmer Savoy1 pour les requetes.xml"
  perl processFormatageStem.pl ../result/Formatage/topics.xml
  stemmer-savoy1-fre ../result/Formatage/Content_Stem_$nomArticle > ../result/Stemmer/stemmer_$nomArticle
  perl concat.pl ../result/Formatage/Titre_$nomArticle ../result/Stemmer/stemmer_$nomArticle > ../result/Article/final_Stem_$nomArticle   

  #Moteur de recherche
  
  #Suppression des Index
  rm -f ../result/Index/indexTag
  rm -f ../result/Index/indexStem
  #indexer le fichier du premier pre-traitement
  echo "#####Indexage du fichier correspondant au premier scenario :Tagger#####"
  indexer.sh ../result/Index/indexTag ../result/Article/final_$nomCorpus
  #indexer le fichier du deuxieme pre-traitement
  echo "#####Indexage du fichier correspondant au deuxieme scenario : Stemmer savoy-1#####"
  indexer.sh ../result/Index/indexStem ../result/Article/final_Stem_$nomCorpus

  echo "#####Lancement du moteur de recherche#####"
  echo "#####Schema de penderation Lnu.ltc#####"
  searchengine.sh  ../result/Index/indexTag ../result/Article/final_$nomArticle Lnu.ltc 1991
  searchengine.sh  ../result/Index/indexStem ../result/Article/final_Stem_$nomArticle Lnu.ltc 1993


  echo "#####Schema de penderation npc.ltu#####"
  searchengine.sh  ../result/Index/indexTag ../result/Article/final_$nomArticle npc.ltu 1
  searchengine.sh  ../result/Index/indexStem ../result/Article/final_Stem_$nomArticle npc.ltu 2

  echo "#####Schema de penderation btn.npn #####"
  searchengine.sh  ../result/Index/indexTag ../result/Article/final_$nomArticle btn.npn 3
  searchengine.sh  ../result/Index/indexStem ../result/Article/final_Stem_$nomArticle btn.npn 4

  #Evaluation
  cd ../../evaluation/
  echo "#####Installation de l'environement d'evaluation#####"
#  make install 
  echo "#####Resultats d'evaluation avec comme schema de ponderation Lnu.ltc #####"

  trec_eval ../../data/assessments/qrels ../preprocessing/programme/1991 > Results/resultTag_Lnu_ltc.eval
  trec_eval ../../data/assessments/qrels ../preprocessing/programme/1993 > Results/resultStem_Lnu_ltc.eval

  echo "#####Resultats d'evaluation avec comme schema de ponderation npc.ltu #####"

  trec_eval ../../data/assessments/qrels ../preprocessing/programme/1 > Results/resultTag_npc_ltu.eval
  trec_eval ../../data/assessments/qrels ../preprocessing/programme/2 > Results/resultStem_npc_ltu.eval

  echo "#####Resultats d'evaluation avec comme schema de ponderation btn.npn #####"

  trec_eval ../../data/assessments/qrels ../preprocessing/programme/3 > Results/resultTag_btn_npn.eval
  trec_eval ../../data/assessments/qrels ../preprocessing/programme/4 > Results/resultStem_btn_npn.eval

  echo "it's draw time's :p"
  #Interpretation du resultat

  echo "Graphique de stemmmer de tree-tagger avec les differents schema de ponderation"
  echo "ireval.pl Results/resultTag_Lnu_ltc.eval Results/resultTag_npc_ltu.eval Results/resultTag_btn_npn.eval"
  #ireval.pl  Results/resultStem.eval #> figure2.png
  echo "Graphique de stemmmer de savoy avec les differents schema de ponderation"
  echo "ireval.pl Results/resultStem_Lnu_ltc.eval Results/resultStem_npc_ltu.eval Results/resultStem_btn_npn.eval"
;;
#./run.sh fr ../../../data/corpus/RecipeBase.xml

en)
#./testrun.sh en ../../../data/corpus/RecipeBase.xml ../../../data/corpus/topics_recipe.xml

  echo "#####SCENARIO1##### "
  echo "#####Application du tokenizer pour le corpus des recettes#####"
  perl reformatRecipt.pl $2 > ../result/Formatage/RecipeBase.xml
  perl processFormatage.pl ../result/Formatage/RecipeBase.xml

  tokenizer.pl ../result/Formatage/Content_$nomCorpus > ../result/Tokenizer/textTokenizedAng.txt
  echo "#####Application du tagger pour les corpus des recettes##### "
  tree-tagger-english ../result/Tokenizer/textTokenizedAng.txt > ../result/Tagger/textTaggerAng.txt
  echo "#####Reccuperation des NP NN VV des recettes #####"
  perl DeleteInTag.pl ../result/Tagger/textTaggerAng.txt  >../result/Tagger/TagDeletedAng.txt 
  perl taggerToText.pl ../result/Tagger/TagDeletedAng.txt  > ../result/Article/ArticleAnalysedAng.txt

  perl concat.pl ../result/Formatage/Titre_$nomCorpus ../result/Article/ArticleAnalysedAng.txt > ../result/Article/final_$nomCorpus


  #En utilisant le stemmer de porter
  echo "#####SCENARIO2#####"
  perl processFormatageStem.pl ../result/Formatage/RecipeBase.xml
  echo "#####Application du stemmer Savoy1 pour le corpus des recettes #####"
  stemmer-porter-eng ../result/Formatage/Content_Stem_$nomCorpus > ../result/Stemmer/stemmer_$nomCorpus
  perl concat.pl ../result/Formatage/Titre_$nomCorpus ../result/Stemmer/stemmer_$nomCorpus > ../result/Article/final_Stem_$nomCorpus 


                #pre-traitement des requetes
  #En utilisant tagger en filtrant que les NP NN VV
 
  echo "#####Reformater les requetes :reccuperation de tous les champs#####"
  reformat.pl -$4 $3  > ../result/Formatage/topics_recipe.xml

  perl processFormatage.pl  ../result/Formatage/topics_recipe.xml
  echo "#####Application de tokenizer pour les requetes#####"
  tokenizer.pl ../result/Formatage/Content_$nomArticle > ../result/Tokenizer/textTokenizedRecip.txt

  echo "#####Application du tagger pour les requetes#####"
  tree-tagger-english ../result/Tokenizer/textTokenizedRecip.txt > ../result/Tagger/textTaggerRecip.txt
  echo "#####Reccuperation des NP NN VV des requetes de recettes #####"
  perl DeleteInTag.pl ../result/Tagger/textTaggerRecip.txt  >../result/Tagger/TagDeletedRecip.txt 
  perl taggerToText.pl ../result/Tagger/TagDeletedRecip.txt  > ../result/Article/TopicsAnalysedRecip.txt
  echo "#####Construction du fichier final#####"
  perl concat.pl ../result/Formatage/Titre_$nomArticle ../result/Article/TopicsAnalysedRecip.txt > ../result/Article/final_$nomArticle 

  #En utilisant le stemmer de porter

  echo "#####Application du stemmer Savoy1 pour les requetes.xml"
  perl processFormatageStem.pl ../result/Formatage/topics_recipe.xml
  stemmer-porter-eng ../result/Formatage/Content_Stem_$nomArticle > ../result/Stemmer/stemmer_$nomArticle
  perl concat.pl ../result/Formatage/Titre_$nomArticle ../result/Stemmer/stemmer_$nomArticle > ../result/Article/final_Stem_$nomArticle   

  #Moteur de recherche
  
  #Suppression des Index
  rm -f ../result/Index/indexTagAng
  rm -f ../result/Index/indexStemAng
  #indexer le fichier du premier pre-traitement
  echo "#####Indexage du fichier correspondant au premier scenario :Tagger#####"
  indexer.sh ../result/Index/indexTagAng ../result/Article/final_$nomCorpus
  #indexer le fichier du deuxieme pre-traitement
  echo "#####Indexage du fichier correspondant au deuxieme scenario : Stemmer savoy-1#####"
  indexer.sh ../result/Index/indexStemAng ../result/Article/final_Stem_$nomCorpus

  echo "#####Lancement du moteur de recherche#####"
  echo "#####Schema de penderation Lnu.ltc#####"
  searchengine.sh  ../result/Index/indexTagAng ../result/Article/final_$nomArticle Lnu.ltc 2000
  searchengine.sh  ../result/Index/indexStemAng ../result/Article/final_Stem_$nomArticle Lnu.ltc 2001


  echo "#####Schema de penderation npc.ltu#####"
  searchengine.sh  ../result/Index/indexTagAng ../result/Article/final_$nomArticle npc.ltu 2002
  searchengine.sh  ../result/Index/indexStemAng ../result/Article/final_Stem_$nomArticle npc.ltu 2003

  echo "#####Schema de penderation btn.npn #####"
  searchengine.sh  ../result/Index/indexTagAng ../result/Article/final_$nomArticle btn.npn 2004
  searchengine.sh  ../result/Index/indexStemAng ../result/Article/final_Stem_$nomArticle btn.npn 2005

  #Evaluation
  cd ../../evaluation/
  echo "#####Installation de l'environement d'evaluation#####"
#  make install 
  echo "#####Resultats d'evaluation avec comme schema de ponderation Lnu.ltc #####"

  trec_eval ../../data/assessments/qrlsAng ../preprocessing/programme/2000 > Results/resultTagAng_Lnu_ltc.eval
  trec_eval ../../data/assessments/qrlsAng ../preprocessing/programme/2001 > Results/resultStemAng_Lnu_ltc.eval

  echo "#####Resultats d'evaluation avec comme schema de ponderation npc.ltu #####"

  trec_eval ../../data/assessments/qrlsAng ../preprocessing/programme/2002 > Results/resultTagAng_npc_ltu.eval
  trec_eval ../../data/assessments/qrlsAng ../preprocessing/programme/2003 > Results/resultStemAng_npc_ltu.eval

  echo "#####Resultats d'evaluation avec comme schema de ponderation btn.npn #####"

  trec_eval ../../data/assessments/qrlsAng ../preprocessing/programme/2004 > Results/resultTagAng_btn_npn.eval
  trec_eval ../../data/assessments/qrlsAng ../preprocessing/programme/2005 > Results/resultStemAng_btn_npn.eval

  echo "it's draw time's :p"
  #Interpretation du resultat

  echo "Graphique de stemmmer de tree-tagger avec les differents schema de ponderation"
  echo "ireval.pl Results/resultTagAng_Lnu_ltc.eval Results/resultTagAng_npc_ltu.eval Results/resultTagAng_btn_npn.eval"
  #ireval.pl  Results/resultStem.eval #> figure2.png
  echo "Graphique de stemmmer de savoy avec les differents schema de ponderation"
  echo "ireval.pl Results/resultStemAng_Lnu_ltc.eval Results/resultStemAng_npc_ltu.eval Results/resultStemAng_btn_npn.eval"
;;

*)
  echo "Utilisation :"
  echo "$0 en|fr [fichier xml a analyser ] [requetes] [n|t|d]"
;;
esac
