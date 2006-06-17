=head1 NAME

Text::NSP::Measures::3D - Perl module that provides basic framework for
building measure of association for trigrams.

=head1 SYNOPSIS

This module can be used as a foundation for building 3-dimensional
measures of association that can then be used by statistic.pl. In
particular this module provides methods that give convenient access to
3-d (i.e., trigram) frequency counts as created by count.pl, as well as
some degree of error handling that verifies the data.


=head3 Basic Usage

  use Text::NSP::Measures::3D::MI::ll;

  my $ll = Text::NSP::Measures::3D::MI::ll->new();

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
    print $ll->getStatisticName."value for trigram is ".$ll_value;
  }

=head1 DESCRIPTION

The methods in this module retrieve observed trigram frequency counts and
marginal totals, and also compute expected values. They also provide
support for error checking of the output produced by count.pl. These
methods are used in all the trigram (3d) measure modules provided in NSP.
If you are writing your own 3d measure, you can use these methods as well.

With trigram or 3d measures we use a 3x3 contingency table to store the
frequency counts associated with each word in the trigram, as well as the
number of times the trigram occurs. The notation we employ is as follows:

Marginal Frequencies:

 n1pp = the number of trigrams where the first word is word1.
 np1p = the number of trigrams where the second word is word2.
 npp1 = the number of trigrams where the third word is word3
 n2pp = the number of trigrams where the first word is not word1.
 np2p = the number of trigrams where the second word is not word2.
 npp2 = the number of trigrams where the third word is not word3.

Observed Frequencies:

 n111 = number of times word1, word2 and word3 occur together in
        their respective positions, joint frequency.
 n112 = number of times word1 and word2 occur in their respective
        positions but word3 does not.
 n121 = number of times word1 and word3 occur in their respective
        positions but word2 does not.
 n211 = number of times word2 and word3 occur in their respective
        positions but word1 does not.
 n122 = number of times word1 occurs in its respective position
        but word2 and word3 do not.
 n212 = number of times word2 occurs in in its respective position
        but word1 and word3 do not.
 n221 = number of times word3 occurs in its respective position
        but word1 and word2 do not.
 n222 = number of time neither word1, word2 or word3 occur in their
        respective positions.

Expected Frequencies:

 m111 = expected number of times word1, word2 and word3 occur together in
        their respective positions.
 m112 = expected number of times word1 and word2 occur in their respective
        positions but word3 does not.
 m121 = expected number of times word1 and word3 occur in their respective
        positions but word2 does not.
 m211 = expected number of times word2 and word3 occur in their respective
        positions but word1 does not.
 m122 = expected number of times word1 occurs in its respective position
        but word2 and word3 do not.
 m212 = expected number of times word2 occurs in in its respective position
        but word1 and word3 do not.
 m221 = expected number of times word3 occurs in its respective position
        but word1 and word2 do not.
 m222 = expected number of time neither word1, word2 or word3 occur in their
        respective positions.

=head2 Methods

=over

=cut


package Text::NSP::Measures::3D;


use Text::NSP::Measures;
use strict;
use Carp;
use warnings;
use Exporter;            # Gain export capabilities


our ($VERSION, @ISA, $marginals, @EXPORT);

@EXPORT = qw($marginals);      # Export $a and @b by default

@ISA = qw(Text::NSP::Measures);

$VERSION = '0.93';

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
  if ($class eq 'Text::NSP::Measures::3D::MI')
  {
    $this->{errorMessage} .= "\nError (${class}::new()) - ";
    $this->{errorMessage} .= "This class is intended to be an abstract base class.";
    $this->{errorMessage} .= "Your class should override it.";
    $this->{errorCodeNumber} = 100;
  }
  bless $this, $class;
  return $this;
}


