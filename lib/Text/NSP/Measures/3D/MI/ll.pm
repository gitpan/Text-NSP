=head1 NAME

Text::NSP::Measures::3D::MI::ll - Perl module that implements Loglikelihood
measure of association for trigrams.

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

The log-likelihood ratio measures the devitation between the observed data
and what would be expected if <word1>, <word2> and <word3> were independent.
The higher the score, the less evidence there is in favor of concluding that
the words are independent.

The expected values for the internal cells are calculated by taking the
product of their associated marginals and dividing by the sample size,
for example:

            n1pp * np1p * npp1
   m111=   --------------------
                   nppp

Then the deviation between observed and expected values for each internal
cell is computed to arrive at the log-likelihood value.

 Log-Likelihood = 2 * [n111 * log(n111/m111) + n112 * log(n112/m112) +
           n121 * log(n121/m121) + n122 * log(n122/m122) +
           n211 * log(n211/m211) + n212 * log(n212/m212) +
           n221 * log(n221/m221) + n222 * log(n222/m222)]

=head2 Methods

=over

=cut


package Text::NSP::Measures::3D::MI::ll;


use Text::NSP::Measures::3D::MI;
use strict;
use Carp;
use warnings;


our ($VERSION, @ISA);

@ISA = qw(Text::NSP::Measures::3D::MI);

$VERSION = '0.93';

=item calculateStatistic($count_values) - This method calculates
the ll value

INPUT PARAMS  : $count_values       .. Reference of an hash containing
                                       the count values computed by the
                                       count.pl program.

RETURN VALUES : $loglikelihood      .. Loglikelihood value for this trigram.

=cut

sub calculateStatistic
{
  my $self = shift;
  my %values = @_;

  my $observed;
  my $expected;

  # computes and returns the observed and expected values from
  # the frequency combination values. returns 0 if there is an
  # error in the computation or the values are inconsistent.
  if( !(($observed, $expected) = $self->SUPER::calculateStatistic(\%values)) ) {
    return;
  }

  #  Now for the actual calculation of Loglikelihood!
  my $logLikelihood = 0;

  # dont want ($nxy / $mxy) to be 0 or less! flag error if so!
  $logLikelihood += $observed->{n111} * $self->computePMI( $observed->{n111}, $expected->{m111} );
  $logLikelihood += $observed->{n112} * $self->computePMI( $observed->{n112}, $expected->{m112} );
  $logLikelihood += $observed->{n121} * $self->computePMI( $observed->{n121}, $expected->{m121} );
  $logLikelihood += $observed->{n122} * $self->computePMI( $observed->{n122}, $expected->{m122} );
  $logLikelihood += $observed->{n211} * $self->computePMI( $observed->{n211}, $expected->{m211} );
  $logLikelihood += $observed->{n212} * $self->computePMI( $observed->{n212}, $expected->{m212} );
  $logLikelihood += $observed->{n221} * $self->computePMI( $observed->{n221}, $expected->{m221} );
  $logLikelihood += $observed->{n222} * $self->computePMI( $observed->{n222}, $expected->{m222} );

  $Text::NSP::Measures::3D::marginals = undef;

  return ( 2 * $logLikelihood );
}


=item getStatisticName() - Returns the name of this statistic

INPUT PARAMS  : none

RETURN VALUES : $name      .. Name of the measure.

=cut
sub getStatisticName
{
    return "Loglikelihood";
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

Last updated: $Id: ll.pm,v 1.6 2006/06/15 16:53:05 saiyam_kohli Exp $

=head1 BUGS


=head1 SEE ALSO

  @article{Dunning93,
            author = {Dunning, T.},
            title = {Accurate Methods for the Statistics of
          Surprise and Coincidence},
            journal = {Computational Linguistics},
            volume = {19},
            number = {1},
            year = {1993},
            pages = {61-74}
            url = L<http://www.comp.lancs.ac.uk/ucrel/papers/tedstats.pdf>}

  @inproceedings{moore:2004:EMNLP,
                author    = {Moore, Robert C.},
                title     = {On Log-Likelihood-Ratios and the Significance of Rare
              Events },
                booktitle = {Proceedings of EMNLP 2004},
                editor = {Dekang Lin and Dekai Wu},
                year      = 2004,
                month     = {July},
                address   = {Barcelona, Spain},
                publisher = {Association for Computational Linguistics},
                pages     = {333--340}
                url = L<http://acl.ldc.upenn.edu/acl2004/emnlp/pdf/Moore.pdf>}

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