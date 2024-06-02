#!/usr/bin/env raku
use v6.d;

use lib <. lib>;

use Algorithm::KDimensionalTree;
use Math::DistanceFunctions;
use Data::TypeSystem;
use Text::Plot;

my @points = ([(^100).rand, (^100).rand] xx 100).unique;

say deduce-type(@points);

my $kdTree = Algorithm::KDimensionalTree.new(@points);

say $kdTree;

my @searchPoint = |@points.head;
#my @searchPoint = [20, 60];
say (:@searchPoint);

# ========================================================================================================================
say "=" x 120;
say 'Nearest k-neighbors';
say "-" x 120;

my $tstart = now;
my @res = $kdTree.k-nearest(@searchPoint, 12);
my $tend = now;
say "Computation time: {$tend - $tstart}";

say (:@res);
say 'elems => ', @res.elems;
say "Contains the search point: {[||] @res.map({ euclidean-distance(@searchPoint, $_) ≤ 0e-12 })}";

my @point-char =  <* ⏺ ▲>;
say <data nns search> Z=> @point-char;
say text-list-plot(
        [@points, @res, [@searchPoint,]],
        :@point-char,
        x-limit => (0, 100),
        y-limit => (0, 100),
        width => 60,
        height => 20);


# ========================================================================================================================
say "=" x 120;
say 'Nearest neighbors within a radius (cosine distance)';
say "-" x 120;

my $kdTree2 = Algorithm::KDimensionalTree.new( @points, distance-function => &cosine-distance );

say $kdTree2;

my $tstart2 = now;
my @res2 = $kdTree2.nearest-within-ball(@searchPoint, 0.02):v;
my $tend2 = now;
say "Computation time: {$tend2 - $tstart2}";

say (:@res2);

@point-char =  <* ⏺ ▲>;
say <data nns search> Z=> @point-char;
say text-list-plot(
        [@points, @res2, [@searchPoint,]],
        :@point-char,
        x-limit => (0, 100),
        y-limit => (0, 100),
        width => 60,
        height => 20);