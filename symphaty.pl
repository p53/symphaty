#!/usr/bin/perl -w

=encoding utf8


=head1 Symphaty

	version = 0.4
	author = savage
	licence = GPL
	
	This is the main script, here is created GUI and are stored
	event functions for whole Symphaty

=head2 Used Modules


	strict
	warnings
	Gtk2
	Glib
	Gtk2::Gdk::Keysyms
	DictionaryDialog
	DictionaryPopUp
	LangOperations
	DbGuiCommunicator
	SymphatyConfig
	File
	Clipboard
	Browser

=cut

use strict;
use warnings;
use Gtk2 -init;
use Glib qw(TRUE FALSE); 
use Gtk2::Gdk::Keysyms;
use Symphaty::DictionaryDialog;
use Symphaty::DictionaryPopUp;
use Symphaty::LangOperations;
use Symphaty::DbGuiCommunicator;
use Symphaty::SymphatyConfig;
use Symphaty::File;
use Clipboard;
use Symphaty::Browser;

##############################Configuration#####################################

#-------------------------------------------------------------------------------
# creating class for retrieving settings from xml file and retrieving settings
#-------------------------------------------------------------------------------
my $configuration = SymphatyConfig->new();
my $lang = $configuration->getLang();
my $langForLabels = $configuration->getLangLabels();
my $langLabels = $configuration->getAllGuiLabels($langForLabels);
my $colorRGB = $configuration->getColor();
my $compact = $configuration->getCompact();
my $iconPath = $configuration->getIconsPath();
###################################GUI##########################################

#------------- Images ----------------------------------------------------------

	#------------- Top Menu Box Images ---------------------------------------------
	my $addWordImage = Gtk2::Image->new_from_file($iconPath . '/word.png');
	my $addWordsImage = Gtk2::Image->new_from_file($iconPath . '/words.png');
	my $addTenseImage = Gtk2::Image->new_from_file($iconPath . '/tense.png');
	my $switchLangEnImage = Gtk2::Image->new_from_file($iconPath . '/eng_to_svk.png');
	my $switchLangSkImage = Gtk2::Image->new_from_file($iconPath . '/svk_to_eng.png');
	my $settingsImage = Gtk2::Image->new_from_file($iconPath . '/settings.png');
	my $helpImage = Gtk2::Image->new_from_file($iconPath . '/help.png');
	my $infoImage = Gtk2::Image->new_from_file($iconPath . '/info.png');
	my $aboutImage = Gtk2::Image->new_from_file($iconPath . '/about.png');
	#-------------------------------------------------------------------------------
	
	#------------- Input Box Images ------------------------------------------------
	my $shrinkImage = Gtk2::Image->new_from_file($iconPath . '/max.png');
	my $maxImage = Gtk2::Image->new_from_file($iconPath . '/shrink.png');
	my $clipboardSearchImage = Gtk2::Image->new_from_file($iconPath . '/clipboardsearch.png');
	my $collapseImage = Gtk2::Image->new_from_file($iconPath . '/collapse.png');
	my $recyclebinImage = Gtk2::Image->new_from_file($iconPath . '/recyclebin.png');
	#-------------------------------------------------------------------------------
	
#-------------------------------------------------------------------------------

################################################################################

#------------- Colors ----------------------------------------------------------
my $color = Gtk2::Gdk::Color->new($$colorRGB{red}, $$colorRGB{green}, $$colorRGB{blue});
#-------------------------------------------------------------------------------

################################################################################

#------------- Windows ---------------------------------------------------------

	#------------- Main Window -----------------------------------------------------
	my $mainWindow = Gtk2::Window->new('toplevel');
	$mainWindow->set_position('mouse');
	$mainWindow->set_icon_from_file ($iconPath . '/symphaty.png'); 
	$mainWindow->set_title('Symphaty');
	$mainWindow->modify_bg ('normal', $color);
	$mainWindow->set_resizable(FALSE);
	#-------------------------------------------------------------------------------
	
	#------------- Output Box Scrolled Window --------------------------------------
	my $outputScrolledWindow = Gtk2::ScrolledWindow->new(undef,undef);
	$outputScrolledWindow->set_shadow_type('etched-out');
	$outputScrolledWindow->set_size_request(500,300);
	#-------------------------------------------------------------------------------
	
#-------------------------------------------------------------------------------

################################################################################

