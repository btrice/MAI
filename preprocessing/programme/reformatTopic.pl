#!/usr/bin/perl -s
############################################################
#             Created by AIT-TAYEB Tlait                   #
#Ce code nous permet mettre en format xml les recettes en  #
# anglais                                                  #
#l'execution se fait comme suit :                          #
#perl reformatRecipt.pl ../../../data/corpus/RecipeBase.xml#
# >../result/ReciptReformat.xml                            #
############################################################



#ouverture du fichier passé en argument en lecture
open(IN,$ARGV[0]);

#mettre le fichier dans un tableau
@fichier=<IN>;
#recuperer le nombre de ligne du tableau
$taille=@fichier;

print "<?xml version=\"1.0\" encoding=\"iso-8859-1\"?>";
print "\n<DOCSET>";
$ok=0;
while($i<$taille)
{
  if(@fichier[$i]=~/^<num>TPREI-Q.([0-9]+)<\/num>/)
  {
      #La variable num correspond au numero de l'article
      $num=$1;
      if($ok==0){
      print "<DOC>\n";
      print "\n<DOCID>$1<\/DOCID>";
      print "\n<TEXT>\n\n";
     }
   }
    $i++;
        if (@fichier[$i]=~/<title>(.+)<\/title>/)
        {
          print $1."\n";
        }
    $i++;
        if(@fichier[$i]=~/<desc>(.+)<\/desc>/)
        {
          print $1." ";
        }
     $i++;
        if(@fichier[$i]=~/<narr>(.+)<\/narr>/)
        {
          print $1." ";
          print "\n<\/TEXT>\n";
          print "<\/DOC>\n";
       
        }
       
     
  $i++;
}

print "<\/DOCSET>";
