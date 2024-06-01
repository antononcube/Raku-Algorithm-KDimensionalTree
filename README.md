# Algorithm::KDimensionalTree

Raku package with implementations of the [K-Dimensional Tree (K-D Tree) algorithm](https://en.wikipedia.org/wiki/K-d_tree).

**Remark:** This package should not be confused with 
["Algorithm::KdTree"](https://raku.land/github:titsuki/Algorithm::KdTree), [ITp1],
which provides Raku bindings to a C-implementation of the K-D Tree algorithm.
(A primary motivation for making this package, "Algorithm::KDimensionalTree", was to have a pure-Raku implementation.)

------

## Installation

From Zef ecosystem:

```
zef install Algorithm::KDimensionalTree
```

From GitHub:

```
zef install https://github.com/antononcube/Raku-Algorithm-KDimensionalTree.git
```

-----

## Usage examples

### Setup

```perl6
use Algorithm::KDimensionalTree;
use Data::TypeSystem;
use Text::Plot;
```
```
# (Any)
```

### Set of points

Make a random set of points: 

```perl6
my @points = ([(^100).rand, (^100).rand] xx 30).unique;
deduce-type(@points);
```
```
# Vector(Vector(Atom((Numeric)), 2), 30)
```

### Create the K-dimensional tree object

```perl6
my $kdTree = Algorithm::KDimensionalTree.new(@points);

say $kdTree;
```
```
# KDTree(points => 30, distance-function => &euclidean-distance)
```

### Nearest k-neighbors

Use as a search point one from the points set:

```perl6
my @searchPoint = |@points.head;
```
```
# [76.11079267429541 19.074237975241303]
```

Find 6 nearest neighbors:

```perl6
my @res = $kdTree.nearest(@searchPoint, 6);
.say for @res;
```
```
# [76.11079267429541 19.074237975241303]
# [77.1914003305045 17.697882436033087]
# [77.60063860528398 15.129373797321177]
# [82.00906846807615 20.61997200485688]
# [69.89508017066133 10.633033332034813]
# [75.99198529805767 33.32069663826959]
```

### Plot

Plot the points, the found nearest neighbors, and the search point:

```perl6
my @point-char =  <* ⏺ ▲>;
say <data nns search> Z=> @point-char;
say text-list-plot(
[@points, @res, [@searchPoint,]],
:@point-char,
x-limit => (0, 100),
y-limit => (0, 100),
width => 60,
height => 20);
```
```
# (data => * nns => ⏺ search => ▲)
# ++----------+-----------+----------+-----------+----------++       
# + *                                                        + 100.00
# |      *              *     *                             *|       
# |                           *                              |       
# +                               *                          +  80.00
# |  *           *                                           |       
# |                              *                           |       
# |    *  *                                                  |       
# +                                                       *  +  60.00
# |                          *                               |       
# |                                *     *                   |       
# +                                                        * +  40.00
# |                          *         *      ⏺              |       
# |                                                          |       
# |                            *                  ⏺        * |       
# +                                           ▲⏺             +  20.00
# |           *                            ⏺                 |       
# |                                                          |       
# +         *                                                +   0.00
# ++----------+-----------+----------+-----------+----------++       
#  0.00       20.00       40.00      60.00       80.00      100.00
```

-----

## TODO

- [ ] TODO Implementation
  - [X] DONE Using distance functions from an "universal" package
    - E.g. "Math::DistanceFunctions"
  - [X] DONE Using distance functions other than Euclidean distance
  - [ ] TODO Returning properties
    - [X] DONE Points
    - [ ] TODO Indexes
    - [ ] TODO Labels
    - [ ] TODO Distances
    - [ ] TODO Combinations of those
  - [ ] TODO Having an umbrella function `nearest`
    - Instead of creating an KDTree object etc.
    - This might require making a functor `nearest-function`
    - This is better done in a different package
- [X] DONE Extensive correctness tests
  - Derived with Mathematica / WL (see the resources)
- [ ] TODO Documentation
  - [X] DONE Basic usage examples with text plots 
  - [ ] TODO More extensive documentation with a Jupyter notebook
    - Using "JavaScript::D3".
  - [ ] TODO Corresponding blog post
  - [ ] MAYBE Corresponding video

-----

## References

[AAp1] Anton Antonov, [Data::TypeSystem Raku package](https://github.com/antononcube/Raku-Data-TypeSystem), (2023), [GitHub/antononcube](https://github.com/antononcube).

[AAp2] Anton Antonov, [Text::Plot Raku package](https://github.com/antononcube/Raku-Text-Plot), (2022), [GitHub/antononcube](https://github.com/antononcube).

[ITp1] Itsuki Toyota, [Algorithm::KdTree Raku package](https://github.com/titsuki/p6-Algorithm-KdTree), (2016-2024), [GitHub/titsuki](https://github.com/titsuki).