#!/usr/bin/perl -w

=head1 Name

	package Searcher
	
=head1 Version

	0.2
	
=head1 Synopsis

	$searcher = Searcher->new();
	%result = $searcher->search($word);
	
=head1 Description

	This package serves for operations on database
	
=cut

package Searcher;

use warnings;
use strict;

use Symphaty::MyDictionary::Schema;
use Symphaty::MyDictionary::Schema::Engword;
use Symphaty::MyDictionary::Schema::Skword;
use Symphaty::MyDictionary::Schema::En_To_Sk;
use Symphaty::MyDictionary::Schema::En_Phrase;

#-------------------------------------------------------------------------------

=head1 Methods

	List of methods
	
=cut

my $schema;

my $dbPath;

sub new {
	my $class = shift;
	my $self = {@_};
	bless($self,$class);
	$self->_init;
	return $self;
} # new

sub _init {
	my $self = shift;
	$schema = Symphaty::MyDictionary::Schema->connection('dbi:SQLite:' . $dbPath,'', '',{ sqlite_unicode => 1} );
} # method _init 

sub setDbPath {
    
    my %params = @_;
    
    if( ! exists($params{'path'}) ) {
        die "Db path must be set!";    
    } # if
    
    $dbPath = $params{'path'};
    
} # setDbPath

=head2 getTranslationDirection

	This method get actual translation direction as it stores
	
=cut

sub getTranslationDirection() {
	my $self = shift;
	return $self->{direction};
} # method getTranslationDirection

=head2 setTranslationDirection

	This method sets translation direction which stores
	
=cut

sub setTranslationDirection($) {
	my $self = shift;
	my $data = shift;
	$self->{direction} = $data if defined $data;
	return $self->{direction};
} # method setTranslationDirection

=head2 search

	This method searches in by methods of this class for word meaning, tense and phrase in direction stored
	
=cut

sub search($) {

	my $self = shift;
	$self->{searched} = shift;
	my @searched = ();
	
	push(@searched,$self->{searched});
	
	my @tense = $self->searchTense($self->{searched});
	my @word = $self->searchWord($self->{searched});
	my %phrase = $self->searchPhrase($self->{searched});
	
	my %result = (
		'searched' => \@searched,
		'word' => \@word,
		'phrase' => \%phrase,
		'tense' => \@tense
	);
	
	return %result;
	
} # method search

=head2 searchWord

	This method searches in database for word meaning
	
=cut

sub searchWord($) {

	my $self = shift;
	my $searchedString = shift;
	my @word = ();
	my @engwords = ();
	my $engword;
	my @skwordsSet = ();
	my $skwordSet;
	my @engwordsSet = ();
	my $engwordSet;
	my @skwords = ();
	my $skword;

	if($self->{direction} eq "eng") {
	
		my @engwords = $schema->resultset('Engword')->search({engword => $searchedString});
		foreach $engword(@engwords){
			my @skwordsSet = $engword->skwords;
			foreach $skwordSet(@skwordsSet){ 
				push(@word,$skwordSet->skword);
			} # foreach
		} # foreach

	} # if

	if($self->{direction} eq "svk") {
		
		my @skwords = $schema->resultset('Skword')->search({skword => $searchedString});
		foreach $skword(@skwords){
			my @engwordsSet = $skword->engwords;
			foreach $engwordSet(@engwordsSet){ 
				push(@word,$engwordSet->engword);
			} # foreach
		} # foreach
		
	} # if
	
	return @word;
		
} # method searchWord

=head2 searchPhrase

	This method searches in database for phrase for given word
	
=cut

sub searchPhrase($) {

	my %phrase = ();
	my $self = shift;
	my $searchedString = shift;
	my @engwords = ();
	my $engword;
	my @phrasesSet = ();
	my $phraseSet;
	
	if($self->{direction} eq "eng") {
		
		my @engwords = $schema->resultset('Engword')->search({engword => $searchedString});
		foreach $engword(@engwords){
			my @phrasesSet = $engword->phrases;
			foreach $phraseSet(@phrasesSet){
				$phrase{$phraseSet->engphrase} = $phraseSet->skphrase;
			} # foreach
		} # foreach
	} # if
	
	return %phrase;
	
} # method searchPhrase

=head2 searchTense

	This method searches for tense for given word in database
	
=cut

