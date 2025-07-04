#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long;
use Filesys::Statvfs;

my $threshold = 5;
my $quiet = 0;
my $script = $0 =~ s!.*/!!r;
my $state_file = "$ENV{HOME}/.$script.state";
my (%fsStates, %fsDates);
my $savedCmdLine = "";
my $savedThreshold = "";
my @fs_args;

# Human-readable formatting
sub human_readable {
    my $size = shift;
    my @units = ('B','K','M','G','T','P');
    my $i = 0;
    while ($size >= 1024 && $i < @units-1) {
        $size /= 1024;
        $i++;
    }
    return sprintf("%.1f%s", $size, $units[$i]);
}

# Pre-parse for -h/--help
for (@ARGV) {
    if ($_ eq '-h' or $_ eq '--help') {
        print STDERR <<"HELP";
Usage: $script [options] fs1 [fs2 ...]
Options:
  -t N       Set threshold percentage (default: 5)
  -q         Quiet mode (minimal output)
  -h, --help Show this help and exit

Without arguments, runs with saved filesystems and threshold.
Example:
  $script -t 10 /home /var
  $script -q
HELP
        exit 0;
    }
}

GetOptions(
    "t=i"    => \$threshold,
    "q"      => \$quiet,
) or do { print STDERR "Bad options. Use -h for help.\n"; exit 1; };

@fs_args = @ARGV;

sub load_state {
    return unless -f $state_file;
    open my $fh, '<', $state_file or return;
    while (<$fh>) {
        chomp;
        my ($key, $value) = split(/=/, $_, 2);
        if ($key eq 'savedThreshold') {
            $savedThreshold = $value;
        } elsif ($key eq 'savedCmdLine') {
            $savedCmdLine = $value;
        } elsif ($key =~ /^initial_percent_(.+)$/) {
            my $fsKey = $1;
            my ($p, $d) = split(/\|/, $value, 2);
            $fsStates{$fsKey} = $p;
            $fsDates{$fsKey} = $d;
        }
    }
    close $fh;
}

sub save_state {
    my @save_fs = @_;
    open my $fh, '>', $state_file or do { print STDERR "Can't write $state_file: $!"; exit 1; };
    print $fh "savedThreshold=$threshold\n";
    print $fh "savedCmdLine=$savedCmdLine\n";
    for my $fs (@save_fs) {
        my $safeFs = $fs; $safeFs =~ s/[^a-zA-Z0-9_]/_/g;
        $safeFs = "FS_$safeFs";
        my $percent = $fsStates{$safeFs};
        my $dt = $fsDates{$safeFs};
        print $fh "initial_percent_$safeFs=$percent|$dt\n"
            if defined $percent and defined $dt;
    }
    close $fh;
}

load_state();

if (!@fs_args) {
    if ($savedCmdLine) {
        @fs_args = split ' ', $savedCmdLine;
        $threshold = $savedThreshold if $savedThreshold ne "";
    } else {
        print STDERR "Usage: $script [-t threshold] [-q] fs1 fs2 ...\n";
        exit 1;
    }
} else {
    $savedCmdLine = join ' ', @fs_args;
}

for my $fs (@fs_args) {
    my $safeFs = $fs; $safeFs =~ s/[^a-zA-Z0-9_]/_/g;
    $safeFs = "FS_$safeFs";

    my $stat = Filesys::Statvfs::statvfs($fs);
    if (!$stat) {
        print "$fs:\n ! Not found or statvfs failed\n";
        next;
    }
    my $block_size   = $stat->f_frsize || $stat->f_bsize;
    my $blocks_total = $stat->f_blocks;
    my $blocks_free  = $stat->f_bfree;
    my $blocks_used  = $blocks_total - $blocks_free;

    my $free    = $blocks_free  * $block_size;
    my $used    = $blocks_used  * $block_size;
    my $percent = $blocks_total == 0 ? 0 : int($blocks_used * 100 / $blocks_total);

    my $free_h = human_readable($free);
    my $used_h = human_readable($used);

    my ($sec,$min,$hour,$mday,$mon,$year) = localtime;
    my $now = sprintf "%02d.%02d.%02d/%02d.%02d", $mday, $mon+1, ($year+1900)%100, $hour, $min;

    my $initialPercent = $fsStates{$safeFs} // 0;
    my $initialDate    = $fsDates{$safeFs} // $now;

    my $updateState = 0;
    if ($initialPercent eq "0") {
        print "now $percent% (0%) free:$free_h used:$used_h\n";
        print "prv:$now act:$now\n";
        $updateState = 1;
    } else {
        if (!$quiet) {
            print "now $percent% ($initialPercent%) free:$free_h used:$used_h\n";
            print "prv:$initialDate act:$now\n";
        }
        $updateState = 0;
    }
    my $diff = $percent - $initialPercent;
    my $absDiff = $diff < 0 ? -$diff : $diff;

    if ($absDiff > $threshold) {
        print "now $percent% ($initialPercent%) free:$free_h used:$used_h\n";
        print "prv:$initialDate act:$now\n";
        $updateState = 1;
    }
    if ($updateState) {
        $fsStates{$safeFs} = $percent;
        $fsDates{$safeFs}  = $now;
    }
}

save_state(@fs_args);
