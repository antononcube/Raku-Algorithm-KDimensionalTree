#!/usr/bin/env raku
use v6.d;

use lib <. lib>;
use Algorithm::NodalKDTree;

sub show-nearest($k, $heading, $kd, @p) {
    print qq:to/END/;
        $heading:
        Point:            [@p.join(',')]
        END

    my $n = find-nearest($k, $kd, @p);
    print qq:to/END/;
        Nearest neighbor: [$n.nearest.join(',')]
        Distance:         &sqrt($n.dist_sqd)
        Nodes visited:    $n.nodes_visited()

        END

}

sub random-point($k) {
    [rand xx $k]
}
sub random-points($k, $n) {
    [random-point($k) xx $n]
}


my $kd1 = NodalKDTree.new([[2, 3], [5, 4], [9, 6], [4, 7], [8, 1], [7, 2]],
        Orthotope.new(:min([0, 0]), :max([10, 10])));

show-nearest(2, "Wikipedia example data", $kd1, [9, 2]);

my $N = 1000;
my $t0 = now;
my $kd2 = NodalKDTree.new(random-points(3, $N), Orthotope.new(:min([0, 0, 0]), :max([1, 1, 1])));
my $t1 = now;
show-nearest(2,
        "k-d tree with $N random 3D points (generation time: { $t1 - $t0 }s)",
        $kd2, random-point(3));
