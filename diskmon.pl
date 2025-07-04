#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long;
use Filesys::Df;
use POSIX qw(strftime);
use File::Basename;

my $scriptName = fileparse($0, ".pl",".plc");
my $threshold = 5;
my $showAll = 0;
my $quiet = 0;
my $help = 0;
my $stateFile = "$ENV{HOME}/.$scriptName.state";
my @fsList;

GetOptions(
    't=i' => \$threshold,
    'a'   => \$showAll,
    'q'   => \$quiet,
    'h|help' => \$help,
) or die "Error in command line arguments\n";

if ($help) {
    print <<"EOF";
Usage: $0 [options] fs1 [fs2 ...]
Options:
  -t N       Set threshold percentage (default: 5)
  -a         Show all filesystems (not only changed ones)
  -q         Quiet mode (suppresses output)
  -h, --help Show this help and exit

Exit status: number of changed filesystems (0 = no change)
EOF
    exit 0;
}

@fsList = @ARGV;

# Load state
my %fsStates;
my %fsDates;
my $savedCmdLine = '';
my $savedThreshold = '';

if (-f $stateFile) {
    open my $sf, '<', $stateFile or die "Cannot open $stateFile: $!";
    while (<$sf>) {
        chomp;
        if (/^savedThreshold=(.*)$/) {
            $savedThreshold = $1;
        } elsif (/^savedCmdLine=(.*)$/) {
            $savedCmdLine = $1;
        } elsif (/^initialPercent(.+?)=(\d+)\|(.*)$/) {
            $fsStates{$1} = $2;
            $fsDates{$1} = $3;
        }
    }
    close $sf;
}

if (!@fsList) {
    if ($savedCmdLine) {
        @fsList = split(/\s+/, $savedCmdLine);
        $threshold = $savedThreshold if $savedThreshold ne '';
    } else {
        die "Usage: $0 [-t threshold] [-a] [-q] fs1 fs2 ...\n";
    }
} else {
    $savedCmdLine = join(' ', @fsList);
}

# Helper: human readable size
sub humanReadable {
    my $bytes = shift;
    my @units = qw(B K M G T P);
    my $unit = 0;
    while ($bytes >= 1024 && $unit < $#units) {
        $bytes /= 1024;
        $unit++;
    }
    return sprintf("%.1f%s", $bytes, $units[$unit]);
}

# Helper: get usage (percent, free, used)
sub getUsage {
    my ($fs) = @_;
    my $ref = Filesys::Df::df($fs);
    return unless $ref;
    my $total = $ref->{blocks};
    my $used = $ref->{bused};
    my $free = $ref->{bavail};
    my $bsize = $ref->{bsize};
    # Check for undefineds or zeros
		if (!defined($bsize)) {
			$bsize = 1024;
		}
		if (!defined($used)) {
			$used = $total - $free;
		}
    return unless defined $total && defined $used && defined $free && defined $bsize && $bsize > 0;
    my $percent = $total ? int($used * 100 / $total + 0.5) : 0;
    return ($percent, $free * $bsize, $used * $bsize);
}
my $now = strftime("%d.%m.%y:%H.%M", localtime);
my $headline = "Disk usage as of " . strftime("%d.%m.%y %H:%M", localtime);
my %updatedFsStates;
my %updatedFsDates;
my $outputBuffer = '';
my $changedCount = 0;

for my $fs (@fsList) {
    my $safeFs = $fs; $safeFs =~ s/[^a-zA-Z0-9]/_/g; $safeFs = "FS$safeFs";
    my ($percent, $free, $used) = getUsage($fs);
    if (!defined $percent) {
        warn "$fs: Could not stat filesystem or directory.\n";
        next;
    }
    my $freeH = humanReadable($free);
    my $usedH = humanReadable($used);

    my $initialPercent = $fsStates{$safeFs};
    my $initialDate = $fsDates{$safeFs};

    # First run for this fs
    if (!defined $initialPercent) {
        $updatedFsStates{$safeFs} = $percent;
        $updatedFsDates{$safeFs}  = $now;
        if ($showAll) {
            $outputBuffer .= "$fs: $percent% -> $percent% free:$freeH used:$usedH\n since: $now\n";
        }
        next;
    }

    my $diff = $percent - $initialPercent;
    my $absDiff = $diff < 0 ? -$diff : $diff;
    my $stateChanged = $absDiff > $threshold ? 1 : 0;

    if ($showAll || $stateChanged) {
        $outputBuffer .= "$fs: $initialPercent% -> $percent% free:$freeH used:$usedH\n since: $initialDate\n";
    }

    # Only update state if threshold exceeded
    if ($stateChanged) {
        $updatedFsStates{$safeFs} = $percent;
        $updatedFsDates{$safeFs}  = $now;
        $changedCount++;
    } else {
        $updatedFsStates{$safeFs} = $initialPercent;
        $updatedFsDates{$safeFs}  = $initialDate;
    }
}

if (!$quiet && $outputBuffer ne '') {
    print "$headline\n";
    print $outputBuffer;
}

# Save state only if not -q
if (!$quiet) {
    open my $sf, '>', $stateFile or die "Cannot write $stateFile: $!";
    print $sf "savedThreshold=$threshold\n";
    print $sf "savedCmdLine=$savedCmdLine\n";
    for my $fs (@fsList) {
        my $safeFs = $fs; $safeFs =~ s/[^a-zA-Z0-9]/_/g; $safeFs = "FS$safeFs";
        my $ip = $updatedFsStates{$safeFs};
        my $id = $updatedFsDates{$safeFs};
        print $sf "initialPercent$safeFs=$ip|$id\n" if defined $ip && defined $id;
    }
    close $sf;
}

exit($changedCount);
