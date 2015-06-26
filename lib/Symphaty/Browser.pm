#!/usr/bin/perl -w

=head1 Name

	package Browser
	
=head1 Version

	0.1
	
=head1 Synopsis

	$browser = Browser->new();
	$browser->openURL($absolutePath);
	
=head1 Description

	This package detects OS and according that opens in browser
	
=cut

package Browser;

#-------------------------------------------------------------------------------

=head1 Methods

	List of methods
	
=cut

my $instance;

sub new {

	my $class = shift;
	
	if(!defined $instance) {
		$instance = {@_};
		bless($instance,$class);
		$instance->_init();
	} # if

	return $instance;
	
} # end sub new

sub _init {
	my $self = shift;
	$self->{OS} = $^O;
	$self->{browsers} = ['firefox', 'google-chrome', 'konqueror', 'opera', 'galeon', 'epiphany', 'safari', 'dillo'];
} # end sub _init

=head2 openURL

	This method opens absoulute path given as parameter in browser
=cut

sub openURL {
	
	my $self = shift;
	my $url = shift;
	my $browsers = $self->{browsers};
	
	if($self->{OS} eq 'MSWin32') {
		system('start /b ' . $url);
	} elsif($self->{OS} eq 'linux' or $self->{OS} eq 'darwin') {
		
		foreach my $browser(@$browsers) {
			my $isThere = `whereis $browser`;
			if($isThere =~ /^[\w-]+\:(\s+[\w\/\-_]+)/) {
				my $cmd = `$1 $url`;
				last;
			} # if
		} # foreach
		
	} # if
	
} # end sub openURL

=head1 Author

	Copyright Pavol Ipoth 2015
	
=head1 Licence

	GPL
	
=cut

1;
