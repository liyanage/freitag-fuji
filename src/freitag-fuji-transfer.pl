#!/usr/bin/perl
#
# Freitag FUJI file transfer helper
#
# 

use warnings;
use strict;

use LWP::UserAgent;
use HTTP::Request::Common ();
use IO::Dir;
use Data::Dumper;

my $args = {@ARGV};
#warn "args: @ARGV";

# /usr/bin/perl "-I/Users/liyanage/svn/entropy-private/freitag-fuji/build/Debug/Freitag FUJI.app/Contents/Resources/perl-lib-lwp" /Users/liyanage/svn/entropy-private/freitag-fuji/src/freitag-fuji-transfer.pl capture_dir_path /Users/liyanage/Desktop/capture temp_dir_path /private/var/tmp/folders.501/TemporaryItems barcode 45 action_url http://betabong.kicks-ass.net/fuji/_communication/action.php

check_args($args);
move_images($args);
upload_images($args);
exit 0;



sub check_args {
	my ($args) = @_;
	my %args = %$args;
	die "capture dir path '$args{capture_dir_path}' invalid" unless (-d "$args{capture_dir_path}");
	die "missing 'barcode' parameter" unless ($args{barcode});
	die "missing 'action_url' parameter" unless ($args{action_url});
	die "missing 'barcode' parameter" unless (-d "$args{temp_dir_path}");
}


sub move_images {
	my ($args) = @_;
	my %args = %$args;
	
	my $jobdir = "$args{capture_dir_path}/$args{barcode}";
	remove_jobdir($jobdir) if (-d $jobdir);
	die "Unable to create job dir '$jobdir': $!" unless (mkdir($jobdir));

	my @files = sort grep {/.jpg$/i} IO::Dir->new($args{capture_dir_path})->read();
	foreach my $file (@files) {
		my ($from, $to) = ("$args{capture_dir_path}/$file", "$jobdir/$file");
		die "Unable to move '$from' to '$to': $!" unless (rename($from, $to));
	}

	$args->{files} = \@files;
	$args->{jobdir} = $jobdir;
}


sub upload_images {
	my ($args) = @_;
	my %args = %$args;

	my @params = ($args{action_url},
		Content_Type => 'form-data',
		Content      => [
			action => 'spin_add',
            param  => $args{barcode},
			make_file_list($args)
		]);

	my $request = HTTP::Request::Common::POST(@params);
	my $ua = LWP::UserAgent->new();
	my $response = $ua->request($request);
	
	unless ($response->is_success()) {
		die "Unable to upload images for job '$args{barcode}': " . $response->status_line();
	}
	
	remove_jobdir($args{jobdir});
}


sub make_file_list {
	my ($args) = @_;
	my %args = %$args;

	my $index = 1;
	my @list;
	foreach my $file (@{$args{files}}) {
#		push @list, "file_$index" => ["$args{jobdir}/$file", "$args{barcode}_$index.jpg", Content_Type => 'image/jpeg'];
		push @list, "file[]" => ["$args{jobdir}/$file", "$args{barcode}_$index.jpg", Content_Type => 'image/jpeg'];
		$index++;
	}

	return @list;
}


sub remove_jobdir {
	my ($jobdir) = @_;
	if (system('rm', '-rf', $jobdir) >> 8) {
		die "Unable to remove existing job dir '$jobdir': $!";
	}
}