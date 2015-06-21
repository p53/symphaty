#!/usr/bin/perl -w

#-------------------------------------------------------------------------------
# 
# Package Symphaty::MyDictionary::Schema
# Here we derive class schema for my Dictionary database from DBIx class
#
#-------------------------------------------------------------------------------

package Symphaty::MyDictionary::Schema;

use base 'DBIx::Class::Schema';

__PACKAGE__->load_classes('Engword','Skword','En_To_Sk','En_Phrase','En_Irregular');

1;

#-------------------------------------------------------------------------------
