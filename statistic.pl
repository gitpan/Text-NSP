#!/usr/local/bin/perl -w

=head1 NAME

statistic.pl

=head1 SYNOPSIS

Program to take a ngram-frequency file (as output by count.pl) and to
then calculate the given statistic. The statistic to be calculated has
to be supplied as a library which will be dynamically loaded. This library
file has to follow a standard as defined in the readme! Thereafter, to
output the result into a destination file.

=head1 DESCRIPTION

See perldoc README.pod

=head1 AUTHOR

Satanjeev Banerjee, bane0025@d.umn.edu

Ted Pedersen, tpederse@d.umn.edu

=head1 BUGS

=head1 SEE ALSO

 home page:    http://www.d.umn.edu/~tpederse/nsp.html

 mailing list: http://groups.yahoo.com/group/ngram/

=head1 COPYRIGHT

Copyright (C) 2000-2003, Ted Pedersen and Satanjeev Banerjee

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

#
###############################################################################
#
#                       -------         CHANGELOG       ---------
#
#version        date            programmer      List of changes     change-id
#
#             
# 0.57          07/01/2003      Ted         (1) if destination file  TDP.57.3
#		                                found, check for 
#                                               source before proceeding
###############################################################################
#-----------------------------------------------------------------------------
#                              Start of Program
#-----------------------------------------------------------------------------

# we have to use commandline options, so use the necessary package!
use Getopt::Long;

