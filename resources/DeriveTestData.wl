(*Points*)

SeedRandom[256];
points = RandomReal[{0, 100}, {300, 2}];

Print @ ListPlot[points];

searchPoint = First@points;

(*Cosine distance*)

nns = Nearest[points, searchPoint, {All, 0.02},
   DistanceFunction -> CosineDistance, Method -> "KDTree"];
Print @ Length[nns];

Print @ ListPlot[{points, nns, {searchPoint}},
 PlotStyle -> {Automatic, PointSize[0.016], {PointSize[0.022]}},
 AspectRatio -> Automatic];

(*Manhattan distance*)

nns = Nearest[points, searchPoint, {All, 20}, DistanceFunction -> ChessboardDistance, Method -> "KDTree"];
Print @ Length[nns];

Print @ ListPlot[{points, nns, {searchPoint}},
 PlotStyle -> {Automatic, PointSize[0.016], {PointSize[0.022]}},
 AspectRatio -> Automatic];

(*Export*)

aData = <|
   "points" -> points,
   "searchPoint" -> searchPoint,
   "EuclideanDistance" -> <|"radius" -> 20,
     "nns" -> Nearest[points, searchPoint, {All, 20},
       DistanceFunction -> EuclideanDistance, Method -> "KDTree"]|>,
   "CosineDistance" -> <|"radius" -> 0.02,
     "nns" -> Nearest[points, searchPoint, {All, 0.02},
       DistanceFunction -> CosineDistance, Method -> "KDTree"]|>,
   "ChessboardDistance" -> <|"radius" -> 20,
     "nns" -> Nearest[points, searchPoint, {All, 20},
       DistanceFunction -> ChessboardDistance, Method -> "KDTree"]|>
   |>;

Export["KDTreeTest.json", aData]