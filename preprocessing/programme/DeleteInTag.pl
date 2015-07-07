#!usr/bin/perl
############################################################
#             Created by AIT-TAYEB Tlait                   #
#Ce code nous permet de garder que les informations qu'on  #
# juge essentiels dans un document :                       #
#francais :nom, adjectifs et verbes                        #
#Anglais: NP ,NN,VV                                        #
#Execution perl deleteInTag.pl ../result/tagerResult.txt > #
#../result/AnalyseTager.txt                                #
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


  #Pour texte en francais
	if(@fichier[$i]=~/^.*NOM.*/)
	{
    print $fichier[$i];
    $i++;
	}

	elsif(@fichier[$i]=~/^.*ADJ.*/)
	{
      print $fichier[$i];
      $i++;
  }

  #elsif(@fichier[$i]=~/^.*VER.*/)
  #{
   # print $fichier[$i];
    #$i++;
  #}

  #Pour texte en anglais
  elsif(@fichier[$i]=~/^.*NP.*/)
  {
    print $fichier[$i];
    $i++;
  }
  elsif(@fichier[$i]=~/^.*NN.*/)
  {
    print $fichier[$i];
    $i++;
  }
  elsif(@fichier[$i]=~/^.*VV.*/)
  {
    print $fichier[$i];
    $i++;
  }
  elsif(@fichier[$i]=~/^OPTIPLEXTEMOOZ360.*/i)
  {
    print $fichier[$i];
    $i++;
  }
  # Ici on ignore les ponctuations, adverbes et les proposition
  else
  {
   $i++;
	}

}

close(IN);
