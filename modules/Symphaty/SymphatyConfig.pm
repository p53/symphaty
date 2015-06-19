#!/usr/bin/perl -s

=head1 Name

	package SymphatyConfig
	
=head1 Version

	0.1
	
=head1 Synopsis

	$config = SymphatyConfig->new();
	$config->getLang();
	
=head1 Description

	This package manipulates with settings stored in xml file
	
=cut

package SymphatyConfig;

use XML::Simple;

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
	my $xmlObject = XML::Simple->new(NoAttr=>1,RootName=>'Configuration',ForceArray=>1);
	my $xmlData = $xmlObject->XMLin('/usr/share/symphaty/config.xml');
	$self->{xml} = $xmlObject;
	$self->{xmlData} = $xmlData;
} # end sub _init

=head2 setLang

	This method sets lang translation direction into xml data stored in xmlData
=cut

sub setLang {
	my $self = shift;
	my $lang = shift;
	$self->{xmlData}->{langDirection}->[0] = $lang;
	return $self;
} # end sub setLang

=head2 getLang

	This method retrieves actual language translation direction from xmlData stored in class property
	
=cut

sub getLang {
	my $self = shift;	
	my $lang = $self->{xmlData}->{langDirection}->[0];
	return $lang;
} # end sub getLang

=head2 setLangLabels

	This method sets language which is used in interface
	
=cut

sub setLangLabels {
	my $self = shift;
	my $lang = shift;
	$self->{xmlData}->{langLabels}->[0] = $lang;
	return $self;
} # end sub setLangLabels

=head2 setLangLabels

	This method gets language which is used in interface
	
=cut

sub getLangLabels {
	my $self = shift;	
	my $lang = $self->{xmlData}->{langLabels}->[0];
	return $lang;
} # end sub getLangLabels

=head2 setColor

	This method stores color values in xml
	
=cut

sub setColor {

	my $self = shift;
	my $red = shift;
	my $green = shift;
	my $blue = shift;
	$self->{xmlData}->{gui}->[0]->{appearance}->[0]->{color}->[0]->{red}->[0] = $red;
	$self->{xmlData}->{gui}->[0]->{appearance}->[0]->{color}->[0]->{green}->[0] = $green;
	$self->{xmlData}->{gui}->[0]->{appearance}->[0]->{color}->[0]->{blue}->[0] = $blue;
	return $self;
	
} # end sub setColor

=head2 getColor

	This method gets color from xml config file
	
=cut

sub getColor {

	my $self = shift;	
	$red = $self->{xmlData}->{gui}->[0]->{appearance}->[0]->{color}->[0]->{red}->[0];
	$green = $self->{xmlData}->{gui}->[0]->{appearance}->[0]->{color}->[0]->{green}->[0];
	$blue = $self->{xmlData}->{gui}->[0]->{appearance}->[0]->{color}->[0]->{blue}->[0];
	my %color = (
					'red' => $red,
					'green' => $green,
					'blue' => $blue
				);
	return \%color;
	
} # end sub getColor

=head2 getStockIcons

	This method retrieves images used as stock icons
	
=cut

sub getStockIcons {
	my $self = shift;	
	$stock = $self->{xmlData}->{gui}->[0]->{appearance}->[0]->{stockIcons}->[0];
	return $stock;
} # end sub getStockIcons

=head2 getCompact

	This method gets actual compactness property settings
	
=cut

sub getCompact {
	my $self = shift;	
	$compact = $self->{xmlData}->{gui}->[0]->{appearance}->[0]->{compact}->[0];
	return $compact;
} # end sub getCompact

=head2 setCompact

	This method sets compactness
	
=cut

sub setCompact {
	my $self = shift;
	my $compact = shift;
	$self->{xmlData}->{gui}->[0]->{appearance}->[0]->{compact}->[0] = $compact;
	return $self;
} # end sub setCompact

=head2 getAllGuiLabels

	This method retrieves all labels according interface language settings
	
=cut

sub getAllGuiLabels {
	my $self = shift;
	my $lang = shift;
	my $labels = $self->{xmlData}->{gui}->[0]->{labels}->[0]->{$lang}->[0];
	return $labels;
} # end sub getAllGuiLabels

=head2 getIconsPath

	This method retrievs path for icons from config
	
=cut

sub getIconsPath {
	my $self = shift;
	my $iconsPath = $self->{xmlData}->{gui}->[0]->{appearance}->[0]->{iconsPath}->[0];
	return $iconsPath;
}

=head2 save

	This method writes all data stored in xmlData property to file
=cut

sub save {
	my $self = shift;
	open my $filehandler,">:utf8",'/usr/share/symphaty/config.xml' or die $!;
	my $success = $self->{xml}->XMLout($self->{xmlData},'OutputFile' => $filehandler,XMLDecl => 1);
	return $success;
} # end sub save

=head1 Dependencies

	Depends on XML::Simple
	
=cut

=head1 Author

	Copyright Pavol Ipoth 2011
	
=head1 Licence

	GPL
	
=cut

1;
