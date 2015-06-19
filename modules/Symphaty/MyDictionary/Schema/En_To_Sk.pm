#!/usr/bin/perl -w

#-------------------------------------------------------------------------------
#
# Package Symphaty::MyDictionary::Schema::En_To_Sk
# Derived from my MyDictionary::Schema, represents en_to_sk table
#
#-------------------------------------------------------------------------------

package Symphaty::MyDictionary::Schema::En_To_Sk;

use base 'DBIx::Class::Core';
  
__PACKAGE__->table('en_to_sk');

__PACKAGE__->add_columns(
	eng_id => {
		data_type => 'integer',
	},
	sk_id => {
		data_type => 'integer',
	},
);

__PACKAGE__->set_primary_key(qw/eng_id sk_id/);
__PACKAGE__->belongs_to( engword => 'Symphaty::MyDictionary::Schema::Engword', 'eng_id' );
__PACKAGE__->belongs_to( skword => 'Symphaty::MyDictionary::Schema::Skword', 'sk_id' );

1;

#-------------------------------------------------------------------------------
