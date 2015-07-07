#!usr/bin/perl
#ouverture du fichier en lecture
open(IN,$ARGV[0]);

#mettre le fichier dans un tableau
@fichier=<IN>;
#recuperer le nombre de ligne du tableau
$ARGV[0]=~/(.*\/)?(.*)\.xml/;

open(OUT,">"."../result/Formatage/Content_Stem_".$2.".xml");

$taille=@fichier;

$i=0;
while($i<$taille)
{
		
                if(@fichier[$i]=~/^<TEXT>/)
		{
      			#$i++;
      			$i++;
      			$article="";
		        while(not(@fichier[$i]=~/<\/TEXT>/))
		        {
				      chomp($fichier[$i]);
				      $article=$article." ".$fichier[$i];
				      $i++;
		        }
          #Au debut de chaque article on met une suite de caractere comme ca on pourra separer les articles apres
      		print OUT $article."\n";
	      }
              
  $i++;                    
}

close(IN);
close(OUT1);
close(OUT2);
