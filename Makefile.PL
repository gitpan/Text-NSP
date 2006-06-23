use 5.008005;

use ExtUtils::MakeMaker;

my @utils_to_install = qw (kocos.pl rank.pl combig.pl huge-count.pl huge-combine.pl sort-bigrams.pl split-data.pl);

my @required_to_install = qw(count.pl statistic.pl);

my @sh_to_install = qw( kocos-script.sh rank-script.sh combig-script.sh );


WriteMakefile(
    NAME              => 'Text::NSP',
    VERSION_FROM      => 'lib/Text/NSP.pm', # finds $VERSION
    PREREQ_PM         => {},
    CONFIGURE         => \&configSub,
    EXE_FILES         => [
                           map ("bin/$_", @required_to_install),
                           map ("bin/utils/$_", @utils_to_install),
                           map ("bin/utils/$_", @sh_to_install),
                         ],
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
    (ABSTRACT_FROM  => 'lib/Text/NSP.pm', # retrieve abstract from module
    AUTHOR         => 'Ted Pedersen <tpederse@d.umn.edu>') : ()),
);


sub configSub
{

  print "#################################################################\n";
  print " You are running Makefile.PL. When this finishes, remember that you\n";
  print " will also need to run the following to finish the install of NSP:\n";
  print "\n";
  print "        make\n";
  print "        make test\n";
  print "        make install\n";
  print "\n";
  print " if \"make install\" fails and indicates that you don\'t have proper\n";
  print " permissions to install, you do have the option to install NSP in\n";
  print " a local directory of your own choosing. You can do this as follows:\n";
  print "\n";
  print "        perl Makefile.PL PREFIX=/MYDIR/NSP\n";
  print "        make\n";
  print "        make test\n";
  print "        make install\n";
  print "\n";
  print " where /MYDIR is a directory that you own and can write to, and\n";
  print " NSP is a new subdirectory. (The name NSP is not required, it\n";
  print " can be anything)\n";
  print "\n";
  print " After all this is done, you can run \"make clean\" to remove some\n";
  print " of the files created during installation\n";
  print "#################################################################\n";

  return {};
}

sub MY::postamble {

  my $postamble = <<'END';
html:

	@echo "*****************************************************"
	@echo "Installing the Ngram Statistics Package, V $(VERSION)..."
	@echo " ...into $(SITEPREFIX) (/doc /bin /lib /man) "
	@echo "Make sure that the following are in your PATH:"
	@echo "     $(INSTALLBIN)"
	@echo "and the following in your PERL5LIB:"
	@echo "     $(INSTALLSITELIB)"
	@echo "*****************************************************"

END
  return ($postamble);
}

sub MY::install
{
  my $self = shift;
  my $string = $self->MM::install;
  my $add = 'html';
  $string =~ s/(pure_install\s+)(.*)/$1 $add $2/;
  return $string;
}

# For testing
sub MY::test
{
    q(
TEST_VERBOSE=0

test: all
	$(FULLPERL) t/TEST $(TEST_VERBOSE)

);
}

