use v6.d;

# Taken from Rosetta Code: https://rosettacode.org/wiki/K-d_tree#Raku

unit module Algorithm::NodalKDTree;

class KD-Node is export {
    has $.d;
    has $.split;
    has $.left;
    has $.right;
}

class Orthotope is export {
    has $.min;
    has $.max;
}

class NodalKDTree is export {
    has $.n;
    has $.bounds;
    method new($pts, $bounds) { self.bless(n => nk2(0,$pts), bounds => $bounds) }

    sub nk2($split, @e) {
        return () unless @e;
        my @exset = @e.sort(*.[$split]);
        my $m = +@exset div 2;
        my @d = @exset[$m][];
        while $m+1 < @exset and @exset[$m+1][$split] eqv @d[$split] {
            ++$m;
        }

        my $s2 = ($split + 1) % @d; # cycle coordinates
        KD-Node.new: :@d, :$split,
                left  => nk2($s2, @exset[0 ..^ $m]),
                right => nk2($s2, @exset[$m ^.. *]);
    }
}

class T3 {
    has $.nearest;
    has $.dist_sqd = Inf;
    has $.nodes_visited = 0;
}

sub find-nearest($k, $t, @p, :$max-distance = Inf) is export {
    return nn($t.n, @p, $t.bounds, $max-distance);

    sub nn($kd, @target, $hr, $max_dist_sqd is copy) {
        return T3.new(:nearest([0.0 xx $k])) unless $kd;

        my $nodes_visited = 1;
        my $s = $kd.split;
        my $pivot = $kd.d;
        my $left_hr = $hr.clone;
        my $right_hr = $hr.clone;
        $left_hr.max[$s] = $pivot[$s];
        $right_hr.min[$s] = $pivot[$s];

        my $nearer_kd;
        my $further_kd;
        my $nearer_hr;
        my $further_hr;
        if @target[$s] <= $pivot[$s] {
            ($nearer_kd, $nearer_hr) = $kd.left, $left_hr;
            ($further_kd, $further_hr) = $kd.right, $right_hr;
        }
        else {
            ($nearer_kd, $nearer_hr) = $kd.right, $right_hr;
            ($further_kd, $further_hr) = $kd.left, $left_hr;
        }

        my $n1 = nn($nearer_kd, @target, $nearer_hr, $max_dist_sqd);
        my $nearest = $n1.nearest;
        my $dist_sqd = $n1.dist_sqd;
        $nodes_visited += $n1.nodes_visited;

        if $dist_sqd < $max_dist_sqd {
            $max_dist_sqd = $dist_sqd;
        }
        my $d = ($pivot[$s] - @target[$s]) ** 2;
        if $d > $max_dist_sqd {
            return T3.new(:$nearest, :$dist_sqd, :$nodes_visited);
        }
        $d = [+] (@$pivot Z- @target) X** 2;
        if $d < $dist_sqd {
            $nearest = $pivot;
            $dist_sqd = $d;
            $max_dist_sqd = $dist_sqd;
        }

        my $n2 = nn($further_kd, @target, $further_hr, $max_dist_sqd);
        $nodes_visited += $n2.nodes_visited;
        if $n2.dist_sqd < $dist_sqd {
            $nearest = $n2.nearest;
            $dist_sqd = $n2.dist_sqd;
        }

        T3.new(:$nearest, :$dist_sqd, :$nodes_visited);
    }
}
