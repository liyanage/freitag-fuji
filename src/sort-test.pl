
use strict;
use warnings;

use IO::Dir;
use Data::Dumper;

my $dir = '/private/tmp';
my @items =
	map {$_->[0]}
	sort {$b->[1] <=> $a->[1] || $a->[0] cmp $b->[0]}
#	sort {$b->[1] <=> $a->[1]}
	map {[$_, -M $_]}
	map {"$dir/$_"}
	sort {int(rand(3)) - 1}
	IO::Dir->new($dir)->read();

warn(Data::Dumper->Dump([\@items]));