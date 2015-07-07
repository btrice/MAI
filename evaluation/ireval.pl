#!/usr/bin/perl -s
#
# Perl Program created by Romaric Besancon on Fri Sep 28 2001
# modified Jul 2005 to integrate compatibility with trec_eval 7.3
# Version : $Id$ 

# Help mode
if ($main::h || $main::help) {
    print <<EOF;
Pour évaluer les résultats d\'un ou plusieurs systèmes de 
Recherche Documentaire
usage ireval.pl [-help] [options] fichier1 fichier2 ...
Les fichiers sont des fichiers de sortie de trec_eval.
Les options possibles sont :
  -best donne le meilleur resultat parmi les fichiers passes 
        en parametres 
  -text sort le tableau de comparaison au format text
  -latex sort le tableau de comparaison au format latex
  -csv sort le tableau de comparaison au format CSV
  -value=.. les valeurs à tester pour -best ou -text
  -values  affiche la liste des valeurs possibles pour l\'option -value

  sinon, dessine les graphiques Precision/Recall   
  -predoc dessine le graphique Precision/Documents
  -eps    sortie d\'un fichier eps genere par gnuplot sur stdout    

  on peut aussi passer en argument le fichier résultat et le fichier
  de référence (qrels) pour voir les résultats requête par requête

  -qrels=.. fichier de référence
  -idquery=.. les requêtes à prendre en compte \("all" pour toutes\)

EOF
    exit;
}

$main::trec_eval_version="7.3" unless $main::trec_eval_version;

#----------------------------------------------------------------------
# pour gnuplot
my %gnuplot_setparam=();
my %gnuplot_plotparam=();
# my $com_gnuplot="/tmp/gnuplot.$$.gp";
# my $data_gnuplot="/tmp/gp_gnuplot.$$";
my $com_gnuplot="/tmp/gnuplot.$$.gp";
my $data_gnuplot="/tmp/gp_gnuplot.$$";
system("/bin/rm/ $com_gnuplot") if (-e $com_gnuplot);
# numeros de fichiers pour les fichiers de donnees 
my $gpnum=0;
#style
my $gpstyle='with linespoints';
# pour distinguer entre plot et replot
my $gpplot='plot';
#----------------------------------------------------------------------


use strict;
no strict 'subs';

my (%valuelabels,%valueGraph,$limit,$insert,
    %ordrevalues,%precision_affiche,%nextline,
    $querylabel);

%valueGraph=('p5' => '5',
             'p10' => '10',
             'p15' => '15',
             'p20' => '20',
             'p30' => '30',
             'p100' => '100',
             'p200' => '200',
             'p500' => '500',
             'p1000' => '1000',
             'interpolated_r0'=>'0.00',
             'interpolated_r1'=>'0.10',
             'interpolated_r2'=>'0.20',
             'interpolated_r3'=>'0.30',
             'interpolated_r4'=>'0.40',
             'interpolated_r5'=>'0.50',
             'interpolated_r6'=>'0.60',
             'interpolated_r7'=>'0.70',
             'interpolated_r8'=>'0.80',
             'interpolated_r9'=>'0.90',
             'interpolated_r10'=>'1.00'
             );

# programmes (utilisés pour -idquery)
my ($treceval,$zcat,$gunzip);
$zcat='/usr/local/bin/zcat';
$gunzip='/usr/local/bin/gunzip';

