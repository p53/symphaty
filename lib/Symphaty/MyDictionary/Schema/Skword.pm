#!/usr/bin/perl -w

#-------------------------------------------------------------------------------
#
# Package Symphaty::MyDictionary::Schema::Skword
# Class derived from my MyDictionary package, represents skwordmeaning table
#
#-------------------------------------------------------------------------------

package  Symphaty::MyDictionary::Schema::Skword;

use base 'DBIx::Class::Core';
  
__PACKAGE__->table('skwordmeaning');

__PACKAGE__->add_columns(
	sk_id => {
		data_type => 'integer',
		is_auto_increment => 1,
	},
		skword => {
		data_type => 'text',
	},
);

 sub sqlt_deploy_hook {
   my ($self, $sqlt_table) = @_;

   $sqlt_table->add_index(name => 'idx_sk_id', fields => ['sk_id']);
 }

__PACKAGE__->set_primary_key('sk_id');
__PACKAGE__->has_many(en_to_sk => 'Symphaty::MyDictionary::Schema::En_To_Sk', 'sk_id');
__PACKAGE__->many_to_many(engwords => 'en_to_sk','engword' );

1;

#-------------------------------------------------------------------------------
