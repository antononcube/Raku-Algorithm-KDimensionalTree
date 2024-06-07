#!/usr/bin/env raku
use v6.d;

use lib <. lib>;

use Algorithm::KDimensionalTree;
use Math::DistanceFunctions;
use Text::Levenshtein::Damerau;
use Data::TypeSystem;
use Data::Generators;


# ========================================================================================================================
say "=" x 120;

my @points = (10.rand xx 100);

say deduce-type(@points);

my $kdTree = Algorithm::KDimensionalTree.new(@points);

say $kdTree.nearest-within-ball(2, 0.2);

say $kdTree.k-nearest(2, 2);

# ========================================================================================================================
say "=" x 120;


#my @words = (('a'..'z').pick(5) xx 100)>>.join;
#my @words = random-pet-name(400).unique.grep({ $_.chars == 5 });
my @words = random-pet-name(120).unique;
my $searchWord = @words.head;

say deduce-type(@words);

my $kdTree2 = Algorithm::KDimensionalTree.new(@words, distance-function => &dld);

say $kdTree2;

say "searchWord : $searchWord";

say $kdTree2.nearest-within-ball($searchWord, 3);

.say for $kdTree2.k-nearest($searchWord, 8, :!values);
