# rightFisher.pm	Version	0.1
#
# Statistical library package to calculate the Fisher's exact test 
# (right-sided). This package should be used with statistic.pl and rank.pl
#
# There is a known problem with rightFisher when min(n11,n12,n21,n22) = n22
# see message of July 25 on the NSP mailing list for more details:
# http://groups.yahoo.com/group/ngram/message/15
#
# Copyright (C)	2000,
# Satanjeev Banerjee, University of Minnesota, Duluth
# bane0025@d.umn.edu
# Ted Pedersen,	University of Minnesota, Duluth
# tpederse@d.umn.edu
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation;	either version 2
# of the License, or (at your option) any later	version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along	with this program; if not, write to the	Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.


package	rightFisher;
require	Exporter;
@ISA = qw ( Exporter );
@EXPORT = qw (initializeStatistic getStatisticName calculateStatistic errorCode errorString);

# function to set up various variables before the actual computation
# starts. also to check if we are being given bigrams, and if our
# frequency combinations are enough to do the computation
sub initializeStatistic
{
    ($ngram, $totalBigrams, $combIndex, @freqComb) = @_;
    
    $errorCodeNumber = 0;
    $errorMessage = "";

    # check if ngram > 2. Right-fisher statistic only defined for ngram = 2. 
    if ($ngram > 2)
    {
	$errorCodeNumber = 1;
	$errorMessage = "Right-fisher statistic is only available for bigrams!";
	return;
    }

    # totalBigrams should not be less than equal to 0
    if ($totalBigrams <= 0) 
    { 
	$errorCodeNumber = 10;
	$errorMessage = "Total number of bigrams ($totalBigrams) must be greater than 0.";
	return;
    }

    # figure out from the @freqComb array if the frequency values we
    # are going to get are indeed the ones we need. the ones we need
    # are (0,1), (0) and (1). while we figure this out, we shall also
    # note which of the indices of the array passed to function
    # calculateStatistic are the ones we want.

    my $i;
    for ($i = 0; $i < $combIndex; $i++)
    {
	$string = join (" ", @{$freqComb[$i]}[1..$freqComb[$i][0]]);

	if ($string eq "0 1") { $jointFreqIndex = $i; }
	elsif ($string eq "0") { $leftFreqIndex = $i; }
	elsif ($string eq "1") { $rightFreqIndex = $i; }
    }

    if (!(defined $jointFreqIndex))
    {
	$errorCodeNumber = 100;
	$errorMessage = "Frequency combination \"0 1\" (frequency of bigram) missing!\n";
    }

    if (!(defined $leftFreqIndex))
    {
	$errorCodeNumber = 101;
	$errorMessage = "Frequency combination \"0\" (frequency of bigrams containing left token) missing!\n";
    }

    if (!(defined $rightFreqIndex))
    {
	$errorCodeNumber = 102;
	$errorMessage = "Frequency combination \"1\" (frequency of bigrams containing right token) missing!\n";
    }
}


