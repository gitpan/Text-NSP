# tmi3.pm Version 0.1
#
# Statistical library package to calculate the true mutual information 
# for trigrams. This package should be used with statistic.pl and rank.pl.
#
# Copyright (C) 2002-2003,
# Satanjeev Banerjee, University of Minnesota, Duluth
# bane0025@d.umn.edu
# Ted Pedersen, University of Minnesota, Duluth
# tpederse@d.umn.edu
# Amruta Purandare, University of Minnesota, Duluth
# pura0010@d.umn.edu
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

# this module was originally written by Satanjeev Banerjee
# for bigrams and was updated by Amruta Purandare for trigrams

package tmi3;
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

    # check if ngram !=3 . tmi3 statistic only defined for ngram = 3. 
    if ($ngram != 3)
    {
	$errorCodeNumber = 1;
	$errorMessage = "tmi3 statistic is only available for trigrams!";
	return;
    }

    # totalBigrams should not be less than equal to 0
    if ($totalBigrams <= 0) 
    { 
	$errorCodeNumber = 10;
	$errorMessage = "Total number of trigrams ($totalBigrams) must be greater than 0.";
	return;
    }

    # figure out from the @freqComb array if the frequency values we
    # are going to get are indeed the ones we need. 
    # while we figure this out, we shall also note which of the indices of the 
    # array passed to function calculateStatistic are the ones we want.

    my $i;
    for ($i = 0; $i < $combIndex; $i++)
    {
	$str="";
        foreach(@{$freqComb[$i]}[1..$freqComb[$i][0]])
        {
                $str.=$_."#";
        }
        if($str eq "0#1#2#")
        {
                $joint=$i;
        }
        if($str eq "0#")
        {
                $first=$i;
        }
        if($str eq "1#")
        {
                $second=$i;
        }
	if($str eq "2#")
        {
                $third=$i;
        }
        if($str eq "0#1#")
        {
                $first_second=$i;
        }
        if($str eq "1#2#")
        {
                $second_third=$i;
        }
        if($str eq "0#2#")
        {
                $first_third=$i;
        }
		
    }

    if (!(defined $joint))
    {
	$errorCodeNumber = 100;
	$errorMessage = "Frequency combination \"0 1 2\" missing!\n";
    }

    if (!(defined $first))
    {
	$errorCodeNumber = 101;
	$errorMessage = "Frequency combination \"0\" missing!\n";
    }

    if (!(defined $second))
    {
	$errorCodeNumber = 102;
	$errorMessage = "Frequency combination \"1\" missing!\n";
    }
	
    if (!(defined $third))
    {
        $errorCodeNumber = 103;
        $errorMessage = "Frequency combination \"2\" missing!\n";
    }
	
	if (!(defined $first_second))
    {
        $errorCodeNumber = 104;
        $errorMessage = "Frequency combination \"0 1\" missing!\n";
    }

	if (!(defined $second_third))
    {
        $errorCodeNumber = 105;
        $errorMessage = "Frequency combination \"1 2\" missing!\n";
    }

	if (!(defined $first_third))
    {
        $errorCodeNumber = 106;
        $errorMessage = "Frequency combination \"0 2\" missing!\n";
    }

}

