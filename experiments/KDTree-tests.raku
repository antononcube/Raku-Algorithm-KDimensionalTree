#!/usr/bin/env raku
use v6.d;

use lib <. lib>;

use Algorithm::KDimensionalTree;
use Data::TypeSystem;
use Data::Summarizers;
use Math::DistanceFunctions;
use Text::Plot;
use JSON::Fast;

my %data = from-json(slurp($*CWD ~ '/resources/KDTreeTest.json'));
my @points = |%data<points>;
say deduce-type(@points);
say deduce-type(@points):tally;

say text-list-plot(@points);

say @points.head(12);

my $distance-function = 'CosineDistance';
my $radius = %data{$distance-function}<radius>;

my @searchPoint = |%data<searchPoint>;
my @expected = |%data{$distance-function}<nns>;

my $kdTree = Algorithm::KDimensionalTree.new(@points, :$distance-function);
say $kdTree;

my @res = $kdTree.nearest(@searchPoint, :$radius);

say 'expected elems => ', @expected.elems;
say 'result elems   => ', @res.elems;
my @diffs = (@expected.sort.Array Z @res.sort.Array).map({ $_.head «-» $_.tail });
say 'max-norm (expected Z- result) => ', norm(@diffs.map({ norm($_) }), p => 1);

my @point-char =  <* ⏺ ▲>;
say <data nns search> Z=> @point-char;
say text-list-plot(
        [@points, @res, [@searchPoint,]],
        :@point-char,
        title => 'result',
        x-limit => (0, 100),
        y-limit => (0, 100),
        width => 60,
        height => 20);

say "\n";

say text-list-plot(
        [@points, @expected, [@searchPoint,]],
        :@point-char,
        title => 'expected',
        x-limit => (0, 100),
        y-limit => (0, 100),
        width => 60,
        height => 20);