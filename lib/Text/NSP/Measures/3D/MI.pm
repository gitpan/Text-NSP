=head1 NAME

Text::NSP::Measures::2D::MI - Perl module that provides error checks for
Loglieklihood, Total Mutual Information, Pointwise Mutual Information.

=head1 SYNOPSIS

=head3 Basic Usage

  use Text::NSP::Measures::3D::MI::ll;

  my $ll = Text::NSP::Measures::3D::MI::ll->new();

  $ll_value = $ll->calculateStatistic( n111=>10,
                                       n1pp=>40,
                                       np1p=>45,
                                       npp1=>42,
                                       n11p=>20,
                                       n1p1=>23,
                                       np11=>21,
                                       nppp=>100);

  if( ($errorCode = $ll->getErrorCode()))
  {
    print STDERR $erroCode." - ".$ll->getErrorMessage();
  }
  else
  {
    print $ll->getStatisticName."value for bigram is ".$ll_value;
  }

=head1 DESCRIPTION

This module is the base class for the Loglikelihood and the True Mutual
Information measures. All these measure are similar. This module provides
error checks specific for these measures, it also implements the
computations that are common to these measures.

=over

=item Log-Likelihood measure is computed as

 Log-Likelihood = 2 * [n111 * log(n111/m111) + n112 * log(n112/m112) +
           n121 * log(n121/m121) + n122 * log(n122/m122) +
           n211 * log(n211/m211) + n212 * log(n212/m212) +
           n221 * log(n221/m221) + n222 * log(n222/m222)]

=item Total Mutual Information

tmi = [n111/nppp * log(n111/m111) + n112/nppp * log(n112/m112) +
        n121/nppp * log(n121/m121) + n122/nppp * log(n122/m122) +
        n211/nppp * log(n211/m211) + n212/nppp * log(n212/m212) +
        n221/nppp * log(n221/m221) + n222/nppp * log(n222/m222)]

=back

All these methods use the ratio of the observed values to expected values,
for computations, and thus have common error checks, sothey have been grouped
togrther.

=head2 Methods

=over

=cut


package Text::NSP::Measures::3D::MI;


use Text::NSP::Measures::3D;
use strict;
use Carp;
use warnings;


our ($VERSION, @ISA);

@ISA = qw(Text::NSP::Measures::3D);

$VERSION = '0.91';


=item calculateStatistic($count_values) - This method calls
the computeObservedValues() and the computeExpectedValues()
methods to compute the observed and expected values. It
checks thes values for any errors that might cause the
Loglikelihood, TMI and PMI measures to fail.

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

  # dont want ($nxy / $mxy) to be 0 or less! flag error if so and return;
  if ( $observed->{n111} )
  {
    if ($expected->{m111} == 0)
    {
      $self->{errorMessage} = "Expected value in cell (1,1,1) must not be zero";
      $self->{errorCodeNumber} = 211;
      return;
    }
  }
  if ( $observed->{n112} )
  {
    if ($expected->{m112} == 0)
    {
      $self->{errorMessage} = "Expected value in cell (1,1,2) must not be zero";
      $self->{errorCodeNumber} = 211;         return;
    }
  }
  if ( $observed->{n121} )
  {
    if ($expected->{m121} == 0)
    {
      $self->{errorMessage} = "Expected value in cell (1,2,1) must not be zero";
      $self->{errorCodeNumber} = 211;     return;
    }
  }
  if ( $observed->{n122} )
  {
    if ($expected->{m122} == 0)
    {
      $self->{errorMessage} = "Expected value in cell (1,2,2) must not be zero";
      $self->{errorCodeNumber} = 211;     return;
    }
  }
  if ( $observed->{n211} )
  {
    if ($expected->{m211} == 0)
    {
      $self->{errorMessage} = "Expected value in cell (2,1,1) must not be zero";
      $self->{errorCodeNumber} = 211;
      return;
    }
  }
  if ( $observed->{n212} )
  {
    if ($expected->{m212} == 0)
    {
      $self->{errorMessage} = "Expected value in cell (2,1,2) must not be zero";
      $self->{errorCodeNumber} = 211;         return;
    }
  }
  if ( $observed->{n221} )
  {
    if ($expected->{m221} == 0)
    {
      $self->{errorMessage} = "Expected value in cell (2,2,1) must not be zero";
      $self->{errorCodeNumber} = 211;     return;
    }
  }
  if ( $observed->{n222} )
  {
    if ($expected->{m222} == 0)
    {
      $self->{errorMessage} = "Expected value in cell (2,2,2) must not be zero";
      $self->{errorCodeNumber} = 211;     return;
    }
  }


  if (($observed->{n111} / $expected->{m111}) < 0)
  {
    $self->{errorMessage} = "About to take log of negative value for cell (1,1,1)";
    $self->{errorCodeNumber} = 212;     return;
  }
  if (($observed->{n112} / $expected->{m112}) < 0)
  {
    $self->{errorMessage} = "About to take log of negative value for cell (1,1,2)";
    $self->{errorCodeNumber} = 212;     return;
  }
  if (($observed->{n121} / $expected->{m121}) < 0)
  {
    $self->{errorMessage} = "About to take log of negative value for cell (1,2,1)";
    $self->{errorCodeNumber} = 212;     return;
  }
  if (($observed->{n122} / $expected->{m122}) < 0)
  {
    $self->{errorMessage} = "About to take log of negative value for cell (1,2,2)";
    $self->{errorCodeNumber} = 212;     return;
  }
  if (($observed->{n211} / $expected->{m211}) < 0)
  {
    $self->{errorMessage} = "About to take log of negative value for cell (2,1,1)";
    $self->{errorCodeNumber} = 212;     return;
  }
  if (($observed->{n212} / $expected->{m212}) < 0)
  {
    $self->{errorMessage} = "About to take log of negative value for cell (2,1,2)";
    $self->{errorCodeNumber} = 212;     return;
  }
  if (($observed->{n221} / $expected->{m221}) < 0)
  {
    $self->{errorMessage} = "About to take log of negative value for cell (2,2,1)";
    $self->{errorCodeNumber} = 212;     return;
  }
  if (($observed->{n222} / $expected->{m222}) < 0)
  {
    $self->{errorMessage} = "About to take log of negative value for cell (2,2,2)";
    $self->{errorCodeNumber} = 212;     return;
  }


  my @values = ($observed,$expected);
  #  Everything looks good so we can return the expected values
  return @values;
}



=item computePMI($n, $m) - Computes the pmi of a given
observed and expected value pair.

INPUT PARAMS  : $n       ..Observed value
                $m       ..Expected value

RETURN VALUES : lognm   .. the log of the ratio of
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

Last updated: $Id: MI.pm,v 1.4 2006/04/20 22:26:19 saiyam_kohli Exp $

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
