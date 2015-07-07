#!usr/bin/perl
############################################################
#             Created by AIT-TAYEB Tlait                   #
#Ce code nous permet mettre en format texte le resultat    #
# apres l'analyse du tagger                                #
#l'execution se fait comme suit :                          #
#perl taggerToText.pl ../result/AnalyseTager.txt >         #
# ../result/TaggerFinal.txt                                #
############################################################

#ouverture du fichier passé en argument en lecture
open(IN,$ARGV[0]);

#mettre le fichier dans un tableau
@fichier=<IN>;
#recuperer le nombre de ligne du tableau
$taille=@fichier;
$i=0;


while($i<$taille)
{
  @variables=split('\t',$fichier[$i]);
#si on tombe sur notre caractere special qui designe le debut d'un article on saute a une autre ligne
  if($variables[0]=~/optiplextemooz360/|| $variables[0]=~/OPTIPLEXTEMOOZ360/)
  {
    if($i>0)
    {
      print "\n";
    }
  }
  else
  {
    if($variables[2]=~/<unknown>/)
    {
       chomp($variables[0]);
      print $variables[0]." ";
    }
  
    else
    {
       chomp($variables[2]);
       print $variables[2]." ";
    }
  }
  $i++;
}