#------------- Boxes -----------------------------------------------------------
	
	#------------- Main Window Sectioner Box ---------------------------------------
	my $mainWindowSectionerVBox = Gtk2::VBox->new(FALSE, 0);
	#-------------------------------------------------------------------------------
	
	#------------- Top Menu Box (parent Main Window Sectioner) ---------------------
	my $topMenuHBox = Gtk2::HBox->new(FALSE, 0);
	#-------------------------------------------------------------------------------
	
	#------------- Input Box (parent Main Window Sectioner) ------------------------
	my $inputHBox = Gtk2::HBox->new(FALSE, 0);
	#-------------------------------------------------------------------------------
	
	#------------- Output Box (parent Main Window Sectioner) -----------------------
	my $outputHBox = Gtk2::HBox->new(FALSE, 0);
	#-------------------------------------------------------------------------------
	
#-------------------------------------------------------------------------------

################################################################################

#------------- Buttons ---------------------------------------------------------

	#------------- Top Menu Box Buttons --------------------------------------------
	my $addWordButton = Gtk2::Button->new();
	$addWordButton->set_property('image' => $addWordImage);
	my $addWordsButton = Gtk2::Button->new();
	$addWordsButton->set_property('image' => $addWordsImage);
	my $addTenseButton = Gtk2::Button->new();
	$addTenseButton->set_property('image' => $addTenseImage);
	my $switchLangButton = Gtk2::Button->new();
	if($lang eq 'eng') {
		$switchLangButton->set_property('image' => $switchLangEnImage);
	} else {
		$switchLangButton->set_property('image' => $switchLangSkImage);
	} # if
	my $settingsButton = Gtk2::Button->new();
	$settingsButton->set_property('image' => $settingsImage);
	my $helpButton = Gtk2::Button->new();
	$helpButton->set_property('image' => $helpImage);
	my $infoButton = Gtk2::Button->new();
	$infoButton->set_property('image' => $infoImage);
	#-------------------------------------------------------------------------------

	#------------- Input Box Buttons -----------------------------------------------
	my $shrinkButton = Gtk2::Button->new();
	$shrinkButton->set_property('image' => $shrinkImage);
	my $clipboardSearchButton = Gtk2::Button->new();
	$clipboardSearchButton->set_property('image' => $clipboardSearchImage);
	my $collapseButton = Gtk2::Button->new();
	$collapseButton->set_property('image' => $collapseImage);
	my $recyclebinButton = Gtk2::Button->new();
	$recyclebinButton->set_property('image' => $recyclebinImage);
	#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------

################################################################################

#------------- Entries ---------------------------------------------------------

	#------------- Input Box Entry -------------------------------------------------
	my $inputEntry = Gtk2::Entry->new();
	#-------------------------------------------------------------------------------
	
#-------------------------------------------------------------------------------

################################################################################

#------------- TreeViews -------------------------------------------------------

	#------------- Output Box TreeView ---------------------------------------------
	my $outputTreeStore = Gtk2::TreeStore->new(qw/Glib::String/);
	my $outputTreeView = Gtk2::TreeView->new($outputTreeStore);
	my $resultsTreeColumn = Gtk2::TreeViewColumn->new();
	$resultsTreeColumn->set_title($langLabels->{output}->[0]->{header}->[0]);
	my $cell = Gtk2::CellRendererText->new();
	$resultsTreeColumn->pack_start ($cell, FALSE);
	$resultsTreeColumn->add_attribute($cell, text => 0);
	$cell->set_property('text', TRUE);
	$cell->set_property('editable', TRUE);
	$outputTreeView->append_column($resultsTreeColumn);
	$outputTreeView->set_search_column(0);
	$resultsTreeColumn->set_sort_column_id(0);
	$outputTreeView->set_reorderable(TRUE);
	#-------------------------------------------------------------------------------
		
#-------------------------------------------------------------------------------

################################################################################

#------------- Separators ------------------------------------------------------

	#------------- Top Menu Box Separators -----------------------------------------
	my $afterAddSeparator = Gtk2::VSeparator->new();
	my $afterSwitchLangSeparator = Gtk2::VSeparator->new();
	#-------------------------------------------------------------------------------
	
#-------------------------------------------------------------------------------

################################################################################

