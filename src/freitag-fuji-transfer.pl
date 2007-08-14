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

#warn "args: @ARGV";

# /usr/bin/perl "-I/Users/liyanage/svn/entropy-private/freitag-fuji/build/Debug/Freitag FUJI.app/Contents/Resources/perl-lib-lwp" /Users/liyanage/svn/entropy-private/freitag-fuji/src/freitag-fuji-transfer.pl capture_files foo1.jpg,foo2.jpg temp_dir_path /private/var/tmp/folders.501/TemporaryItems barcode 45 action_url http://betabong.kicks-ass.net/fuji/_communication/action.php


my $args = {@ARGV};
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

	my @image_files = split(/,/, $args{capture_files});
	my @missing_image_files = grep {! -f "$args{capture_dir_path}/$_"} @image_files;
	unless (@image_files and !@missing_image_files) {
		die "No file list or missing image files: @missing_image_files";
	}
	# sort by file age first then file name second
	my @sorted_images =
		map {$_->[0]}
		sort {$b->[1] <=> $a->[1] || $a->[0] cmp $b->[0]}
		map {[$_, -M "$args{capture_dir_path}/$_"]}
		@image_files;
	$args->{capture_files} = \@sorted_images;
#	warn("sorted files: @sorted_images");
}


sub move_images {
	my ($args) = @_;
	my %args = %$args;
	
	my $jobdir = "$args{capture_dir_path}/$args{barcode}";
	remove_jobdir($jobdir) if (-d $jobdir);
	die "Unable to create job dir '$jobdir': $!" unless (mkdir($jobdir));

	foreach my $file (@{$args{capture_files}}) {
		my ($from, $to) = ("$args{capture_dir_path}/$file", "$jobdir/$file");
		die "Unable to move '$from' to '$to': $!" unless (rename($from, $to));
	}

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

	my $index = 0;
	my @list;
	foreach my $file (@{$args{capture_files}}) {
		push @list, "file_$index" => ["$args{jobdir}/$file", "$args{barcode}_$index.jpg", Content_Type => 'image/jpeg'];
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