=item computeObservedValues($count_values) - A method to
compute observed values, and also to verify that the
computed Observed values are correct, That is they are
positive, less than the marginal totals and the total
bigram count.

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

  my $n111 = -1;
  if(!defined $values->{n111})
  {
    $self->{errorMessage} = "Required trigram (1,1,1) not passed";
    $self->{errorCodeNumber} = 200;
    return;
  }
  else
  {
    $n111=$values->{n111};
  }
  # joint frequency should be greater than equal to zero
  if ($n111< 0)
  {
    $self->{errorMessage} = "Frequency value (n111=$n111) must not be negative.";
    $self->{errorCodeNumber} = 201;  return;
  }

  $marginals = undef;
  if(!defined $marginals)
  {
    if( !($marginals = $self->computeMarginalTotals($values)))
    {
      return;
    }
  }

  # n111 frequency should be less than or equal to totalBigrams
  if ($n111> $marginals->{nppp})
  {
    $self->{errorMessage} = "Frequency value (n111=$n111) must not exceed total number of bigrams.";
    $self->{errorCodeNumber} = 202;  return;
  }
  # joint frequency n111 should be less than or equal to the marginal totals
  if ($n111 > $marginals->{n1pp} || $n111 > $marginals->{np1p} || $n111 > $marginals->{npp1})
  {
    $self->{errorMessage} = "Frequency value of ngram (n111=$n111) must not exceed the marginal totals.";
    $self->{errorCodeNumber} = 202;  return;
  }


  my $n112=$marginals->{n11p}-$n111;
  if ($n112< 0)
  {
    $self->{errorMessage} = "Frequency value (n112=$n112) must not be negative.";
    $self->{errorCodeNumber} = 201;  return;
  }
  # n111 frequency should be less than or equal to totalBigrams
  if ($n112> $marginals->{nppp})
  {
    $self->{errorMessage} = "Frequency value (n112=$n112) must not exceed total number of bigrams.";
    $self->{errorCodeNumber} = 202;  return;
  }
  # joint frequency n111 should be less than or equal to the marginal totals
  if ($n112 > $marginals->{n1pp} || $n112 > $marginals->{np1p} || $n112 > $marginals->{npp2})
  {
    $self->{errorMessage} = "Frequency value of ngram (n112=$n112) must not exceed the marginal totals.";
    $self->{errorCodeNumber} = 202;  return;
  }


  my $n121=$marginals->{n1p1}-$n111;
  if ($n121< 0)
  {
    $self->{errorMessage} = "Frequency value (n121=$n121) must not be negative.";
    $self->{errorCodeNumber} = 201;  return;
  }
  # n111 frequency should be less than or equal to totalBigrams
  if ($n121> $marginals->{nppp})
  {
    $self->{errorMessage} = "Frequency value (n121=$n121) must not exceed total number of bigrams.";
    $self->{errorCodeNumber} = 202;  return;
  }
  # joint frequency n111 should be less than or equal to the marginal totals
  if ($n121 > $marginals->{n1pp} || $n121 > $marginals->{np2p} || $n121 > $marginals->{npp1})
  {
    $self->{errorMessage} = "Frequency value of ngram (n121=$n121) must not exceed the marginal totals.";
    $self->{errorCodeNumber} = 202;  return;
  }


  my $n211=$marginals->{np11}-$n111;
  if ($n211< 0)
  {
    $self->{errorMessage} = "Frequency value (n211=$n211) must not be negative.";
    $self->{errorCodeNumber} = 201;  return;
  }
  # n111 frequency should be less than or equal to totalBigrams
  if ($n211> $marginals->{nppp})
  {
    $self->{errorMessage} = "Frequency value (n211=$n211) must not exceed total number of bigrams.";
    $self->{errorCodeNumber} = 202;  return;
  }
  # joint frequency n111 should be less than or equal to the marginal totals
  if ($n211 > $marginals->{n2pp} || $n211 > $marginals->{np1p} || $n211 > $marginals->{npp1})
  {
    $self->{errorMessage} = "Frequency value of ngram (n211=$n211) must not exceed the marginal totals.";
    $self->{errorCodeNumber} = 202;  return;
  }

  my $n212=$marginals->{np1p}-$n111-$n112-$n211;
  if ($n212< 0)
  {
    $self->{errorMessage} = "Frequency value (n212=$n212) must not be negative.";
    $self->{errorCodeNumber} = 201;  return;
  }
  # n111 frequency should be less than or equal to totalBigrams
  if ($n212> $marginals->{nppp})
  {
    $self->{errorMessage} = "Frequency value (n212=$n212) must not exceed total number of bigrams.";
    $self->{errorCodeNumber} = 202;  return;
  }
  # joint frequency n111 should be less than or equal to the marginal totals
  if ($n212 > $marginals->{n2pp} || $n212 > $marginals->{np1p} || $n212 > $marginals->{npp2})
  {
    $self->{errorMessage} = "Frequency value of ngram (n212=$n212) must not exceed the marginal totals.";
    $self->{errorCodeNumber} = 202;  return;
  }


  my $n122=$marginals->{n1pp}-$n111-$n112-$n121;
  if ($n122< 0)
  {
    $self->{errorMessage} = "Frequency value (n122=$n122) must not be negative.";
    $self->{errorCodeNumber} = 201;  return;
  }
  # n111 frequency should be less than or equal to totalBigrams
  if ($n122> $marginals->{nppp})
  {
    $self->{errorMessage} = "Frequency value (n122=$n122) must not exceed total number of bigrams.";
    $self->{errorCodeNumber} = 202;  return;
  }
  # joint frequency n111 should be less than or equal to the marginal totals
  if ($n122 > $marginals->{n1pp} || $n122 > $marginals->{np2p} || $n122 > $marginals->{npp2})
  {
    $self->{errorMessage} = "Frequency value of ngram (n122=$n122) must not exceed the marginal totals.";
    $self->{errorCodeNumber} = 202;  return;
  }


  my $n221=$marginals->{npp1}-$n111-$n211-$n121;
  if ($n221< 0)
  {
    $self->{errorMessage} = "Frequency value (n221=$n221) must not be negative.";
    $self->{errorCodeNumber} = 201;  return;
  }
  # n111 frequency should be less than or equal to totalBigrams
  if ($n221> $marginals->{nppp})
  {
    $self->{errorMessage} = "Frequency value (n221=$n221) must not exceed total number of bigrams.";
    $self->{errorCodeNumber} = 202;  return;
  }
  # joint frequency n111 should be less than or equal to the marginal totals
  if ($n221 > $marginals->{n2pp} || $n221 > $marginals->{np2p} || $n221 > $marginals->{npp1})
  {
    $self->{errorMessage} = "Frequency value of ngram (n221=$n221) must not exceed the marginal totals.";
    $self->{errorCodeNumber} = 202;  return;
  }


  my $n222=$marginals->{nppp}-($n111+$n112+$n121+$n122+$n211+$n212+$n221);
  if ($n222< 0)
  {
    $self->{errorMessage} = "Frequency value (n222=$n222) must not be negative.";
    $self->{errorCodeNumber} = 201;  return;
  }
  # n111 frequency should be less than or equal to totalBigrams
  if ($n222> $marginals->{nppp})
  {
    $self->{errorMessage} = "Frequency value (n222=$n222) must not exceed total number of bigrams.";
    $self->{errorCodeNumber} = 202;  return;
  }
  # joint frequency n111 should be less than or equal to the marginal totals
  if ($n222 > $marginals->{n2pp} || $n222 > $marginals->{np2p} || $n222 > $marginals->{npp2})
  {
    $self->{errorMessage} = "Frequency value of ngram (n222=$n222) must not exceed the marginal totals.";
    $self->{errorCodeNumber} = 202;  return;
  }


  my %observed = ();
  $observed{n111} = $n111;
  $observed{n112} = $n112;
  $observed{n121} = $n121;
  $observed{n122} = $n122;
  $observed{n211} = $n211;
  $observed{n212} = $n212;
  $observed{n221} = $n221;
  $observed{n222} = $n222;

  return (\%observed);
}





