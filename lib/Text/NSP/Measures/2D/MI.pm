=head1 NAME

Text::NSP::Measures::2D::MI - Perl module that provides error checks
                              for Loglieklihood, Total Mutual
                              Information, Pointwise Mutual Information.

=head1 SYNOPSIS

=head3 Basic Usage

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

This module is the base class for the Loglikelihood, Total Mutual
Information and the Pointwise Mutual Information measures. All these
measure are similar. This module provides error checks specific for
these measures, it also implements the computations that are common
to these measures.

=over

=item Log-Likelihood measure is computed as

Log-Likelihood = 2 * [n11 * log(n11/m11) + n12 * log(n12/m12) +
                 n21 * log(n21/m21) + n22 * log(n22/m22)]

=item Total Mutual Information

TMI =   (1/npp)*[n11 * log(n11/m11)/log 2 + n12 * log(n12/m12)/log 2 +
                 n21 * log(n21/m21)/log 2 + n22 * log(n22/m22)/log 2]

=item Pointwise Mutual Information

PMI =   log (n11/m11)/log 2

=back

All these methods use the ratio of the observed values to expected values,
for computations, and thus have common error checks, sothey have been grouped
togrther.

=head2 Methods

=over

=cut


package Text::NSP::Measures::2D::MI;


use Text::NSP::Measures::2D;
use strict;
use Carp;
use warnings;

our ($VERSION, @ISA);

@ISA = qw(Text::NSP::Measures::2D);

$VERSION = '0.91';


=item calculateStatistic() - This method calls the
computeObservedValues() and the computeExpectedValues() methods to
compute the observed and expected values. It checks thes values for
any errors that might cause the Loglikelihood, TMI & PMI measures to
fail.


INPUT PARAMS  : $count_values           .. Reference of an hash containing
                                           the count values computed by the
                                           count.pl program.


RETURN VALUES : $observed, $expected    .. Observed and expected values for the
                                           given counts.

=cut

sub calculateStatistic
{
  my ($self,$values)=@_;

  my $observed;
  my $expected;

  if( !($observed = $self->computeObservedValues($values)) ) {
      return;
  }

  if( !($expected = $self->computeExpectedValues($values)) ) {
      return;
  }

  my $n11; my $n12; my $n21; my $n22;
  my $m11; my $m12; my $m21; my $m22;

  $n11 = $observed->{n11};
  $n12 = $observed->{n12};
  $n21 = $observed->{n21};
  $n22 = $observed->{n22};

  $m11 = $expected->{m11};
  $m12 = $expected->{m12};
  $m21 = $expected->{m21};
  $m22 = $expected->{m22};

  # dont want ($nxy / $mxy) to be 0 or less! flag error if so and return;
  if ( $n11 )
  {
    if ($m11 == 0)
    {
      $self->{errorMessage} = "Expected value in cell (1,1) must not be zero";
      $self->{errorCodeNumber} = 211;
      return;
    }
  }
  if ( $n12 )
  {
    if ($m12 == 0)
    {
      $self->{errorMessage} = "Expected value in cell (1,2) must not be zero";
      $self->{errorCodeNumber} = 211;         return;
    }
  }
  if ( $n21 )
  {
    if ($m21 == 0)
    {
      $self->{errorMessage} = "Expected value in cell (2,1) must not be zero";
      $self->{errorCodeNumber} = 211;     return;
    }
  }
  if ( $n22 )
  {
    if ($m22 == 0)
    {
      $self->{errorMessage} = "Expected value in cell (2,2) must not be zero";
      $self->{errorCodeNumber} = 211;     return;
    }
  }
  if (($n11 / $m11) < 0)
  {
    $self->{errorMessage} = "About to take log of negative value for cell (1,1)";
    $self->{errorCodeNumber} = 212;     return;
  }
  if (($n12 / $m12) < 0)
  {
    $self->{errorMessage} = "About to take log of negative value for cell (1,2)";
    $self->{errorCodeNumber} = 212;     return;
  }
  if (($n21 / $m21) < 0)
  {
    $self->{errorMessage} = "About to take log of negative value for cell (2,1)";
    $self->{errorCodeNumber} = 212;     return;
  }
  if (($n22 / $m22) < 0)
  {
    $self->{errorMessage} = "About to take log of negative value for cell (2,2)";
    $self->{errorCodeNumber} = 212;     return;
  }

  my @values = ($observed,$expected);

  #  Everything looks good so we can return the expected values
  return @values;
}



=item computePMI() - Computes the pmi of a given observed and expected
value pair.

INPUT PARAMS  : $n         ..Observed value
                $m         ..Expected value

RETURN VALUES : log(n/m)   ..the log of the ratio of
                             observed value to expected
                             value.

=cut

sub computePMI
{
  my $self = shift;
  my $n = shift;
  my $m = shift;
  my $val = $n/$m;
  if($val)
  {
    return log($val);
  }
  else
  {
    return 0;
  }
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

Last updated: $Id: MI.pm,v 1.16 2006/04/20 22:26:19 saiyam_kohli Exp $

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