
=head1 NAME

ll.pm Version 0.1

=head1 SYNOPSIS

Statistical library package to calculate the Loglikelihood ratio. This
package should be used with statistic.pl and rank.pl.

=head1 DESCRIPTION

The log-likelihood ratio measures the devitation between the observed data 
and what would be expected if <word1> and <word2> were independent. The 
higher the score, the less evidence there is in favor of concluding that 
the words are independent. 

=head1 AUTHORS

Ted Pedersen <tpederse@d.umn.edu>

Satanjeev Banerjee <banerjee@cs.cmu.edu>

=head1 BUGS

This measure currently only defined for bigram data stored in 2x2 
contingency table. 

=head1 SEE ALSO

Mailing List: http://groups.yahoo.com/ngram

=head1 COPYRIGHT

Copyright 2000-2004 by Ted Pedersen and Satanjeev Banerjee

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

=cut

package ll;
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

    # check if ngram > 2. ll statistic only defined for ngram = 2. 
    if ($ngram > 2)
    {
	$errorCodeNumber = 1;
	$errorMessage = "Log-likelihood statistic is only available for bigrams!";
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

# function to calculate the ll value!
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

    $n11 = $jointFrequency;       # pair freq
    $n1p = $leftFrequency;        # single freq of first word
    $np1 = $rightFrequency;       # single freq of second word
    $n12 = $n1p - $n11;
    $n21 = $np1 - $n11;
    $np2 = $totalBigrams - $np1;
    $n2p = $totalBigrams - $n1p;
    $n22 = $np2 - $n12;
    $npp = $totalBigrams;

    # we know totalBigrams cant be zero. so we are safe in the next 4 calculations
    $m11 = $n1p * $np1 / $npp;
    $m12 = $n1p * $np2 / $npp;
    $m21 = $n2p * $np1 / $npp;
    $m22 = $n2p * $np2 / $npp;

    $logLikelihood = 0;

    # dont want ($nxy / $mxy) to be 0 or less! flag error if so!
    if ( $n11 ) 
    { 
	if ($m11 == 0) 
	{
	    $errorCodeNumber = 231;
	    $errorMessage = "Expected value in cell (1,1) must not be zero";
	    return(0);
	}

	if (($n11 / $m11) < 0)
	{
	    $errorCodeNumber = 232;
	    $errorMessage = "About to take log of negative value for cell (1,1)";
	    return(0);
	}

	$logLikelihood += $n11 * log ( $n11 / $m11 ); 
    }

    if ( $n12 ) 
    { 
	if ($m12 == 0) 
	{
	    $errorCodeNumber = 233;
	    $errorMessage = "Expected value in cell (1,2) must not be zero";
	    return(0);
	}

	if (($n12 / $m12) < 0)
	{
	    $errorCodeNumber = 234;
	    $errorMessage = "About to take log of negative value for cell (1,2)";
	    return(0);
	}

	$logLikelihood += $n12 * log ( $n12 / $m12 ); 
    }

    if ( $n21 ) 
    { 
	if ($m21 == 0) 
	{
	    $errorCodeNumber = 235;
	    $errorMessage = "Expected value in cell (2,1) must not be zero";
	    return(0);
	}

	if (($n21 / $m21) < 0)
	{
	    $errorCodeNumber = 236;
	    $errorMessage = "About to take log of negative value for cell (2,1)";
	    return(0);
	}

	$logLikelihood += $n21 * log ( $n21 / $m21 ); 
    }

    if ( $n22 ) 
    { 
	if ($m22 == 0) 
	{
	    $errorCodeNumber = 237;
	    $errorMessage = "Expected value in cell (2,2) must not be zero";
	    return(0);
	}

	if (($n22 / $m22) < 0)
	{
	    $errorCodeNumber = 238;
	    $errorMessage = "About to take log of negative value for cell (2,2)";
	    return(0);
	}

	$logLikelihood += $n22 * log ( $n22 / $m22 ); 
    }
    return ( 2 * $logLikelihood );
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
    return "Loglikelihood";
}

1;

