=head1 NAME

Text::NSP::Measures - Perl modules for computing association scores of
                      Ngrams. This module provides the basic framework
                      for these measures.

=head1 SYNOPSIS

=head2 Basic Usage

  use Text::NSP::Measures::2D::MI::ll;

  my $ll = Text::NSP::Measures::2D::MI::ll->new();

  $ll_value = $ll->calculateStatistic( n11=>10,
                                       n1p=>20,
                                       np1=>20,
                                       npp=>60);

  if( ($errorCode = $ll->getErrorCode()))
  {
    print STDERR $erroCode." - ".$ll->getErrorMessage();
  }
  else
  {
    print $ll->getStatisticName."value for bigram is ".$ll_value;
  }

=head1 DESCRIPTION



=head2 Introduction

These modules provide perl implementations of mathematical functions
(association measures) that can be used to interpret the cooccurrence
frequency data for Ngrams. We define an Ngram as a sequence of 'n'
tokens that occur within a window of at least 'n' tokens in the text;
what constitutes a "token" can be defined by the user.

The measures that have been implemented in this distribution are:

      1.) Loglikelihood (for Bigrams and Trigrams)
      2.) True Mutual Information (for Bigrams and Trigrams)
      3.) Pointwise Mutual Information
      4.) Chi-squared Measure
      5.) Phi Coefficient
      6.) T-Score
      7.) Dice Coefficient
      8.) Odds Ratio
      9.) Fishers Exact Tests (Left, Right and TwoTailed)

Further discussion about these measures is in their respective
implementations.

=head2 Writing your own association measures

This module also provides a basic framework for building new measures
of association for Ngrams. The new Measure should either inherit from
Text::NSP::Measures::2D or Text::NSP::Measures::3D modules, depending
on whether it is a bigram or a trigram measure. Both these modules
implement methods that retrieve observed frequency counts, marginal
totals, and also compute expected values. They also provide error
checks for these counts.

You can either write your new measure as a new module, using Perl's
Object Oriented concepts, or you can simply write a perl program. Here
we will describe how to write a new measure using Object Oriented
Perl.

=over 4

=item 1


To create a new Perl module for the measure issue the following
command (replace 'NewMeasure' with the name of your measure):

h2xs -AXc -n Text::NSP::Measures::2D::NewMeasure
(for bigram measures)

                      or

h2xs -AXc -n Text::NSP::Measures::3D::NewMeasure
(for trigram measures)

This will create a new folder namely...

Text-NSP-Measures-2D-NewMeasure (for bigram)

            or

Text-NSP-Measures-3D-NewMeasure (for trigram)


This will create an empty framework for the new association measure.
Once you are done completing the changes you will have to install the
module before you can use it.

To make changes to the module open:

Text-NSP-Measures-2D-NewMeasure/lib/Text/NSP/Measures/2D/NewMeasure/
NewMeasure.pm

                        or

Text-NSP-Measures-3D-NewMeasure/lib/Text/NSP/Measures/3D/NewMeasure/
NewMeasure.pm

in your favorite text editor, and do as follows.

=item 2

Let us say you have named your module NewMeasure. The first line of
the file should declare that it is a package. Thus the first line of
the file NewMeasure.pm should be...

   package Text::NSP::Measures::2D::NewMeasure; (for bigram measures)

                     or

   package Text::NSP::Measures::3D::NewMeasure; (for trigram measures)

=item 3

To inherit the functionality from the 2D or 3D module you need to
include it in your NewMeasure.pm module.

A small code snippet to ensure that it is included is as follows:

=over 3

=item 1 For Bigrams

  use Text::NSP::Measures::2D;

  my @ISA;

  @ISA = qw(Text::NSP::Measures::2D);

=item 2 For Trigrams

  use Text::NSP::Measures::3D;

  my @ISA;

  @ISA = qw(Text::NSP::Measures::3D);

=back

=item 4

You need to implement at least one method in your package

   i)  calculateStatistic()

This method is passed an reference of a hash containing the
frequency values for an Ngram as found in the input Ngram file.

method calculateStatistic() is expected to return a (possibly
floating) value as the value of the statistical measure calculated
using the frequency values passed to it.

The first line of code in calculateStatistic should be

  my $self = shift;

this will store the reference of the object for the measure which was
used to invoke calculateStatistic().

There exist three methods in the modules Text::NSP::Measures::2d and
Text::NSP::Measures::3D in order to help calculate the bigram
statistic.

   1.  computeObservedValues($frequencies);
   2.  computeExpectedValues($frequencies);
   3.  computeMarginalTotals($frequencies);


