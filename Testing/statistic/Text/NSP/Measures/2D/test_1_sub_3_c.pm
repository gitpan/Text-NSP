package Text::NSP::Measures::2D::test_1_sub_3_c;
use Text::NSP::Measures::2D;
use strict;

our ($VERSION, @ISA);

@ISA = qw(Text::NSP::Measures::2D);

$VERSION = '0.93';


sub new
{
  my $class = shift;
  my $this = {};

  $class = ref $class || $class;

  $this->{errorMessage} = '';
  $this->{errorCodeNumber} = 0;
  $this->{traceOutput} = '';
  if ($class eq 'Text::NSP::Measures::2D::MI')
  {
    $this->{errorMessage} .= "\nError (${class}::new()) - ";
    $this->{errorMessage} .= "This class is intended to be an abstract base class.";
    $this->{errorMessage} .= "Your class should override it.";
    $this->{errorCodeNumber} = 100;
  }
  elsif ($class eq 'Text::NSP::Measures::2D::CHI')
  {
    $this->{errorMessage} .= "\nError (${class}::new()) - ";
    $this->{errorMessage} .= "This class is intended to be an abstract base class.";
    $this->{errorMessage} .= "Your class should override it.";
    $this->{errorCodeNumber} = 100;
  }
  elsif ($class eq 'Text::NSP::Measures::2D::Fisher')
  {
    $this->{errorMessage} .= "\nError (${class}::new()) - ";
    $this->{errorMessage} .= "This class is intended to be an abstract base class.";
    $this->{errorMessage} .= "Your class should override it.";
    $this->{errorCodeNumber} = 100;
  }
  bless $this, $class;
  return $this;
}


sub calculateStatistic { return 0; }

1;
