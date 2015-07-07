#!usr/bin/perl
############################################################
#             Created by AIT-TAYEB Tlait                   #
#Ce code nous permet de reccupérer le titre ainsi que le   #
# corps de document les tests sont effectuer sur           #
#/data/test/test.xml                                       #
#Le programme prend en argument le nom de fichier          #
#perl reformater.pl ../../../data/test/test.xml            #
# >../result/result.txt                                    #
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

	#on recuppere la ligne ou apparait le titre et on fait un Stemmer de Porter
	if(@fichier[$i]=~/^<DOCID>(TPREI-DOC.)([0-9]*)<\/DOCID>/)
	{
		#La variable num correspond au numero de l'article
		$num=$1.$2;
    print $num." ";
	}


	if(@fichier[$i]=~/^<TEXT>/)
	{
      $i++;
      #$ligne=@fichier[$i];
      $i++;
      $article="";
      while(not(@fichier[$i]=~/<\/TEXT>/))
      {
        #print chomp($fichier[$i]);
        chomp($fichier[$i]);
        $article=$article." ".$fichier[$i];
        $i++;
      }
      print $article."\n";
	}
  $i++;

}

close(IN);