sub searchTense($) {

	my @tense = ();	
	my $self = shift;
	my $searchedString = shift;
	my @irregulars = ();
	
	if($self->{direction} eq "eng") {
	
		@irregulars = $schema->resultset('En_Irregular')->search({ 
																	-or => [
																		infinitive => $searchedString,
																		past => $searchedString,
																		participle => $searchedString
																	]
																});
																
		foreach my $irregular(@irregulars){
			$self->{searched} = $irregular->infinitive;
			push(@tense,$irregular->infinitive . " - " . $irregular->past . " - " . $irregular->participle);
		} # foreach
		
	} # if
	
	return @tense;
	
} # method searchTense

=head2 searchEngWordId

	This method returns id of supplied english word
	
=cut

sub searchEngWordId {

	my $self = shift;
	my $searchedString = shift;
	my $wordId;
	
	my @engword = $schema->resultset('Engword')->search({engword => $searchedString});
	$wordId = $engword[0]->eng_id;
	
	return $wordId;
	
} # method searchEngWordId

=head2 searchSkWordId

	This method returns id of supplied slovak word
	
=cut

sub searchSkWordId {

	my $self = shift;
	my $searchedString = shift;
	my $wordId;
	
	my @skword = $schema->resultset('Skword')->search({skword => $searchedString});
	$wordId = $skword[0]->sk_id;
		
	return $wordId;
	
} # method searchSkWordId

=head2 addWord

	This method adds word in word table and controls if there already is or not 
	
=cut

sub addWord {

	my $self = shift;
	my $word = shift;
	my $resultSetName = shift;
	my $ignore = shift;
	
	if($resultSetName eq 'Engword') {
		
		my $alreadyEng = $schema->resultset('Engword')->search({engword => $word});

		if($alreadyEng != 0 && ($ignore eq 'FALSE')) {
			return "already";
		} else {
		
			my $insertEng = $schema->resultset($resultSetName)->new({
																		engword => $word
																	});
			$insertEng->insert();
			return $insertEng->id;
			
		} # if
			
	} # if
	
	if($resultSetName eq 'Skword') {
		
		my $alreadySk = $schema->resultset('Skword')->search({skword => $word});
		
		if($alreadySk != 0 && ($ignore eq 'FALSE')) {
			return "already";
		} else {
		
			my $insertSk = $schema->resultset($resultSetName)->new({
																		skword => $word
																	});
			$insertSk->insert();
			return $insertSk->id;
			
		} # if
		
	} # if
	
} # method addWord

=head2 addManyToMany

	This method adds junction between word tables to many to many table and controls if there are already
	
=cut

sub addManyToMany {

	my $self = shift;
	my $eng_id = shift;
	my $sk_id = shift;
	
	my $insertManyToMany = $schema->resultset('En_To_Sk')->new({
															eng_id => $eng_id,
															sk_id => $sk_id
														});
												
	my $already = $insertManyToMany->in_storage();
	
	if($already) {
		return "already";
	} else {
		$insertManyToMany->insert();
		$insertManyToMany->in_storage();
		return $insertManyToMany->id;
	} # if
	
} # method addManyToMany

=head2 addTense

	This method adds tense to database and controls if there already is word and their tenses
	
=cut

sub addTense {

	my $self = shift;
	my $infinitive = shift;
	my $past = shift;
	my $participle = shift;
	my $ignore = shift;

	my $isInEng = $schema->resultset('Engword')->search({engword => $infinitive});
	my $alreadyInfinitive = $schema->resultset('En_Irregular')->search({infinitive => $infinitive});

	if($alreadyInfinitive == 0 && $isInEng == 0) {
		return "firstAddInEng";
	} elsif($alreadyInfinitive == 0 && $isInEng != 0) {

		my $insertIrregular = $schema->resultset('En_Irregular')->new({
																infinitive => $infinitive,
																past => $past,
																participle => $participle,
																eng_id => $isInEng->first->eng_id
															});

		$insertIrregular->insert();
		return $insertIrregular->id;

	} elsif($alreadyInfinitive != 0 && $ignore eq 'FALSE') {
		return "update";
	} elsif($alreadyInfinitive != 0 && $ignore eq 'TRUE') {

		my $row = $alreadyInfinitive->first->update({
										irregular_id => $alreadyInfinitive->first->irregular_id,
										infinitive => $infinitive,
										past => $past,
										participle => $participle,
										eng_id => $alreadyInfinitive->first->eng_id
									});
		
		if($row) {
			return "updated";
		}

	}

	
} # method addTense
 
=head1 Dependencies

	MyDictionary::Schema;
	MyDictionary::Schema::Engword;
	MyDictionary::Schema::Skword;
	MyDictionary::Schema::En_To_Sk;
	MyDictionary::Schema::En_Phrase;
	
=cut

=head1 Author

	Copyright Pavol Ipoth 2015
	
=head1 Licence

	GPL
	
=cut

1;