=item computeExpectedValues($count_values) - A method to compute
expected values.

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

  if(!defined $marginals)
  {
    if( !($marginals = $self->computeMarginalTotals($values)))
    {
      return;
    }
  }

  my $m111=$marginals->{n1pp}*$marginals->{np1p}*$marginals->{npp1}/($marginals->{nppp}**2);
  my $m112=$marginals->{n1pp}*$marginals->{np1p}*$marginals->{npp2}/($marginals->{nppp}**2);
  my $m121=$marginals->{n1pp}*$marginals->{np2p}*$marginals->{npp1}/($marginals->{nppp}**2);
  my $m122=$marginals->{n1pp}*$marginals->{np2p}*$marginals->{npp2}/($marginals->{nppp}**2);
  my $m211=$marginals->{n2pp}*$marginals->{np1p}*$marginals->{npp1}/($marginals->{nppp}**2);
  my $m212=$marginals->{n2pp}*$marginals->{np1p}*$marginals->{npp2}/($marginals->{nppp}**2);
  my $m221=$marginals->{n2pp}*$marginals->{np2p}*$marginals->{npp1}/($marginals->{nppp}**2);
  my $m222=$marginals->{n2pp}*$marginals->{np2p}*$marginals->{npp2}/($marginals->{nppp}**2);

  my %ex_values = ();
  $ex_values{m111}=$m111;
  $ex_values{m112}=$m112;
  $ex_values{m121}=$m121;
  $ex_values{m122}=$m122;
  $ex_values{m211}=$m211;
  $ex_values{m212}=$m212;
  $ex_values{m221}=$m221;
  $ex_values{m222}=$m222;

  return (\%ex_values);
}






