use v6.d;

class Algorithm::KDTree {
    has @.points;
    has %.tree;
    has $.distance-function;

    #======================================================
    # Creators
    #======================================================
    submethod BUILD(:@points, :$distance-function = &euclidean) {
        @!points = @points;
        $!distance-function = $distance-function;
        self.build-tree();
    }

    multi method new(:@points, :$distance-function = &euclidean) {
        self.bless(:@points, :$distance-function);
    }

    multi method new(@points, $distance-function = &euclidean) {
        self.bless(:@points, :$distance-function);
    }

    #======================================================
    # Representation
    #======================================================
    method gist(){
        my $func-id = do given $!distance-function {
#            when $_ ~~ &euclidean() { "Euclidean" }
#            when $_ ~~ &cosine() { "Cosine" }
            default { "Unknown" }
        }
        return "KDTree(points => {@!points.elems}, distance-function => $func-id)";
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
    method nearest(@point, UInt $k = 1) {
        self.k-nearest-rec(%!tree, @point, $k, 0).map(*<point>);
    }

    method neighbors-within-ball(@point, Numeric $r) {
        self.neighbors-within-ball-rec(%!tree, @point, $r, 0);
    }

    method build-tree() {
        %!tree = self.build-tree-rec(@!points, 0);
    }

    #======================================================
    # Build the tree
    #======================================================
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
        @best.push( { point => %node<point>, distance => self.distance-function.(@point, %node<point>) });

        # Reorder best neighbors
        @best = @best.sort({ $_<distance> });
        @best = @best[^$k] if @best.elems > $k;

        # Recursively search if viable candidates _might_ exist
#        note "pivot : ", %node<point>, ", axis : ", $axis;
#        note (abs(@point[$axis] - %node<point>[$axis]) < @best.tail<distance>);
#        note "abs   : ", abs(@point[$axis] - %node<point>[$axis]), " < ", @best.tail<distance>;
#        note "dist  : ", self.distance-function.(@point, %node<point>), " < ", @best.tail<distance>;
        if @best.elems < $k || (abs(@point[$axis] - %node<point>[$axis]) ≤ @best.tail<distance>) {
            @best.append: self.k-nearest-rec(%other, @point, $k, $depth + 1);
            @best = @best.sort({ $_<distance> });
            @best = @best[^$k] if @best.elems > $k;
#            note 'loop :', (@best);
        }
#        note 'end  :', (@best);
        return @best;
    }

    #======================================================
    # Nearest within a radius
    #======================================================
    method neighbors-within-ball-rec(%node, @point, $r, $depth) {
        return [] unless %node;
        my $axis = $depth % @point.elems;
        my @inside = self.distance-function(@point, %node<point>) <= $r ?? %node<point> !! ();
        my %next = @point[$axis] < %node<point>[$axis] ?? %node<left> !! %node<right>;
        my %other = @point[$axis] < %node<point>[$axis] ?? %node<right> !! %node<left>;
        my @neighbors = self.neighbors-within-ball-rec(%next, @point, $r, $depth + 1);
        @neighbors.push: @inside;
        if (abs(@point[$axis] - %node<point>[$axis]) < $r) {
            @neighbors.append: self.neighbors-within-ball-rec(%other, @point, $r, $depth + 1);
        }
        return @neighbors;
    }

    #======================================================
    # Distance functions
    #======================================================
    sub euclidean(@a, @b) {
        sqrt [+] (@a Z- @b).map(* ** 2);
    }

    sub cosine(@a, @b) {
        my $na = @a.map(* ** 2).sum.sqrt;
        my $nb = @b.map(* ** 2).sum.sqrt;
        if $na > 0 && $nb > 0 {
            1 - (@a Z* @b).sum / $na / $nb
        } else {
            1
        }
    }
}