if ($main::trec_eval_version eq "7.3") {
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
                    'p1000' => 11, 'relret' => 12, 'map' => 1, 'R_p'=> 2,
                    'r1000' => 13
                    );
    # la precision à l'affichage
    foreach (keys %valuelabels) {
        $precision_affiche{$_}='%2.3g';
    }
    $precision_affiche{'relret'}='%4d';
    
    # ceux pour lesquels l'information est sur la ligne suivante
    %nextline = ();
    
    # any line contains query label with trec_eval 7.3: take first
    $querylabel = quotemeta("num_ret");
    $treceval="trec_eval";
}
else {
    %valuelabels = (
                    'p5' => 'At    5 docs',
                    'p10' => 'At   10 docs',
                    'p15' => 'At   15 docs',
                    'p20' => 'At   20 docs',
                    'p30' => 'At   30 docs',
                    'p100' => 'At  100 docs',
                    'p200' => 'At  200 docs',
                    'p500' => 'At  500 docs',
                    'p1000' => 'At 1000 docs',
                    'relret' => 'Rel_ret',
                    'map' => 'Average precision (non-interpolated) over all rel docs',
                    'R_p'=> 'Exact',
                    'r1000' => 'Relevant',
                    'interpolated_r0'=>'at 0.00',
                    'interpolated_r1'=>'at 0.10',
                    'interpolated_r2'=>'at 0.20',
                    'interpolated_r3'=>'at 0.30',
                    'interpolated_r4'=>'at 0.40',
                    'interpolated_r5'=>'at 0.50',
                    'interpolated_r6'=>'at 0.60',
                    'interpolated_r7'=>'at 0.70',
                    'interpolated_r8'=>'at 0.80',
                    'interpolated_r9'=>'at 0.90',
                    'interpolated_r10'=>'at 1.00'
                    );
    $limit=quotemeta(":");
    $insert="";
    # le recall à 1000 (r1000) est en fait relret/Relevant, donc relret/r1000
    
    # l'ordre dans lequel on les affiche
    %ordrevalues = ('p5' => 3, 'p10' => 4, 'p15' => 5, 'p20' => 6,
                    'p30' => 7, 'p100' => 8, 'p200' => 9, 'p500' => 10,
                    'p1000' => 11, 'relret' => 12, 'map' => 1, 'R_p'=> 2,
                    'r1000' => 13
                    );
    # la precision à l'affichage
    foreach (keys %valuelabels) {
        $precision_affiche{$_}='%2.3g';
    }
    $precision_affiche{'relret'}='%4d';
    
    # ceux pour lesquels l'information est sur la ligne suivante
    %nextline = ('map' => 1);
    
    $querylabel = quotemeta("Queryid (Num):");
    $treceval="/home/romaric/bin/trec_eval.old";
}

# help for -value option
if ($main::values) {
    my %valueComments=(
		       'p5' => 'precision at 5 docs',
		       'p10' => 'precision at 10 docs',
		       'p15' => 'precision at 15 docs',
		       'p20' => 'precision at 20 docs',
		       'p30' => 'precision at 30 docs',
		       'p100' => 'precision at 100 docs',
		       'p200' => 'precision at 200 docs',
		       'p500' => 'precision at 500 docs',
		       'p1000' => 'precision at 1000 docs',
		       'relret' => 'number of relevant document retrieved',
		       'map' => 'mean average precision (non interpolated)',
		       'R_p'=> 'R-precision',
		       'r1000' => 'recall at 1000 docs',
		       'interpolated_r0'=>'interpolated precision at recall 0.0',
		       'interpolated_r1'=>'interpolated precision at recall 0.1',
		       'interpolated_r2'=>'interpolated precision at recall 0.2',
		       'interpolated_r3'=>'interpolated precision at recall 0.3',
		       'interpolated_r4'=>'interpolated precision at recall 0.4',
		       'interpolated_r5'=>'interpolated precision at recall 0.5',
		       'interpolated_r6'=>'interpolated precision at recall 0.6',
		       'interpolated_r7'=>'interpolated precision at recall 0.7',
		       'interpolated_r8'=>'interpolated precision at recall 0.8',
		       'interpolated_r9'=>'interpolated precision at recall 0.9',
		       'interpolated_r10'=>'interpolated precision at recall 1.0'
		       );
    my $val;
    foreach $val (sort keys %valueComments) {
	print $val.":\t".($valueComments{$val})."\n";
    }
    exit;
}

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

#print "--[valeurs=".join("|",@les_valeurs_a_tester)."]--\n";

my (@Files);

my $fileref=$main::qrels; # fichier de référence (si besoin de recalculer)

# pour l'option -idquery=.. résultats par requête
my $tmpqueryeval="/tmp/query";

