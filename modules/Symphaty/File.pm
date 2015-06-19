#!/usr/bin/perl -w

=head1 Name 

	package File
	
=head1 Version

	0.1

=head1 Synopsis

	$file = File->new();
	@lines = $file->read($filepath);
	
=head1 Description

	This package encapsulates some file operations
	
=cut

package File;

use warnings;
use strict;

use Symphaty::Verifier;

#-------------------------------------------------------------------------------

=head1 Methods
	
	List of methods
=cut

sub new() {
	my $class = shift;
	my $self = {@_};
	bless($self,$class);
	return $self;
} # method new

=head2 read

	This method reads content of the file and returns it in array additionaly count lines
=cut

sub read() {

	my $self = shift;
	my $filepath = shift;

	open FH,"< $filepath" or die "cant open $!";
	my @lines = <FH>;
	my $count = @lines;
	close(FH);
	$self->{count} = $count;
	$self->{lines} = \@lines;

	return \@lines;
	
} # method read

=head2 verify

	This method verifies if file is non-empty, text-file and has batch format
=cut

sub verify() {

	my $self = shift;
	my $filepath = shift;
	
	my $message = 'fileok';
	my $count = 1;
	my $size = -s $filepath;
	my $text = -T $filepath;
	
	if($size == 0){ print $size;
		return "emptyFile";
	} # if
	
	if($text != 1) {print $text;
		return "nonTextFile";
	} # if

	my $verifier = Verifier->new();

	foreach my $line(@{$self->{lines}}){
		my $batch = $verifier->verify('batch', $line);
		if(!$batch) {
			return "badFormatFile" . $count;
		} # if
		$count++;
	} # foreach
	
	return $message;
	
} # method verify

=head2 parseLine

	This method splits line passed to it
=cut

sub parseLine() {
	my $self = shift;
	my $line = shift;
	my @lineParts = split(':', $line);
	return @lineParts; 
} # method parseLine

=head2 getCount

	This method retrieves number of lines of previously read file
	
=cut

sub getCount() {
	my $self = shift;
	return $self->{count};
}

=head1 Author

	Copyright Pavol Ipoth 2011
	
=head1 Dependencies

	Verifier
	
=cut

1;