These methods return the observed and expected values of the cells in
the contingency table. A 2D contingency table looks like:

            |word2  | not-word2|
            --------------------
    word1   | n11   |   n12    |  n1p
  not-word1 | n21   |   n22    |  n2p
            --------------------
              np1       np2       npp

Here the marginal totals are np1, n1p, np2, n2p, the Observed values
are n11, n12, n21, n22 and the expected values for the corresponding
observed values are represented using m11, m12, m21, m22, here m11
represents the expected value for the cell (1,1), m12 for the cell
(1,2) and so on.

The method computeObservedValues will return the observed values for
the given Ngram. The observed values are stored in a hash and the
reference to  the hash is returned. If it does not then there existed
an error in the calculation of these values and zero should be
returned. An example of how this can be used is as follows:

  my $self = shift;
  my %values = @_;

  if( !($observed = $self->computeObservedValues(\%values) ) )
  {
    return(0);
  }

where @_ is the parameters passed to calculateStatistic. And $self
contains a reference to the measures object. The method returns
referrence to a hash. This hash contains the key value pairs for the
observed values. You can use these values in your code by:

    $observed->{n11}
    $observed->{n12} and so on for each cell in the contingency table.

The method computeExpectedValues will return the list of expected
values from the given Ngram. If it does not then there was an error in
the calculation of these values and zero should be returned. An
example of how this can be used is as follows:

  my $self = shift;
  my %values = @_;

  if( !($expected = $self->computeExpectedValues(\%values) ) )
  {
          return(0);
  }

To use the expected values, you can

      $expected->{m11}
      $expected->{m12} and so on for the respective expected values


Similarly the computeMarginalTotals method computes the marginal
totals in the contingency table based on the observed frequencies. It
also returns 0 in case of some error. An example of usage for the
computeMarginalTotals() method is

  my $self = shift;
  my %values = @_;

  if( !($marginal = $self->computeMarginalTotals(\%values) ) )
  {
          return(0);
  }

To use the returned values you can use

      $marginal->{m11}
      $marginal->{m12} and so on for the respective marginal values

The last lines of a module should always return true, to achieve this
make sure that the last two lines of the are:

  1;
  __END__

Please see, that you can put in documentation after these lines.

To tie it all together here is an example of a measure that computes
the sum of ngram frequency counts.

use Text::NSP::Measures::2D;
use strict;

our ($VERSION, @ISA);

@ISA = qw(Text::NSP::Measures::2D::MI);

$VERSION = '0.91';

sub calculateStatistic
{
  my $self = shift;
  my %values = @_;

  my $observed;

  # computes and returns the observed and expected values from
  # the frequency combination values. returns 0 if there is an
  # error in the computation or the values are inconsistent.
  if( !($observed = $self->computeObservedValues(\%values)) ) {
    return;
  }

  #  Now for the actual calculation of the association measure
  my $NewMeasure = 0;

  $NewMeasure += $observed->{n11};
  $NewMeasure += $observed->{n12};
  $NewMeasure += $observed->{n21};
  $NewMeasure += $observed->{n22};

  return ( $NewMeasure );
}



=item 5

There are four other methods that are not mandatory, but may be
implemented. These are:

     i) initializeStatistic()
    ii) getErrorCode
   iii) getErrorMessage
   iv) getStatisticName()

Whenever an object of the measure is created the constructor
will invoke the initializeStatistic() method, if there is no
need for any specific initialization in the measure you need
not define this method, and the initialization will be handled
by the Text::NSP::Measures modules initializeStatistic() method.

The getErrorCode method is called immediately after every call to
method calculateStatistic(). This method is used to return the
errorCode, if any, in the previous operations. To view all the
possible errorcodes and the corresponding error message please reffer
to the Text::NSP documentation (perldoc Text::NSP).You can create new
errorcodes in your measure, if the existing errorcodes are not
sufficient.

The Text::NSP::Measures module implements both getErrorCode()
and getErrorMessage() methods and these implementations of the method
will be invoked if the user does not define these methods. But if you
want to add some other actions that need to be performed in case
of an error you must override these methods by implementing them in
your module. You can invoke the Text::NSP::Measures getErrorCode()
methods from your measures getErrorCode() method.

An example of this is below:

  sub getErrorCode
  {
    my $self = shift;

    my $code = $self->SUPER::getErrorCode();

    #your code here

    return $code; #(or any other value)
  }

  sub getErrorMessage
  {
    my $self = shift;

    my $message = $self->SUPER::getErrorMessage();

    #your code here

    return $message; #(or any other value)
  }