# files to treat
@Files=@ARGV;

# pas deux fois le meme resultat
sub nosame {
    my (@files)=@_;
    my ($fn,$f,$g, @newfiles,$new);
    local ($_);
    while (@files) {
	$_=shift @files; 
	/(.*):(.*)/; $fn=$1; $f=$2;
	$new=1;
	foreach (@files) {
	    /.*:(.*)/; $g=$1;
	    if ($f eq $g) {
		$new=0; last;
	    }
	}
	push @newfiles, $fn if $new;
    }
    return @newfiles;
}

# est-ce qu'on regarde les requêtes une par une
if ($main::idquery) {
    die "need a reference file..." unless $main::qrels;
    # on cherche les résultats par requête
    # les fichiers passés en paramètres sont les fichiers résultats de DSIR
    my (@idquery,%Query_id);
    my ($id,$file,$topfile,@queryfiles);
#     if (@idquery>8) {
# 	print STDERR "two much queries, keeping only 8\n";
# 	splice(@idquery,7,$#idquery-7);
#     }
    if ($main::idquery eq 'all') {  $Query_id{'all'}=1; }
    else {
	@idquery = split(',',$main::idquery);
	foreach (@idquery) { $Query_id{$_}=1; }
    }
    foreach $file (@Files) {
	if ($file =~ /\.top/) {
	    $topfile=$file;
	    if ($topfile =~ /\.gz/) {
		system("$gunzip $topfile");
		$topfile =~ s/\.gz//;
	    }
	}
	else {
# 	    $topfile=&cree_topfile($file);
	    $topfile=$file;
	}
	push @queryfiles, &cree_queryeval($topfile,$fileref,\%Query_id);
    }
    if ($main::idquery eq 'all') {
	foreach $id (sort {$a<=>$b} keys %Query_id) { 
#	    print "--[id=$id]--\n";
	    @Files = grep { /query\_$id\_/; } @queryfiles;
#	    print "--[".join("|",@Files)."]--\n";
	    &traitement_principal(@Files);
	}
    }
    else {
	foreach $id (@idquery) { 
	    @Files = grep { /query\_$id\_/; } @queryfiles;
	    &traitement_principal(@Files);
	}
    }
    exit;
}

&traitement_principal(@Files);

sub traitement_principal {
    my (@Files)=@_;
    if ($main::best) { # les meilleurs resultats
	&affiche_best(@Files);
    }
    elsif ($main::latex) { # les resultats dans un tableau latex
	&affiche_latex(@Files);
    }
    elsif ($main::text) { # les resultats dans un tableau texte
	&affiche_text(@Files);
    }
    elsif ($main::csv) { # les resultats dans une feuille csv (pour import tableur)
	&affiche_csv(@Files);
    }
    else {
	print STDERR join("\n",@Files)."\n";
	&affiche_graphique(@Files);
    }
    
}

# affiche les résultats triés du meilleur au moins bon
sub affiche_best {
    my (@Files)=@_;
    my (%values,%entetes);
    &stocke_results(\@Files,\%values,\%entetes,\@les_valeurs_a_tester);

    my ($val);
    foreach $val (@les_valeurs_a_tester) {
        print "Resultats dans l'ordre de $val:\n";

        print join "\n", map {$_="${$values{$val}}{$_} $_"} 
        sort {${$values{$val}}{$b} <=> ${$values{$val}}{$a}} 
        keys %{$values{$val}};
        print "\n";
        
	#foreach $file (sort keys %{$values{$val}}) {
	#    print "$val $file $$values{$val}{$file}\n";
	#}
    }
}

#graphiques d'un ou plusieurs resultat
sub affiche_graphique {
    my (@Files)=@_;
    my (%values,%entetes);
    undef @les_valeurs_a_tester;
    if ($main::predoc) {
        push @les_valeurs_a_tester,
        'p5','p10','p15','p20','p30','p100','p200','p500','p1000';
    }
    else {
        push @les_valeurs_a_tester,
        'interpolated_r0','interpolated_r1','interpolated_r2',
        'interpolated_r3','interpolated_r4','interpolated_r5',
        'interpolated_r6','interpolated_r7','interpolated_r8',
        'interpolated_r9','interpolated_r10';
    }
    &stocke_results(\@Files,\%values,\%entetes,\@les_valeurs_a_tester);
    &affiche_results_graphique(\@Files,\%values,\@les_valeurs_a_tester);
}

