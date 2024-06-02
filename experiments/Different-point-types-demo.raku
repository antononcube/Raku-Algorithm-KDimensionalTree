#!/usr/bin/env raku
use v6.d;

use lib <. lib>;

use Algorithm::KDimensionalTree;
use Math::DistanceFunctions;
use Data::TypeSystem;

# ========================================================================================================================
say "=" x 120;

my @points = (10.rand xx 100);

say deduce-type(@points);

my $kdTree = Algorithm::KDimensionalTree.new(@points);

say $kdTree.nearest-within-ball(2, 0.2);

say $kdTree.k-nearest(2, 2);

# ========================================================================================================================
say "=" x 120;

#`[
my @words = (('a'..'z').pick(5) xx 100)>>.join;
my $searchWord = @words.head;

say deduce-type(@words);

my $kdTree2 = Algorithm::KDimensionalTree.new(@points, distance-function => &hamming-distance);

say $kdTree2;

say $kdTree2.nearest-within-ball([$searchWord, ], 3);

say $kdTree2.k-nearest([$searchWord,], 4);
]