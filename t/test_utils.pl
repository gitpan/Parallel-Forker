# $Id: test_utils.pl 17052 2006-03-30 15:30:47Z wsnyder $
# DESCRIPTION: Perl ExtUtils: Common routines required by package tests
#
# Copyright 2003-2006 by Wilson Snyder.  This program is free software;
# you can redistribute it and/or modify it under the terms of either the GNU
# Lesser General Public License or the Perl Artistic License.
######################################################################

use vars qw($PERL $GCC);

$PERL = "$^X -Iblib/arch -Iblib/lib";

mkdir 'test_dir',0777;

if (!$ENV{HARNESS_ACTIVE}) {
    use lib "blib/lib";
    use lib "blib/arch";
    use lib "..";
    use lib "../..";
}

sub run_system {
    # Run a system command, check errors
    my $command = shift;
    print "\t$command\n";
    system "$command";
    my $status = $?;
    ($status == 0) or die "%Error: Command Failed $command, $status, stopped";
}

1;