#!/usr/bin/perl
# 
# Taking a known nagios configuration directory, will check that the objects.cache is as expected

use warnings;
use strict;
use Test::More;

defined($ARGV[0]) or die "Usage: $0 <top build dir>";

my $top_builddir = shift @ARGV;
my $nagios = "$top_builddir/base/nagios";
my $etc = "etc";
my $precache = "var/objects.precache";

plan tests => 2;

my $output = `$nagios -v "$etc/nagios.cfg"`;
if ($? == 0) {
	pass("Nagios validated test configuration successfully");
} else {
	fail("Nagios validation failed:\n$output");
}

system("$nagios -vp '$etc/nagios.cfg' > /dev/null") == 0 or die "Cannot create precached objects file";
system("grep -v 'Created:' $precache > '$precache.generated'");

my $diff = "diff -u $precache.expected $precache.generated";
my @output = `$diff`;
if ($? == 0) {
	pass( "Nagios precached objects file matches expected" );
} else {
	fail( "Nagios precached objects discrepancy!!!\nTest with: $diff\nCopy with: cp $precache.generated $precache.expected" );
	print "#$_" foreach @output;
}	

