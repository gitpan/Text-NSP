package Text::NSP::Measures::2D::Fisher2;


use Text::NSP::Measures::2D;
use strict;
use Carp;
use warnings;


our ($VERSION, @ISA);

@ISA = qw(Text::NSP::Measures::2D);

$VERSION = '0.91';


=item calculateStatistic()

This method calculates the ll value

INPUT PARAMS  : $count_values       .. Reference of an array containing
                                       the count valuescomputed by the
                                       count.pl program.

RETURN VALUES : $observed           .. Observed contingency table counts.
                $marginal           .. Marginal totals for the cobtingency tables
                $probability        .. Reference to a hash containg hypergeometric
                                       probabilities for all the possible contingency
                                       tables

=cut
sub calculateStatistic
{
  my $self = shift;
  my $values = shift;

  my $observed;
  my $marginal;

  # computes and returns the observed and marginal values from
  # the frequency combination values. returns 0 if there is an
  # error in the computation or the values are inconsistent.
  if( !($observed = $self->computeObservedValues($values)) ) {
      return;
  }

  if( !($marginal = $self->computeMarginalTotals($values)) ) {
      return;
  }

  my @values = ($observed,$marginal);

  return(@values);
}


sub computeDistribution
{
  my $self = shift @_;
  my $observed = shift @_;
  my $marginal = shift @_;
  my $n11_start = shift @_;
  my $final_limit = shift @_;

  # initialize the observed values variables.
  my $n11 = $observed->{n11};
  my $n12 = $observed->{n12};
  my $n21 = $observed->{n21};
  my $n22 = $observed->{n22};

  # initialize the marginal total values variables.
  my $npp = $marginal->{npp};
  my $n1p = $marginal->{n1p};
  my $np1 = $marginal->{np1};
  my $n2p = $marginal->{n2p};
  my $np2 = $marginal->{np2};

  # declare some temporary variables for use in loops and computing the values.
  my $i;

  # initialize the hash to store the probability distribution values.
  my %probability = ();


  # set the values for the first contingency table.
  $n11 = $n11_start;
  $n12 = $n1p-$n11;
  $n21 = $np1-$n11;
  $n22 = $n2p - $n21;

  while($n22 < 0)
  {
    $n11++;
    $n12 = $n1p - $n11;
    $n21 = $np1 - $n11;
    $n22 = $n2p - $n21;
  }



  for ( $i = $n11; $i <= $final_limit; $i++ )
  {
    $n12 = $n1p - $i;
    $n21 = $np1 - $i;
    $n22 = $n2p - $n21;

    # since, all the variables have been initialized, we start the computations.
    $probability{$i} = $self->computeHyperGeometric($i,$n12,$n21,$n22,$npp,$n1p,$np1,$n2p,$np2);
  }
  return (\%probability);
}


sub computeHyperGeometric
{
  my $self = shift @_;
  my $n11 = shift @_;
  my $n12 = shift @_;
  my $n21 = shift @_;
  my $n22 = shift @_;
  my $npp = shift @_;
  my $np1 = shift @_;
  my $n1p = shift @_;
  my $n2p = shift @_;
  my $np2 = shift @_;

  # declare some temporary variables for use in loops and computing the values.
  my $j=0;

  # first sort the numerator array in the descending order.
  my @numerator = sort { $b <=> $a } ($n1p, $np1, $n2p, $np2);

  # initialize the product variable to be used in the probability computation.
  my $product = 1;

  # declare the denominator array.
  my @denominator = ();

  # initialize the denominator array with values sorted in the descending order.
  @denominator = sort { $b <=> $a } ($npp, $n22, $n12, $n21, $n11);

  #decalare other variables for use in computation.
  my @dLimits = ();
  my @nLimits = ();
  my $dIndex = 0;
  my $nIndex = 0;

  # set the dLimits and nLimits arrays to be used in the cancellation of factorials
  # and to be used in the computation of factorial.
  # the dLimits and the nLimits allow us to cancel out factorials in the numerator
  # and the denominator. for example:
  #       6!        1*2*3*4*5*6
  #      ---  =  ---------------  =  5*6
  #       4!          1*2*3*4
  #
  # we achieve this by defining a range within which all the
  # nos must be multiplied. So every pair of entries in the nLimits array defines a range
  # so for the above case the entries would be:
  #     5,6
  #
  for ( $j = 0; $j < 4; $j++ )
  {
    if ( $numerator[$j] > $denominator[$j] )
    {
      $nLimits[$nIndex] = $denominator[$j] + 1;
      $nLimits[$nIndex+1] = $numerator[$j];
      $nIndex += 2;
    }
    elsif ( $denominator[$j] > $numerator[$j] )
    {
      $dLimits[$dIndex] = $numerator[$j] + 1;
      $dLimits[$dIndex+1] = $denominator[$j];
      $dIndex += 2;
    }
  }
  $dLimits[$dIndex] = 1;
  $dLimits[$dIndex+1] = $denominator[4];

  # compute the probability now, since all the variables have been initialized.
  while ( defined ( $nLimits[0] ) )
  {
    # the no. 10000000 is being used to prevent overflow...
    # since the no.s generally correspond to bigram counts, they are very large
    # and the computation of their factorial results in a overflow
    # to prevent this we compute the factorial in the numerator till we reach
    # a threshold of 10000000 then we start diviing so, the result is again
    # scaled down, this prevents overflow and underflow errors.
    while ( ( $product < 10000000 ) && ( defined ( $nLimits[0] ) ) )
    {
      $product *= $nLimits[0];
      $nLimits[0]++;
      if ( $nLimits[0] > $nLimits[1] )
      {
        shift @nLimits;
        shift @nLimits;
      }
    }
    while ( $product > 1 )
    {
      $product /= $dLimits[0];
      $dLimits[0]++;
      if ( $dLimits[0] > $dLimits[1] )
      {
        shift @dLimits;
        shift @dLimits;
      }
    }
  }
  # since there is one more factor in the denominator we have to
  # run the loop again
  while ( defined ( $dLimits[0] ) )
  {
    $product /= $dLimits[0];
    $dLimits[0]++;
    if ( $dLimits[0] > $dLimits[1] )
    {
      shift @dLimits;
      shift @dLimits;
    }
  }

  return $product;
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

Last updated: $Id: Fisher2.pm,v 1.2 2006/03/25 04:21:24 saiyam_kohli Exp $

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