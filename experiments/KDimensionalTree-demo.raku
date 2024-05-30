#!/usr/bin/env raku
use v6.d;

use lib <. lib>;

use Algorithm::KDimensionalTree;
use Data::TypeSystem;
use ML::Clustering::DistanceFunctions;
use Text::Plot;

my $df = {} but ML::Clustering::DistanceFunctions;

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
my @res = $kdTree.nearest(@searchPoint, 12);
my $tend = now;
say "Computation time: {$tend - $tstart}";

say (:@res);
say 'elems => ', @res.elems;
say "Contains the search point: {[||]  @res.map({ $df.euclidean-distance(@searchPoint, $_) ≤ 0e-12 })}";

my @point-char =  <* ⏺ ▲>;
say <data nns search> Z=> @point-char;
say text-list-plot(
        [@points, @res, [@searchPoint,]],
        :@point-char,
        x-limit => (0, 100),
        y-limit => (0, 100),
        width => 90,
        height => 30);


# ========================================================================================================================
say "=" x 120;
say 'Nearest neighbors within a radius';
say "-" x 120;

my $tstart2 = now;
#my @res2 = $kdTree.nearest-within-ball(@searchPoint, 45);
my @res2 = $kdTree.nearest(@searchPoint, n => 30, r =>45);
my $tend2 = now;
say "Computation time: {$tend2 - $tstart2}";

say (:@res2);
say 'elems => ', @res2.elems;
say "Contains the search point: {[||]  @res2.map({ $df.euclidean-distance(@searchPoint, $_) ≤ 0e-12 })}";

say <data nns search> Z=> @point-char;
say text-list-plot(
        [@points, @res2, [@searchPoint,]],
        :@point-char,
        x-limit => (0, 100),
        y-limit => (0, 100),
        width => 90,
        height => 30);