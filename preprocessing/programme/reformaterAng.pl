#!usr/bin/perl
#ouverture du fichier en lecture
open(IN,$ARGV[0]);

#mettre le fichier dans un tableau
@fichier=<IN>;
#recuperer le nombre de ligne du tableau
$taille=@fichier;
#$taille=10;
$i=3;
while($i<$taille)
{

	#on recuppere la ligne ou apparait le titre et on fait un Stemmer de Porter
       
		if(@fichier[$i]=~/^<ID>([0-9]*)<\/ID>/)
		{
		        $val=0;
			#La variable num correspond au numero de l'article
			$num=$1;
	    		print $num." ";
                        $ligne=$';
                       # print " AVANT SPLIT $ligne\n\n";
                       # print " FIN LIGNE \n\n";
        		@valeur=split(/(?<=>)(?=<)/,$ligne);
                        # print " APRES SPLIT\n\n";
                        foreach $val (@valeur){ 
                               if ($val=~/<TI>(.+)<\/TI>/)
                                 {
				  print $1." ";
                                 }
				 if($val=~/<IN>(.+)<\/IN>/)
                                 {
				  print $1." ";
                                 }   
                                 if($val=~/<PR>(.+)<\/PR>/)
                                 {
				  print $1." ";
                                 }
				 #if($val=~/<RECIPE>(.+)<\/RECIPE>/)
                                 #{
				 # print "$1\n";
                                 #}       
                        }
		    print "\n*******************************************\n";
		}
               
                
  $i++;
}

close(IN);
