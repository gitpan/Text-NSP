=head1 NAME

Text::NSP::Measures::2D - Perl module that provides basic framework
                          for building measure of association for
                          bigrams.

=head1 SYNOPSIS

=head3 Basic Usage

  use Text::NSP::Measures::2D::MI::ll;

  my $ll = Text::NSP::Measures::2D::MI::ll->new();

  my $npp = 60; my $n1p = 20; my $np1 = 20;  my $n11 = 10;

  $ll_value = $ll->calculateStatistic( n11=>$n11,
                                      n1p=>$n1p,
                                      np1=>$np1,
                                      npp=>$npp);

  if( ($errorCode = $ll->getErrorCode()))
  {
    print STDERR $erroCode." - ".$ll->getErrorMessage();
  }
  else
  {
    print $ll->getStatisticName."value for bigram is ".$ll_value;
  }


=head1 DESCRIPTION

This module is to be used as a foundation for building 2-dimensional
measures of association. The methods in this module retrieve observed
bigram frequency counts, marginal totals, and also compute expected
values. They also provide error checks for these counts.

With bigram or 2d measures we use an hash to store the 2x2 contingency
table to store the frequency counts associated with each word in the
bigram, as well as the number of times the bigram occurs. A
contingency table looks like

            |word2  | not-word2|
            --------------------
    word1   | n11   |   n12    |  n1p
  not-word1 | n21   |   n22    |  n2p
            --------------------
              np1       np2       npp

Marginal Frequencies:

  n1p = the number of bigrams where the first word is word1.
  np1 = the number of bigrams where the second word is word2.
  n2p = the number of bigrams where the first word is not word1.
  np2 = the number of bigrams where the second word is not word2.

  These marginal totals are stored in a hash. These values may then be
  referred to as follows (if the hash name is $marginal):

        $marginal->{n1p},
        $marginal->{np1},
        $marginal->{n2p},
        $marginal->{np2},
        $marginal->{npp}

  where the keys are n1p, np1, n2p, np2 and npp.

Observed Frequencies:

  n11 = number of times the bigram occurs, joint frequency
  n12 = number of times word1 occurs in the first position of a bigram
        when word2 does not occur in the second position.
  n21 = number of times word2 occurs in the second position of a
        bigram when word1 does not occur in the first position.
  n22 = number of bigrams where word1 is not in the first position and
        word2 is not in the second position.

  The observed frequencies are also stored in a hash. These values may
  then be referred to as follows (if the hash name is $observed):


        $observed->{n11},
        $observed->{n12},
        $observed->{n21},
        $observed->{n22}

  where the keys are n11, n12, n21 and n22.

Expected Frequencies:

  m11 = expected number of times both words in the bigram occur
        together if they are independent. (n1p*np1/npp)
  m12 = expected number of times word1 in the bigram will occur in
        the first position when word2 does not occur in the second
        position given that the words are independent. (n1p*np2/npp)
  m21 = expected number of times word2 in the bigram will occur
        in the second position when word1 does not occur in the first
        position given that the words are independent. (np1*n2p/npp)
  m22 = expected number of times word1 will not occur in the first
        position and word2 will not occur in the second position
        given that the words are independent. (n2p*np2/npp)

  Similarly the expected values are stored as

        $expected->{m11},
        $expected->{m12},
        $expected->{m21},
        $expected->{m22}

=head2 Methods

=over

=cut


package Text::NSP::Measures::2D;


use Text::NSP::Measures;
use strict;
use Carp;
use warnings;
use Exporter;            # Gain export capabilities


our ($VERSION, @ISA, $marginals, @EXPORT);

@EXPORT = qw($marginals);      # Export $a and @b by default

@ISA = qw(Text::NSP::Measures);

$VERSION = '0.91';

=item new() - This method creates and returns an object for the
              measures(constructor)


INPUT PARAMS  : none

RETURN VALUES : $this      .. Reference to the new object of
                              the measure.

=cut

