# odds.pm Version 0.1
#
# Statistical library package to calculate the Odds Ratio. This
# package should be used with statistic.pl and rank.pl.
#
# The odds ratio computes the ratio of the number of times that
# the words in a bigram occur together (or not at all) to the
# number of times the words occur individually. It is the cross
# product of the diagonal and the off-diagonal. 
#
# if this is a 2x2 contingency table...
# 
# n11 n12 
# n21 n22
#
# ODDS RATIO = n11*n22/n21*n12
#
# if n21 and/or n12 is 0, then each zero value is "smoothed" to one to  
# avoid a zero in the denominator. 
#
#
# Copyright (C) 2003
# Ted Pedersen, University of Minnesota, Duluth
# tpederse@d.umn.edu
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


package odds;
require Exporter;
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

    # check if ngram > 2. Odds ratio only defined for ngram = 2. 
    if ($ngram > 2)
    {
	$errorCodeNumber = 1;
	$errorMessage = "Odds Ratio is only available for bigrams!";
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

# function to calculate the odds ratio!

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

    # figure out all the values in the contingency table representation

    $n11 = $jointFrequency;       # pair freq
    $n1p = $leftFrequency;        # single freq of first word
    $np1 = $rightFrequency;       # single freq of second word
    $n12 = $n1p - $n11;
    $n21 = $np1 - $n11;
    $np2 = $totalBigrams - $np1;
    $n2p = $totalBigrams - $n1p;
    $n22 = $np2 - $n12;
    
    # zero handling to avoid zero denominator

    if ($n21 == 0) { 
	$n21 = 1;
    }
    if ($n12 == 0) { 
	$n12 = 1;
    }

    $term1 = $n11*$n22;
    $term2 = $n21*$n12;

    $odds = $term1/$term2; 

return ($odds);
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
    return "Odds Ratio";
}

1;

