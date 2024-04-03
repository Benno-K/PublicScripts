#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;

my $tocheck = "/ /boot /data /ssd";
my $lastfile = "$ENV{'HOME'}/.dusagedd";
my %res;
my %lastdf;
my %limits = (
	"default" => {
		low => 2,
		high => 2,
	},
	"x" => {
		low => 3,
		high => 1,
	},
	"3ssd" => {
		low => 5,
		high => 5,
	},
);

sub writelast () {
	open(OUT,">$lastfile") || die "Error opening $lastfile ($!)";
	print(OUT Data::Dumper->Dump([\%res],[ qw(*lastdf) ]));
	close(OUT);
}

sub dodf {
	my %retval;
	open(DF,"df -m --output=target,size,used,avail,pcent $tocheck|");
	<DF>;
	while(<DF>) {
		my ($mp,$size,$used,$avail,$pcent) = split;
		$retval{$mp}{size} = $size;
		$retval{$mp}{used} = $used;
		$retval{$mp}{avail} = $avail;
		$retval{$mp}{pcent} = substr($pcent,0,-1);
	}
	close(DF);
	return(%retval);
}
%res = dodf();
open DF,"<$lastfile";
local $/;
my $all = (<DF>);
close DF;
eval($all);
for my $k (sort keys %lastdf) {
	printf("c:%s %s\n",$k, $res{$k}{pcent});
	printf("l:%s %s\n",$k, $lastdf{$k}{pcent});
}
exit(0)
