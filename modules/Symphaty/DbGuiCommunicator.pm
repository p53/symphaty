#!/usr/bin/perl -w

=encoding utf8

=head1 Name

	package DbGuiCommunicator
	
=head1 Version

	0.1
	
=head1 Synopsis

	$communicator = DbGuiCommunicator->new();
	$communicatro->displayResult($treeStore, $result, $labels);
	
=head1 Description

	This module is used for displaying words to gui interface
	
=cut

package DbGuiCommunicator;

use strict;
use warnings;

use Symphaty::DictionaryPopUp;

#-------------------------------------------------------------------------------

=head1 Methods
	
	Listing of methods
=cut

sub new {
	my $class = shift;
	my $self = {@_};
	bless($self,$class);
	return $self;
} # end sub new

=head2 displayResult
	
	This method displays result from retrieved from database to tree view gtk2 widget
=cut

sub displayResult {
	
	my $self = shift;
	my $outputTreeStore = shift;
	my $result = shift;
	my $labels = shift;
	my $searched = $$result{searched}->[0];
	
	delete($$result{searched});
	
	my $iter = $outputTreeStore->append(undef);
	$outputTreeStore->set($iter,0 => $searched );
	my $path = $outputTreeStore->get_path($iter);

	foreach my $item(keys %$result) {

		my $iter_child = $outputTreeStore->append($iter);
		$outputTreeStore->set ($iter_child,0 => $$labels{$item});

		foreach my $out ($$result{$item}) {

			if (ref $out && $out =~ /ARRAY/) { 
				foreach my $val(@$out){
					my $iter_child_child = $outputTreeStore->append($iter_child);
					$outputTreeStore->set ($iter_child_child,0 => $val);
				} # foreach
			} # if
			
			if (ref $out && $out =~ /HASH/) {
				foreach my $key(keys %$out){
					my $iter_child_child = $outputTreeStore->append($iter_child);
					$outputTreeStore->set ($iter_child_child,0 => $$out{$key});
					my $iter_child_child_child = $outputTreeStore->append($iter_child_child);
					$outputTreeStore->set ($iter_child_child_child,0 => $key);
				} # foreach
			} # if
			
		} # foreach
		
	} # foreach
	
	return $path;
	
} # end sub displayResult

=head2 displayShortCutResult
	
	This method displays result from database to popup messages when it is in compact mode
=cut

sub displayShortCutResult {

	my $self = shift;
	my($result, $title, $shortCutMessage, $searched, $window, $color, $iconPath) = @_;
	my $text ='';

	my $dialog = DictionaryPopUp->new();

	$text = '<span foreground="black" size="x-large"><b>' . $shortCutMessage . '</b></span>';
	$text .= ' <span size="xx-large" underline="single"><b>' . $searched . '</b></span>

';

	my $words = $result->{word};

	foreach my $meaning(@$words[0..4]){
		$text .= '	<span foreground="DarkRed" size="x-large">' . $meaning . '</span>
';
	} # foreach


	$dialog->createTranslationPopUp($title, $text, $window, $color, $iconPath);

} # end sub displayShortCutResult

=head1 Dependencies

	DictionaryPopUp
	
=cut

=head1 Author

	Copyright Pavol Ipoth 2011
	
=head1 Licence

	GPL
	
=cut

1;
