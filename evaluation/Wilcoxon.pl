#!/usr/bin/perl -s
#
# Perl Program created by Romaric Besancon on Mon Sep 24 2001
# Version : $Id$ 

# Help mode
if ($main::h || $main::help) {
    print <<EOF;
Test de Wilcoxon pour voir si les résultats d\'un modèle
de RI sont significativement meilleurs que ceux d\'un autre.

usage Wilcoxon.pl [-help] [options] fileref file1 file2

Les options peuvent être :
   -value=.. : sur quelles valeurs on fait le test de Wilcoxon : liste
       de valeurs séparées par des virgules, parmi les suivantes 
       \(map, p5, p10, p15, p20, p30, p100, p200, p500, p1000, relret,
         R_p, r1000), "all" pour toutes (par défaut).
    -latex : sortie dans un tableau au format LaTeX
    -sign : fait le test des signes au lieu du test de Wilcoxon
EOF
    exit;
}

use strict;
no strict 'subs';
no strict 'refs';

die "il faut trois arguments (cf. -help)" unless @ARGV>2;

my $treceval='trec_eval';

my (%valuelabels,%valueGraph,$limit,$insert,
    %ordrevalues,%precision_affiche,
    $querylabel);

%valuelabels = (
    'p5' => 'P5',
    'p10' => 'P10',
    'p15' => 'P15',
    'p20' => 'P20',
    'p30' => 'P30',
    'p100' => 'P100',
    'p200' => 'P200',
    'p500' => 'P500',
    'p1000' => 'P1000',
    'relret' => 'num_rel_ret',
    'avg_p' => 'map',
    'map' => 'map',
    'R_p'=> 'R-prec',
    'r1000' => 'num_rel',
    'interpolated_r0'=>'ircl_prn.0.00',
    'interpolated_r1'=>'ircl_prn.0.10',
    'interpolated_r2'=>'ircl_prn.0.20',
    'interpolated_r3'=>'ircl_prn.0.30',
    'interpolated_r4'=>'ircl_prn.0.40',
    'interpolated_r5'=>'ircl_prn.0.50',
    'interpolated_r6'=>'ircl_prn.0.60',
    'interpolated_r7'=>'ircl_prn.0.70',
    'interpolated_r8'=>'ircl_prn.0.80',
    'interpolated_r9'=>'ircl_prn.0.90',
    'interpolated_r10'=>'ircl_prn.1.00'
    );
$limit=" ";
$insert="[ \t]*[a0-9][^ \t]*";
# le recall à 1000 (r1000) est en fait relret/Relevant, donc relret/r1000

# l'ordre dans lequel on les affiche
%ordrevalues = ('p5' => 3, 'p10' => 4, 'p15' => 5, 'p20' => 6,
    'p30' => 7, 'p100' => 8, 'p200' => 9, 'p500' => 10,
    'p1000' => 11, 'relret' => 12, 'avg_p' => 1, 'R_p'=> 2,
    'r1000' => 13
    );

my %precision_affiche;
# la precision à l'affichage
foreach (keys %valuelabels) {
    $precision_affiche{$_}='%2.3g';
}
$precision_affiche{'relret'}='%4d';

# any line contains query label with trec_eval 7.3: take first
$querylabel = quotemeta("num_ret");

my ($fileref,$file1,$file2) = @ARGV;

# les valeurs à tester
my (@les_valeurs_a_tester);
$main::value='all' unless $main::value;
if ($main::value eq 'all') {
    @les_valeurs_a_tester = sort {$ordrevalues{$a}<=>$ordrevalues{$b}} 
    keys %valuelabels;
}
else {
    @les_valeurs_a_tester = split(',',$main::value);
    # some tests on values
    my $val;
    my ($relret,$relret_percent,$r1000)=(0,0,0);
    foreach $val (@les_valeurs_a_tester) {
        if ($val eq 'relret') { $relret=1; }
        elsif ($val eq 'relret_percent') { $relret_percent=1; }
        elsif ($val eq 'r1000') { $r1000=1; }
    }
    if ($r1000 & ! $relret) {
        push @les_valeurs_a_tester, 'relret';
    }
}

