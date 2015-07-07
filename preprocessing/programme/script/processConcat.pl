#!usr/bin/perl

open(IN1,$ARGV[0]);
open(IN2,$ARGV[1]);
#contient le fichier avec les titres
@fichier1=<IN1>;
#contient le corps de chaque test texte
@fichier2=<IN2>;
$taille1=@fichier1;
$taille2=@fichier2;

while($i<$taille1)
{
  chomp($fichier1[$i]);
  print $fichier1[$i]." ".$fichier2[$i]."\n";
  $i++;
}