#------------- Tooltips --------------------------------------------------------

	#-------------------------------------------------------------------------------
	my $toolTips = Gtk2::Tooltips->new();
	$toolTips->set_tip($addWordButton, $langLabels->{addword}->[0]->{tooltip}->[0]);
	$toolTips->set_tip($addWordsButton, $langLabels->{addwords}->[0]->{tooltip}->[0]);
	$toolTips->set_tip($addTenseButton, $langLabels->{addtense}->[0]->{tooltip}->[0]);
	$toolTips->set_tip($switchLangButton, $langLabels->{switchlang}->[0]->{tooltip}->[0]);
	$toolTips->set_tip($settingsButton, $langLabels->{settings}->[0]->{tooltip}->[0]);
	$toolTips->set_tip($helpButton, $langLabels->{help}->[0]->{tooltip}->[0]);
	$toolTips->set_tip($infoButton, $langLabels->{info}->[0]->{tooltip}->[0]);
	$toolTips->set_tip($inputEntry, $langLabels->{inputentry}->[0]->{tooltip}->[0]);
	$toolTips->set_tip($clipboardSearchButton, $langLabels->{clipboardsearch}->[0]->{tooltip}->[0]);
	$toolTips->set_tip($shrinkButton, $langLabels->{shrink}->[0]->{tooltip}->[0]);
	$toolTips->set_tip($collapseButton, $langLabels->{collapse}->[0]->{tooltip}->[0]);
	$toolTips->set_tip($recyclebinButton, $langLabels->{recyclebin}->[0]->{tooltip}->[0]);
	#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------

################################################################################

#------------- Signals ---------------------------------------------------------

	#------------- Main Window -----------------------------------------------------
	$mainWindow->signal_connect(delete_event => sub { $configuration->save();Gtk2 ->main_quit });
	#-------------------------------------------------------------------------------
	
	#------------- Top Menu Box Buttons --------------------------------------------
	$addWordButton->signal_connect(clicked => \&addWordGUI);
	$addWordsButton->signal_connect(clicked => \&addWordsGUI);
	$addTenseButton->signal_connect(clicked => \&addTenseGUI);
	
	$switchLangButton->signal_connect(clicked => \&switchLangGUI);
	
	$settingsButton->signal_connect(clicked => \&settingsGUI);
	$helpButton->signal_connect(clicked => \&helpGUI);
	$infoButton->signal_connect(clicked => \&infoGUI);
	#-------------------------------------------------------------------------------

	#------------- Input Box -------------------------------------------------------
	$inputEntry->signal_connect('key-press-event' => \&ifKeyTranslateGUI);
	$shrinkButton->signal_connect(clicked => \&switchShrinkGUI);
	$clipboardSearchButton->signal_connect(clicked => \&ifKeyTranslateGUI);
	$collapseButton->signal_connect(clicked => \&collapseAllWords);
	$recyclebinButton->signal_connect(clicked => \&recyclebinAllWords);
	#-------------------------------------------------------------------------------

################################################################################

#------------- Accelerators --------------------------------------------------------

	#------------- Accelerator Objects ---------------------------------------------
	my $accel = Gtk2::AccelGroup->new();
	#-------------------------------------------------------------------------------
	
	#------------- Accelerator Shortcuts -------------------------------------------
	my ( $key, $mods ) = Gtk2::Accelerator->parse( '<alt>T' );
	#-------------------------------------------------------------------------------
	
	#------------- Accelerator connecting ------------------------------------------
	$accel->connect($key, $mods, [qw/visible/], sub { ifKeyTranslateGUI($clipboardSearchButton); });
	#-------------------------------------------------------------------------------
	
	#------------- Accelerator adding to window ------------------------------------
	$mainWindow->add_accel_group ($accel);
	#-------------------------------------------------------------------------------

################################################################################

