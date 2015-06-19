#!/usr/bin/perl -w

=head1 Name

	package DictionaryPopUp
	
=head1 Version

	0.1
	
=head1 Synopsis

	$popup = DictionaryPopUp->new();
	$popup->createAddingPopUp($title, $ok, $cancel, $color);
	
=head1 Description

	This package encapsulates creation of different types of popups
	
=cut

package DictionaryPopUp;

use strict;
use warnings;
use Glib qw(TRUE FALSE); 

=head1 Methods

	List of methods
	
=cut

sub new {
	my $class = shift;
	my $self = {@_};
	bless($self,$class);
	$self->{cancel} = 0;
	return $self;
} # end sub new

=head2 createAddingPopUp
	
	This method creates popup with progressbar and text view, to display messages
=cut

sub createAddingPopUp {
	
	my $self = shift;
	my($title, $ok, $cancel, $color, $iconPath) = @_;

	my $popup = Gtk2::Window->new("toplevel");
	my $vbox = Gtk2::VBox->new(FALSE, 0);
	my $scrolled = Gtk2::ScrolledWindow->new();
	my $textView = Gtk2::TextView->new();
	my $close = Gtk2::Button->new();
	my $progressbar = Gtk2::ProgressBar->new();
	my $cancelButton = Gtk2::Button->new();

	my $textBuffer = $textView->get_buffer();
	my $textIter = $textBuffer->get_end_iter();
	$self->{close} = $close;
	$self->{scrolled} = $scrolled;
	$self->{progressbar} = $progressbar;
	$self->{textview} = $textView;
	$self->{textbuffer} = $textBuffer;
	$self->{textiter} = $textIter;

	$popup->set_title($title);
	$popup->modify_bg ('normal', $color);
	$popup->set_position('center');
	$popup->set_resizable(FALSE);
	$popup->set_size_request(350,250);
	$popup->set_icon_from_file ($iconPath . '/symphaty.png'); 
	$close->set_label($ok);
	$close->set_sensitive(0);
	$cancelButton->set_label($cancel);
	$textView->set_editable(0);
	$textView->set_cursor_visible(0);
	$progressbar->set_orientation('left_to_right');

	$popup->add($vbox);
	$vbox->pack_start($close, FALSE, FALSE, 4);
	$vbox->pack_start($scrolled, TRUE, TRUE, 4);
	$vbox->pack_start($progressbar, FALSE, FALSE, 4);
	$vbox->pack_start($cancelButton, FALSE, FALSE, 4);
	$scrolled->add($textView);

	$close->signal_connect(clicked => sub { $popup->destroy });
	$cancelButton->signal_connect(clicked => sub {$self->cancel();$popup->destroy;});

	$popup->show_all;

} # end sub createAddingPopUp

=head2 createTranslationPopUp

	This method creates popup which lives just 5 secs, it is used for displying words in compact mode
=cut

sub createTranslationPopUp {

	my $self = shift;
	my($title, $text, $window, $color, $iconPath) = @_;
	my($xscr, $yscr) = (Gtk2::Gdk->screen_width, Gtk2::Gdk->screen_height);
	my($xpos, $ypos) = $window->get_position();
	my($width, $height) = $window->get_size();

	my $popup = Gtk2::Window->new("toplevel");
	my $vbox = Gtk2::VBox->new(FALSE,5);
	my $label = Gtk2::Label->new();

	$popup->modify_bg ('normal', $color);
	$popup->set_title($title);
	$popup->set_icon_from_file ($iconPath . '/symphaty.png'); 
	$label->set_markup($text);
	$vbox->set_border_width(10);

	$popup->add($vbox);
	$vbox->pack_start($label, FALSE, FALSE, 5);

	my($heightPop, $widthPop) = $popup->get_size();

	if($ypos > ($yscr/2) && ($ypos+$height+$heightPop) > $yscr) {
		$popup->move($xpos, $ypos-$heightPop-30);
	} else {
		$popup->move($xpos, $ypos+2*$height);
	} # if

	$popup->show_all();

	my $id = Glib::Timeout->add(4000, sub{$popup->hide; return FALSE;});

} # end sub createTranslationPopUp

=head2 insertTextToPopUp

	This method is used for inserting text in text view of popup window
	
=cut

sub insertTextToPopUp {
	
	my $self = shift;
	my $text = shift;
	
	$self->{textbuffer}->insert($self->{textiter},"$text\n");
	$self->{textview}->set_buffer($self->{textbuffer});
	
} # end sub insertTextToPopup

=head2 getCancel

	This method is used for retrieving cancel value, which is set by some popups
	if the cancel button is pushed
=cut

sub getCancel {
	my $self = shift;
	return $self->{cancel};
} # end sub getCancel

=head2 cancel

	This method is used for setting cancel value by some popups, when cancel is clicked
=cut

sub cancel {
	my $self = shift;
	$self->{cancel} = 1;
} # end sub cancel

=head2 updateProgressBar

	This method is used for updating progressbar in popup
	
=cut

sub updateProgressBar {

	my $self = shift;
	my $fraction = shift;
	$self->{progressbar}->set_fraction($fraction);

	if($fraction == 1) {
		$self->{close}->set_sensitive(1);
	} # if

	Gtk2->main_iteration while Gtk2->events_pending; 

} # end sub updateProgressBar

=head1 Dependencies

	Glib
	
=cut

=head1 Author

	Copyright Pavol Ipoth 2011
	
=head1 Licence

	GPL
	
=cut

1;
