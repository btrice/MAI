#!usr/bin/perl
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

while($i<$taille)
{
  if(@fichier[$i]=~/^<ID>([0-9]*)<\/ID>/)
  {
      #La variable num correspond au numero de l'article
      $num=$1;
      print "\n<DOCID>$1<\/DOCID>";
      print "\n<TEXT>\n\n";
      $ligne=$';
      @valeur=split(/(?<=>)(?=<)/,$ligne);
      foreach $val (@valeur)
      {
        if ($val=~/<TI>(.+)<\/TI>/)
        {
          print $1."\n";
        }

        if($val=~/<IN>(.+)<\/IN>/)
        {
          print $1." ";
        }

        if($val=~/<PR>(.+)<\/PR>/)
        {
          print $1." ";
        }
       
      }
      print "\n<\/TEXT>\n";
      print "<\/DOC>\n";
  }
  $i++;
}

print "<\/DOCSET>";
