package Text::NSP::Measures::3D::test_2;
use Text::NSP::Measures::3D;
use strict;

our ($VERSION, @ISA);

@ISA = qw(Text::NSP::Measures::3D);

$VERSION = '0.93';

sub new
{
  my $class = shift;
  my $this = {};

  $class = ref $class || $class;

  $this->{errorMessage} = '';
  $this->{errorCodeNumber} = 0;
  $this->{traceOutput} = '';
  if ($class eq 'Text::NSP::Measures::3D::MI')
  {
    $this->{errorMessage} .= "\nError (${class}::new()) - ";
    $this->{errorMessage} .= "This class is intended to be an abstract base class.";
    $this->{errorMessage} .= "Your class should override it.";
    $this->{errorCodeNumber} = 100;
  }
  elsif ($class eq 'Text::NSP::Measures::3D::CHI')
  {
    $this->{errorMessage} .= "\nError (${class}::new()) - ";
    $this->{errorMessage} .= "This class is intended to be an abstract base class.";
    $this->{errorMessage} .= "Your class should override it.";
    $this->{errorCodeNumber} = 100;
  }
  elsif ($class eq 'Text::NSP::Measures::3D::Fisher')
  {
    $this->{errorMessage} .= "\nError (${class}::new()) - ";
    $this->{errorMessage} .= "This class is intended to be an abstract base class.";
    $this->{errorMessage} .= "Your class should override it.";
    $this->{errorCodeNumber} = 100;
  }
  bless $this, $class;
  return $this;
}


sub initializeStatistic {}

sub calculateStatistic
{
  my $self = shift;
  my %values = @_;
  my $number=0;
  my $NewMeasure=0;
  my $key;

  foreach $key (keys %values)
  {
    if($key !~ /npp/)
    {
      $NewMeasure += $values{$key};
      $number++;
    }
  }
  return($NewMeasure / (2 * $number));
}

1;



