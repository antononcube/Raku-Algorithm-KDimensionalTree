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
# KDTree(points => 30, distance-function => Unknown)
```

### Nearest k-neighbors

Use as a search point one from the points set:

```perl6
my @searchPoint = |@points.head;
```
```
# [47.33064406506299 76.37307064050573]
```

Find 6 nearest neighbors:

```perl6
my @res = $kdTree.nearest(@searchPoint, 6);
.say for @res;
```
```
# [47.33064406506299 76.37307064050573]
# [33.321989165943265 72.2106395557012]
# [42.367775385271564 92.76001291548755]
# [56.24834629183131 60.79449358393906]
# [44.09972101660911 95.32962593733126]
# [69.96118735293926 66.53535849892195]
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
# +                                                      *   + 100.00
# |                        ⏺⏺             *                  |       
# |                                                          |       
# + *                                                        +  80.00
# |                           ▲              *    *          |       
# | *        *        ⏺                                      |       
# |                                        ⏺          *      |       
# +                                ⏺                  **     +  60.00
# |                 *                                        |       
# |             *                                          * |       
# + *             *                                          +  40.00
# |                            *       **                    |       
# |                                                          |       
# |                                                          |       
# +                                               *          +  20.00
# |                                *         *         *     |       
# |             *                                            |       
# +                        *                                 +   0.00
# ++----------+-----------+----------+-----------+----------++       
#  0.00       20.00       40.00      60.00       80.00      100.00
```

-----

## TODO

- [ ] TODO Implementation
  - [ ] TODO Using distance functions other than Euclidean distance
  - [ ] TODO Using distance functions from an "universal" package
    - E.g. "Math::DistanceFunctions"
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