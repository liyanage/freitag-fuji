#!/usr/bin/perl

use warnings;
use strict;

my %args = @ARGV;

#warn "args: @ARGV";

# capture_dir_path /Users/liyanage/Desktop/capture temp_dir_path /private/var/tmp/folders.501/TemporaryItems barcode 3456 action_url http://betabong.kicks-ass.net/fuji/_communication/action.php

check_args(%args);
copy_images(%args);
upload_images(%args);

exit 0;




sub check_args {
	my (%args) = @_;
	
	unless (-d "$args{capture_dir_path}") {
		die "capture dir path '$args{capture_dir_path}' invalid";
	}
	
	unless ($args{barcode}) {
		die "missing 'barcode' parameter";
	}

	unless ($args{action_url}) {
		die "missing 'action_url' parameter";
	}

	unless (-d "$args{temp_dir_path}") {
		die "missing 'barcode' parameter";
	}

}



sub copy_images {
	my (%args) = @_;


}


sub upload_images {


}
