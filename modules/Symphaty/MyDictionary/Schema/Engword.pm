#!/usr/bin/perl -w

#-------------------------------------------------------------------------------
#
# Package Symphaty::MyDictionary::Schema::Engword
# Derived from my MyDictionary::Schema, represents englisword table
#
#-------------------------------------------------------------------------------

package  Symphaty::MyDictionary::Schema::Engword;

use base 'DBIx::Class::Core';
  
__PACKAGE__->table('englishword');

__PACKAGE__->add_columns(
	eng_id => {
		data_type => 'integer',
		is_auto_increment => 1,
	},
	engword => {
		data_type => 'text',
	},
);

 sub sqlt_deploy_hook {
   my ($self, $sqlt_table) = @_;

   $sqlt_table->add_index(name => 'idx_eng_id', fields => ['eng_id']);
 }

__PACKAGE__->set_primary_key('eng_id');
__PACKAGE__->has_many(en_to_sk => 'Symphaty::MyDictionary::Schema::En_To_Sk', 'eng_id');
__PACKAGE__->has_many(phrases => 'Symphaty::MyDictionary::Schema::En_Phrase', 'eng_id');
__PACKAGE__->has_one(irregular => 'Symphaty::MyDictionary::Schema::En_Irregular', 'eng_id');
__PACKAGE__->many_to_many(skwords => 'en_to_sk','skword' );

1;

#-------------------------------------------------------------------------------
