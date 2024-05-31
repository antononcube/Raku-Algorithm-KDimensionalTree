# Algorithm::KDimensionalTree

Raku package with implementations of the [K-Dimensional Tree (K-D Tree) algorithm](https://en.wikipedia.org/wiki/K-d_tree).


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
# [81.81880244297301 53.23255038156823]
```

Find 6 nearest neighbors:

```perl6
my @res = $kdTree.nearest(@searchPoint, 6);
.say for @res;
```
```
# [81.81880244297301 53.23255038156823]
# [74.92034114924729 55.816607496405645]
# [77.56879366771614 72.38261384087915]
# [68.03286380472335 72.34886942314922]
# [62.60282286103242 37.97391086337581]
# [64.41537717616772 32.783882441183174]
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
# +                                *                         + 100.00
# |                  *                                       |       
# |                                                  *       |       
# +                            *                             +  80.00
# |                                                          |       
# |   *                                   ⏺    ⏺             |       
# |                                                          |       
# + *       *                                                +  60.00
# |                                           ⏺   ▲          |       
# |                *             *                           |       
# +       *                                                  +  40.00
# | *                                  ⏺⏺                    |       
# |  *                                                       |       
# |           *                                         *    |       
# +    **                                        *           +  20.00
# |                    *   *                                 |       
# |        *   *              *    *                         |       
# +                                                          +   0.00
# ++----------+-----------+----------+-----------+----------++       
#  0.00       20.00       40.00      60.00       80.00      100.00
```

-----

## References

[AAp1] Anton Antonov, [Data::TypeSystem Raku package](https://github.com/antononcube/Raku-Data-TypeSystem), (2023), [GitHub/antononcube](https://github.com/antononcube).

[AAp2] Anton Antonov, [Text::Plot Raku package](https://github.com/antononcube/Raku-Text-Plot), (2022), [GitHub/antononcube](https://github.com/antononcube).