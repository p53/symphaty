#!/usr/bin/perl -w

=encoding utf8

=head1 Name

	package DictionaryDialog
	
=head1 Version

	0.1
	
=head1 Synopsis

	$dialog = DictionaryDialog->new();
	$dialog-> createMessage($window, $icon, 'info', 'lala', 'title', $color);
	
=head1 Description

	This package helps to encapsulate dialog creation
=cut

package DictionaryDialog;

use strict;
use warnings;
use Glib qw(TRUE FALSE); 

my $dialogResult = {};

=head1 Methods

	List of methods
=cut

sub new {
	my $class = shift;
	my $self = {@_};
	bless($self,$class);
	return $self;
} # end sub new

=head2 createMessage
	
	This method creates gtk2 message dialog
=cut

sub createMessage {

	my $self = shift;
	(my $parent, my $icon, my $button_type, my $text, my $title, my $color) = @_;

	my $dialog = Gtk2::MessageDialog->new_with_markup (
															$parent,
															[qw/modal destroy-with-parent/],
															$icon,
															$button_type,
															$text
														);
	
	$dialog->set_title($title);
	$dialog->set_resizable(FALSE);
	$dialog->modify_bg ('normal', $color);

	my $retval = $dialog->run;

	$dialog->destroy;
	
} # end sub createMessage

=head2 createInputDialog
	
	This method helps to create dialog with custom number of inputs
=cut

sub createInputDialog {

	my $self = shift;
	my($parent, $title, $labelList, $ok, $cancel, $color) = @_;
	my @labels = @$labelList;
	my $numberLabels = @labels;
	
	my $entries = {};
	my $x = 0;
	my $y = 0;
	my $z = 0;
	
	my $dialog = Gtk2::Dialog->new (	
										$title,
										$parent,
										[qw/modal destroy-with-parent/],
										$ok     => 'accept',
										$cancel => 'reject'
									);

	$dialog->set_position('mouse');
	$dialog->set_resizable(FALSE);
	$dialog->modify_bg ('normal', $color);
	
	my $container = Gtk2::Table->new(2,$numberLabels, TRUE);

	foreach my $label(@labels) {
	
		my $boxLabel = Gtk2::Label->new($label);
		my $boxEntry = Gtk2::Entry->new();
		$container->attach_defaults($boxLabel,$x,$x+1,$y,$y+1);
		$container->attach_defaults($boxEntry,$x+1,$x+2,$y,$y+1);
		$entries->{$label} = $boxEntry;
		$y++;
		$z+=2;
		
	} # foreach

	$dialog->vbox->pack_start($container, FALSE, FALSE, 4);
	$dialog->show_all;
	
	my $returnValue = $dialog->run;
	
	if($returnValue eq 'accept') {
		foreach my $label(keys %$entries){
			$dialogResult->{$label} = lc($entries->{$label}->get_text());
		} # foreach
	} # if

	$dialog->destroy;
	
} # end sub createInputDialog

=head2 createFileChooser

	This method creates file chooser dialog
	
=cut

sub createFileChooser() {

	my $self = shift;
	my ($parent, $title, $ok, $cancel, $color) = @_;
	
	my $dialog = Gtk2::FileChooserDialog->new (	
										$title,
										$parent,
										'open',
										$ok     => 'accept',
										$cancel => 'reject'
									);
									
	$dialog->modify_bg ('normal', $color);
	$dialog->show_all;
	
	my $retval = $dialog->run;
	
	if($retval eq 'accept') {
		my $filename = $dialog->get_filename();
		$dialogResult->{filename} = $filename;
	} # if
	
	$dialog->destroy;
	
} # end sub createFileChooser

=head2 createQuestionDialog

	This methos creates dialog with question
=cut

sub createQuestionDialog () {

	my $self = shift;
	my($parent, $title, $ok, $cancel, $question, $color) = @_;

	my $dialog = Gtk2::Dialog->new (	
										$title,
										$parent,
										[qw/modal destroy-with-parent/],
										$ok     => 'accept',
										$cancel => 'reject'
									);

	$dialog->set_position('mouse');
	$dialog->modify_bg ('normal', $color);
	$dialog->set_resizable(FALSE);

	my $questionLabel = Gtk2::Label->new($question);
	
	$dialog->vbox->pack_start($questionLabel, FALSE, FALSE, 4);

	$dialog->show_all;

	my $retval = $dialog->run;
	
	if($retval eq 'accept') {
		$dialogResult->{question} = 1;
	} # if

	$dialog->destroy;

} # end sub createQuestionDialog

=head2 getDialogResult
	
	This methods serves for getting result of dialog, e.g. filechooser returns name of choosed file etc.
=cut

sub getDialogResult {
	my $return = $dialogResult;
	$dialogResult = {};
	return $return;
} # end sub getDialogResult

=head1 Dependencies

	Glib
	
=cut

=head1 Author

	Copyright Pavol Ipoth 2011
	
=head1 Licence

	GPL
	
=cut

1;