# les values1 et values2 sont des tableaux associatifs qui à chaque
# valeurs (p5,p10,...) associent un tableau (array) des valeurs retournés
# pour chaque requête
my (%values1,%values2,$val);
my (%meanvalues1,%meanvalues2);

&getvalues(\%values1,\%meanvalues1,$file1,\@les_valeurs_a_tester);
&getvalues(\%values2,\%meanvalues2,$file2,\@les_valeurs_a_tester);
# &affiche_values(\%values1);
# &affiche_values(\%values2);

sub affiche_values {
    my ($values)=@_;
    my ($val);
    foreach $val (@les_valeurs_a_tester) {
	print "$val : ".join("|",@{$$values{$val}})."\n";
    }
}

if ($main::latex) {
    #entete latex
}

my ($wilcoxon);
foreach $val (@les_valeurs_a_tester) {
    if ($main::sign) {
	my ($nplus,$nmoins,$n) = &calcule_nplus_nmoins(\@{$values1{$val}},
						       \@{$values2{$val}});
	&affiche_entete($val,$meanvalues1{$val},$meanvalues2{$val});
	$_=&signtest($nplus,$nmoins);
	if ($main::latex) {
	    printf("\$_{p_s=%1.2g\}\$ \\\\ \\hline\n",$_);
	}
	else {
	    print "N+ = $nplus, N- = $nmoins, N = $n, p = $_\n";
	}
    }
    elsif ($main::w1) {
	my ($wplus,$wmoins,$n) = &calcule_wplus_wmoins(\@{$values1{$val}},
						       \@{$values2{$val}});
	&affiche_entete($val,$meanvalues1{$val},$meanvalues2{$val});
	print "W+ = $wplus, W- = $wmoins, N = $n\n";
    }
    else {
	&affiche_entete($val,$meanvalues1{$val},$meanvalues2{$val});
	$_=&wilcoxon1(\@{$values1{$val}},\@{$values2{$val}});
	if ($main::latex) {
	    ($wilcoxon) = /W\+ = *[0-9\.]*, W\- = *[0-9\.]*, N = *[0-9\.]*, p <= *([0-9\.]*)/;
	    printf("\$_{p_w=%1.2g\}\$ \\\\ \\hline\n",$wilcoxon);
	}
	else { print "$_\n"; }
    }
}

# ce qu'on affiche en début de ligne pour chaque valeur
sub affiche_entete {
    my ($la_valeur, $val1, $val2)=@_;
    my ($pourcentage); 
    # pourcentage d'amélioration (sur la valeur moyenne)
    $pourcentage=($val2-$val1)*100;
    if ($val1==0) { $pourcentage/=$val2 if $val2; }
    elsif ($val2==0) { $pourcentage/=$val1; }
    else { $pourcentage/=(($val1>$val2)?$val2:$val1); }
    
    if ($main::latex) {
	$la_valeur =~ s/_/\\_/;
	printf("%s\t& %6.4g & %6.4g & (%+1.3g\\\%)",$la_valeur,
	       $val1,$val2,$pourcentage);
    }
    else {
	printf("%s\t: %6.4g %6.4g %+6.3g\% ",$la_valeur,$val1,$val2,
	       $pourcentage);
    }
}