The fourth method that may be implemented is getStatisticName().
If this method is implemented, it is expected to return a string
containing the name of the statistic being implmented. This string
is used in the formatted output of statistic.pl. If this method
is not implemented, then the statistic name entered on the
commandline is used in the formatted output.

Note that all the methods described in this section are optional.
So, if the user elects to not implement these methods, no harm will
be done.

The user may implement other methods too, but since statistic.pl is
not expecting anything besides the five methods above, doing so would
have no effect on statistic.pl.

=item 6

You will need to install your module before you can use it. You can do
this by

  Change to the base directory for the module, i.e.
  NewMeasure

  Then issue the following commands:

    perl Makefile.PL
    make
    make test
    make install

        or

    perl Makefile.PL PREFIX=<desination directory>
    make
    make test
    make install


If you get any errors in the installation process, please make sure
that you have not made any syntactical error in your code and also
make sure that you have already installed the Text-NSP package.

=back

=head2 Errors to look out for:

=over 4

=item 1

The Text-NSP package is not installed - Make sure that Text-NSP
package is installed and you have inherited the correct module
(Text::NSP::Measures::2D or Text::NSP::Measures::3D).

=item 2

The five methods (1 mandatory, 4 non-mandatory) must have their
names match EXACTLY with those shown above. Again, names are all
case sensitive.

=item 3

This statement is present at the end of the module:
1;

=back

=head2 Methods

=over

=cut


package Text::NSP::Measures;


use strict;
use Carp;
use warnings;


our ($VERSION, @ISA);

@ISA = qw(Text::NSP);

$VERSION = '0.91';


=item new() - In case user tries to create an object of the abstract
class, this method is here to handle the error and print a small help.

# INPUT PARAMS  : none

# RETURN VALUES : none

=cut

sub new
{
  my $class = shift;
  my $this = {};
  if ($class eq 'Text::NSP::Measures')
  {
    $this->{errorMessage} .= "\nError (${class}::new()) - ";
    $this->{errorMessage} .= "This class is intended to be an abstract base class for measures";
    $this->{errorCodeNumber} = 100;
  }
  return $this;
}


=item getErrorCode() - Returns the error code in the last operation if
any and resets the errorcode to 0.

# INPUT PARAMS  : none

# RETURN VALUES : errorCode  .. The current error code.

=cut

sub getErrorCode
{
  my ($self) = @_;
  my $temp = $self->{errorCodeNumber};
  $self->{errorCodeNumber} = undef;
  return $temp;
}



=item getErrorMessage() - Returns the error message in the last
operation if any and resets the string to ''.

# INPUT PARAMS  : none

# RETURN VALUES : errorMessage  .. The current error message.

=cut

sub getErrorMessage
{
  my ($self) = @_;
  my $temp = $self->{errorMessage};
  $self->{errorMessage} = undef;
  return($temp);
}




sub getStatisticName
{
    return;
}



1;
__END__


=back

=head1 AUTHOR

Ted Pedersen,                University of Minnesota Duluth
                             E<lt>tpederse@d.umn.eduE<gt>

Satanjeev Banerjee,          Carnegie Mellon University
                             E<lt>satanjeev@cmu.eduE<gt>

Amruta Purandare,            University of Pittsburgh
                             E<lt>amruta@cs.pitt.eduE<gt>

Bridget Thomson-McInnes,     University of Minnesota Twin Cities
                             E<lt>bthompson@d.umn.eduE<gt>

Saiyam Kohli,                University of Minnesota Duluth
                             E<lt>kohli003@d.umn.eduE<gt>

=head1 HISTORY

Last updated: $Id: Measures.pm,v 1.15 2006/03/25 04:21:22 saiyam_kohli
Exp $

=head1 BUGS


=head1 SEE ALSO

L<http://groups.yahoo.com/group/Ngram/>

L<http://www.d.umn.edu/~tpederse/nsp.html>


=head1 COPYRIGHT

Copyright (C) 2000-2006, Ted Pedersen, Satanjeev Banerjee, Amruta
Purandare, Bridget Thomson-McInnes and Saiyam Kohli

=head1 COPYRIGHT

Copyright (C) 2000-2006, Ted Pedersen, Satanjeev Banerjee,
Amruta Purandare, Bridget Thomson-McInnes and Saiyam Kohli

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or (at
your option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to

    The Free Software Foundation, Inc.,
    59 Temple Place - Suite 330,
    Boston, MA  02111-1307, USA.

Note: a copy of the GNU General Public License is available on the web
at L<http://www.gnu.org/licenses/gpl.txt> and is included in this
distribution as GPL.txt.

=cut