#------------- Packing ---------------------------------------------------------

	#------------- Main Window -----------------------------------------------------
	$mainWindow->add($mainWindowSectionerVBox);
	#-------------------------------------------------------------------------------
	
	#------------- Main Window Sectioner Box ---------------------------------------
	$mainWindowSectionerVBox->pack_start($topMenuHBox, FALSE, FALSE, 4);
	$mainWindowSectionerVBox->pack_start($inputHBox, FALSE, FALSE, 4);
	$mainWindowSectionerVBox->pack_start($outputHBox, FALSE, FALSE, 4);
	#-------------------------------------------------------------------------------

	#------------- Top Menu Box ----------------------------------------------------
	$topMenuHBox->pack_start($addWordButton, FALSE, FALSE, 4);
	$topMenuHBox->pack_start($addWordsButton, FALSE, FALSE, 4);
	$topMenuHBox->pack_start($addTenseButton, FALSE, FALSE, 4);
	
	$topMenuHBox->pack_start($afterAddSeparator, FALSE, FALSE, 4);
	
	$topMenuHBox->pack_start($switchLangButton, FALSE, FALSE, 4);
	
	$topMenuHBox->pack_start($afterSwitchLangSeparator, FALSE, FALSE, 4);
	
	$topMenuHBox->pack_start($settingsButton, FALSE, FALSE, 4);
	$topMenuHBox->pack_start($helpButton, FALSE, FALSE, 4);
	$topMenuHBox->pack_start($infoButton, FALSE, FALSE, 4);
	#-------------------------------------------------------------------------------
	
	#------------- Input Box -------------------------------------------------------
	$inputHBox->pack_start($inputEntry, FALSE, FALSE, 4);
	$inputHBox->pack_end($shrinkButton, FALSE, FALSE, 4);
	$inputHBox->pack_start($clipboardSearchButton, FALSE, FALSE, 4);
	$inputHBox->pack_start($collapseButton, FALSE, FALSE, 4);
	$inputHBox->pack_start($recyclebinButton, FALSE, FALSE, 4);
	#-------------------------------------------------------------------------------
	
	#------------- Output Box ------------------------------------------------------
	$outputHBox->pack_start($outputScrolledWindow, FALSE, FALSE, 4);
	$outputScrolledWindow->add($outputTreeView);
	$resultsTreeColumn->pack_start($cell, FALSE);
	#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------

################################################################################

#------------- Create Custom Dialog Icons --------------------------------------
createStockIcons();
#-------------------------------------------------------------------------------

#------------- Display GUI -----------------------------------------------------
$mainWindow->show_all;
$inputEntry->grab_focus();
if($compact) {minimize()} else {maximize()};
Gtk2->main;
#-------------------------------------------------------------------------------

################################################################################

=head2 Functions

	Listing of used functions

=head3 addWordGUI

	This function serves for adding word to database
=cut


sub addWordGUI {

	my $english = $langLabels->{addword}->[0]->{englishword}->[0];
	my $slovak = $langLabels->{addword}->[0]->{slovakword}->[0];
	my $title = $langLabels->{addword}->[0]->{header}->[0];
	my $ok = $langLabels->{addword}->[0]->{add}->[0];
	my $cancel = $langLabels->{addword}->[0]->{cancel}->[0];
	my $message;

	my $addWordDialog = DictionaryDialog->new();

	my @list=($english, $slovak);
	$addWordDialog->createInputDialog($mainWindow, $title, \@list, $ok, $cancel, $color);
	my $dialogResult = $addWordDialog->getDialogResult();

	if(%$dialogResult) {
		my $inserter = LangOperations->new();
		$message = $inserter->addWordSet($dialogResult, $english, $slovak);
		$message = $langLabels->{addword}->[0]->{$message}->[0];
		$message =~ s/###word###/$dialogResult->{$english}/g;
		$message =~ s/###meaning###/$dialogResult->{$slovak}/g;
		infoMessage($message);
	} # if

} # end sub addWordGUI

=head3 addWordsGUI

	This function serves for adding words to database from
	file. File must be in predefined format:
	englishword:slovakword1:slovakword2
=cut