sub affiche_results_graphique {
    my ($Files,$values,$les_values)=@_;
    local $_;

    # paramètres de gnuplot
    if ($main::eps) {
	&gnuplot_setparam('term','postscript eps');
    }
    &gnuplot_setparam('grid');
    &gnuplot_setparam('yrange','[0:1]');
    &gnuplot_setparam('ylabel','"Precision"');
    &gnuplot_setparam('xlabel','"Recall"');
    
    if ($main::predoc) {
	# 250 documents retournés par le système
	&gnuplot_setparam('xrange','[0:250]');
	&gnuplot_setparam('xlabel','"Nb documents"');
    }
    
    &gnuplot_plot('plot');
    &gnuplot_range('[0:1][0:1]');
    &gnuplot_title('');
    &gnuplot_style('with linespoints');
    
    &gnuplot_open_commande();
    &gnuplot_open_data();
    
    my ($file,$val);
    foreach $file (@{$Files}) {
        &gnuplot_title($file);
        foreach $val (@{$les_values}) {
            #print STDERR "--[$val]--\n";
            &gnuplot_print_data($valueGraph{$val}." ".
                                $$values{$val}{$file}."\n");
        }
  	&gnuplot_print_commande();
  	&gnuplot_new_data();
  	&gnuplot_plot(', ');
    }

#     foreach $i (0..$#Files) {
# 	$file=$Files[$i];
# #	print "--[$file]--\n";
# 	if (!open(FIN, $file)) {
# 	    print STDERR "Cannot open file $file... Ignored\n"; next; }
# 	$premier=1;
# 	while (<FIN>) {
# 	    if ($premier) {
# 		$_=$file."\n";  #\n parce qu'on chop derriere
# 		&gnuplot_title(&entete($_,$file));
# 		$premier=0;
# 	    }
# 	    if ($main::predoc) {
# 		if (/^[ \t]*At[ \t]*([0-9]*) docs:[ \t\|]*([0-9\.]*)/) {
# 		    &gnuplot_print_data("$1 $2\n");
# 		}
# 	    }
# 	    elsif (/^[ \t]*at[ \t]*([0-9\.]*)[ \t\|]*([0-9\.]*)/) {
# 		&gnuplot_print_data("$1 $2\n");
# 	    }
# 	}
# 	close(FIN);
# 	&gnuplot_print_commande();
# 	&gnuplot_new_data();
# #	&gnuplot_plot('replot');
# 	&gnuplot_plot(', ');
#     }
    
    &gnuplot_close_commande();
    &gnuplot_draw();
    &gnuplot_clean() unless $main::noclean;
}

sub affiche_latex {
    my (@Files)=@_;
    my (%values,%entetes);
    &stocke_results(\@Files,\%values,\%entetes,\@les_valeurs_a_tester);
#    &affiche_results(\%values,\@les_valeurs_a_tester);
    &affiche_results_latex(\@Files,\%values,\%entetes,\@les_valeurs_a_tester);
}

sub affiche_text {
    my (@Files)=@_;
    my (%values,%entetes);
    &stocke_results(\@Files,\%values,\%entetes,\@les_valeurs_a_tester);
    &affiche_results_text(\@Files,\%values,\%entetes,\@les_valeurs_a_tester);
}

sub affiche_csv {
    my (@Files)=@_;
    my (%values,%entetes);
    undef @les_valeurs_a_tester;
    if ($main::predoc) {
        push @les_valeurs_a_tester,
        'p5','p10','p15','p20','p30','p100','p200','p500','p1000';
    }
    else {
        push @les_valeurs_a_tester,
        'interpolated_r0','interpolated_r1','interpolated_r2',
        'interpolated_r3','interpolated_r4','interpolated_r5',
        'interpolated_r6','interpolated_r7','interpolated_r8',
        'interpolated_r9','interpolated_r10';
    }
    &stocke_results(\@Files,\%values,\%entetes,\@les_valeurs_a_tester);
    &affiche_graphique_csv(\@Files,\%values,\@les_valeurs_a_tester);
}


