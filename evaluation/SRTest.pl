#!/usr/bin/perl -s
#
# Windows version (all in)
# 
# Perform a Wilcoxon Matched-pair Signed-Ranks Test on the pairs in ARGV[0]
# Either entered as two columns of pairs ("\n" separated) or as
# two lines (ARGV[0] and ARGV[1]). If ARGV[0] is a filename (or '-')
# the corresponding file is read (or STDIN).
#
# E.g., 
# > echo -e '1 2\n2 3\n3 4\n4 3\n'| SignedRankTest.pl -
# => W+ =  2.50, W- =  7.50, N = 4, p <= 0.375
#
# Copyright (C) 1996, 2001  Rob van Son
# 
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
# 
# Where are the Normal-Z  and WX-MP-SR tests (NOT needed in windows version)
$Script = '.';
#
# The absolute function
sub abs{
($_[0] >= 0) ? $_[0] : -$_[0];
}
#
# Significance levels
@level5 =  (0.05,  0, 0, 0, 0, 0, 21, 26, 33, 40, 47, 56, 65, 74, 84,  95);
@level1 =  (0.01,  0, 0, 0, 0, 0,  0,  0, 36, 44, 52, 61, 71, 81, 92, 104);
@level05 = (0.005, 0, 0, 0, 0, 0,  0,  0,  0, 45, 54, 63, 73, 84, 96, 108);

#
# Get STDIN if needed
if($ARGV[0] eq '-')
{
	$ARGV[0] = join("\n", <STDIN>);
}
elsif(-e $ARGV[0])
{
	open(INPUT, "<$ARGV[0]") || die "<$ARGV[0]: $!";
	$ARGV[0] = join("\n", <INPUT>);
};

#
# Recalculate input values to differences
$ARGV[0] =~ s/[ ]+/ /g;
$ARGV[0] =~ s/[\n]+/\n/g;
@InputList = split('\n', $ARGV[0]);