sub addWordsGUI {

	my $english = $langLabels->{addword}->[0]->{englishword}->[0];
	my $slovak = $langLabels->{addword}->[0]->{slovakword}->[0];
	my $title = $langLabels->{addwords}->[0]->{header}->[0];
	my $ok = $langLabels->{addwords}->[0]->{open}->[0];
	my $cancel = $langLabels->{addwords}->[0]->{cancel}->[0];
	
	my $file;
	my $fileContent;
	my $message = '';

	my $addWordsDialog = DictionaryDialog->new();
	$addWordsDialog->createFileChooser($mainWindow, $title, $ok, $cancel, $color);
	my $dialogResult = $addWordsDialog->getDialogResult();
	
	if(%$dialogResult) {
		$file = File->new();
		$fileContent = $file->read($dialogResult->{filename});
		$message = $file->verify($dialogResult->{filename});
	} # if

	if($message eq 'fileok') {

		my $title = $langLabels->{addwordsProgress}->[0]->{header}->[0];
		my $ok = $langLabels->{addwordsProgress}->[0]->{ok}->[0];
		my $cancel = $langLabels->{addwordsProgress}->[0]->{cancel}->[0];

		my $addWordsStateDialog = DictionaryPopUp->new();
		$addWordsStateDialog->createAddingPopUp($title, $ok, $cancel, $color, $iconPath);

		my $inserter = LangOperations->new();
		my $counter = 0;

		foreach my $line(@$fileContent) {

			$line = lc($line);
			
			my $cancelProgress = $addWordsStateDialog->getCancel();

			if(!$cancelProgress) {

				my @parts = $file->parseLine($line);
				my $engword = shift(@parts);
				my $total = $file->getCount();

				foreach my $skword(@parts){

					$counter++;
					$dialogResult->{$english} = $engword;
					$dialogResult->{$slovak} = $skword;
					$message = $inserter->addWordSet($dialogResult, $english, $slovak);
					$message = $langLabels->{addword}->[0]->{$message}->[0];
					$message =~ s/###word###/$dialogResult->{$english}/g;
					$message =~ s/###meaning###/$dialogResult->{$slovak}/g;
					my $fraction = $counter/$total;
					$addWordsStateDialog->updateProgressBar($fraction);
					$addWordsStateDialog->insertTextToPopUp($message);

				} # foreach

			} else {
				my $cancelationMessage = $langLabels->{addwordsProgress}->[0]->{cancelationMessage}->[0];
				infoMessage($cancelationMessage);
				last;
			} # if

		} # foreach

	} else {
		if($message =~ /(badFormatFile)(\d+)/) {
			$message = $langLabels->{addwords}->[0]->{$1}->[0] . $2;
			warningMessage($message);
		} # if
	}# if

} # end sub addWordsGUI

=head3 addTenseGUI

	This function serves for adding tense to word
=cut

sub addTenseGUI {

	my $infinitive = $langLabels->{addtense}->[0]->{infinitive}->[0];
	my $past = $langLabels->{addtense}->[0]->{past}->[0];
	my $participle = $langLabels->{addtense}->[0]->{participle}->[0];
	my $title = $langLabels->{addtense}->[0]->{header}->[0];
	my $ok = $langLabels->{addtense}->[0]->{add}->[0];
	my $cancel = $langLabels->{addtense}->[0]->{cancel}->[0];
	
	my $message = '';
	my $inserter;

	my $addWordDialog = DictionaryDialog->new();
	my @list=($infinitive, $past, $participle);
	$addWordDialog->createInputDialog($mainWindow, $title, \@list, $ok, $cancel, $color);
	my $dialogResult = $addWordDialog->getDialogResult();
	
	if(%$dialogResult) {
		$inserter = LangOperations->new();
		$message = $inserter->addTenseSet($dialogResult, $infinitive, $past, $participle, 'FALSE');
	}

	if($message eq "update") {

		my $title = $langLabels->{addtenseUpdate}->[0]->{header}->[0];
		my $ok = $langLabels->{addtenseUpdate}->[0]->{update}->[0];
		my $cancel = $langLabels->{addtenseUpdate}->[0]->{cancel}->[0];
		my $question = $langLabels->{addtenseUpdate}->[0]->{question}->[0];
		$question =~ s/###word###/$dialogResult->{$infinitive}/g;
		my $questionDialog = DictionaryDialog->new();
		$questionDialog->createQuestionDialog($mainWindow, $title, $ok, $cancel, $question, $color);
		my $try = $questionDialog->getDialogResult();

		if($try->{question}) {
			my $message = $inserter->addTenseSet($dialogResult, $infinitive, $past, $participle, 'TRUE');
			$message = $langLabels->{addtense}->[0]->{$message}->[0];
			$message =~ s/###word###/$dialogResult->{$infinitive}/g;
			infoMessage($message);
		}

	} elsif($message ne '') {
		$message = $langLabels->{addtense}->[0]->{$message}->[0];
		$message =~ s/###word###/$dialogResult->{$infinitive}/g;
		warningMessage($message);
	}

} # end sub addTenseGUI

=head3 switchLangGUI

	This function switches translation direction
=cut