=item computeMarginalTotals($marginal_values) - This method
computes the marginal totals from the valuescomputed by the count.pl
program and are passed to the calculateStatistic() method.

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

  my %marginal_values = ();
  my $nppp = -1;
  if(!defined $values->{nppp})
  {
    $self->{errorMessage} = "Total trigram count not passed";
    $self->{errorCodeNumber} = 200;
    return;
  }
  elsif($values->{nppp}<=0)
  {
    $self->{errorMessage} = "Total trigram count cannot be less than to zero";
    $self->{errorCodeNumber} = 200;
    return;
  }
  else
  {
    $marginal_values{nppp}=$values->{nppp};
    $nppp = $values->{nppp};
  }


  my $n1pp = -1;
  if(!defined $values->{n1pp})
  {
    $self->{errorMessage} = "Required marginal total (1,p,p) not passed";
    $self->{errorCodeNumber} = 200;
    return;
  }
  else
  {
    $n1pp=$values->{n1pp};
  }
  # n1pp should be greater than or equal to zero
  if ($n1pp< 0)
  {
    $self->{errorMessage} = "Marginal total value ($n1pp) must not be negative.";
    $self->{errorCodeNumber} = 204;  return;
  }
  # n1pp should be less than or equal to totalBigrams
  if ($n1pp > $nppp)
  {
    $self->{errorMessage} = "Marginal total value ($n1pp) must not exceed total number of bigrams.";
    $self->{errorCodeNumber} = 203;  return;
  }



  my $np1p = -1;
  if(!defined $values->{np1p})
  {
    $self->{errorMessage} = "Required marginal total (p,1,p) not passed";
    $self->{errorCodeNumber} = 200;
    return;
  }
  else
  {
    $np1p=$values->{np1p};
  }
  # np1p should be greater than or equal to zero
  if ($np1p< 0)
  {
    $self->{errorMessage} = "Marginal total value ($np1p) must not be negative.";
    $self->{errorCodeNumber} = 204;  return;
  }
  # np1p should be less than or equal to totalBigrams
  if ($np1p > $nppp)
  {
    $self->{errorMessage} = "Marginal total value ($np1p) must not exceed total number of trigrams.";
    $self->{errorCodeNumber} = 203;  return;
  }


  my $npp1 = -1;
  if(!defined $values->{npp1})
  {
    $self->{errorMessage} = "Required marginal total (p,p,1) not passed";
    $self->{errorCodeNumber} = 200;
    return;
  }
  else
  {
    $npp1=$values->{npp1};
  }
  # npp1 should be greater than or equal to zero
  if ($npp1< 0)
  {
    $self->{errorMessage} = "Marginal total value ($npp1) must not be negative.";
    $self->{errorCodeNumber} = 204;  return;
  }
  # npp1 should be less than or equal to totalBigrams
  if ($npp1 > $nppp)
  {
    $self->{errorMessage} = "Marginal total value ($npp1) must not exceed total number of bigrams.";
    $self->{errorCodeNumber} = 203;  return;
  }

  my $n11p = -1;
  if(!defined $values->{n11p})
  {
    $self->{errorMessage} = "Required marginal total (1,1,p) not passed";
    $self->{errorCodeNumber} = 200;
    return;
  }
  else
  {
    $n11p=$values->{n11p};
  }
  # n11p should be greater than or equal to zero
  if ($n11p< 0)
  {
    $self->{errorMessage} = "Marginal total value ($n11p) must not be negative.";
    $self->{errorCodeNumber} = 204;  return;
  }
  # n11p should be less than or equal to totalBigrams
  if ($n11p > $nppp)
  {
    $self->{errorMessage} = "Marginal total value ($n11p) must not exceed total number of bigrams.";
    $self->{errorCodeNumber} = 203;  return;
  }

  my $np11=-1;
  if(!defined $values->{np11})
  {
    $self->{errorMessage} = "Required marginal total (p,1,1) not passed";
    $self->{errorCodeNumber} = 200;
    return;
  }
  else
  {
    $np11=$values->{np11};
  }
  # np11 should be greater than or equal to zero
  if ($np11< 0)
  {
    $self->{errorMessage} = "Marginal total value ($np11) must not be negative.";
    $self->{errorCodeNumber} = 204;  return;
  }
  # np11 should be less than or equal to totalBigrams
  if ($np11 > $nppp)
  {
    $self->{errorMessage} = "Marginal total value ($np11) must not exceed total number of trigrams.";
    $self->{errorCodeNumber} = 203;  return;
  }

  my $n1p1=-1;
  if(!defined $values->{n1p1})
  {
    $self->{errorMessage} = "Required marginal total (1,p,1) not passed";
    $self->{errorCodeNumber} = 200;
    return;
  }
  else
  {
    $n1p1=$values->{n1p1};
  }
  # n1p1 should be greater than or equal to zero
  if ($n1p1< 0)
  {
    $self->{errorMessage} = "Marginal total value ($n1p1) must not be negative.";
    $self->{errorCodeNumber} = 204;  return;
  }
  # n1p1 should be less than or equal to totalBigrams
  if ($n1p1 > $nppp)
  {
    $self->{errorMessage} = "Marginal total value ($n1p1) must not exceed total number of bigrams.";
    $self->{errorCodeNumber} = 203;  return;
  }

  my $n2pp=$values->{nppp}-$n1pp;
  my $np2p=$values->{nppp}-$np1p;
  my $npp2=$values->{nppp}-$npp1;


  $marginal_values{n1pp} = $n1pp;
  $marginal_values{np1p} = $np1p;
  $marginal_values{npp1} = $npp1;
  $marginal_values{n11p} = $n11p;
  $marginal_values{np11} = $np11;
  $marginal_values{n1p1} = $n1p1;
  $marginal_values{n2pp} = $n2pp;
  $marginal_values{np2p} = $np2p;
  $marginal_values{npp2} = $npp2;

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

Last updated: $Id: 3D.pm,v 1.11 2006/06/15 16:53:04 saiyam_kohli Exp $

=head1 BUGS


=head1 SEE ALSO

L<http://groups.yahoo.com/group/ngram/>

L<http://www.d.umn.edu/~tpederse/nsp.html>


=head1 COPYRIGHT

Copyright (C) 2000-2006, Ted Pedersen, Satanjeev Banerjee, Amruta
Purandare, Bridget Thomson-McInnes and Saiyam Kohli

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the Free
Software Foundation; either version 2 of the License, or (at your option)
any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to

    The Free Software Foundation, Inc.,
    59 Temple Place - Suite 330,
    Boston, MA  02111-1307, USA.

Note: a copy of the GNU General Public License is available on the web
at L<http://www.gnu.org/licenses/gpl.txt> and is included in this
distribution as GPL.txt.

=cut