sub new
{
  my $class = shift;
  my $this = {};

  $class = ref $class || $class;

  $this->{errorMessage} = '';
  $this->{errorCodeNumber} = 0;
  $this->{traceOutput} = '';
  if ($class eq 'Text::NSP::Measures::2D::MI')
  {
    $this->{errorMessage} .= "\nError (${class}::new()) - ";
    $this->{errorMessage} .= "This class is intended to be an abstract base class.";
    $this->{errorMessage} .= "Your class should override it.";
    $this->{errorCodeNumber} = 100;
  }
  elsif ($class eq 'Text::NSP::Measures::2D::CHI')
  {
    $this->{errorMessage} .= "\nError (${class}::new()) - ";
    $this->{errorMessage} .= "This class is intended to be an abstract base class.";
    $this->{errorMessage} .= "Your class should override it.";
    $this->{errorCodeNumber} = 100;
  }
  elsif ($class eq 'Text::NSP::Measures::2D::Fisher')
  {
    $this->{errorMessage} .= "\nError (${class}::new()) - ";
    $this->{errorMessage} .= "This class is intended to be an abstract base class.";
    $this->{errorMessage} .= "Your class should override it.";
    $this->{errorCodeNumber} = 100;
  }
  bless $this, $class;
  return $this;
}




=item computeObservedValues() - A method to compute observed values,
and also to verify that the computed Observed values are correct,
That is they are positive, less than the marginal totals and the
total bigram count.


INPUT PARAMS  : $count_values     .. Reference to an hash consisting
                                     of the count values passed to
                                     the calcualteStatistic() method.

RETURN VALUES : $observed         .. Reference to an hash consisting
                                     of the observed values computed
                                     from the marginal totals.
                                     (n11,n12,n21,n22)

=cut

sub computeObservedValues()
{
  my ($self,$values) = @_;

  #temporary local variables to store the cell values
  #of the contingency table
  my $n11= -1; my $n12; my $n21; my $n22;

  #temporary local variables to store the marginal totals
  my $npp; my $n1p; my $np1; my $n2p; my $np2;

  if(!defined $values->{n11})
  {
    $self->{errorMessage} = "Required frequency count (1,1) not passed";
    $self->{errorCodeNumber} = 200;
    return;
  }
  else
  {
    $n11=$values->{n11};
  }
  # joint frequency should be greater than equal to zero
  if ($n11 < 0)
  {
    $self->{errorMessage} = "Frequency value 'n11' must not be negative.";
    $self->{errorCodeNumber} = 201;
    return;
  }

  # get the marginal totals.
  $marginals = undef;
  if(!defined $marginals)
  {
    if( !($marginals = $self->computeMarginalTotals($values)))
    {
      return;
    }
  }

  #initialize the temporary local variables using the
  #marginal totals just computed
  $npp = $marginals->{npp};
  $n1p = $marginals->{n1p};
  $np1 = $marginals->{np1};
  $n2p = $marginals->{n2p};
  $np2 = $marginals->{np2};


  # joint frequency (n11) should be less than or equal to the
  # total number of bigrams (npp)
  if($n11 > $npp)
  {
    $self->{errorMessage} = "Frequency value 'n11' must not exceed total number of bigrams.";
    $self->{errorCodeNumber} = 202;
    return;
  }

  # joint frequency should be less than or equal to the marginal totals
  if ($n11 > $np1 || $n11 > $n1p)
  {
    $self->{errorMessage} = "Frequency value of ngram 'n11' must not exceed the marginal totals.";
    $self->{errorCodeNumber} = 202;
    return;
  }

  #  The marginal totals are reasonable so we can
  #  calculate the observed frequencies
  $n12 = $n1p - $n11;
  $n21 = $np1 - $n11;
  $n22 = $np2 - $n12;

  if ($n12 < 0)
  {
    $self->{errorMessage} = "Frequency value 'n12' must not be negative.";
    $self->{errorCodeNumber} = 201;
    return;
  }

  if ($n21 < 0)
  {
    $self->{errorMessage} = "Frequency value 'n21' must not be negative.";
    $self->{errorCodeNumber} = 201;
    return;
  }

  if ($n22 < 0)
  {
    $self->{errorMessage} = "Frequency value 'n22' must not be negative.";
    $self->{errorCodeNumber} = 201;
    return;
  }

  #initialize the hash to store and return the observed counts just computed.
  my %observed_values=();
  $observed_values{n11}=$n11;
  $observed_values{n12}=$n12;
  $observed_values{n21}=$n21;
  $observed_values{n22}=$n22;

  return (\%observed_values);
}



=item computeExpectedValues() - A method to compute expected values.


INPUT PARAMS  : $count_values     .. Reference to an hash consisting
                                     of the count output.

RETURN VALUES : $expected         .. Reference to an hash consisting
                                     of the expected values computed
                                     from the marginal totals.
                                     (m11,m12,m21,m22)

=cut