sub switchLangGUI {

	my $actualLang = $configuration->getLang();
	my $switchLangOperation = LangOperations->new('direction' => $actualLang);
	$switchLangOperation->switchLang();
	my $newLang = $switchLangOperation->getLangDirection();
	$configuration->setLang($newLang);
	
	if($newLang eq 'eng') {
		my $switchLangEnImageLocal = Gtk2::Image->new_from_file($iconPath . '/eng_to_svk.png');
		$switchLangButton->set_property('image' => $switchLangEnImageLocal);
	} else {
		my $switchLangSkImageLocal = Gtk2::Image->new_from_file($iconPath . '/svk_to_eng.png');
		$switchLangButton->set_property('image' => $switchLangSkImageLocal);
	} # if
	
} # end sub switchLangGUI

=head3 settingsGUI

	This function builds settings dialog and invokes
	functions responsible for changing settings
=cut

sub settingsGUI {

	my $english = $langLabels->{settings}->[0]->{englishlabels}->[0];
	my $slovak = $langLabels->{settings}->[0]->{slovaklabels}->[0];
	my $chooser = $langLabels->{settings}->[0]->{colorchooser}->[0];
	my $ok = $langLabels->{settings}->[0]->{ok}->[0];
	my $cancel = $langLabels->{settings}->[0]->{cancel}->[0];
	my $title = $langLabels->{settings}->[0]->{header}->[0];
	
	my $dialog = Gtk2::Dialog->new (	
										$title,
										$mainWindow,
										[qw/modal destroy-with-parent/],
										$ok     => 'accept',
										$cancel => 'reject'
									);
	
	$dialog->modify_bg ('normal', $color);				
	$dialog->set_resizable(FALSE);
	
	my $container = Gtk2::Table->new(2,2, TRUE);
	
	my $radiobuttonEnglish = Gtk2::RadioButton->new_with_label(undef,$english);	
	my $radiobuttonSlovak = Gtk2::RadioButton->new_with_label($radiobuttonEnglish->get_group(),$slovak);
	
	if($langForLabels eq 'eng') {
		$radiobuttonEnglish->set_active(TRUE);
	} else {
		$radiobuttonSlovak->set_active(TRUE);
	} # if
	
	my $labelColorButton = Gtk2::Label->new($chooser);
	my $colorButton = Gtk2::ColorButton->new();
	$colorButton->set_color($color);
	$colorButton->set_title($chooser);

	$container->attach_defaults($radiobuttonEnglish,0,1,0,1);			 
	$container->attach_defaults($radiobuttonSlovak,0,1,1,2);
	$container->attach_defaults($labelColorButton,0,1,2,3);
	$container->attach_defaults($colorButton,1,2,2,3);
	$dialog->vbox->pack_start($container, FALSE, FALSE, 4);
	
	$radiobuttonEnglish->signal_connect('toggled' => \&switchLangLabelsGUI);
	
	$dialog->show_all;
	my $response = $dialog->run;
	
	if($response eq "accept") {
		$color = $colorButton->get_color();
		$configuration->setColor($color->red, $color->green, $color->blue);
		$mainWindow->modify_bg('normal', $color);
	} else {
		switchLangLabelsGUI($radiobuttonEnglish);
	} # if
	
	$dialog->destroy;
	
} # end sub settingGUI

=head3 helpGUI

	This function serves for invoking help
	
=cut

sub helpGUI {
	
	my $browser = Browser->new();
	my $langInterface = $configuration->getLangLabels();
	
	if($langInterface eq 'eng') {
		$browser->openURL('/usr/share/symphaty/doc/help/index_eng.html');
	} else {
		$browser->openURL('/usr/share/symphaty/doc/help/index.html');
	} # if
	
} # end sub helpGUI

=head3 infoGUI

	This function serves for invoking info dialog
=cut

sub infoGUI {

	my $version = $langLabels->{info}->[0]->{version}->[0];
	my $author = $langLabels->{info}->[0]->{author}->[0];
	my $license = $langLabels->{info}->[0]->{license}->[0];
	my $year = $langLabels->{info}->[0]->{year}->[0];
	my $title = $langLabels->{info}->[0]->{header}->[0];
	
	my $text = '<span foreground="#6598d7" size="x-large"><b>Symphaty</b></span>
	
<span foreground="black" size="x-large"><b>' . $version . ':</b> 0.4</span>
<span foreground="black" size="x-large"><b>' . $author . ':</b> savage</span>
<span foreground="black" size="x-large"><b>' . $license . ':</b> GPL</span>
<span foreground="black" size="x-large"><b>'. $year . ':</b> 2011</span>';

	my $infoAbout = DictionaryDialog->new();
	$infoAbout->createMessage($mainWindow, 'info', 'ok', $text, $title, $color);
	
} # end sub infoGUI

