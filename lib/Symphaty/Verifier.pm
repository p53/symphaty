#!/usr/bin/perl -w

=head1 Name

	package Verifier
	
=head1 Version

	0.1
	
=head1 Synopsis

	$verifier = Verifier->new();
	$return = $verifier->verify('empty',$value);

=head1 Description
	
	This package is used for verifying values if they match criteria which can be added as regular expression
=cut

package Verifier;

#-------------------------------------------------------------------------------

=head1 Methods
	
	List of methods
=cut

sub new() {
	my $class = shift;
	my $self = {@_};
	bless($self,$class);
	$self->_init();
	return $self;
} # end sub new

sub _init() {
	my $self = shift;
	if(!$self->{patterns}) {
		$self->{patterns} = {
			'empty' => qr/^\s*$/,
			'batch' => qr/^(\w+:\w+)+$/
		};
	} # if
} # end sub _init

=head2 addPattern
	
	This method serves for adding your custom patterns
=cut

sub addPattern() {
	my $self = shift;
	my $key = shift;
	my $pattern = shift;
	$self->{patterns}->{$key} = $pattern;
	return $self;
} # end sub addPattern

=head2 verify
	
	This method servers for verifying according your pattern and supplied value
=cut

sub verify() {

	my $self = shift;
	my $patternType = shift;
	my $string = shift;

	if($string =~ $self->{patterns}->{$patternType}) {
		return $patternType;
	} # if
	
	return 0;
	
} # end sub verify

=head1 Author

	Copyright Pavol Ipoth 2011
	
=head1 Licence

	GPL
	
=cut

1;
