#!/usr/bin/env raku
use v6.d;

use lib <. lib>;

use Algorithm::KDTree;
use Data::TypeSystem;
use ML::Clustering::DistanceFunctions;
use Text::Plot;

my $df = {} but ML::Clustering::DistanceFunctions;

my @points = ([(^100).rand, (^100).rand] xx 50).unique>>.Num;

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

my @res = $kdTree.nearest(@searchPoint, 20);

say (:@res);
say "Contains the search point: {[||]  @res.map({ $df.euclidean-distance(@searchPoint, $_) ≤ 0e-12 })}";

say "=" x 120;
my @point-char =  <* ⏺ ▲>;
say <data nns search> Z=> @point-char;
say text-list-plot(
        [@points, @res, [@searchPoint,]],
        :@point-char,
        x-limit => (0, 100),
        y-limit => (0, 100),
        width => 60,
        height => 20);