sub getvalues() {
    my ($values,$meanvalues,$file,$les_values)=@_;
    open(TRECEVAL,"$treceval -q $fileref $file|");
    my (%label);
    foreach $val (@{$les_values}) { 
	$label{$valuelabels{$val}}=$val;
    }
    my ($idquery,$suivante);
    while (<TRECEVAL>) {
	chop; 
	if (/$querylabel[\t ]*([^ \t]*)/o) {
	    $idquery=$1;
	}
        elsif (/^[ \t]*([^$limit]*)$limit$insert[ \t]*([0-9\.]+)/) {
            #print STDERR "--$1--\n";
            if (exists($label{$1})) {
                $val=$label{$1};
                #print STDERR "--store $val=>$2--\n";
                push @{$$values{$val}}, $2;
            }
        }
    }
    close(TRECEVAL);

    foreach $val (@{$les_values}) { 
	# la derniere valeur est la valeur moyenne des autres
	$$meanvalues{$val} = pop @{$$values{$val}}; 
    }

    # correction : ce qui est contenu dans r1000 est en fait le nombre de 
    # documents pertinents
    if (exists($label{$valuelabels{'r1000'}})) {
	my ($i);
	foreach $i (0..$#{$$values{'r1000'}}) {
	    $$values{'r1000'}[$i] = $$values{'relret'}[$i]/$$values{'r1000'}[$i];
	}
	$$meanvalues{'r1000'} = $$meanvalues{'relret'}/$$meanvalues{'r1000'};
    }
}


# mon wilcoxon à moi
sub calcule_wplus_wmoins() {
    my ($val1,$val2) = @_;
    local ($_);
    my (@val,$i,$diff);
    foreach $i (0..$#{$val1}) {
	$diff=$$val1[$i] - $$val2[$i];
	push @val, $diff if $diff ;
    }
    my @sortval = sort { abs($a) <=> abs($b) } @val;
#    print join("\n",@sortval)."\n";
    my ($rank,$sumrank,$meanrank,$n,$val,$pre,@ranks);
    $pre=0; $rank=1; $n=0; $sumrank=$rank;
    foreach $val (@sortval) {
	if (abs($val) ne $pre) { # != ne marche pas !!!!!! 
	    if ($n) {
		print "--[$sumrank]--\n" if $main::showdiff;
		$meanrank=$sumrank/$n;
		foreach (1..$n) { push @ranks, $meanrank; }
		$rank++;
		$sumrank=$rank;
	    }
	    $n=1; 
	}
	else {
	    $n++;
	    $rank++;
	    $sumrank+=$rank;
	}
	$pre=abs($val);
    }
    # le ou les derniers
    if ($n) {
	$meanrank=$sumrank/$n;
	foreach (1..$n) {
	    push @ranks, $meanrank;
	}
    }

    foreach $i (0..$#sortval) {
	print "$sortval[$i] $ranks[$i]\n";
    }
    my ($wplus,$wmoins)=(0,0);
    $n=0;
    foreach $i (0..$#sortval) {
	if ($sortval[$i] > 0) {
	    $wplus += $ranks[$i];
	    $n++;
	}
	elsif ($sortval[$i] < 0) {
	    $wmoins += $ranks[$i];
	    $n++;
	}
    }
    return ($wplus,$wmoins,$n);
}

# nombre de plus et nombre de moins
sub calcule_nplus_nmoins {
    my ($val1,$val2) = @_;
    local ($_);
    my ($i,$diff,$nplus,$nmoins,$n);
    $nplus=0; $nmoins=0; $n=0;
    foreach $i (0..$#{$val1}) {
	$diff=$$val1[$i] - $$val2[$i];
	$nplus++  if ($diff > 0);
	$nmoins++ if ($diff < 0);
	$n++ if $diff;
    }
    return ($nplus,$nmoins,$n);
}

sub signtest {
    my ($nplus,$nmoins)=@_;
    my $commande="SignTest.pl $nplus $nmoins";
#    print "$commande\n";
    return `$commande`;
}

# un programme pour le test de wilcoxon fait par quelqu'un d'autre
sub wilcoxon1() {
    my ($val1,$val2) = @_;
    my $i;
    my $tmpfile="tmp_$$";
    open(FTMP,">$tmpfile") || die "cannot open temporary file $tmpfile";
    foreach $i (0..$#{$val1}) {
	print FTMP $$val1[$i]." ".$$val2[$i]."\n";
    }
    close(FTMP);
    my $commande="SRTest.pl";
    $commande .= " -showdiff" if $main::showdiff;
    $commande .= " $tmpfile";
#    print $commande."\n";
#    return `$commande;`;
    return `$commande; /bin/rm $tmpfile`;
}
