#!/usr/bin/env raku
use v6.d;

use lib <. lib>;

use Algorithm::KDimensionalTree;
use Data::TypeSystem;
use Math::DistanceFunctions;
use Text::Plot;

my @points = ([(^100).rand, (^100).rand] xx 300).unique;

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
say "Contains the search point: {[||] @res.map({ euclidean-distance(@searchPoint, $_) ≤ 0e-12 })}";

my @point-char =  <* ⏺ ø>;
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

use Data::Generators;

my @labels = random-pet-name(2 * @points.elems).unique[^@points.elems];
my @points2 = (@labels.Array Z=> @points).Array;

my $kdTree2 = Algorithm::KDimensionalTree.new( @points2 );

say $kdTree2;

my $tstart2 = now;
my @res2 = $kdTree2.nearest(@searchPoint, count => Whatever, radius => 20, prop => <label>);
my $tend2 = now;
say "Computation time: {$tend2 - $tstart2}";

my @res3 = $kdTree2.nearest(@searchPoint, count => 10, radius => 20, prop => <label>);

say (:@res2);
say (:@res3);

@point-char =  <* ⏺ ▲ ø>;
say <data all-nns 20-nns search> Z=> @point-char;
say text-list-plot(
        [@points, @points2.Hash{|@res2}, @points2.Hash{|@res3}, [@searchPoint,]],
        :@point-char,
        x-limit => (0, 100),
        y-limit => (0, 100),
        width => 90,
        height => 30);