#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;
use Carp;
use Hash::Util;

Analyzer->new()->run();


package Analyzer;

sub new {
	my $self = shift @_;
	my (%args) = @_;
	
	my $class = ref($self) || $self;
	$self = bless {%args}, $class;
	$self->{$_} ||= undef foreach qw(jobs);
	$self->init();
	Hash::Util::lock_keys(%$self);
	
	return $self;
}

sub init {
	my $self = shift @_;
}

sub run {
	my $self = shift @_;

	while (my $line = <>) {
		chomp $line;
		my $jobid = $self->jobid_for_line($line);
		next unless $jobid;
		my $job = $self->job_for_id($jobid);
		$job->apply_line($line);
#		print "id $jobid $job\n";
	}
	
	my @abnormal = grep {!$_->is_normal()} values %{$self->{jobs}};
	warn(Data::Dumper->Dump([\@abnormal]));

}


sub jobid_for_line {
	my $self = shift @_;
	my ($line) = @_;
	my ($id) = grep {$_} $line =~ /for job (?:'(\d+)'|(\d+))/;
	return $id;
}


sub job_for_id {
	my $self = shift @_;
	my ($id) = @_;
	return $self->{jobs}->{$id} ||= Job->new(id => $id);
}



package Job;

sub new {
	my $self = shift @_;
	my (%args) = @_;
	
	my $class = ref($self) || $self;
	$self = bless {%args}, $class;
	$self->init();
	Hash::Util::lock_keys(%$self);
	
	return $self;
}

sub init {
	my $self = shift @_;
	$self->{$_} ||= undef foreach qw(timestamp);
	$self->{flags}->{$_} = 0 foreach qw(launched started finished);
}

sub apply_line {
	my $self = shift @_;
	my ($line) = @_;
	my ($flag) = $line =~ /(launched|started|finished)/;
	($self->{timestamp}) = $line =~ /^(....-..-.. ..:..:..)/ unless $self->{timestamp};
	$self->{flags}->{$flag}++;
}


sub is_normal {
	my $self = shift @_;
	return $self->{flags}->{launched} == 1 && $self->{flags}->{started} == 1 && $self->{flags}->{finished} == 1;
}






__DATA__


2007-12-12 14:22:09.609 Freitag FUJI[200] transfer script launched with pid 202 for job 000000288768
2007-12-12 14:22:10 freitag-fuji-transfer.pl [202] transfer for job '000000288768' started at /Applications/Freitag FUJI.app/Contents/Resources/freitag-fuji-transfer.pl line 129.
2007-12-12 14:22:16 freitag-fuji-transfer.pl [202] transfer for job '000000288768' finished successfully at /Applications/Freitag FUJI.app/Contents/Resources/freitag-fuji-transfer.pl line 129.