# stocke les résultats dans un  tableau associatif qui à chaque
# valeurs (p5,p10,...) associent un tableau associatif des valeurs retournés
# pour chaque fichier
sub stocke_results {
    my ($Files,$values,$entetes,$les_values)=@_;
    my ($file);
    my (%label,$nextline,$val);
    my ($idquery,$suivante,$nbrel);
    
    # les valeurs qu'on garde (toutes par défaut)
    foreach $val (@{$les_values}) { 
	$label{$valuelabels{$val}}=$val;
	$nextline = $nextline{$val} unless $nextline;
    }
#     print "--[val=$val]--\n";
#     print "--[label=".join("|",values %label)."]--\n";
#     print "--[nextline=$nextline]--\n";
    
    foreach $file (@{$Files}) {
	if (!open(FIN, $file)) {
	    warn "Cannot open file $file... Ignored\n"; next; }
	while (<FIN>) {
	    chop; 
	    if (! exists $$entetes{$file}) {
		$$entetes{$file}=&entete($_,$file); 
	    }
	    if (/$querylabel[\t ]*([^ \t]*)/o) {
		$idquery=$1;
	    }
	    if ($nextline && exists($label{$_})) {
		$val=$label{$_};
		$suivante=1;
	    }
	    elsif ($nextline && $suivante && /([0-9\.]+)/) {
		$$values{$val}{$file} = $1; 
		$suivante=0;
	    }
	    elsif (/^[ \t]*([^$limit]*)$limit$insert[ \t]*([0-9\.]+)/) {
                #print STDERR "--$1--\n";
                if (exists($label{$1})) {
                    $val=$label{$1};
                    #print STDERR "--store $val=>$2--\n";
                    $$values{$val}{$file} = $2;
                }
            }
	    else {
                my $label;
                foreach $label (keys %label) {
                    if (/^[ \t]*$label[ \t]*([0-9\.]+)/) {
                        $val=$label{$label};
                        print STDERR "--store $val=>$1--\n";
                        $$values{$val}{$file} = $1;
                    }
                }
            }
	}
	close(FIN);
    }
    # correction : ce qui est contenu dans r1000 est en fait le nombre de 
    # documents pertinents
    if (exists($label{$valuelabels{'r1000'}}) &&
        exists($label{$valuelabels{'relret'}})) {
	foreach $file (@{$Files}) {
            if ($$values{'r1000'}{$file}!=0) {
                $$values{'r1000'}{$file} = 
                    $$values{'relret'}{$file}/$$values{'r1000'}{$file};
            }
        }
    }
}

sub affiche_results {
    my ($values,$les_valeurs) = @_;
    my ($val,$file);
    foreach $val (@{$les_valeurs}) {
	foreach $file (sort keys %{$$values{$val}}) {
	    print "$val $file $$values{$val}{$file}\n";
	}
    }
}

