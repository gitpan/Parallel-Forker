#!/usr/bin/perl -w
# $Id: 12_rsh.t 17052 2006-03-30 15:30:47Z wsnyder $
# DESCRIPTION: Perl ExtUtils: Type 'make test' to test this package
#
# Copyright 2003-2006 by Wilson Snyder.  This program is free software;
# you can redistribute it and/or modify it under the terms of either the GNU
# Lesser General Public License or the Perl Artistic License.
######################################################################

use Test;
use strict;

our $Other_Host = "ws102";

BEGIN { plan tests => 3 }
BEGIN { require "t/test_utils.pl"; }

BEGIN { $Parallel::Forker::Debug = 1; }

use Parallel::Forker;
ok(1);

######################################################################

a_test();

sub a_test {
    my $failit = shift;

    my $fork = new Parallel::Forker;
    $SIG{CHLD} = sub { Parallel::Forker::sig_child($fork); };
    $SIG{TERM} = sub { ok(0); $fork->kill_tree_all('TERM') if $fork; die "Quitting...\n"; };
    $SIG{ALRM} = sub { print "Timeout!\n"; ok(0); $fork->kill_tree_all('TERM') if $fork; die "Timeout...\n"; };
    ok(1);

    for (my $i=0; $i<3; $i++) {
	$fork->schedule(
			run_on_start => sub {
			    print "Start\n";
			    exec "ssh $Other_Host sleep 2;";
			    exit(0);
			},
			run_on_finish => sub {
			    my ($procref, $status) = @_;
			    my $running=0;
			    foreach my $proc ($fork->running()) {   # Loop on each running child
				$running++;
			    }
			    print "Stat = $status, Running = $running\n";
			},
			);
    }

    # Run them
    alarm(60);
    $fork->ready_all();
    $fork->wait_all();
    ok(1);
}