# first check if no commandline options have been provided... in which case
# print out the usage notes!
if ( $#ARGV == -1 )
{
    &minimalUsageNotes();
    exit;
}

# now get the options!
GetOptions("version", "help", "format", "frequency=i", "rank=i", "precision=i",
	   "score=f", "extended", "ngram=i", "get_freq_combo=s", "set_freq_combo=s");
	   
# if help has been requested, print out help!
if ( defined $opt_help ) 
{
    $opt_help = 1;
    showHelp();
    exit;
}

# if version has been requested, show version!
if ( defined $opt_version ) 
{
    $opt_version = 1;
    showVersion();
    exit;
}

# set the variables according to what has been provided!
if ( defined $opt_ngram )     { $ngram = $opt_ngram; }
else                          { $ngram = 2; }

if ( defined $opt_rank )      { $show = $opt_rank; }
else                          { $show = -1; } # -1 stands for show all!

if ( defined $opt_precision ) { $precision = $opt_precision; }
else                          { $precision = 4; } # default precision

if ( defined $opt_score )     { $scoreCutOff = $opt_score; }


if ($precision !~ /^\d+$/) 
{ 
    print STDERR "Value for switch --precision should be integer >= 0. Using 4.\n"; 
    $precision = 4;
}

# create the floating point conversion format as required by sprintf! 
$floatFormat = join '', '%', '.', $precision, 'f';

# now get hold of the frequency combinations that we need to know
# about so as to understand the input data.
if (defined $opt_set_freq_combo)
{
    readFreqCombo($opt_set_freq_combo);
}
# or, by default, everything possible
else
{
    getDefaultFreqCombos();
}

if (defined $opt_get_freq_combo)
{
    open (FREQ_COMBO_OUT, ">$opt_get_freq_combo") || die ("Couldnt open $opt_get_freq_combo");
    
    for ($i = 0; $i < $combIndex; $i++)
    {
	for ($j = 1; $j <= $freqComb[$i][0]; $j++)
	{
	    print FREQ_COMBO_OUT "$freqComb[$i][$j] ";
	}
	print FREQ_COMBO_OUT "\n";
    }

    close (FREQ_COMBO_OUT); 
}

# at the end of those two functions we should have with us the @freqComb
# array!

# check if frequency cut off has been requested. if so find the index
# of the input numbers that contains the frequency. if not found warn
# that frequency cutoff ineffective

if (defined $opt_frequency) 
{ 
    # find index
    my $requiredString = "";
    my $i; 

    for ($i = 0; $i < $ngram; $i++)
    {
	$requiredString .= $i;
	if ($i < $ngram-1) { $requiredString .= " "; }
    }

    $ngramFreqIndex = -1;

    for ($i = 0; $i < $combIndex; $i++)
    {
	my $thisString = join (" ", @{$freqComb[$i]}[1..$freqComb[$i][0]]);
	if ($requiredString eq $thisString) { $ngramFreqIndex = $i; last; }
    }

    if ($ngramFreqIndex == -1)
    {
	print STDERR "Warning: Frequency of n-gram not found, ignoring frequency cut-off!\n";
	undef $opt_frequency;
    }
}

# having stripped the commandline of all the options et al, we should now be
# left only with the source/destination files

# so, first get hold of the statistic library, and include it!
$statistic = shift;

# check to see if a library has been supplied at all!
if ( !( $statistic ) )
{
    print "No statistic library supplied. ";
    askHelp();
    exit;
}

# now remove the ".pm" in the end of the statistic filename, if present
@pathComponents = split (/\./, $statistic);

if ( $pathComponents[$#pathComponents] eq "pm" ) 
{ 
    $#pathComponents --;
    $statistic = join ( ".", @pathComponents );
}

$importname = $statistic;
$statistic = $importname . ".pm";

# if statistic file not present in currect directory, then search in the path
if ( !( -f $statistic ) )
{
    my @directories = split (/:/, $ENV{PATH});
    my $dir;
    my $found = 0;

    foreach $dir (@directories)
    {
	$statistic = $dir . "/" . $importname . ".pm";
	if ( -f $statistic ) 
	{ 
	    $found = 1;
	    last;
	}
    }

    # if still not found anywhere, quit!
    if ( !($found) ) 
    {
	print "Could not find package $importname.\n";
	askHelp();
	exit;
    }
}

# now include the module and import the default symbols into the current
# package
require $statistic;
import $importname;

# the statistic library must mandatorily implement two functions -
# &initializeStatistic and &calculateStatistic, and may optionally
# implement &getStatisticName, &errorCode and &errorString. Check if
# the two mandatory functions are implemented; if not, complain and
# quit.
if (!(defined &initializeStatistic && defined &calculateStatistic))
{
    print STDERR "ERROR!! Mandatory functions initializeStatistic() and calculateStatistic()\n";
    print STDERR "not defined in statistic library $statistic. Aborting!\n";
    exit;
}


# now get hold of the destination filename
$destination = shift;

# check to see if a destination has been supplied at all...
if ( !( $destination ) )
{
    print "No output file (DESTINATION) supplied. ";
    askHelp();
    exit;
}

## start TDP.57.3 (moved existing code to here)

# now get the name of the source file
$source = shift;

# check to see if a src has been supplied at all...
if ( !( $source ) )
{
    print "No input file (SOURCE) specified. ";
    askHelp();
    exit;
}

# now see if src exists...
if ( ! ( -e $source ) )
{
    print "Cant find input file (SOURCE) $source.\n"; 
    exit;
}
## finish TDP.57.3 (moved existing code to here)

# check to see if destination exists, and if so, if we should overwrite...
if ( -e $destination )
{
    print "Output file $destination already exists! Overwrite (Y/N)? ";
    $reply = <STDIN>;
    chomp $reply;
    $reply = uc $reply;
    exit 0 if ($reply ne "Y");
}

# having ascertained that we may open the destination file for output, lets
# do so...
open ( DST, ">$destination" ) || die "Cant open output file $destination";

## old location of TDP.57.3

# now open the source file.
open( SRC, "$source" ) || die "Cant open input file $source, quitting";

# now read in all the @ data and write them out to the destination file
# if -extended has been selected

$flag = 1;
my $lineNo = 0; # will tell us where in the source file we have a problem!
while ($flag)
{
    $temp = <SRC>;
    $lineNo++;

    if ( $temp =~ /^@/ && ! ($temp =~ /^@@/ ) )
    {
	if ( defined $opt_extended ) { print DST $temp; }
    }
    else
    {
	$flag = 0;
    }
}

# $temp should now have the total number of ngrams!
$totalNgrams = $temp;
if (defined($totalNgrams))
{
    chomp $totalNgrams;
}

# check to see if we really have an ngram-total, or some garbage!
if ( !(defined($totalNgrams)) || (!isInteger($totalNgrams)))
{
    print ("$source does not look like a ngram frequency file at line number $lineNo\n");
    exit;
}

# having read the ngram-total, we now need to read in the ngrams and their
# data one by one, all the while calculating their statistic too! before doing so, 
# initialize the statistic 

initializeStatistic($ngram, $totalNgrams, $combIndex, @freqComb);

# check if the initialization created an error!
if (defined &errorCode) 
{ 
    my $error = errorCode();

    if ($error =~ /^1/) # error!
    {
	printf(STDERR "Error from statistic library!\n  Error code: %d\n", $error);
	if (defined (&errorString))
	{
	    my $errorMessage = errorString();
	    print STDERR "  Error message: $errorMessage\n" if( $errorMessage ne "");
	}
	exit; # exit on error, not on warning
    }

    if ($error =~ /^2/) # warning!
    {
	printf(STDERR "Warning from statistic library!\n  Warning code: %d\n", $error);
	if (defined (&errorString))
	{
	    my $errorMessage = errorString();
	    print STDERR "  Warning message: $errorMessage\n" if( $errorMessage ne "");
	}
    }
}

while(<SRC>)
{
    $lineNo++;
    # our target record is in $_. now...
    chomp $_;

    # get the various fields of the record!
    if ( defined @tokens  ) { undef @tokens;  }
    if ( defined @numbers ) { undef @numbers; }

    # split on the <>. thus @tokens will have all the separate tokens
    # that make up this ngram and its last element will be the string
    # of space separated numbers
    @tokens = split(/<>/, $_);
    
    # check if we have enough tokens! if not, complain and quit
    # interestingly, @tokens will actually have one more element than
    # $ngram. so $#tokens should be exactly the same as $ngram!
    if ($#tokens != $ngram) 
    {
	print STDERR "Wrong number of tokens in ngram on line $lineNo. Expecting $ngram.\n";
	exit;
    }

    # put the frequency values for this ngram into @numbers
    @numbers = split(/ /, $tokens[$#tokens]);
    
    # remove the last element from tokens so that we really have only
    # tokens in @tokens
    pop @tokens;
    
    # remove bit stuffed '@' symbol from first token if present. 
    $tokens[0] =~ s/^@@/@/; 

    # the number of frequency values should be equal to $combIndex. if
    # not, quit! note this is the only check we can do to ascertain if
    # there is some problem with the frequency values. as long as we
    # have the right number of frequency values, we are happy!
    if ($#numbers != $combIndex - 1)
    {
	print STDERR "Wrong number of frequency values on line $lineNo. Expecting $combIndex.\n";
	exit;
    }

    # if we are doing frequency cutoffs and the frequency of this
    # ngram is below the cut off level, then skip this iteration of
    # the loop
    if (defined $opt_frequency && $numbers[$ngramFreqIndex] < $opt_frequency) { next; }
    
    # having got this far, we are ready to compute! first recreate the ngram string. 
    my $ngramString = join("<>", @tokens);

    # next create the string with the frequency values in it. we shall
    # output this later on, so put it in a hash whose keys are the
    # ngram strings
    $NUMBERSTRINGS{$ngramString} = join(" ", @numbers);

    # calculate the statistic and create the statistic hash.
    my $statisticValue = calculateStatistic(@numbers); # function implemented by stat library

    # check for errors/warnings
    if (defined &errorCode) 
    { 
	my $error = errorCode();
	
	if ($error =~ /^1/) # error!
	{
	    printf(STDERR "Error from statistic library!\n  Error code: %d\n", $error);
	    if (defined (&errorString))
	    {
		my $errorMessage = errorString();
		print STDERR "  Error message: $errorMessage\n" if( $errorMessage ne "");
	    }
	    exit; # exit on error
	}
	
	if ($error =~ /^2/) # warning!
	{
	    printf(STDERR "Warning from statistic library!\n  Warning code: %d\n", $error);
	    if (defined (&errorString))
	    {
		my $errorMessage = errorString();
		print STDERR "  Warning message: $errorMessage\n" if( $errorMessage ne "");
	    }
	    print STDERR "Skipping ngram $ngramString<>$NUMBERSTRINGS{$ngramString}\n";
	    next; # if warning, dont save the statistic value just computed
	}
    }
    
    # ah, so no error or warning

    # round the statistic value returned according to the precision
    # requested by using the float format created earlier.
    $STATISTIC{$ngramString} = sprintf $floatFormat, $statisticValue;
}	

# that completes the calculations. now to write out the data onto the
# destination file, ranking the ngrams according to the statistic just
# calculated. we will do formatted as well as unformatted printing.

# but first print out some @ data if -extended is chosen

$statisticName = (defined &getStatisticName) ? getStatisticName() : "$statistic";

if ( defined $opt_extended )
{
    # first the name of the statistic...
    print DST "\@statistic.StatisticName=$statisticName\n"; 

    # next if output is formatted...
    if ( defined $opt_format ) 
    { 
	print DST "\@statistic.Formatted=1\n"; 
    }
    else { print DST "\@statistic.Formatted=0\n"; }
    
    # the frequency cut off, if defined...
    if (defined $opt_frequency) { print DST "\@statistic.Frequency=$opt_frequency\n"; }
    
    # the rank...
    if ( $show > 0 ) { print DST "\@statistic.Rank=$show\n"; }

    # and finally the score cut off
    if ( defined $scoreCutOff ) { print DST "\@statistic.Score=$scoreCutOff\n"; }
}

if ( defined $opt_format ) { &formattedPrinting(); }
else { &unformattedPrinting(); }

# close all open files...
close SRC;
close DST;

# ...and thats it!

#-----------------------------------------------------------------------------
# User Defined Functions
#-----------------------------------------------------------------------------

# function to do unformatted printing to the destination file!
sub unformattedPrinting
{
    chomp $totalNgrams;
    print DST "$totalNgrams\n";
    
    # we will do the ranking ourselves, whereby all tied ngrams will
    # receive the same rank. moreover ranks wont have holes in them,
    # which means that no matter how many ngrams have rank x, the next
    # lower valued ngram will have a rank of x+1!
    
    my $rank = 1;
    my $lastValue = 0;

    # find the smallest statistic value and assign to $lastValue
    foreach ( sort { $STATISTIC{$b} <=> $STATISTIC{$a} } keys %STATISTIC )
    { 
	$lastValue = $STATISTIC{$_}; 
	last;
    }

    foreach ( sort { $STATISTIC{$b} <=> $STATISTIC{$a} } keys %STATISTIC )
    {
	my @tokens = split ( /<>/, $_ );
	
	if ( $lastValue != $STATISTIC{$_} ) 
	{
	    $lastValue = $STATISTIC{$_};
	    $rank++;
	}
	
	# if less than score cut-off, then quit!
	if ( defined $scoreCutOff && $STATISTIC{$_} < $scoreCutOff ) { last; }

	# if exceeded the showing limit for the rank, quit!
	if ( ( $show > 0 ) && ( $show < $rank ) ) { last; }

	# do bit-stuffing
	if ( $_ =~ /^@/ ) { print DST "@"; }
	print DST "$_<>$rank $STATISTIC{$_} $NUMBERSTRINGS{$_}\n";
    }
}


# function to do formatted printing to the destination file!
sub formattedPrinting
{
    # we shall do the entire ranking first and create a rank hash so
    # that before we print we know the exact string size of the
    # biggest rank. basically we want to know exactly how big
    # everything is before we start printing so that we can space
    # things out just perfectly ("perfectly" being used a lil lightly)

    my $spaceBetwFields = 2;

    # set up the initial values as the minimum we need per field
    my $maxNgramStringLength = length("N-gram");
    my $maxStatStringLength = 0;
    my $maxFreqLength = 0;

    my $rank = 1;
    my $lastValue = 0;

    # find the smallest statistic value and assign to $lastValue
    foreach ( sort { $STATISTIC{$b} <=> $STATISTIC{$a} } keys %STATISTIC )
    { 
	$lastValue = $STATISTIC{$_}; 
	last;
    }

    foreach ( sort { $STATISTIC{$b} <=> $STATISTIC{$a} } keys %STATISTIC )
    {
	my @tokens = split ( /<>/, $_ );
	
	if ( $lastValue != $STATISTIC{$_} ) 
	{
	    $lastValue = $STATISTIC{$_};
	    $rank++;
	}
	
	# if less than score cut-off, then quit!
	if ( defined $scoreCutOff && $STATISTIC{$_} < $scoreCutOff ) { last; }
	
	# if exceeded the showing limit for the rank, quit!
	if ( ( $show > 0 ) && ( $show < $rank ) ) { last; }
	
	if (length($_) > $maxNgramStringLength) { $maxNgramStringLength = length($_); }
	if (length($STATISTIC{$_}) > $maxStatStringLength) { $maxStatStringLength = length($STATISTIC{$_}); }
	if (length($NUMBERSTRINGS{$_}) > $maxFreqLength) { $maxFreqLength = length($NUMBERSTRINGS{$_}); }
    }

    my $maxRankLength = length($rank);

    # so thats all our max lengths per field.
    # now create the heading string
    my $heading = "";

    my $spacesToAppend = ($maxNgramStringLength + $spaceBetwFields - length("N-gram")) / 2;
    for ($i = 0; $i < $spacesToAppend; $i++)
    {
	$heading .= " ";
    }
    $heading .= "N-gram";
    for ($i = 0; $i < $spacesToAppend; $i++)
    {
	$heading .= " ";
    }

    $spacesToAppend = (length("Rank") > $maxRankLength) ? length("Rank") : $maxRankLength;
    $spacesToAppend += $spaceBetwFields;
    $spacesToAppend = ($spacesToAppend - length("Rank")) / 2;
    for ($i = 0; $i < $spacesToAppend; $i++)
    {
	$heading .= " ";
    }
    $heading .= "Rank";
    for ($i = 0; $i < $spacesToAppend; $i++)
    {
	$heading .= " ";
    }

    $spacesToAppend = 
	(length("$statisticName value") > $maxStatStringLength) ? length("$statisticName value") : $maxStatStringLength;
    $spacesToAppend += $spaceBetwFields;
    $spacesToAppend = ($spacesToAppend - length("$statisticName value")) / 2;
    for ($i = 0; $i < $spacesToAppend; $i++)
    {
	$heading .= " ";
    }
    $heading .= "$statisticName value";
    for ($i = 0; $i < $spacesToAppend; $i++)
    {
	$heading .= " ";
    }

    $spacesToAppend = (length("Frequency Values") > $maxFreqLength) ? length("Frequency Values") : $maxFreqLength;
    $spacesToAppend += $spaceBetwFields;
    $spacesToAppend = ($spacesToAppend - length("Frequency Values")) / 2;
    for ($i = 0; $i < $spacesToAppend; $i++)
    {
	$heading .= " ";
    }
    $heading .= "Frequency Values";
    for ($i = 0; $i < $spacesToAppend; $i++)
    {
	$heading .= " ";
    }

    my $spacesToAppendForRank = (length("Rank") + $spaceBetwFields - $maxRankLength) / 2;
    my $spacesToAppendForStat = (length("$statisticName value") + $spaceBetwFields - $maxStatStringLength) / 2;
    my $spacesToAppendForFreqValues = (length("Frequency Values") + $spaceBetwFields - $maxFreqLength) / 2;

    printf DST "Total sample size = $totalNgrams\n\n";
    print DST "$heading\n";

    # now to draw the underline
    for ($i = 0; $i < length($heading); $i++) { print DST "-"; }
    printf DST "\n";

    $rank = 1;
    $lastValue = 0;

    # find the smallest statistic value and assign to $lastValue
    foreach ( sort { $STATISTIC{$b} <=> $STATISTIC{$a} } keys %STATISTIC )
    { 
	$lastValue = $STATISTIC{$_}; 
	last;
    }

    foreach ( sort { $STATISTIC{$b} <=> $STATISTIC{$a} } keys %STATISTIC )
    {
        my @tokens = split ( /<>/, $_ );
	
	if ( $lastValue != $STATISTIC{$_} )
	{
	    $lastValue = $STATISTIC{$_};
	    $rank++;
	}
	
	# if less than score cut-off, then quit!
	if ( defined $scoreCutOff && $STATISTIC{$_} < $scoreCutOff ) { last; }

	# if exceeded the showing limit for the rank, quit!
        if ( ( $show > 0 ) && ( $show < $rank ) ) { last; }
	
	# check size of string...
	$spacesToAppend = ($maxNgramStringLength + $spaceBetwFields - length($_));
	print DST $_;
	for ($i = 0; $i < $spacesToAppend; $i++) { print DST " "; }
	
	for ($i = 0; $i < $spacesToAppendForRank; $i++) { print DST " "; }
        chomp $rank;
	printf(DST "%${maxRankLength}d", $rank);
	for ($i = 0; $i < $spacesToAppendForRank; $i++) { print DST " "; }

	for ($i = 0; $i < $spacesToAppendForStat; $i++) { print DST " "; }
        chomp $STATISTIC{$_};
	printf(DST "%${maxStatStringLength}.${precision}f", $STATISTIC{$_});
	for ($i = 0; $i < $spacesToAppendForStat; $i++) { print DST " "; }

	for ($i = 0; $i < $spacesToAppendForFreqValues; $i++) { print DST " "; }
        chomp $NUMBERSTRINGS{$_};
	printf DST "$NUMBERSTRINGS{$_}\n";
    }
}

# function to check if parameter is an integer or not!
sub isInteger
{
    my $num = shift;
    my @array = split(//, $num);
    my $i = 0;
    my $flag = 1;
    
    while (defined($array[$i]))
    {
	if ($array[$i] eq '-' && $i == 0) { $i++; next; }

        if ( $array[$i] lt '0' || $array[$i] gt '9' )
        {
            $flag = 0;
            last;
        }
        $i++;
    }
    return $flag;
}

# function to create the default frequency combinations to be computed
# and output
sub getDefaultFreqCombos
{
    my $i;

    # first create the first index of the comb, that is the
    # combination that includes all the characters in the window

    $combIndex = 0;
    $freqComb[0][0] = $ngram;
    for ($i = 0; $i < $ngram; $i++)
    {
        $freqComb[0][$i+1] = $i;
    }
    $combIndex++;

    # now create the rest, starting with size 1
    for ($i = 1; $i < $ngram; $i++)
    {
        createCombination(0, $i);
    }
}

# function to read in the user requested frequency combinations
sub readFreqCombo
{
    my $sourceFile = shift;

    # open the source file
    open (FREQ_SRC, $sourceFile) || die ("Couldnt open $sourceFile\n");

    # read in the freq combo's one by one into the @freqComb array
    $combIndex = 0;
    while (<FREQ_SRC>)
    {
        s/^\s*//;
        s/\s*$//;
        my @tempArray = split(/\s+/);

        # first how many words make up this combination
        $freqComb[$combIndex][0] = $#tempArray+1;

        # next the indices of the words. note that these indices
        # shouldnt exceed $ngram-1... we'll check for that here.
        my $i;
        for ($i = 1; $i <= $freqComb[$combIndex][0]; $i++)
        {
            $freqComb[$combIndex][$i] = $tempArray[$i-1];

            # check!
            if ($freqComb[$combIndex][$i] >= $ngram)
            {
                printf STDERR ("Illegal index value at row %d column %d in file %s\n", $combIndex+1, $i, $sourceFile);
                exit;
            }
        }
        $combIndex++;
    }
}

sub createCombination
{
    my $level = shift;
    my $size = shift;

    if ($level == $size)
    {
        $freqComb[$combIndex][0] = $size;

        my $i;
        for ($i = 1; $i <= $size; $i++)
        {
            $freqComb[$combIndex][$i] = $tempCombArray[$i-1];
        }
        $combIndex++;
    }
    else
    {
        my $i;
        my $loopStart = (!$level)?0:$tempCombArray[$level-1]+1;

        for ($i = $loopStart; $i < $ngram; $i++)
        {
            $tempCombArray[$level] = $i;
            createCombination($level+1, $size);
        }
    }
}

# function to output a minimal usage note when the user has not provided any
# commandline options
sub minimalUsageNotes
{
    print "Usage: statistic.pl [OPTIONS] STATISTIC_LIBRARY DESTINATION SOURCE\n";
    askHelp();
}

# function to output help messages for this program
sub showHelp
{
    print "Usage: statistic.pl [OPTIONS] STATISTIC_LIBRARY DESTINATION SOURCE\n\n";

    print "Loads the given STATISTIC_LIBRARY, calculates the statistic on n-grams\n";
    print "in SOURCE and outputs results to DESTINATION. SOURCE must be an\n";
    print "n-gram-frequency file output by count.pl. N-grams in DESTINATION are\n";
    print "ranked on the value of their statistic.\n\n";

    print "OPTIONS:\n\n";

    print "  --ngram N          Assumes that n-grams in SOURCE file have N\n";
    print "                     tokens each. N = 2 by default.\n\n";
	  
    print "  --set_freq_combo FILE \n";
    print "                     Uses the frequency combinations in FILE to\n";
    print "                     decode the \"meaning\" of the frequency\n";
    print "                     values in SOURCE. By default, the default\n";
    print "                     frequency combinations output by count.pl\n";
    print "                     for ngrams of size N are assumed.\n\n";
	  
    print "  --get_freq_combo FILE \n";
    print "                     Prints out the frequency combinations being\n";
    print "                     used to FILE. If frequency combinations have\n";
    print "                     been provided through --set_freq_combo switch\n";
    print "                     above these are output; otherwise the default\n";
    print "                     combinations being used are output.\n\n";
	  
    print "   --frequency N     Ignores all n-grams with frequency < N.\n\n";
			        
    print "   --rank N          Shows only n-grams with rank <= N.\n\n";
			        
    print "   --precision N     Displays values upto N places of decimal.\n\n";
			        
    print "   --score N         Shows only n-grams which have score >= N.\n\n";
			        
    print "   --extended        Outputs chosen parameters in \"extended\"\n";
    print "                     format, and retains any extended data in\n";
    print "                     SOURCE. By default, suppresses any extended\n";
    print "                     information in SOURCE, and outputs no new\n";
    print "                     parameters.\n\n";
			        
    print "   --format          Creates formatted output.\n\n";
			        
    print "   --version         Prints the version number.\n\n";
			        
    print "   --help            Prints this help message.\n\n";

}

# function to show version number
sub showVersion
{
    print "statistic.pl     -      version 0.57\n";
    print "Copyright (C) 2000-2003, Ted Pedersen & Satanjeev Banerjee\n";
    print "Date of Last Update: 07/01/03\n";
}

# function to output "ask for help" message when the user's goofed up!
sub askHelp
{
    print "Type statistic.pl --help for help.\n";
}

