# This file was initially created by h2xs, and then modified by TDP
# in December 2003 to account for documentation and source code files. 
# This was created for version 0.63 of NSP. 

use 5.008;
use ExtUtils::MakeMaker;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

## these are lists of the files that are to be installed

## source code programs (.pl) and shell scripts (.sh) (install to /bin)

my @pgms_to_install = qw( count.pl statistic.pl );

my @utils_to_install = qw (kocos.pl rank.pl combig.pl); 

my @sh_to_install = qw( kocos-script.sh rank-script.sh combig-script.sh ); 

## documents (.pod) (install to /doc)

my @docs_to_install = qw( Measures.pod NewStats.pod Todo.pod FAQ.pod Usage.pod); 

## test scripts (combination of shell scripts and data files) (install to ??)
## nothing installed as yet. make test is very minimal right now. 

WriteMakefile(

# The module name

    'NAME'		=> 'Text::NSP',

# Version Number

    'VERSION'	 	=> '0.65', 

# List any required Perl modules

    'PREREQ_PM'		=> { }, # Module::Name => 1.1

# Run this subroutine prior to creating makefile

    'CONFIGURE'         => \&configSub,

# choose the perl set of installation directories. 
# choices are site (default), vendor, and perl. 

    'INSTALLDIRS'	=> 'site',

## man files are categorized as follows:
##  Man1 - Applications and Utilities
##  Man2 - System Calls
##  Man3 - C Libraries
##  Man4 - Device Drivers
##  Man5 - File Formats
##  Man6 - games
##  Man8 - system administration
##  .pl and .sh files should go into man1, and .pm to man3
##

##  these settings are overridden by PM
#	'MAN1PODS' =>  {
#
#		'count.pl' => '$(INST_MAN1DIR)/count.1',
#		'statistic.pl' => '$(INST_MAN1DIR)/statistic.1',
#		'Utils/kocos.pl' => '$(INST_MAN1DIR)/kocos.1',
#		'Utils/combig.pl' => '$(INST_MAN1DIR)/combig.1',
#		'Utils/rank.pl' => '$(INST_MAN1DIR)/rank.1'
#
#	},


'MAN3PODS' =>  {

		'Measures/dice.pm' => '$(INST_MAN3DIR)/dice.3',
		'Measures/leftFisher.pm' => '$(INST_MAN3DIR)/leftFisher.3',
		'Measures/ll.pm' => '$(INST_MAN3DIR)/ll.3',
		'Measures/ll3.pm' => '$(INST_MAN3DIR)/ll3.3',
		'Measures/odds.pm' => '$(INST_MAN3DIR)/odds.3',
		'Measures/phi.pm' => '$(INST_MAN3DIR)/phi.3',
		'Measures/pmi.pm' => '$(INST_MAN3DIR)/pmi.3',
		'Measures/rightFisher.pm' => '$(INST_MAN3DIR)/rightFisher.3',
		'Measures/tmi.pm' => '$(INST_MAN3DIR)/tmi.3',
		'Measures/tmi3.pm' => '$(INST_MAN3DIR)/tmi3.3',
		'Measures/tscore.pm' => '$(INST_MAN3DIR)/tscore.3',
		'Measures/x2.pm' => '$(INST_MAN3DIR)/x2.3',
	 },

## executable files to be installed, copied to INST_SCRIPT
## and then installed to /bin,  man pages to /man1 (in the
## typical case.  

    'EXE_FILES'         => [
			      map ("$_", @pgms_to_install),
			      map ("Utils/$_", @utils_to_install),
			      map ("Utils/$_", @sh_to_install),
			 ],

## location of libraries to be installed. Will be installed at
## corresponding location in INST_LIBDIR. Not a good choice if
## you want to change the directory structure where the libraries
## are installed. Use PM instead in this case. 
##
##    'PMLIBDIRS'         => [ 'Measures' ],

## PM enumerates where .pm and .pl files should be installed. Use
## this is you want to rearrange the installed versions of things.
## PM requires a hashref as input. These are installed to /lib,
## and the man pages to /man3 (in the typical case). 

	'PM' =>         {
	'NSP.pm' => '$(INST_LIB)/Text/NSP.pm',
	'Measures/dice.pm' => '$(INST_LIB)/dice.pm',
	'Measures/leftFisher.pm' => '$(INST_LIB)/leftFisher.pm',
	'Measures/ll.pm' => '$(INST_LIB)/ll.pm',
	'Measures/ll3.pm' => '$(INST_LIB)/ll3.pm',
	'Measures/odds.pm' => '$(INST_LIB)/odds.pm',
	'Measures/phi.pm' => '$(INST_LIB)/phi.pm',
	'Measures/pmi.pm' => '$(INST_LIB)/pmi.pm',
	'Measures/rightFisher.pm' => '$(INST_LIB)/rightFisher.pm',
	'Measures/tmi.pm' => '$(INST_LIB)/tmi.pm',
	'Measures/tmi3.pm' => '$(INST_LIB)/tmi3.pm',
	'Measures/tscore.pm' => '$(INST_LIB)/tscore.pm',
	'Measures/x2.pm' => '$(INST_LIB)/x2.pm',
	} ,

## what happens when you run "make test" (test.pl is also run BTW). 

    'test' 		=> {'TESTS' => 't/*.t'}, 

    'clean' 		=> {'FILES' => 'pod2htm*x*'}, 

    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005

      (ABSTRACT => 'The Ngram Statistics Package allows a user to count Ngrams in large corpora of text, and measure their association.',

       AUTHOR     => 'Ted Pedersen <tpederse@d.umn.edu>') : ()),
);

