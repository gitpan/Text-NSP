package test_2;
require Exporter;
@ISA = qw ( Exporter );
@EXPORT = qw (initializeStatistic calculateStatistic);

sub initializeStatistic {}

sub calculateStatistic
{
    my @numbers = @_;
    my $value = 0;

    foreach $num (@numbers) { $value += $num; }
    return($value / (2 * ($#numbers + 1)));
}
    
1;



