# dice.pm Version 0.1
#
# Statistical library package to calculate the Dice coefficient. This package
# should be used with statistic.pl and rank.pl
#
# Copyright (C) 2000,
# Satanjeev Banerjee, University of Minnesota, Duluth
# bane0025@d.umn.edu
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


package dice;
require Exporter;
@ISA = qw (Exporter);
@EXPORT = qw (initializeStatistic getStatisticName calculateStatistic errorCode errorString);

# function to set up various variables before the actual computation
# starts. also to check if we are being given bigrams, and if our
# frequency combinations are enough to do the computation
sub initializeStatistic
{
    ($ngram, $totalBigrams, $combIndex, @freqComb) = @_;
    
    $errorCodeNumber = 0;
    $errorMessage = "";

    # check if ngram > 2. dice statistic only defined for ngram = 2. 
    if ($ngram > 2)
    {
	$errorCodeNumber = 1;
	$errorMessage = "Dice statistic is only available for bigrams!";
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

# function to calculate the dice value!
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

    # sum of left and right frequency should be greater than zero
    # since this sum comes in the denominator of the dice equation
    if ($leftFrequency + $rightFrequency == 0)
    {
	$errorCodeNumber = 203;
	$errorMessage = "Sum of marginal totals must not be 0."; 
	return(0);
    }

    # finally the calculation!!
    return (2 * $jointFrequency / ($leftFrequency + $rightFrequency));
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
    return "Dice";
}

1;