sub configSub {

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

## postamble is run with "make install"

sub MY::postamble {

	my $postamble = <<'END';
html: 

	@echo "*****************************************************"
	@echo "Installing the Ngram Statistics Package, V $(VERSION)..."
	@echo " ...into $(SITEPREFIX) (/doc /bin /lib /man) "
	@echo "Make sure that the following are in your PATH:"
	@echo "     $(INSTALLSITEBIN)"
	@echo "     $(INSTALLSITELIB)"
	@echo "After your paths are set, run Testing/ALL-TESTS.sh to"
	@echo "verify that installation is ok"
	@echo "*****************************************************"
	

# @ keeps make from repeating command

# create /doc/html and /doc/pod directory

	@$(MKPATH) $(SITEPREFIX)/doc/html
	@$(MKPATH) $(SITEPREFIX)/doc/pod
	
# measures documentation to html

	@echo "Installing measures documentation in $(SITEPREFIX)/doc/html"

	@pod2html --outfile=$(SITEPREFIX)/doc/html/dice.html --infile=Measures/dice.pm --title="NSP Dice Coefficient"
	@pod2html --outfile=$(SITEPREFIX)/doc/html/ll.html --infile=Measures/ll.pm --title="NSP Log Likelihood Ratio"
	@pod2html --outfile=$(SITEPREFIX)/doc/html/ll3.html --infile=Measures/ll3.pm --title="NSP Log Likelihood Ratio"
	@pod2html --outfile=$(SITEPREFIX)/doc/html/odds.html --infile=Measures/odds.pm --title="NSP Odds Ratio"
	@pod2html --outfile=$(SITEPREFIX)/doc/html/phi.html --infile=Measures/phi.pm --title="NSP Phi Coefficient"
	@pod2html --outfile=$(SITEPREFIX)/doc/html/tmi.html --infile=Measures/tmi.pm --title="NSP True Mutual Information"
	@pod2html --outfile=$(SITEPREFIX)/doc/html/pmi.html --infile=Measures/pmi.pm --title="NSP Pointwise Mutual Information"
	@pod2html --outfile=$(SITEPREFIX)/doc/html/tscore.html --infile=Measures/tscore.pm --title="NSP T-Score"
	@pod2html --outfile=$(SITEPREFIX)/doc/html/x2.html --infile=Measures/x2.pm --title="NSP Pearsons Chi Squared Tests"
	@pod2html --outfile=$(SITEPREFIX)/doc/html/leftFisher.html --infile=Measures/leftFisher.pm --title="NSP Left Sided Fisher's Exact Test"
	@pod2html --outfile=$(SITEPREFIX)/doc/html/rightFisher.html --infile=Measures/rightFisher.pm --title="NSP Right Sided Fisher's Exact Test"

# program documentation to html

	@echo "Installing program documentation in $(SITEPREFIX)/doc/html"

	@pod2html --outfile=$(SITEPREFIX)/doc/html/count.html --infile=count.pl --title="NSP count"
	@pod2html --outfile=$(SITEPREFIX)/doc/html/statistic.html --infile=statistic.pl --title="NSP statistic"
	@pod2html --outfile=$(SITEPREFIX)/doc/html/rank.html --infile=Utils/rank.pl --title="NSP rank"
	@pod2html --outfile=$(SITEPREFIX)/doc/html/kocos.html --infile=Utils/kocos.pl --title="NSP kocos"
	@pod2html --outfile=$(SITEPREFIX)/doc/html/combig.html --infile=Utils/combig.pl --title="NSP combig"

# general documentation to html

	@echo "Installing general documentation in $(SITEPREFIX)/doc/html"

	@pod2html --outfile=$(SITEPREFIX)/doc/html/FAQ.html --infile=Docs/FAQ.pod --title="NSP FAQ"
	@pod2html --outfile=$(SITEPREFIX)/doc/html/NewStats.html --infile=Docs/NewStats.pod --title="NSP NewStats"
	@pod2html --outfile=$(SITEPREFIX)/doc/html/Measures.html --infile=Docs/Measures.pod --title="NSP Measures"
	@pod2html --outfile=$(SITEPREFIX)/doc/html/README.html --infile=Docs/README.pod --title="NSP README"
	@pod2html --outfile=$(SITEPREFIX)/doc/html/Todo.html --infile=Docs/Todo.pod --title="NSP Todo"
	@pod2html --outfile=$(SITEPREFIX)/doc/html/Usage.html --infile=Docs/Usage.pod --title="NSP Usage"

# general documentation to man/man3

	@echo "Installing man page documentation in $(SITEPREFIX)/man/man3"

	@pod2man Docs/FAQ.pod $(SITEPREFIX)/man/man3/FAQ.$(MAN3EXT) 
	@pod2man Docs/NewStats.pod $(SITEPREFIX)/man/man3/NewStats.$(MAN3EXT) 
	@pod2man Docs/Measures.pod $(SITEPREFIX)/man/man3/Measures.$(MAN3EXT) 
	@pod2man Docs/README.pod $(SITEPREFIX)/man/man3/README.$(MAN3EXT) 
	@pod2man Docs/Todo.pod $(SITEPREFIX)/man/man3/Todo.$(MAN3EXT) 
	@pod2man Docs/Usage.pod $(SITEPREFIX)/man/man3/Usage.$(MAN3EXT) 

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

sub MY::install {
	my $self = shift;
	my $string = $self->MM::install;
	my $add = 'html';
	$string =~ s/(pure_install\s+)(.*)/$1 $add $2/;
	return $string;
}