=head3 ifKeyTranslateGUI

	This function serves for translating word and displaying results
=cut

sub ifKeyTranslateGUI {

	my ($widget,$event,$parameter) = @_;
	my $widgetType = $widget->get_name();
	my $searched;
	my $keyPushed = 0;

	if($widgetType eq 'GtkButton') {
		$searched = Clipboard->paste();
	} else {
		$keyPushed = $event->keyval();
	} # if

	if($keyPushed == 65293 or ($widgetType eq 'GtkButton')){
	
		my $meaning = $langLabels->{output}->[0]->{resultitems}->[0]->{word}->[0];
		my $tense = $langLabels->{output}->[0]->{resultitems}->[0]->{tense}->[0];
		my $phrase = $langLabels->{output}->[0]->{resultitems}->[0]->{phrase}->[0];

		if(!$searched) {
			$searched ='';
			$searched = $inputEntry->get_text();
		} # if

		$searched = lc($searched);
		
		my $langOperation = LangOperations->new('direction' => $lang);
		my $result = $langOperation->translate($searched);
		my $deliveryToGui = DbGuiCommunicator->new();

		my %labels = (
						'tense' => $tense,
						'word' => $meaning,
						'phrase' => $phrase
					);

		my $test = $result->{word};

		if(@$test) {
			
			my $path = $deliveryToGui->displayResult($outputTreeStore, $result, \%labels);
			$outputTreeView->expand_row($path,TRUE);
			
			if($compact) {
				my $shortCutMessage = $langLabels->{output}->[0]->{messages}->[0]->{shortCutDisplay}->[0];
				my $title = $langLabels->{output}->[0]->{header}->[0];
				$deliveryToGui->displayShortCutResult($result, $title, $shortCutMessage, $searched, $mainWindow, $color, $iconPath);
			} # if
			
		} else {			
			my $wayLang = $configuration->getLang();
			my $notFound = 'notFound' . ucfirst($wayLang);
			$notFound = $langLabels->{output}->[0]->{messages}->[0]->{$notFound}->[0];
			$notFound =~ s/###word###/$searched/g;
			infoMessage($notFound);
		} # if

	} # if

} # end sub ifKeyTranslateGUI

=head3 switchLangLabelsGUI

	This function serves for switching labels according
	language chosen
=cut

sub switchLangLabelsGUI {
	
	my $radioButton = shift;
	my $radio = $radioButton->get_active();
	
	if($radio == 1) {
		$configuration->setLangLabels('eng');
		setLabelsGUI();
	} else {
		$configuration->setLangLabels('svk');
		setLabelsGUI();
	} # if
	
} # end sub switchLangLabelsGUI

=head3 createStockIcons

	This function serves for creating own stock icons,
	which are then used in dialogs and messages
=cut

sub createStockIcons {

	my $icons = $configuration->getStockIcons();

	foreach my $icon(keys %$icons){

		# the stock id our stock item will be accessed with
		my $stock_id = $icon;

		# add a new entry to the stock system with our id
		Gtk2::Stock->add ({
							stock_id => $stock_id,
							label    => $icon,
							modifier => [],
							translation_domain => 'gtk2_image',
						});

		# create an icon set, with only one member in this particular case
		my $icon_set = Gtk2::IconSet->new_from_pixbuf (
															Gtk2::Gdk::Pixbuf->new_from_file ($iconPath . "/" . $icons->{$icon}->[0])
														);

		# create a new icon factory to handle rendering the image at various sizes...
		my $icon_factory = Gtk2::IconFactory->new;
		# add our new stock icon to it...
		$icon_factory->add ($stock_id, $icon_set);
		# and then add this custom icon factory to the list of default places in
		# which to search for stock ids, so any gtk+ code can find our stock icon.
		$icon_factory->add_default;

	} # foreach

} # end sub 

=head3 switchShrinkGUI

	This function serves for switching between full and compact version
=cut

sub switchShrinkGUI {

	$compact = $configuration->getCompact();

	if($compact) {
		maximize();
	} else {
		minimize();
	} # if

} # end sub switchShrinkGUI

