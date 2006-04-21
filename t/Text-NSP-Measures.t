##################### We start with some black magic to print on failure.

BEGIN { $| = 1; print "1..2\n"; }
END {print "not ok 1\n" unless $loaded;}
use Text::NSP::Measures;
$loaded = 1;
print "ok 1\n";

#####################

############ Create Object

my $obj = Text::NSP::Measures->new();
my $err = $obj->{errorCodeNumber};
if($err == 100)
{
    print "ok 2\n";
}
else
{
    print "not ok 2\n";
}