# function to calculate the left fisher value!
sub calculateStatistic
{
    my @numbers = @_;
    my $jointFrequency = $numbers[$jointFreqIndex];
    my $leftFrequency  = $numbers[$leftFreqIndex];
    my $rightFrequency = $numbers[$rightFreqIndex];

    # joint frequency should be greater than equal to zero 
    if ($jointFrequency < 0)
    {
	$errorCodeNumber = 200;
	$errorMessage = "Frequency value ($jointFrequency) must not be negative.";
	return(0);
    }

    # joint frequency should be less than or equal to totalBigrams
    if ($jointFrequency > $totalBigrams)
    {
	$errorCodeNumber = 201;
	$errorMessage = "Frequency value ($jointFrequency) must not exceed total number of bigrams.";
	return(0);
    }

    # joint frequency should be less than or equal to the marginal totals
    if ($jointFrequency > $leftFrequency || $jointFrequency > $rightFrequency)
    {
	$errorCodeNumber = 202;
	$errorMessage = "Frequency value of ngram ($jointFrequency) must not exceed the marginal totals.";
	return(0);
    }

    # left frequency should be greater than or equal to zero 
    if ($leftFrequency < 0)
    {
	$errorCodeNumber = 210;
	$errorMessage = "Marginal total value ($leftFrequency) must not be negative.";
	return(0);
    }

    # left frequency should be less than or equal to totalBigrams
    if ($leftFrequency > $totalBigrams)
    {
	$errorCodeNumber = 211;
	$errorMessage = "Marginal total value ($leftFrequency) must not exceed total number of bigrams.";
	return(0);
    }

    # right frequency should be greater than or equal to zero 
    if ($rightFrequency < 0)
    {
	$errorCodeNumber = 220;
	$errorMessage = "Marginal total value ($rightFrequency) must not be negative.";
	return(0);
    }

    # right frequency should be less than or equal to totalBigrams
    if ($rightFrequency > $totalBigrams)
    {
	$errorCodeNumber = 221;
	$errorMessage = "Marginal total value ($rightFrequency) must not exceed total number of bigrams.";
	return(0);
    }

    # now the actual calculation!

    my $n11 = $jointFrequency;
    my $npp = $totalBigrams;
    my $n1p = $leftFrequency;
    my $np1 = $rightFrequency;
    my $n2p = $npp - $n1p;
    my $np2 = $npp - $np1;

    # Added by Bridget
    my $n12 = $n1p - $n11;
    my $n21 = $np1 - $n11;
    my $n22 = $np2 - $n12;

    
    # we shall have two	arrays one for the numerator and one for the
    # denominator. the arrays will contain the factorial upper limits. we
    # shall be arrange these two arrays	in descending order. while doing the
    # actual calculation, we shall take	a numerator/denominator	pair, and
    # go from the lower	value to the higher value, in effect doing a
    # "cancellation" of	sorts.

    # first create the numerator
    my @numerator = sort { $b <=> $a } ($n1p, $np1, $n2p, $np2);

    # now to the real calculation!!!
    my $probability = 0;
    my $i;
    my $j;

    # we shall calculate for n11 = 0. thereafter we shall just multiply	and
    # divide the result	for 0 with correct numbers to obtain result for	i,
    # i>0, i<=n11!! :o)

   


    #  Bridget Thomson McInnes 15 October 2003
    #  Set the final limit to the leaste of the marginal totals
    #  n1p or np1 because that is the maximum number of times
    #  the bigram would be seen

    $final_Limit = ($n1p < $np1) ? $n1p : $np1;

    ########### this part by Nitin O Verma

    #$final_Limit = $n11;
    #$n11  = 0;
    #my $n12 = $n1p;
    #my $n21 = $np1;
    #my $n22 = $n2p - $n21;
    
    #while($n22 < 0)
    #{
    #	$n11++;
    #    $n12 = $n1p - $n11;
    #    $n21 = $np1 - $n11;
    #    $n22 = $n2p - $n21;
    #}

    ########### end of part by Nitin O Verma

    my @denominator = sort { $b	<=> $a } ($npp,	$n22, $n12, $n21, $n11);

    # now that we have our two arrays all nicely sorted	and in place,
    # lets do the calculations!

    my @dLimits	= ();
    my @nLimits	= ();
    my $dIndex = 0;
    my $nIndex = 0;

    for	( $j = 0; $j < 4; $j ++	)
    {
	if ( $numerator[$j] > $denominator[$j] )
	{
	    $nLimits[$nIndex] =	$denominator[$j] + 1;
	    $nLimits[$nIndex+1]	= $numerator[$j];
	    $nIndex += 2;
	}

	elsif (	$denominator[$j] > $numerator[$j] )
	{
	    $dLimits[$dIndex] =	$numerator[$j] + 1;
	    $dLimits[$dIndex+1]	= $denominator[$j];
	    $dIndex += 2;
	}
    }
    $dLimits[$dIndex] =	1;
    $dLimits[$dIndex+1]	= $denominator[4];

    my $product	= 1;
    while ( defined ( $nLimits[0] ) )
    {
	while (	( $product < 10000 ) &&	( defined ( $nLimits[0]	) ) )
	{
	    $product *=	$nLimits[0];
	    $nLimits[0]++;
	    if ( $nLimits[0] > $nLimits[1] )
	    {
		shift @nLimits;
		shift @nLimits;
	    }
	}

	while (	$product > 1 )
	{
	    $product /=	$dLimits[0];
	    $dLimits[0]++;
	    if ( $dLimits[0] > $dLimits[1] )
	    {
		shift @dLimits;
		shift @dLimits;
	    }
	}
    }

    while ( defined ( $dLimits[0] ) )
    {
	$product /= $dLimits[0];
	$dLimits[0]++;
	if ( $dLimits[0] > $dLimits[1] )
	{
	    shift @dLimits;
	    shift @dLimits;
	}
    }

    # $product now has the hypergeometric probability for n11 = 0. add it to
    # the cumulative probability

    # Actually we are now adding the hypergeometric probability for the
    # original n11 - Bridget Thomson McInnes 15 October 2003
    $probability += $product;

    # now for the rest of n11's	!!
    
    #for ( $i = 1; $i <= $n11; $i++ )
    
    # Bridget Thomson McInnes 15 October 2003
    # Now we add the hypergeometric probability for the possible
    # n11 values greater than the original n11 up until the
    # final limit. 
    for	( $i = $n11+1; $i <= $final_Limit; $i++ )
    {
	$product *= $n12;
	$n22++;
	if ($n22 <= 0) { next; }
	$product /= $n22;
	$product *= $n21;
	$n12--;
	$n21--;
	$product /= $i;

	# thats	our new	probability for	n11 = i! :o)) cool eh? ;o))
	# add it to the	main probability! :o))

	$probability +=	$product; # !! :o)

    }

    # thats abt	it!
    return $probability;
}

# function to return the error code of the last operation and reset
# error code. useful if the error can be recovered from!
sub errorCode 
{ 
    my $temp = $errorCodeNumber;
    $errorCodeNumber = 0;
    return($temp); 
}

# function to return the error message of the last operation and reset
# the message string. useful if error can be recovered from!
sub errorString
{
    my $temp = $errorMessage;
    $errorMessage = "";
    return($temp);
}

# function to return the name of this statistic
sub getStatisticName
{
    return "Right Fisher";
}

1;
