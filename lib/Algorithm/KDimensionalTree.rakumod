use v6.d;

use Math::DistanceFunctions;
use Math::DistanceFunctionish;

class Algorithm::KDimensionalTree
        does Math::DistanceFunctionish {
    has @.points;
    has %.tree;
    has $.distance-function;
    has @.labels;

    #======================================================
    # Creators
    #======================================================
    submethod BUILD(:@points, :$distance-function = Whatever) {
        @!points = @points;
        given $distance-function {
            when $_.isa(Whatever) || $_.isa(WhateverCode) {
                $!distance-function = &euclidean-distance;
            }

            when $_ ~~ Str:D {
                $!distance-function = self.get-distance-function($_, :!warn);
                if $!distance-function.isa(WhateverCode) {
                    die "Unknown name of a distance function ⎡$distance-function⎦.";
                }
            }

            when $_ ~~ Callable {
                $!distance-function = $distance-function;
            }

            default {
                die "Do not know how to process the distance function spec.";
            }
        }

        # Process points
        # If an array of arrays make it an array of pars
        if @!points.all ~~ Positional:D {
            @!points = @!points.pairs;
        } elsif @!points.all ~~ Pair:D {
            @!labels = @!points>>.key;
            @!points = @!points>>.value.pairs;
        } else {
            die "The points argument is expected to be an array of arrays or an array of pairs.";
        }

        self.build-tree();
    }

    multi method new(:@points, :$distance-function = Whatever) {
        self.bless(:@points, :$distance-function);
    }

    multi method new(@points, :$distance-function = Whatever) {
        self.bless(:@points, :$distance-function);
    }

    multi method new(@points, $distance-function = Whatever) {
        self.bless(:@points, :$distance-function);
    }

    #======================================================
    # Representation
    #======================================================
    multi method gist(::?CLASS:D:-->Str) {
        my $lblPart = @!labels.elems > 0 ?? ", labels => {@!labels.elems}" !! '';
        return "Algorithm::KDimensionalTree(points => {@!points.elems}, distance-function => {$!distance-function.gist}" ~ $lblPart ~ ')';
    }

    method Str(){
        return self.gist();
    }

    #======================================================
    # Insert
    #======================================================
    multi method insert(@point) {
        my $new = Pair.new( @!points.elems, @point);
        @!points.push($new);
        self.build-tree();
    }

    multi method insert(Pair:D $new) {
        @!points.push($new);
        self.build-tree();
    }

    #======================================================
    # Build the tree
    #======================================================
    method axis-vector(UInt :$dim, UInt :$axis, :$val) {
        my @vec = 0 xx $dim;
        @vec[$axis] = $val;
        return @vec;
    }

    method build-tree() {
        %!tree = self.build-tree-rec(@!points, 0);
    }

    method build-tree-rec(@points, $depth) {
        return %() if @points.elems == 0;
        my $axis = $depth % @points[0].value.elems;
        @points = @points.sort({ $_.value[$axis] });
        my $median = @points.elems div 2;
        return {
            point => @points[$median],
            left  => self.build-tree-rec(@points[^$median], $depth + 1),
            right => self.build-tree-rec(@points[$median + 1 .. *], $depth + 1)
        };
    }

    #======================================================
    # K-nearest
    #======================================================
    method k-nearest(@point, UInt $k = 1, Bool :v(:$values) = True) {
        my @res = self.k-nearest-rec(%!tree, @point, $k, 0);
        return $values ?? @res.map(*<point>.value) !! @res;
    }

    method k-nearest-rec(%node, @point, $k, UInt $depth) {
        return [] unless %node;
        my $axis = $depth % @point.elems;

        my (%next, %other);
        if @point[$axis] < %node<point>.value[$axis] {
            %next = %node<left>; %other = %node<right>;
        } else {
            %next = %node<right>; %other = %node<left>;
        }

        # Recursively search
        my @best = self.k-nearest-rec(%next, @point, $k, $depth + 1);
        @best.push( { point => %node<point>, distance => self.distance-function.(@point, %node<point>.value) } );

        # Reorder best neighbors
        @best = @best.sort({ $_<distance> });
        @best = @best[^$k] if @best.elems > $k;

        # Recursively search if viable candidates _might_ exist
        #if @best.elems < $k || (abs(@point[$axis] - %node<point>[$axis]) ≤ @best.tail<distance>) {
        my @av1 = self.axis-vector(dim => @point.elems, :$axis, val => @point[$axis]);
        my @av2 = self.axis-vector(dim => @point.elems, :$axis, val => %node<point>.value[$axis]);
        if @best.elems < $k || self.distance-function.(@av1, @av2) ≤ @best.tail<distance> {
            @best.append: self.k-nearest-rec(%other, @point, $k, $depth + 1);
            @best = @best.sort({ $_<distance> });
            @best = @best[^$k] if @best.elems > $k;
        }

        # Result
        return @best;
    }

    #======================================================
    # Nearest within a radius
    #======================================================
    method nearest-within-ball(@point, Numeric $r, Bool :v(:$values) = True) {
        my @res = self.nearest-within-ball-rec(%!tree, @point, $r, 0);
        return $values ?? @res.map(*<point>.value) !! @res;
    }

    method nearest-within-ball-rec(%node, @point, $r, $depth) {
        return [] unless %node;
        my $axis = $depth % @point.elems;

        my $dist = self.distance-function.(@point, %node<point>.value);
        my %inside = $dist ≤ $r ?? { point => %node<point>, distance => $dist } !! Empty;

        my (%next, %other);
        if @point[$axis] < %node<point>.value[$axis] {
            %next = %node<left>; %other = %node<right>;
        } else {
            %next = %node<right>; %other = %node<left>;
        }

        my @neighbors = self.nearest-within-ball-rec(%next, @point, $r, $depth + 1);

        @neighbors.push(%inside) if %inside;

        #if (abs(@point[$axis] - %node<point>[$axis]) ≤ $r) {
        my @av1 = self.axis-vector(dim => @point.elems, :$axis, val => @point[$axis]);
        my @av2 = self.axis-vector(dim => @point.elems, :$axis, val => %node<point>.value[$axis]);
        if self.distance-function.(@av1, @av2) ≤ $r {
            @neighbors.append( self.nearest-within-ball-rec(%other, @point, $r, $depth + 1) );
        }

        # Result
        return @neighbors;
    }
}

