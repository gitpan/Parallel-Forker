#!/usr/bin/perl -w
# $Id: 12_rsh.t 64613 2008-11-13 14:55:57Z wsnyder $
# DESCRIPTION: Perl ExtUtils: Type 'make test' to test this package
#
# Copyright 2003-2008 by Wilson Snyder.  This program is free software;
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

    my $fork = new Parallel::Forker (use_sig_child=>1);
    $SIG{CHLD} = sub { Parallel::Forker::sig_child($fork); };
    $SIG{TERM} = sub { ok(0); $fork->kill_tree_all('TERM') if $fork && $fork->in_parent; die "Quitting...\n"; };
    $SIG{ALRM} = sub { print "Timeout!\n"; ok(0); $fork->kill_tree_all('TERM') if $fork && $fork->in_parent; die "Timeout...\n"; };
    ok(1);

    warn "-Note: It's ok if you get 'No route to host' below.\n";
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