sub affiche_results_latex {
    my ($files,$values,$entetes,$les_valeurs) = @_;
    my ($val,$afficheval,$file,$format);
    local ($_);
    if ($main::reverse) {
        # values in columns, files in lines

        print "\\begin{tabular}{|";
        #foreach (0..@{$files}) { print "c|"; }
        print "l|"."*{".(scalar @{$les_valeurs})."}{c|}";
        print "}\n        ";
        foreach $val (@{$les_valeurs}) {
            $afficheval=$val;
            $afficheval =~ s/_/\\_/;
            print " & ".$afficheval;
        }
        print " \\\\ \\hline\n";
        foreach $file (@{$files}) {
            print $$entetes{$file};
            foreach $val (@{$les_valeurs}) {
                $format=$precision_affiche{$val};
                printf(" & $format",$$values{$val}{$file});
            }
            print " \\\\ \\hline\n";
        }
        print "\\end{tabular}\n";
    }
    else {
        # files in columns, values in lines
        print "\\begin{tabular}{|";
        #foreach (0..@{$files}) { print "c|"; }
        print "c|"."*{".$#{$files}."}{c|}";
        print "}\n        ";
        foreach $file (@{$files}) {
            print " & ".$$entetes{$file};
        }
        print " \\\\ \\hline\n";
        foreach $val (@{$les_valeurs}) {
            $afficheval=$val;
            $afficheval =~ s/_/\\_/;
            printf("  %6s",$afficheval);
            foreach $file (@{$files}) {
                $format=$precision_affiche{$val};
                printf(" & $format",$$values{$val}{$file});
            }
            print " \\\\ \\hline\n";
        }
        print "\\end{tabular}\n";
    }
}


sub affiche_results_text {
    my ($files,$values,$entetes,$les_valeurs) = @_;
    my ($val,$afficheval,$file,$format);
    local ($_);
    if ($main::reverse) {
        # values in columns, files in lines
        print "       ";
        foreach $val (@{$les_valeurs}) {
            $afficheval=$val;
            $afficheval =~ s/_/\\_/;
            printf("  %6s",$afficheval);
        }
        print "\n";
        foreach $file (@{$files}) {
            printf("  %6s",$$entetes{$file});
            foreach $val (@{$les_valeurs}) {
                $format=$precision_affiche{$val};
                printf("  $format",$$values{$val}{$file});
            }
            print "\n";
        }
    }
    else {
        # files in columns, values in lines
        print "       ";
        foreach $file (@{$files}) {
            print " ".$$entetes{$file};
        }
        print "\n";
        foreach $val (@{$les_valeurs}) {
            $afficheval=$val;
            $afficheval =~ s/_/\\_/;
            printf("  %6s",$afficheval);
            foreach $file (@{$files}) {
                $format=$precision_affiche{$val};
                printf("  $format",$$values{$val}{$file});
            }
            print "\n";
        }
    }
}

sub affiche_graphique_csv {
    my ($files,$values,$les_valeurs) = @_;
    my ($val,$afficheval,$file,$format);

    my ($file,$val);
    foreach $file (@{$files}) {
        print ";$file";
    }
    print "\n";
    foreach $val (@{$les_valeurs}) {
        print $valueGraph{$val};
        foreach $file (@{$files}) {
            print ";".$$values{$val}{$file};
        }
        print "\n";
    }
}

sub entete{
    my ($entete,$file)=@_;
    return $file;
}

sub cree_topfile {
    my ($file)=@_;
    my ($topfile);
    $topfile="tmp_$file.top";
    if ($file =~ /\.gz$/) {  # si le fichier est gzippé
	$topfile =~ s/\.gz\.top/\.top/;
	open(ZIPFILE,"$zcat $file|") || die "cannot unzip $file";
	open(TOPFILE,">$topfile") || die "cannot write to $topfile";
	&reformulate(ZIPFILE,TOPFILE);
	close(ZIPFILE);
	close(TOPFILE);
    }
    else {
	&reformulate_file($file,$topfile);
    }
    return $topfile;
}

# crée les fichiers .eval pour les requêtes indiquées
sub cree_queryeval {
    my ($filetop,$fileref,$id)=@_;
    my ($idquery,$indoc,$file,@queryfiles);
    open(TRECEVAL,"$treceval -q $fileref $filetop|");
    while (<TRECEVAL>) {
	if (/$querylabel[\t ]*([^ \t\n]*)/o) {
	    $idquery=$1;
#	    print "$idquery [".join('|',keys %{$id})."]\n";
	    if (exists($$id{$idquery}) || $$id{'all'}) {
		$file=$tmpqueryeval."_$idquery"."_$filetop";
		push @queryfiles, $file;
		open (QUERYFILE, ">$file") || die "cannot open $file";
		print QUERYFILE "$filetop|query_$idquery\n\n";
		print QUERYFILE $_;
		$indoc=1;
		if ($$id{'all'}==1) { $$id{$idquery}=1; }
	    }
	    else { 
		if ($indoc) { close(QUERYFILE); }
		$indoc=0;
	    }
	}
	elsif ($indoc) {
	    print QUERYFILE $_;
	}
    }
    if ($$id{'all'}==1) { delete $$id{'all'}; }

#    print "--[queryfiles:".join('|',@queryfiles)."]--\n";
    return @queryfiles;
}

