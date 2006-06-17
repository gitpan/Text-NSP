=head1 NAME

Text::NSP::Measures::2D::CHI

=head1 SYNOPSIS

=head3 Basic Usage

  use Text::NSP::Measures::2D::CHI::x2;

  my $x2 = Text::NSP::Measures::2D::CHI::x2->new();

  my $npp = 60; my $n1p = 20; my $np1 = 20;  my $n11 = 10;

  $x2_value = $x2->calculateStatistic( n11=>$n11,
                                      n1p=>$n1p,
                                      np1=>$np1,
                                      npp=>$npp);


  if( ($errorCode = $x2->getErrorCode()))
  {
    print STDERR $erroCode." - ".$x2->getErrorMessage();
  }
  else
  {
    print $x2->getStatisticName."value for bigram is ".$x2_value;
  }

=head1 DESCRIPTION

This module is the base class for the Chi-squared and Phi coefficient
measures. This module provides error checks specific for these measures,
it also implements the computations that are common to these measures.

=over

=item Pearson's Chi-Squared

  x2 = 2 * [((n11 - m11)/m11)^2 + ((n12 - m12)/m12)^2 +
           ((n21 - m21)/m21)^2 + ((n22 -m22)/m22)^2]

=item Phi Coefficient

 PHI^2 = ((n11 * n22) - (n21 * n21))^2/(n1p * np1 * np2 * n2p)

=item T-Score

 tscore = (n11 - m11)/sqrt(n11)

=back

Note that the value of PHI^2 is equivalent to
Pearson's Chi-Squared test multiplied by the sample size, that is:

 Chi-Squared = npp * PHI^2

 Although T-score seems quite different from the other two measures we
 have put it in the CHI family because like the other two measures it
 uses the difference between the obseved and expected values and is also
 quite similar in ranking the bigrams.

=over

=cut


package Text::NSP::Measures::2D::CHI;


use Text::NSP::Measures::2D;
use strict;
use Carp;
use warnings;
require Exporter;


our ($VERSION, @ISA);

@ISA = qw(Text::NSP::Measures::2D);

$VERSION = '0.93';

=item calculateStatistic() - This method calls the
computeObservedValues() and the computeExpectedValues() methods to
compute the observed and expected values. It checks thes values for
any errors that might cause the PHI and x2 measures to fail.

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

  if( !($expected  = $self->computeExpectedValues($values)) ) {
      return;
  }

  # dont want ($nxy / $mxy) to be 0 or less! flag error if so and return;
  if ( $observed->{n11} )
  {
    if ($expected->{m11} == 0)
    {
      $self->{errorMessage} = "Expected value in cell (1,1) must not be zero";
      $self->{errorCodeNumber} = 221;
      return;
    }
  }
  if ( $observed->{n12} )
  {
    if ($expected->{m12} == 0)
    {
      $self->{errorMessage} = "Expected value in cell (1,2) must not be zero";
      $self->{errorCodeNumber} = 221;         return;
    }
  }
  if ( $observed->{n21} )
  {
    if ($expected->{m21} == 0)
    {
      $self->{errorMessage} = "Expected value in cell (2,1) must not be zero";
      $self->{errorCodeNumber} = 221;     return;
    }
  }
  if ( $observed->{n22} )
  {
    if ($expected->{m22} == 0)
    {
      $self->{errorMessage} = "Expected value in cell (2,2) must not be zero";
      $self->{errorCodeNumber} = 221;     return;
    }
  }
  #  Everything looks good so we can return the expected values
  return $observed,$expected;
}




=item computeVal() - Computes the deviation in observed value with respect
to the expected values

INPUT PARAMS  : $n         ..Observed value
                $m         ..Expected value

RETURN VALUES : (n-m)^2/m  ..the log of the ratio of
                             observed value to expected
                             value.

=cut

sub computeVal
{
  my $self = shift;
  my $n = shift;
  my $m = shift;
  return (($n-$m)**2)/$m;
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

Last updated: $Id: CHI.pm,v 1.7 2006/05/27 17:37:21 saiyam_kohli Exp $

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