if($#InputList != 1)
{  foreach (@InputList)
   { @pair = split(' ', $_);
     $diff = ($#pair >= 1) ? ($pair[0]-$pair[1]) : $pair[0];
     if($diff != 0){ push(@difference_list, $diff);};
   };
}
else
{
   @ListA = split(' ', $InputList[0]);
   @ListB = split(' ', $InputList[1]);
   if($#ListA == $#ListB)
   { for($i=0; $i<=$#ListA; ++$i)
     { 
       $diff = $ListA[$i]-$ListB[$i];
       if($diff != 0){ push(@difference_list, $diff);};
     };
   }
   else { die "Unequal number of entries in input lists"};
};
@difference_list = sort {&abs($a) <=> &abs($b)} @difference_list;
#
# Replace differences by ranks
$previous = undef;
$start = 0;
for($i=0; $i <= $#difference_list; ++$i)
#{ if(&abs($difference_list[$i]) == $previous)
# chgt RB cause bug perl (sept 2001)
{ if(&abs($difference_list[$i]) eq $previous)
  { $mean_rank = ($start+$i+2)/2.0;
    for($j=$start; $j<=$i; ++$j)
    { $difference_rank[$j] = ($difference_list[$j]>0) ? 
                              $mean_rank : -$mean_rank;
    };
  }
  else
  { $difference_rank[$i] = ($difference_list[$i]>0) ? $i+1 : -($i+1);
    $previous = &abs($difference_list[$i]);
    $start = $i;
  };
};
## pour debug (RB Sept 2001)
if ($main::showdiff) {
    foreach $i (0..$#difference_list) {
	print "$difference_list[$i] $difference_rank[$i]\n";
    }
}

#
# Determine test parameters
$N = $#difference_rank+1;
$Wplus = 0;
$Wminus = 0;
foreach $diff (@difference_rank)
{ if($diff > 0)
  { $Wplus += $diff;}
  else
  { $Wminus += &abs($diff);};
};
$Wmaximal = ($Wplus > $Wminus) ? $Wplus : $Wminus;
# Determine level of significance
$p = 0;
if($N <= 16)	# Exact
{ 
  # $p = LevelOfSignificanceWXMPSR($Wmaximal, $N) # The Perl routine
  if(-e "$Script\\WX-MP-SR.exe")
  {
  	$p = `$Script\\WX-MP-SR.exe $Wmaximal $N`; chomp $p; # The faster C routine
  }
  else
  {
      $p = LevelOfSignificanceWXMPSR($Wmaximal, $N);		# The slower Perl routine
  	# $p = `$Script\\WX-MP-SR.pl $Wmaximal $N`; chomp $p; # The slower Perl routine
  };
  $Z = undef;
}
elsif($N <= 16)	# Table lookup, used only for slow systems
{ $p = ($level05[$N] && $level05[$N]<= $Wmaximal) ? $level05[0] :
       ($level1[$N]  && $level1[$N] <= $Wmaximal) ? $level1[0]  :
       ($level5[$N]  && $level5[$N] <= $Wmaximal) ? $level5[0]  :
       1.0;
  $Z = undef;
}
else	# Normal approximation
{
  # Normal approximation
  $Z = ($Wmaximal - 0.5 - $N*($N+1)/4)/sqrt($N*($N+1)*(2*$N+1)/24);
  $p = NormalZ($Z);
};

# Print output
if($Wplus == int($Wplus))
{ printf("W+ = %d, W- = %d, N = %d, p <= %5.4g ", $Wplus, $Wminus, $N, $p);}
else
{ printf("W+ = %5.2f, W- = %5.2f, N = %d, p <= %5.4g ", 
          $Wplus, $Wminus, $N, $p);
};




########################################################################
# This is the actual routine that calculates the exact (two-tailed)
# level of significance for the Wilcoxon Matched-Pairs Signed-Ranks
# test in PERL. The inputs are the Sum of Ranks of either the positive of 
# negative samples (W) and the sample size (N).
# The Level of significance is calculated by checking for each
# possible outcome (2**N possibilities) whether the sum of ranks
# is larger than or equal to the observed Sum of Ranks (W).
#
# NOTE: The execution-time ~ N*2**N, i.e., more than exponential. 
# Adding a single pair to the sample (i.e., increase N by 1) will 
# more than double the time needed to complete the calculations
# (apart from an additive constant).
# The execution-time of this program can easily outrun your 
# patience.
# 
sub LevelOfSignificanceWXMPSR  # ($W, $N)
{
  my $W = shift;
  my $N = shift;
  #
  # Determine Wmax, i.e., work with the largest Rank Sum
  my $MaximalW = $N*($N+1)/2;
  $W = $MaximalW - $W if($W < $MaximalW/2);

  # Change RB -> bug : if $W == $MaximalW/2, the symmetric cases
  # are counted twice. Anyway, in those cases, p=1 : we don't 
  # even need to count!
  return 1 if ($W == $MaximalW/2);
  
  #
  # The total number of possible outcomes is 2**N
  my $NumberOfPossibilities = 2**$N;
  #
  # Initialize and loop. The loop-interior will be run 2**N times.
  my $CountLarger = 0;
  # Generate all distributions of sign over ranks as bit-strings.
  for(my $i=0; $i < $NumberOfPossibilities; ++$i)
  { 
    my $RankSum = 0;
    # Shift "sign" bits out of $i to determine the Sum of Ranks
    for(my $j=0; $j<$N; ++$j)
    { 
      $RankSum += $j + 1 if(($i >> $j) & 1);
    };
    # Count the number of "samples" that have a Sum of Ranks larger or
    # equal to the one found (i.e., >= W).
    ++$CountLarger if($RankSum >= $W);
  };
  #
  # The level of significance is the number of outcomes with a
  # sum of ranks equal to or larger than the one found (W) 
  # divided by the total number of possible outcomes. 
  # The level is doubled to get the two-tailed result.
  my $p = 2*$CountLarger / $NumberOfPossibilities;
  return $p;
};

#
# Calculate two-tailed significance level associated with Z(x) with x = ARGV[0]
#
# i.e., P(|Z|>=x|Normal Distribution), error(x) < 7.5*10(-8)
#
# Probabilities are calculated according to: 
# Abramowitz and Stegun,
# Handbook of mathematical functions
# Ninth printing, Dover publications, Inc., 1970                  
# p932, 26.2.17
# 
# The absolute function
sub abs{
($_[0] >= 0) ? $_[0] : -$_[0];
}
#
sub NormalZ   # ($Z) -> $p
{
	$x = shift;
	#
	# P(x) = 1 - Z(x)(b1*t+b2*t**2+b3*t**3+b4*t**4+b5*t**5)
	# Z(x) = exp(-$x*$x/2.0)/(sqrt(2*3.14159265358979323846))
	# t = 1/(1+p*x)
	#
	# Parameters
	@b = (0.319381530, -0.356563782, 1.781477937, -1.821255978, 1.330274429);
	$p = 0.2316419;
	$t = 1/(1+$p*$x);
	# Initialize variables
	$fact = $t;
	$Sum = 0;
	# Sum polynomial
	for($i=0; $i <= $#b; ++$i)
	{ 
  		$Sum += $b[$i]*$fact;
  		$fact *= $t;
	};
	# Calculate probability
	$p = 2*$Sum*exp(-$x*$x/2.0)/(sqrt(2*3.14159265358979323846));
	#
	return $p;
};
