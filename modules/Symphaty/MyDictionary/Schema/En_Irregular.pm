#!/usr/bin/perl -w

#-------------------------------------------------------------------------------
#
# Package Symphaty::MyDictionary::Schema::En_Irregular
# Derived from my MyDictionary::Schema, represents phrase table
#
#-------------------------------------------------------------------------------

package  Symphaty::MyDictionary::Schema::En_Irregular;

use base 'DBIx::Class::Core';
  
__PACKAGE__->table('irregular');

__PACKAGE__->add_columns(
	eng_id => {
		data_type => 'integer',
	},
	infinitive => {
		data_type => 'text',
	},
	past => {
		data_type => 'text',
	},
	participle => {
		data_type => 'text',
	},
	irregular_id => {
		data_type => 'integer',
		is_auto_increment => 1,
	},
);

 sub sqlt_deploy_hook {
   my ($self, $sqlt_table) = @_;

   $sqlt_table->add_index(name => 'idx_irregular_id', fields => ['irregular_id']);
 }

__PACKAGE__->set_primary_key('irregular_id');
__PACKAGE__->has_one(engword => 'Symphaty::MyDictionary::Schema::Engword', 'eng_id');

1;

#-------------------------------------------------------------------------------
