/*
-- basins from example

..999.....
.9...9.9..
9.....9.9.
.....9...9
9.999.....

Find the three largest basins and multiply their sizes together. In the above example, this is 9 * 14 * 9 = 1134.

In theory I could ignore the cell values except for 9, like the figure above.
In practice the decending path to the basin's low point make it easer, for me.
I can make a tree-ish structure and find the root of each cell.
Doing this once per cell lets me ignore the problem of finding nooks and crannies or overcounting visited cells.

I repeat the first two steps from Part1.
This leaves me with a gradient map at each cell.
STEP 3, find a lower adjacent cell, by construction that will eventually find the bottom of the basin.
STEP 4, treating the lower cells as a parent, use a recursive query to find the root of the tree; the lowest cell in the basin.
STEP 5, count the number of cells leading to the same root.
STEP 6, cheat by manually multiplying the top 3 numbers.
  Oracle doesn't have an aggregate multiply function and I've gone through the process before.
*/
