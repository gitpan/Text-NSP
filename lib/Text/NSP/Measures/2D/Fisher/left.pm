=head1 NAME

Text::NSP::Measures::2D::Fisher::left - Perl module implementation of the left sided
                                        Fisher's exact test.

=head1 SYNOPSIS

=head3 Basic Usage

  use Text::NSP::Measures::2D::Fisher::left;

  my $leftFisher = Text::NSP::Measures::2D::Fisher::left->new();

  my $npp = 60; my $n1p = 20; my $np1 = 20;  my $n11 = 10;

  $leftFisher_value = $leftFisher->calculateStatistic( n11=>$n11,
                                                       n1p=>$n1p,
                                                       np1=>$np1,
                                                       npp=>$npp);

  if( ($errorCode = $leftFisher->getErrorCode()))
  {
    print STDERR $erroCode." - ".$leftFisher->getErrorMessage();
  }
  else
  {
    print $leftFisher->getStatisticName."value for bigram is ".$leftFisher_value;
  }


=head1 DESCRIPTION

Assume that the frequency count data associated with a bigram
<word1><word2> is stored in a 2x2 contingency table:

          word2   ~word2
  word1    n11      n12 | n1p
 ~word1    n21      n22 | n2p
           --------------
           np1      np2   npp

where n11 is the number of times <word1><word2> occur together, and
n12 is the number of times <word1> occurs with some word other than
word2, and n1p is the number of times in total that word1 occurs as
the first word in a bigram.

The fishers exact tests are calculated by fixing the marginal totals
and computing the hypergeometric probabilities for all the possible
contingency tables,

A left sided test is calculated by adding the probabilities of all
the possible two by two contingency tables formed by fixing the
marginal totals and changing the value of n11 to less than the given
value. A left sided Fisher's Exact Test tells us how likely it is to
randomly sample a table where n11 is less than observed. In other words,
it tells us how likely it is to sample an observation where the two words
are less dependent than currently observed.

=head2 Methods

=over

=cut


package Text::NSP::Measures::2D::Fisher::left;


use Text::NSP::Measures::2D::Fisher;
use strict;
use Carp;
use warnings;


our ($VERSION, @ISA);

@ISA = qw(Text::NSP::Measures::2D::Fisher);

$VERSION = '0.95';


=item calculateStatistic()

This method calculates the ll value

INPUT PARAMS  : $count_values       .. Reference of an array containing
                                       the count values computed by the
                                       count.pl program.

RETURN VALUES : $left               .. Left Fisher value.

=cut

sub calculateStatistic
{
  my $self = shift;
  my %values = @_;

  my $observed;
  my $probabilities;

  # computes and returns the observed and marginal values from
  # the frequency combination values. returns 0 if there is an
  # error in the computation or the values are inconsistent.
  if( !($observed = $self->SUPER::calculateStatistic(\%values)) )
  {
    return;
  }

  my $marginals = $Text::NSP::Measures::2D::marginals;

  my $final_limit = $observed->{n11};
  my $n11 = $marginals->{n1p}+$marginals->{np1}-$marginals->{npp};
  if($n11<0)
  {
    $n11 = 0;
  }

  if( !($probabilities = $self->computeDistribution($observed, $marginals, $n11, $final_limit)))
  {
      return;
  }


  my $key_n11;

  my $leftfisher=0;

  foreach $key_n11 (sort { $a <=> $b } keys %$probabilities)
  {
    if($key_n11>$observed->{n11})
    {
      last;
    }
    $leftfisher += exp($probabilities->{$key_n11});
  }

  $Text::NSP::Measures::2D::marginals = undef;

  return $leftfisher;
}


=item getStatisticName()

Returns the name of this statistic

INPUT PARAMS  : none

RETURN VALUES : $name      .. Name of the measure.

=cut

sub getStatisticName
{
    return "Left Fisher";
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

Last updated: $Id: left.pm,v 1.10 2006/06/17 18:03:23 saiyam_kohli Exp $

=head1 BUGS


=head1 SEE ALSO

  @inproceedings{Pedersen96,
          author = {Pedersen, T.},
          title = {Fishing For Exactness},
          booktitle = {Proceedings of the South Central SAS User's
                      Group (SCSUG-96) Conference},
          year = {1996},
          pages = {188--200},
          month ={October},
          address = {Austin, TX}
          url = L<http://www.d.umn.edu/~tpederse/pubs.html>}

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