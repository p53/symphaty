#!/usr/bin/perl -w

#-------------------------------------------------------------------------------
#
# Package Symphaty::MyDictionary::Schema::En_Phrase
# Derived from my MyDictionary::Schema, represents phrase table
#
#-------------------------------------------------------------------------------

package  Symphaty::MyDictionary::Schema::En_Phrase;

use base 'DBIx::Class::Core';
  
__PACKAGE__->table('phrase');

__PACKAGE__->add_columns(
	eng_id => {
		data_type => 'integer',
	},
	engphrase => {
		data_type => 'text',
	},
	skphrase => {
		data_type => 'text',
	},
	phrase_id => {
		data_type => 'integer',
		is_auto_increment => 1,
	},
);

 sub sqlt_deploy_hook {
   my ($self, $sqlt_table) = @_;

   $sqlt_table->add_index(name => 'idx_phrase_id', fields => ['phrase_id']);
 }

__PACKAGE__->set_primary_key('phrase_id');
__PACKAGE__->has_one(engword => 'Symphaty::MyDictionary::Schema::Engword', 'eng_id');

1;

#-------------------------------------------------------------------------------
