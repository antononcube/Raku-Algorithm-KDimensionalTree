#!/usr/bin/env raku
use v6.d;

use lib <. lib>;

use Algorithm::KDTree;
use Data::TypeSystem;

my @points = ([(^100).rand, (^100).rand] xx 20).unique>>.Num;

say deduce-type(@points);

my $kdTree = Algorithm::KDTree.new(@points);

say $kdTree;

say $kdTree.raku;

say '-' x 60;
.say for |$kdTree.tree;
say '-' x 60;

my @searchPoint = |@points.head;
#my @searchPoint = [20, 60];
say (:@searchPoint);

my $res = $kdTree.nearest(@searchPoint, 2);

say (:$res);