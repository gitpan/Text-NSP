=head1 NAME

Text::NSP::Measures::3D::MI::tmi -Perl implementation for True Mutual
Information for trigrams.

=head1 SYNOPSIS

=head3 Basic Usage

  use Text::NSP::Measures::3D::MI::tmi;

  my $tmi = Text::NSP::Measures::3D::MI::tmi->new();

  $tmi_value = $tmi->calculateStatistic( n111=>10,
                                         n1pp=>40,
                                         np1p=>45,
                                         npp1=>42,
                                         n11p=>20,
                                         n1p1=>23,
                                         np11=>21,
                                         nppp=>100);

  if( ($errorCode = $tmi->getErrorCode()))
  {
    print STDERR $erroCode." - ".$tmi->getErrorMessage();
  }
  else
  {
    print $tmi->getStatisticName."value for bigram is ".$tmi_value;
  }

=head1 DESCRIPTION

True Mutual Information (tmi) is defined as the weighted average of the
pointwise mutual informations for all the observed and expected value pairs.

 tmi = [n111/nppp * log(n111/m111) + n112/nppp * log(n112/m112) +
        n121/nppp * log(n121/m121) + n122/nppp * log(n122/m122) +
        n211/nppp * log(n211/m211) + n212/nppp * log(n212/m212) +
        n221/nppp * log(n221/m221) + n222/nppp * log(n222/m222)]

 PMI =   log (n111/m111)

Here n111 represents the observed value for the cell (1,1,1) and m111
represents the expected value for that cell. The expected values for
the internal cells are calculated by taking the product of their
associated marginals and dividing by the sample size, for example:

            n1pp * np1p * npp1
   m111=   --------------------
                   nppp

=head2 Methods

=over

=cut


package Text::NSP::Measures::3D::MI::tmi;


use Text::NSP::Measures::3D::MI;
use strict;
use Carp;
use warnings;


our ($VERSION, @ISA);

@ISA = qw(Text::NSP::Measures::3D::MI);

$VERSION = '0.93';


=item calculateStatistic($count_values) - This method calculates
the tmi value

INPUT PARAMS  : $count_values   .. Reference of an hash containing
                                   the count values computed by the
                                   count.pl program.

RETURN VALUES : $tmi            .. TMI value for this trigram.

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
    return(0);
  }

  #my $marginals = $self->computeMarginalTotals(@_);

  #  Now for the actual calculation of TMI!
  my $tmi = 0;

  # dont want ($nxy / $mxy) to be 0 or less! flag error if so!
  $tmi += $observed->{n111}/$values{nppp} * $self->computePMI( $observed->{n111}, $expected->{m111} )/ log 2;
  $tmi += $observed->{n112}/$values{nppp} * $self->computePMI( $observed->{n112}, $expected->{m112} )/ log 2;
  $tmi += $observed->{n121}/$values{nppp} * $self->computePMI( $observed->{n121}, $expected->{m121} )/ log 2;
  $tmi += $observed->{n122}/$values{nppp} * $self->computePMI( $observed->{n122}, $expected->{m122} )/ log 2;
  $tmi += $observed->{n211}/$values{nppp} * $self->computePMI( $observed->{n211}, $expected->{m211} )/ log 2;
  $tmi += $observed->{n212}/$values{nppp} * $self->computePMI( $observed->{n212}, $expected->{m212} )/ log 2;
  $tmi += $observed->{n221}/$values{nppp} * $self->computePMI( $observed->{n221}, $expected->{m221} )/ log 2;
  $tmi += $observed->{n222}/$values{nppp} * $self->computePMI( $observed->{n222}, $expected->{m222} )/ log 2;

  $Text::NSP::Measures::3D::marginals = undef;

  return ($tmi);
}


=item getStatisticName() - Returns the name of this statistic

INPUT PARAMS  : none

RETURN VALUES : $name      .. Name of the measure.

=cut
sub getStatisticName
{
    return "Total Mutual Information";
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

Last updated: $Id: tmi.pm,v 1.7 2006/06/15 16:53:05 saiyam_kohli Exp $

=head1 BUGS


=head1 SEE ALSO

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