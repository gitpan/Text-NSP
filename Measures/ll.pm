
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

Bridget Thomson McInnes <bthomson@d.umn.edu>

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

#  Make sure that measure2d.pm is available in the PATH. First
#  we check in the directory you are running from, and then we
#  look through the system path. If the module is not found anywhere
#  then abort. 

my $module = "measure2d.pm"; my $modulename = "measure2d.pm";

if( !( -f $modulename ) ) {
    my $found = 0;
    #  Check each of the PATHS to see if the module is there
    foreach (split(/:/, $ENV{PATH})) {
 	$module = $_ . "/" . $modulename;
	if ( -f $module ) { $found = 1; last; }
    }
    # if still not found anywhere, quit!
    if ( ! $found ) { print "Could not find $modulename.\n"; exit; }
}

# Include the module into the current package.    
require $module;
require Exporter;

@ISA = qw ( Exporter );
@EXPORT = qw (initializeStatistic getStatisticName calculateStatistic errorCode errorString);

# function to set up various variables before the actual computation
# starts. also to check if we are being given bigrams, and if our
# frequency combinations are enough to do the computation
sub initializeStatistic
{ 
    measure2d::initializeStatistic(@_);
}

# function to calculate the ll value!
sub calculateStatistic
{
  
    #  The parameters passed into calculateStatistic
    #  need to be passed into getObservedValues for it 
    #  to calculate the Observed values. If there is a 
    #  problem with the observed values, this function 
    #  will return, causing the measure to abort its 
    #  computations and return with a zero code.

    if( !( ($n11, $n12, $n21, $n22) = measure2d::getObservedValues(@_) ) ) {
	return(0);
    }
    
    #  Check the expected values to ensure that they are not 
    #  equal to zero. Also, the quotient of the observed and 
    #  expected value should not be less than zero. If there 
    #  is a problem with the expected values, this function
    #  will return, causing the measure to abort and return
    #  with a zero code.

    if( !( ($m11, $m12, $m21, $m22) = measure2d::getExpectedValues() ) ) {
	return(0);
    }
        
    #  Get the total number of bigrams; no need to check 
    #  if this is correct because this value was already 
    #  checked and computed in measure2d::initalizeStatistic.
    #  getTotalBigrams simply reads an existing value. 

    my $npp = measure2d::getTotalBigrams();

    #  Now for the actual calculation of true mututal information!
    $logLikelihood = 0;

    # dont want ($nxy / $mxy) to be 0 or less! flag error if so!
    if ( $n11 ) { $logLikelihood += $n11 * log ( $n11 / $m11 ); }
    if ( $n12 ) { $logLikelihood += $n12 * log ( $n12 / $m12 ); }
    if ( $n21 ) { $logLikelihood += $n21 * log ( $n21 / $m21 ); }
    if ( $n22 ) { $logLikelihood += $n22 * log ( $n22 / $m22 ); }
    
    return ( 2 * $logLikelihood );
}

# function to return the error code of the last operation and reset
# error code. useful if the error can be recovered from!
sub errorCode 
{ 
    return measure2d::errorCode(); 
}

# Function to return the error message of the last operation and reset
# the message string. Useful if error can be recovered from!
sub errorString
{
    return measure2d::errorString();
}

# function to return the name of this statistic
sub getStatisticName
{
    return "Loglikelihood";
}

1;

