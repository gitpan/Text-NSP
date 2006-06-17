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
    AUTHOR         => 'Saiyam Kohli <kohli003@d.umn.edu>') : ()),
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

  # @ keeps make from repeating command

  # create /doc/html and /doc/pod directory

	@$(MKPATH) $(SITEPREFIX)/doc/html
	@$(MKPATH) $(SITEPREFIX)/doc/pod

  # measures documentation to html

	@echo "Installing measures documentation in $(SITEPREFIX)/doc/html"

	@pod2html --outfile=$(SITEPREFIX)/doc/html/dice.html --infile=lib/Text/NSP/Measures/2D/Dice/dice.pm --title="NSP Dice Coefficient"
	@pod2html --outfile=$(SITEPREFIX)/doc/html/jaccard.html --infile=lib/Text/NSP/Measures/2D/Dice/jaccard.pm --title="NSP Jaccard Coefficient"
	@pod2html --outfile=$(SITEPREFIX)/doc/html/ll.html --infile=lib/Text/NSP/Measures/2D/MI/ll.pm --title="NSP Log Likelihood Ratio"
	@pod2html --outfile=$(SITEPREFIX)/doc/html/odds.html --infile=lib/Text/NSP/Measures/2D/odds.pm --title="NSP Odds Ratio"
	@pod2html --outfile=$(SITEPREFIX)/doc/html/phi.html --infile=lib/Text/NSP/Measures/2D/CHI/phi.pm --title="NSP Phi Coefficient"
	@pod2html --outfile=$(SITEPREFIX)/doc/html/tmi.html --infile=lib/Text/NSP/Measures/2D/MI/tmi.pm --title="NSP True Mutual Information"
	@pod2html --outfile=$(SITEPREFIX)/doc/html/pmi.html --infile=lib/Text/NSP/Measures/2D/MI/pmi.pm --title="NSP Pointwise Mutual Information"
	@pod2html --outfile=$(SITEPREFIX)/doc/html/tscore.html --infile=lib/Text/NSP/Measures/2D/CHI/tscore.pm --title="NSP T-Score"
	@pod2html --outfile=$(SITEPREFIX)/doc/html/x2.html --infile=lib/Text/NSP/Measures/2D/CHI/x2.pm --title="NSP Pearsons Chi Squared Tests"
	@pod2html --outfile=$(SITEPREFIX)/doc/html/measure2d.html --infile=lib/Text/NSP/Measures/2D.pm --title="NSP 2D measures"

	# program documentation to html

	@echo "Installing program documentation in $(SITEPREFIX)/doc/html"

	@pod2html --outfile=$(SITEPREFIX)/doc/html/count.html --infile=bin/count.pl --title="NSP count"
	@pod2html --outfile=$(SITEPREFIX)/doc/html/statistic.html --infile=bin/statistic.pl --title="NSP statistic"
	@pod2html --outfile=$(SITEPREFIX)/doc/html/rank.html --infile=bin/utils/rank.pl --title="NSP rank"
	@pod2html --outfile=$(SITEPREFIX)/doc/html/kocos.html --infile=bin/utils/kocos.pl --title="NSP kocos"
	@pod2html --outfile=$(SITEPREFIX)/doc/html/combig.html --infile=bin/utils/combig.pl --title="NSP combig"
	@pod2html --outfile=$(SITEPREFIX)/doc/html/huge-count.html --infile=bin/utils/huge-count.pl --title="NSP huge-count"
	@pod2html --outfile=$(SITEPREFIX)/doc/html/huge-combine.html --infile=bin/utils/huge-combine.pl --title="NSP huge-combine"
	@pod2html --outfile=$(SITEPREFIX)/doc/html/sort-bigrams.html --infile=bin/utils/sort-bigrams.pl --title="NSP sort-bigrams"
	@pod2html --outfile=$(SITEPREFIX)/doc/html/split-data.html --infile=bin/utils/split-data.pl --title="NSP split-data"

  # general documentation to html

	@echo "Installing general documentation in $(SITEPREFIX)/doc/html"

	@pod2html --outfile=$(SITEPREFIX)/doc/html/FAQ.html --infile=Docs/FAQ.pod --title="NSP FAQ"
	@pod2html --outfile=$(SITEPREFIX)/doc/html/NewStats.html --infile=Docs/NewStats.pod --title="NSP NewStats"
	@pod2html --outfile=$(SITEPREFIX)/doc/html/Measures.html --infile=Docs/Measures.pod --title="NSP Measures"
	@pod2html --outfile=$(SITEPREFIX)/doc/html/README.html --infile=Docs/README.pod --title="NSP README"
	@pod2html --outfile=$(SITEPREFIX)/doc/html/Todo.html --infile=Docs/Todo.pod --title="NSP Todo"
	@pod2html --outfile=$(SITEPREFIX)/doc/html/Usage.html --infile=Docs/Usage.pod --title="NSP Usage"


  # general documentation to doc/pod

	@echo "Installing pod documentation in $(SITEPREFIX)/doc/pod"

	@$(CP) Docs/FAQ.pod $(SITEPREFIX)/doc/pod/FAQ.pod
	@$(CP) Docs/NewStats.pod $(SITEPREFIX)/doc/pod/NewStats.pod
	@$(CP) Docs/Measures.pod $(SITEPREFIX)/doc/pod/Measures.pod
	@$(CP) Docs/README.pod $(SITEPREFIX)/doc/pod/README.pod
	@$(CP) Docs/Todo.pod $(SITEPREFIX)/doc/pod/Todo.pod
	@$(CP) Docs/Usage.pod $(SITEPREFIX)/doc/pod/Usage.pod

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

