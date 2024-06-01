use v6.d;

use Math::DistanceFunctions;

class Algorithm::KDimensionalTree
        does Math::DistanceFunctionish {
    has @.points;
    has %.tree;
    has $.distance-function;

    #======================================================
    # Creators
    #======================================================
    submethod BUILD(:@points, :$distance-function = 'euclidean-distance') {
        @!points = @points;
        given $distance-function {
            when Whatever {
                $!distance-function = &euclidean-distance;
            }

            when $_ ~~ Str:D && $_.lc ∈ <euclidean euclideandistance euclidean-distance> {
                $!distance-function = &euclidean-distance;
            }

            when $_ ~~ Str:D && $_.lc ∈ <cosine cosinedistance cosine-distance> {
                $!distance-function = &cosine-distance;
            }

            when $_ ~~ Callable {
                $!distance-function = $distance-function;
            }
            default {
                note "Do not know how to process the distance function spec.";
                $!distance-function = &euclidean-distance;
            }
        }
        self.build-tree();
    }

    multi method new(:@points, :$distance-function = 'euclidean-distance') {
        self.bless(:@points, :$distance-function);
    }

    multi method new(@points, :$distance-function = 'euclidean-distance') {
        self.bless(:@points, :$distance-function);
    }

    multi method new(@points, $distance-function = 'euclidean-distance') {
        self.bless(:@points, :$distance-function);
    }

    #======================================================
    # Representation
    #======================================================
    method gist(){
        return "KDTree(points => {@!points.elems}, distance-function => {$!distance-function.gist})";
    }

    method Str(){
        return self.gist();
    }

    #======================================================
    # Insert
    #======================================================
    method insert(@point) {
        @!points.push(@point);
        self.build-tree();
    }

    #======================================================
    # Top-level methods
    #======================================================
    multi method nearest(@point, :n(:$count) = 1, :r($radius) = Whatever) {
        return do given ($count, $radius) {
            when ( $_.head ~~ UInt:D && $_.tail.isa(Whatever) ) {
                self.k-nearest-rec(%!tree, @point, $count, 0).map(*<point>);
            }
            when ( $_.head.isa(Whatever) && $_.tail ~~ Numeric:D ) {
                self.nearest-within-ball-rec(%!tree, @point, $radius, 0).map(*<point>);
            }
            when ( $_.head ~~ UInt:D && $_.tail ~~ Numeric:D ) {
                self.nearest(@point, $_);
            }
            default {
                note 'The argument $number-of-nearest-neighbors is expected to be non-negative integer or Whatever.' ~
                    'The argument $radius is expected to be a non-negative number of Whatever.';
                Nil
            }
        }
    }

    multi method nearest(@point, UInt:D $k = 1) {
        self.k-nearest-rec(%!tree, @point, $k, 0).map(*<point>);
    }

    multi method nearest(@point, Whatever) {
        self.nearest(@point, 1);
    }

    multi method nearest(@point, ($k, $r)) {
        if $r.isa(Whatever) {
            return self.nearest(@point, $k);
        }
        my @res = self.nearest-within-ball-rec(%!tree, @point, $r, 0);
        return do given $k {
            when Whatever { @res.map(*<point>) }
            when $_ ~~ UInt:D { @res.sort(*<distance>).map(*<point>)[^min($_, @res.elems)] }
            default {
                note "The number of nearest neighbors spec (the first element of the second argument) " ~
                    "is expeted to be a non-negative integer or Whatever.";
                @res
            }
        }
    }

    method nearest-within-ball(@point, Numeric $r) {
        self.nearest-within-ball-rec(%!tree, @point, $r, 0).map(*<point>);
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
        my $axis = $depth % @points[0].elems;
        @points = @points.sort({ $_[$axis] });
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
    method k-nearest-rec(%node, @point, $k, UInt $depth) {
        return [] unless %node;;
        my $axis = $depth % @point.elems;

        my (%next, %other);
        if @point[$axis] < %node<point>[$axis] {
            %next = %node<left>; %other = %node<right>;
        } else {
            %next = %node<right>; %other = %node<left>;
        }

        # Recursively search
        my @best = self.k-nearest-rec(%next, @point, $k, $depth + 1);
        @best.push( { point => %node<point>, distance => self.distance-function.(@point, %node<point>) } );

        # Reorder best neighbors
        @best = @best.sort({ $_<distance> });
        @best = @best[^$k] if @best.elems > $k;

        # Recursively search if viable candidates _might_ exist
        #if @best.elems < $k || (abs(@point[$axis] - %node<point>[$axis]) ≤ @best.tail<distance>) {
        my @av1 = self.axis-vector(dim => @point.elems, :$axis, val => @point[$axis]);
        my @av2 = self.axis-vector(dim => @point.elems, :$axis, val => %node<point>[$axis]);
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
    method nearest-within-ball-rec(%node, @point, $r, $depth) {
        return [] unless %node;
        my $axis = $depth % @point.elems;

        my $dist = self.distance-function.(@point, %node<point>);
        my %inside = $dist ≤ $r ?? { point => %node<point>, distance => $dist } !! Empty;

        my (%next, %other);
        if @point[$axis] < %node<point>[$axis] {
            %next = %node<left>; %other = %node<right>;
        } else {
            %next = %node<right>; %other = %node<left>;
        }

        my @neighbors = self.nearest-within-ball-rec(%next, @point, $r, $depth + 1);

        @neighbors.push(%inside) if %inside;

        #if (abs(@point[$axis] - %node<point>[$axis]) ≤ $r) {
        my @av1 = self.axis-vector(dim => @point.elems, :$axis, val => @point[$axis]);
        my @av2 = self.axis-vector(dim => @point.elems, :$axis, val => %node<point>[$axis]);
        if self.distance-function.(@av1, @av2) ≤ $r {
            @neighbors.append( self.nearest-within-ball-rec(%other, @point, $r, $depth + 1) );
        }

        # Result
        return @neighbors;
    }
}