#----------------------------------------------------------------------
# fonctions pour utiliser gnuplot avec Perl 
# (librairie externe directement intégrée dans le source)
#
# Perl Library created by Romaric Besancon on Fri Nov 12 1999
# Version : $Id$ 
#
# fonctions pour utiliser gnuplot dans un programme Perl.
# ces fonctions sont :
#
# fonctions pour les paramètres ##############################
# gnuplot_plot
# gnuplot_range
# gnuplot_function
# gnuplot_file
# gnuplot_title
# gnuplot_style
#
# fonctions pour la commande gnuplot ####################
# gnuplot_open_commande 
# gnuplot_print_commande 
# gnuplot_close_commande
#
# fonctions pour les données ##############################
# gnuplot_open_data
# gnuplot_print_data
# gnuplot_close_data
# gnuplot_new_data
# 
# gnuplot_draw		pour dessiner
# gnuplot_clean		pour effacer les fichier temporaires

sub gnuplot_setparam {
    my ($param,$value)=@_;
    $gnuplot_setparam{$param}=$value;
}

sub gnuplot_plotparam {
    my ($param,$value)=@_;
    $gnuplot_plotparam{$param}=$value;
}

sub gnuplot_plot { &gnuplot_plotparam("plot",@_); return @_; }
sub gnuplot_range { &gnuplot_plotparam("range",@_); return @_; }
sub gnuplot_function { &gnuplot_plotparam("function",@_); return @_; }
sub gnuplot_file { &gnuplot_plotparam("file",@_); return @_; }
sub gnuplot_title { &gnuplot_plotparam("title",@_); return @_; }
sub gnuplot_style { &gnuplot_plotparam("style",@_); return @_; }

sub gnuplot_open_commande {
    local $_;
    open(GNUPLOT_COM, ">$com_gnuplot") || die "Cannot open $com_gnuplot";
    foreach (keys %gnuplot_setparam) {
	print GNUPLOT_COM "set $_ $gnuplot_setparam{$_}\n";
    }
}

sub gnuplot_print_commande {
#    my ($commande)=@_;
    my $quidplot=$gnuplot_plotparam{"function"}?$gnuplot_plotparam{"function"}:
	'"'.$gnuplot_plotparam{"file"}.'"';
#    print "YOUHOU\n";
    print GNUPLOT_COM $gnuplot_plotparam{"plot"}." ".
	$quidplot.
 	" title \"".$gnuplot_plotparam{"title"}."\" ".
 	$gnuplot_plotparam{"style"}
	;
}

sub gnuplot_close_commande {
    # pas de pause si postscript 
    unless ($gnuplot_setparam{'term'} =~ /postscript/i) {
	print GNUPLOT_COM "\npause 300";
    }
    close(GNUPLOT_COM);
}


sub gnuplot_print_data {
    my ($data)=@_;
    print GNUPLOT_DATA $data;
}

sub gnuplot_open_data {
    $gpnum++;
    open(GNUPLOT_DATA, ">$data_gnuplot.$gpnum") 
	|| die "Cannot open $data_gnuplot.$gpnum";
    &gnuplot_plotparam("file","$data_gnuplot.$gpnum");
}

sub gnuplot_close_data {
    close(GNUPLOT_DATA);
}

sub gnuplot_new_data {
    &gnuplot_close_data();
    &gnuplot_open_data();
}

sub gnuplot_draw {
    system("gnuplot -persist $com_gnuplot");
}

sub gnuplot_clean {
    system("/bin/rm $com_gnuplot $data_gnuplot.*");
}