# function to calculate the tmi3 value!
sub calculateStatistic
{
	my @freqs=@_;
        my $n111=$freqs[$joint];;
        my $n1pp=$freqs[$first];
        my $np1p=$freqs[$second];
        my $npp1=$freqs[$third];
        my $n11p=$freqs[$first_second];
        my $np11=$freqs[$second_third];
        my $n1p1=$freqs[$first_third];

        my $n112=$n11p-$n111;
        my $n211=$np11-$n111;
        my $n212=$np1p-$n111-$n112-$n211;

	my $n121=$n1p1-$n111;
        my $n122=$n1pp-$n111-$n112-$n121;
        my $n221=$npp1-$n111-$n211-$n121;
        my $nppp=$totalBigrams;
	my $n222=$nppp-($n111+$n112+$n121+$n122+$n211+$n212+$n221);
	my $n2pp=$nppp-$n1pp;
        my $np2p=$nppp-$np1p;
        my $npp2=$nppp-$npp1;

   # n111 should be greater than equal to zero 
    if ($n111< 0)
    {
	$errorCodeNumber = 200;
	$errorMessage = "Frequency value ($n111) must not be negative.";
	return(0);
    }

    # n111 frequency should be less than or equal to totalBigrams
    if ($n111> $nppp)
    {
	$errorCodeNumber = 201;
	$errorMessage = "Frequency value ($n111) must not exceed total number of bigrams.";
	return(0);
    }

    # joint frequency n111 should be less than or equal to the marginal totals
    if ($n111 > $n1pp || $n111 > $np1p || $n111 > $npp1)
    {
	$errorCodeNumber = 202;
	$errorMessage = "Frequency value of ngram ($n111) must not exceed the marginal totals.";
	return(0);
    }

    # n1pp should be greater than or equal to zero 
    if ($n1pp< 0)
    {
	$errorCodeNumber = 203;
	$errorMessage = "Marginal total value ($n1pp) must not be negative.";
	return(0);
    }

    # n1pp should be less than or equal to totalBigrams
    if ($n1pp > $nppp)
    {
	$errorCodeNumber = 204;
	$errorMessage = "Marginal total value ($n1pp) must not exceed total number of bigrams.";
	return(0);
    }
# np1p should be greater than or equal to zero
    if ($np1p< 0)
    {
        $errorCodeNumber = 205;
        $errorMessage = "Marginal total value ($np1p) must not b
e negative.";
        return(0);
    }

# np1p should be less than or equal to totalBigrams
    if ($np1p > $nppp)
    {
        $errorCodeNumber = 206;
        $errorMessage = "Marginal total value ($np1p) must not 
xceed total number of trigrams.";
        return(0);
    }

    # npp1 should be greater than or equal to zero 
    if ($npp1< 0)
    {
	$errorCodeNumber = 207;
	$errorMessage = "Marginal total value ($npp1) must not be negative.";
	return(0);
    }

    # npp1 should be less than or equal to totalBigrams
    if ($npp1 > $nppp)
    {
	$errorCodeNumber = 208;
	$errorMessage = "Marginal total value ($npp1) must not exceed total number of bigrams.";
	return(0);
    }

	$e111=$n1pp*$np1p*$npp1/($nppp**2);
        $e112=$n1pp*$np1p*$npp2/($nppp**2);
        $e121=$n1pp*$np2p*$npp1/($nppp**2);
        $e122=$n1pp*$np2p*$npp2/($nppp**2);
        $e211=$n2pp*$np1p*$npp1/($nppp**2);
        $e212=$n2pp*$np1p*$npp2/($nppp**2);
        $e221=$n2pp*$np2p*$npp1/($nppp**2);
        $e222=$n2pp*$np2p*$npp2/($nppp**2);
	
    $tmi3 = 0;

    # dont want ($n111 / $e111) to be 0 or less! flag error if so!
    if ( $n111 ) 
    { 
	if ($e111 == 0) 
	{
	    $errorCodeNumber = 231;
	    $errorMessage = "Expected value in cell (1,1,1) must not be zero";
	    return(0);
	}

	if (($n111 / $e111) < 0)
	{
	    $errorCodeNumber = 232;
	    $errorMessage = "About to take log of negative value for cell (1,1)";
	    return(0);
	}

	$tmi3 += $n111/$nppp * log ( $n111 / $e111 ) / log 2; 
    }

    if ( $n112 ) 
    { 
	if ($e112 == 0) 
	{
	    $errorCodeNumber = 233;
	    $errorMessage = "Expected value in cell (1,1,2) must not be zero";
	    return(0);
	}

	if (($n112 / $e112) < 0)
	{
	    $errorCodeNumber = 234;
	    $errorMessage = "About to take log of negative value for cell (1,1,2)";
	    return(0);
	}

	$tmi3 += $n112/$nppp * log ( $n112 / $e112 ) / log 2; 
    }

    if ( $n121 ) 
    { 
	if ($e121 == 0) 
	{
	    $errorCodeNumber = 235;
	    $errorMessage = "Expected value in cell (1,2,1) must not be zero";
	    return(0);
	}

	if (($n121 / $e121) < 0)
	{
	    $errorCodeNumber = 236;
	    $errorMessage = "About to take log of negative value for cell (1,2,1)";
	    return(0);
	}

	$tmi3 += $n121/$nppp * log ( $n121 / $e121 ) / log 2; 
    }

    if ( $n122 ) 
    { 
	if ($e122 == 0) 
	{
	    $errorCodeNumber = 237;
	    $errorMessage = "Expected value in cell (1,2,2) must not be zero";
	    return(0);
	}

	if (($n122 / $e122) < 0)
	{
	    $errorCodeNumber = 238;
	    $errorMessage = "About to take log of negative value for cell (1,2,2)";
	    return(0);
	}

	$tmi3 += $n122/$nppp * log ( $n122 / $e122 ) / log 2; 
    }
    if ( $n211 )
    {
        if ($e211 == 0)
        {
            $errorCodeNumber = 239;
            $errorMessage = "Expected value in cell (2,1,1) must
 not be zero";
            return(0);
        }

        if (($n211 / $e211) < 0)
        {
            $errorCodeNumber = 240;
            $errorMessage = "About to take log of negative value
 for cell (2,1,1)";
            return(0);
        }
	$tmi3 += $n211/$nppp * log ( $n211 / $e211 ) / log 2;
}
	if ( $n212 )
    {
        if ($e212 == 0)
        {
            $errorCodeNumber = 241;
            $errorMessage = "Expected value in cell (2,1,2) must
 not be zero";
            return(0);
        }

        if (($n212 / $e212) < 0)
        {
            $errorCodeNumber = 242;
            $errorMessage = "About to take log of negative value
 for cell (2,1,2)";
            return(0);
        }

        $tmi3 += $n212/$nppp * log ( $n212 / $e212 ) / log 2;
    }

	if ( $n221 )
    {
        if ($e221 == 0)
        {
            $errorCodeNumber = 243;
            $errorMessage = "Expected value in cell (2,2,1) must
 not be zero";
            return(0);
        }

        if (($n221 / $e221) < 0)
        {
            $errorCodeNumber = 244;
            $errorMessage = "About to take log of negative value
 for cell (2,2,1)";
            return(0);
        }

        $tmi3 += $n221/$nppp * log ( $n221 / $e221 ) / log 2;
    }

	if ( $n222 )
    {
        if ($e222 == 0)
        {
            $errorCodeNumber = 245;
            $errorMessage = "Expected value in cell (2,2,2) must
 not be zero";
            return(0);
        }

        if (($n222 / $e222) < 0)
        {
            $errorCodeNumber = 246;
            $errorMessage = "About to take log of negative value
 for cell (2,2,2)";
            return(0);
        }

        $tmi3 += $n222/$nppp * log ( $n222 / $e222 ) / log 2;
    }

    return ($tmi3);
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
    return "True Mututal Information 3";
}

1;