=head3 setLabelsGUI

	This function serves sets labels after switching
	interface language
=cut

sub setLabelsGUI {
	
	$langForLabels = $configuration->getLangLabels();
	$langLabels = $configuration->getAllGuiLabels($langForLabels);
	
	$resultsTreeColumn->set_title($langLabels->{output}->[0]->{header}->[0]);
	$toolTips->set_tip($addWordButton, $langLabels->{addword}->[0]->{tooltip}->[0]);
	$toolTips->set_tip($addWordsButton, $langLabels->{addwords}->[0]->{tooltip}->[0]);
	$toolTips->set_tip($addTenseButton, $langLabels->{addtense}->[0]->{tooltip}->[0]);
	$toolTips->set_tip($switchLangButton, $langLabels->{switchlang}->[0]->{tooltip}->[0]);
	$toolTips->set_tip($settingsButton, $langLabels->{settings}->[0]->{tooltip}->[0]);
	$toolTips->set_tip($helpButton, $langLabels->{help}->[0]->{tooltip}->[0]);
	$toolTips->set_tip($infoButton, $langLabels->{info}->[0]->{tooltip}->[0]);
	$toolTips->set_tip($inputEntry, $langLabels->{inputentry}->[0]->{tooltip}->[0]);
	$toolTips->set_tip($clipboardSearchButton, $langLabels->{clipboardsearch}->[0]->{tooltip}->[0]);
	$toolTips->set_tip($shrinkButton, $langLabels->{shrink}->[0]->{tooltip}->[0]);
	$toolTips->set_tip($collapseButton, $langLabels->{collapse}->[0]->{tooltip}->[0]);
	$toolTips->set_tip($recyclebinButton, $langLabels->{recyclebin}->[0]->{tooltip}->[0]);
	
} # end sub setLabelsGUI

=head3 maximize

	This function serves for changing to full windowed version
=cut

sub maximize {

	my $rect = $inputHBox->allocation();
	$topMenuHBox->show();
	$outputHBox->show();
	$mainWindow->resize($rect->width,$rect->height);
	
	my $maxImageLocal = Gtk2::Image->new_from_file($iconPath . '/shrink.png');
	$shrinkButton->set_property('image', $maxImageLocal);
	
	$configuration->setCompact(0);
	$compact = $configuration->getCompact();

} # end sub maximize

=head3 minimize

	This function serves for changing to compact version
=cut

sub minimize {

	my $rect = $inputHBox->allocation();
	$topMenuHBox->hide();
	$outputHBox->hide();
	$mainWindow->resize($rect->width,$rect->height);
	my $shrinkImageLocal = Gtk2::Image->new_from_file($iconPath . '/max.png');
	$shrinkButton->set_property('image', $shrinkImageLocal);
	$configuration->setCompact(1);
	$compact = $configuration->getCompact();

} # end sub minimize

=head3 sub collapseAllWords

	This function serves for collapsing all translated words
=cut

sub collapseAllWords {
	$outputTreeView->collapse_all();
} # end sub collapseAllWords

=head3 recyclebinAllWords

	This function serves for removing all translated words from results
=cut

sub recyclebinAllWords {
	$outputTreeStore->clear();
} # end sub recyclebinWords

=head3 infoMessage

	This function serves for creating info message dialog
=cut

sub infoMessage {
	my $text = shift;
	my $title = 'Info';
	my $infoMessage = DictionaryDialog->new();
	$infoMessage->createMessage($mainWindow,'info','ok', $text, $title, $color);
} # end sub infoMessage

=head3 warningMessage

	This function serves for creating warning message dialog
=cut

sub warningMessage {
	my $text = shift;
	my $title = 'Warning';
	my $warningMessage = DictionaryDialog->new();
	$warningMessage->createMessage($mainWindow,'warning','ok', $text, $title, $color);
} # end sub warningMessage

=head3 errorMessage

	This function serves for creating error message dialog
=cut

sub errorMessage {
	my $text = shift;
	my $title = 'Error';
	my $errorMessage = DictionaryDialog->new();
	$errorMessage->createMessage($mainWindow,'error','ok', $text, $title, $color);
} # end sub errorMessage

=head1 Author

	Copyright Pavol Ipoth 2011
	
=head1 Licence

	GPL
	
=cut
