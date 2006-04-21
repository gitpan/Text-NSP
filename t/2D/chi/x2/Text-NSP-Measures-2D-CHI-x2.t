# Before `make install' is performed this script should be runnable with
# `make test'.

##################### We start with some black magic to print on failure.

BEGIN { $| = 1; print "1..14\n"; }
END {print "not ok 1\n" unless $loaded;}
use Text::NSP::Measures;
use Text::NSP::Measures::2D;
use Text::NSP::Measures::2D::CHI;
use Text::NSP::Measures::2D::CHI::x2;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

############ Create Object for x2

$x2 = Text::NSP::Measures::2D::CHI::x2->new();
if($x2)
{
    $err = $x2->{errorCodeNumber};
    if($err)
    {
        print "not ok 2\n";
    }
    else
    {
        print "ok 2\n";
    }
}
else
{
    print "not ok 2\n";
}



############ Computing x2 value for some count values.
$x2_value = $x2->calculateStatistic(n11 => 10,
                                    n1p => 20,
                                    np1 => 20,
                                    npp => 60);
$err = $x2->getErrorCode();
if($err)
{
    print "not ok 3\n";
}
elsif($x2_value == 3.75)
{
    print "ok 3\n";
}
else
{
    print "not ok 3\n";
}

############Error Code check for missing values

%count_values = (n1p => 20,
                 np1 => 20,
                 npp => 60);

$value = $x2->calculateStatistic(%count_values);

$err = $x2->getErrorCode();
if($err == 200)
{
  print "ok 4\n";
}
else
{
  print"not ok 4\n";
}

############Error Code check for missing values

%count_values = (n11 =>10,
                 np1 => 20,
                 npp => 60);

$value = $x2->calculateStatistic(%count_values);

$err = $x2->getErrorCode();
if($err == 200)
{
  print "ok 5\n";
}
else
{
  print"not ok 5\n";
}
############Error Code check for missing values

%count_values = (n11=>10,
                 n1p => 20,
                 np1 => 20);

$value = $x2->calculateStatistic(%count_values);

$err = $x2->getErrorCode();
if($err == 200)
{
  print "ok 6\n";
}
else
{
  print"not ok 6\n";
}
############Error Code check for -ve values

%count_values = (n11 => -10,
                 n1p => 20,
                 np1 => 20,
                 npp => 60);

$value = $x2->calculateStatistic(%count_values);

$err = $x2->getErrorCode();
if($err == 201)
{
  print "ok 7\n";
}
else
{
  print"not ok 7\n";
}

############Error Code check for -ve values

%count_values = (n11 => 10,
                 n1p => -20,
                 np1 => 20,
                 npp => 60);

$value = $x2->calculateStatistic(%count_values);

$err = $x2->getErrorCode();
if($err == 204)
{
  print "ok 8\n";
}
else
{
  print"not ok 8\n";
}

############Error Code check for -ve values

%count_values = (n11 => 10,
                 n1p => 20,
                 np1 => 20,
                 npp => -60);

$value = $x2->calculateStatistic(%count_values);

$err = $x2->getErrorCode();
if($err == 204)
{
  print "ok 9\n";
}
else
{
  print"not ok 9\n";
}

############Error Code check invalid values

%count_values = (n11 => 80,
                 n1p => 20,
                 np1 => 20,
                 npp => 60);

$value = $x2->calculateStatistic(%count_values);

$err = $x2->getErrorCode();
if($err == 202)
{
  print "ok 10\n";
}
else
{
  print"not ok 10\n";
}

############Error Code check invalid values

%count_values = (n11 => 30,
                 n1p => 20,
                 np1 => 20,
                 npp => 60);

$value = $x2->calculateStatistic(%count_values);

$err = $x2->getErrorCode();
if($err == 202)
{
  print "ok 11\n";
}
else
{
  print"not ok 11\n";
}


############Error Code check invalid values

%count_values = (n11 => 10,
                 n1p => 70,
                 np1 => 20,
                 npp => 60);

$value = $x2->calculateStatistic(%count_values);

$err = $x2->getErrorCode();
if($err == 203)
{
  print "ok 12\n";
}
else
{
  print"not ok 12\n";
  print $err;
}

############## Checking Error code for -ve observed frequency

$value = $x2->calculateStatistic(n11 => 10,
                                    n1p => 20,
                                    np1 => 11,
                                    npp => 20);
$err = $x2->getErrorCode();
if($err==201)
{
    print "ok 13\n";
}
else
{
    print "not ok 13\n";
}

############## Checking measure value for a contingency table with a zero observed value

$value = $x2->calculateStatistic(n11 => 10,
                                    n1p => 20,
                                    np1 => 20,
                                    npp => 30);
$err = $x2->getErrorCode();
if($value == 7.5)
{
    print "ok 14\n";
}
else
{
    print "not ok 14\n";
}