sub computeExpectedValues
{
  my ($self, $values)=@_;

  # get the marginal totals.
  if(!defined $marginals)
  {
    if( !($marginals = $self->computeMarginalTotals($values)))
    {
      return;
    }
  }

  #temporary local variables to store the marginal totals
  my $npp; my $n1p; my $np1; my $n2p; my $np2;

  #initialize the temporary local variables using the
  #marginal totals just computed
  $npp = $marginals->{npp};
  $n1p = $marginals->{n1p};
  $np1 = $marginals->{np1};
  $n2p = $marginals->{n2p};
  $np2 = $marginals->{np2};

  #  calculate the expected values
  my $m11 = $n1p * $np1 / $npp;
  my $m12 = $n1p * $np2 / $npp;
  my $m21 = $n2p * $np1 / $npp;
  my $m22 = $n2p * $np2 / $npp;

  #alls well so initialize the hash with the expected values
  #thus computed and return it.
  my %ex_values = ();
  $ex_values{m11}=$m11;
  $ex_values{m12}=$m12;
  $ex_values{m21}=$m21;
  $ex_values{m22}=$m22;

  return (\%ex_values);
}



=item computeMarginalTotals() - This method computes the marginal totals from the count values as
passed to it.


INPUT PARAMS  : $count_values     .. Reference to an hash consisting
                                     of the frequency combination
                                     output.

RETURN VALUES : $marginals        .. Reference to an hash consisting
                                     of the marginal totals computed
                                     from the freq combination output.

=cut

sub computeMarginalTotals
{

  my ($self, $values)=@_;

  #temporary local variable to store the total bigram count.
  my $npp;

  my %marginal_values = ();
  if(!defined $values->{npp})
  {
    $self->{errorMessage} = "Total bigram count not passed";
    $self->{errorCodeNumber} = 200;
    return;
  }
  elsif($values->{npp}<=0)
  {
    $self->{errorMessage} = "Total bigram count cannot be less than to zero";
    $self->{errorCodeNumber} = 204;
    return;
  }
  else
  {
    $npp = $values->{npp};
    $marginal_values{npp} = $npp;
  }

  my $n1p = -1;
  if(!defined $values->{n1p})
  {
    $self->{errorMessage} = "Required Marginal total (1,p) count not passed";
    $self->{errorCodeNumber} = 200;
    return;
  }
  else
  {
    $n1p=$values->{n1p};
  }
  # right frequency (n1p) should be greater than or equal to zero
  if ($n1p < 0)
  {
    $self->{errorMessage} = "Marginal total value 'n1p' must not be negative.";
    $self->{errorCodeNumber} = 204;
    return;
  }
  # right frequency (n1p) should be less than or equal to the total
  # number of bigrams (npp)
  if ($n1p > $npp)
  {
    $self->{errorMessage} = "Marginal total value 'n1p' must not exceed total number of bigrams.";
    $self->{errorCodeNumber} = 203;
    return;
  }


  my $np1 = -1;
  if(!defined $values->{np1})
  {
    $self->{errorMessage} = "Required Marginal total (p,1) count not passed";
    $self->{errorCodeNumber} = 200;
    return;
  }
  else
  {
    $np1=$values->{np1};
  }
  # left frequency (np1) should be greater than or equal to zero
  if ($np1 < 0)
  {
    $self->{errorMessage} = "Marginal total value 'np1' must not be negative.";
    $self->{errorCodeNumber} = 204;
    return;
  }
  # left frequency (np1) should be less than or equal to the total
  #  number of bigrams (npp)
  if ($np1 > $npp)
  {
    $self->{errorMessage} = "Marginal total value 'np1' must not exceed total number of bigrams.";
    $self->{errorCodeNumber} = 203;
    return;
  }

  my $np2 = $npp - $np1;
  my $n2p = $npp - $n1p;

  #initialize the hash with the rest of the marginal totals
  #and return a referrence to this hash.
  $marginal_values{n1p}=$n1p;
  $marginal_values{np1}=$np1;
  $marginal_values{n2p}=$n2p;
  $marginal_values{np2}=$np2;
  return \%marginal_values;
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

Last updated: $Id: 2D.pm,v 1.18 2006/04/20 22:26:19 saiyam_kohli Exp $

=head1 BUGS


=head1 SEE ALSO

L<http://groups.yahoo.com/group/ngram/>

L<http://www.d.umn.edu/~tpederse/nsp.html>


=head1 COPYRIGHT

=head1 SEE ALSO

L<http://groups.yahoo.com/group/ngram/>

L<http://www.d.umn.edu/~tpederse/nsp.html>


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
