##################### We start with some black magic to print on failure.

BEGIN { $| = 1; print "1..2\n"; }
END {print "not ok 1\n" unless $loaded;}
use Text::NSP::Measures::3D::MI;
$loaded = 1;
print "ok 1\n";

#####################

############
calculateStatistic();
$errorCode = getErrorCode();
if($errorCode == 101)
{
    print "ok 2\n";
}
else
{
    print "not ok 2\n";
}