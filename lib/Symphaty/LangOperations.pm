#!/usr/bin/perl -w

=head1 Name

	package LangOperations
	
=head1 Version

	0.2
	
=head1 Synopsis

	 $operator = LangOperations->new();
	 $result = $operator->translate($searched);
	 
=head1 Description

	This package serves for operations with language, translation, changing direction
	of translation and methods for adding word, this class uses other classes to db
	access and verification
	
=cut

package LangOperations;

use strict;
use warnings;

use Symphaty::Searcher;
use Symphaty::Verifier;

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
	
} # new method

sub _init() {
	my $self = shift;
	if(!$self->{direction}) {
		$self->{direction} = 'eng';
	} # if
} # initialization method

=head2 getResult

	This method retrieves result from translate operation
	
=cut

sub getResult {
	my $self = shift;
	return $self->{result};
} # getResult method

=head2 getLangDirection

	This method gets actual translation direction
	
=cut

sub getLangDirection {
	my $self = shift;
	return $self->{direction};
} # getLangDirection method

=head2 translate

	This method translates supplied word in actual translation direction
	
=cut

sub translate {
	
	my $self = shift;
	my $searched = shift;

	my $searcher = Searcher->new('direction' => $self->{direction});
	my %searchResult = $searcher->search($searched);
	
	my %result = (
					'searched' => $searchResult{searched},
					'word' => $searchResult{word},
					'phrase' => $searchResult{phrase},
					'tense' => $searchResult{tense}
				);
	
	$self->{result} = \%result;
	
	return \%result;
	
} # translate method

=head2 switchLang

	This method switches language direction of this class
	
=cut

sub switchLang {

	my $self = shift;
	
	if($self->{direction} eq 'eng') {
		$self->{direction} = 'svk';
	} else {
		$self->{direction} = 'eng';
	} # if

	return $self;
	
} # switchLang method

=head2 addWordSet

	This method controls process of adding word to database, verification etc..
	
=cut

sub addWordSet {

	my $self = shift;
	my $insertArray = shift;
	my $labelEng = shift;
	my $labelSk = shift;
	
	my $message;

	my $verifier = Verifier->new();
	my $verifySk = $verifier->verify('empty', $insertArray->{$labelSk});
	my $verifyEng = $verifier->verify('empty', $insertArray->{$labelEng});
	
	if($verifyEng or $verifySk) {
	
		$message = 'empty';
		
		if($verifyEng && !$verifySk) {
			$message .= 'Eng';
		} # if
		
		if($verifySk && !$verifyEng) {
			$message .= 'Sk';
		} # if
		
	} # if
	
	if(!$verifySk && !$verifyEng) {
	
		my $inserter = Searcher->new();
		
		my $successSk = $inserter->addWord($insertArray->{$labelSk}, 'Skword', 'FALSE');
		my $successEng = $inserter->addWord($insertArray->{$labelEng}, 'Engword', 'FALSE');

		if($successEng ne "already" or $successSk ne "already"){

			if($successEng ne "already" && $successSk ne "already") {
				$message = "new";
			} else {
			
				if($successEng ne "already"){
					$successSk = $inserter->searchSkWordId($insertArray->{$labelSk});
					$message = "alreadySk";
				} else {
					$successEng = $inserter->searchEngWordId($insertArray->{$labelEng});
					$message = "alreadyEng";
				} # if
				
			} # if
			
			my $successManyToMany = $inserter->addManyToMany($successEng, $successSk);

		} else {
			$message = "already";
		} # if
		
	} # if
	
	return $message;
	
} # method addWordSet

=head2 addTenseSet

	This method controls process of adding tense to database, verifiacation etc.
	
=cut

sub addTenseSet() {

	my $self = shift;
	my $insertArray = shift;
	my $labelInfinitive = shift;
	my $labelPast = shift;
	my $labelParticiple = shift;
	my $ignore = shift;

	my $message;

	my $verifier = Verifier->new();
	my $verifyInfinitive = $verifier->verify('empty', $insertArray->{$labelInfinitive});
	my $verifyPast = $verifier->verify('empty', $insertArray->{$labelPast});
	my $verifyParticiple = $verifier->verify('empty', $insertArray->{$labelParticiple});

	if($verifyInfinitive or $verifyPast or $verifyParticiple) {
	
		$message = 'empty';
		
		if($verifyInfinitive && !$verifyPast && !$verifyParticiple) {
			$message .= 'Infinitive';
		} elsif($verifyPast && !$verifyParticiple) {
			$message .= 'Past';
		} else {
			$message .= 'Participle';
		} # if
		
	} # if
	
	if(!$verifyInfinitive && !$verifyPast && !$verifyParticiple) {
	
		my $inserter = Searcher->new();
		
		my $success = $inserter->addTense($insertArray->{$labelInfinitive}, $insertArray->{$labelPast}, $insertArray->{$labelParticiple}, $ignore);

		if($success eq 'update' or $success eq 'firstAddInEng' or $success eq 'updated'){
			return $success;
		} else {
			return "new";
		} # if
		
	} # if
	
	return $message;

}

=head1 Dependencies

	Searcher
	Verifier
	
=cut

=head1 Author

	Copyright Pavol Ipoth 2015
	
=head1 Licence

	GPL
	
=cut

1;
