/*
-- basins from example

..999.....
.9...9.9..
9.....9.9.
.....9...9
9.999.....

Find the three largest basins and multiply their sizes together. In the above example, this is 9 * 14 * 9 = 1134.

In theory I could ignore the cell values except for 9, like the figure above.
In practice the decending path to the basin's low point make it easier, for me.
I can make a tree-ish structure and find the root of each cell.
Doing this once per cell lets me ignore the problems of overcounting visited cells or of missing nooks and crannies.

I repeat the first two steps from Part1 but include a unique identifier for each cell.

STEP 1, find a lower adjacent cell, by construction it will eventually lead the bottom of the basin.
STEP 2, find a lower adjacent cell, by construction it will eventually lead the bottom of the basin.

STEP 3, find a lower adjacent cell, by construction it will eventually lead the bottom of the basin.
STEP 4, treating the lower cells as a parent, use a recursive query to find the root of the tree; the lowest cell in the basin.
STEP 5, count the number of cells leading to the same root.
STEP 6, cheat by manually multiplying the top 3 numbers.
  Oracle doesn't have an aggregate multiply function and I've gone through the process before.
*/

-- STEP 1, like Part1 except using rownum as a unique identifier. Could have used a sequence, etc.
-- Notice how assigning an alias to rownum at each level prevents name collision.
create or replace view day09_part2_4 as
select e.lineno y, n.rn x, n.cv value, rownum id
from day09_part1  e
  ,lateral(select column_value cv, rownum rn from table( string2rows(e.linevalue))) n
;
select * from day09_part2_4;

--STEP 2, like Part1 except exposes the unique cell id.
create or replace view day09_part2_5 as
select x
  ,y
  ,id
  ,value
  ,value-lag(value) over (partition by y order by x) diff_pre_x
  ,value-lag(value) over (partition by y order by x desc) diff_post_x
  ,value-lag(value) over (partition by x order by y) diff_pre_y
  ,value-lag(value) over (partition by x order by y desc) diff_post_y
from day09_part2_4
order by x,y
/
select * from day09_part2_5;

--STEP 3, find a lower adjacent cell, by construction it will eventually lead the bottom of the basin.
-- use diffs to find a neighbor "lower" cell
-- any one lower cell eventually leads to the drain so just find the first
create or replace view day09_part2_6 as
select
  id
  ,case
    when diff_pre_x > 0 then lag(id) over (partition by y order by x)
    when diff_post_x > 0 then lag(id) over (partition by y order by x desc)
    when diff_pre_y > 0 then lag(id) over (partition by x order by y)
    when diff_post_y > 0 then lag(id) over (partition by x order by y desc)
  end down_id
from day09_part2_5
where value!=9;
select * from day09_part2_6;
/*
Root cells do not have a "DOWN_ID" because there are no lower value cells next to them.
The lag function, by default, returns a null.

ID	DOWN_ID
1	2
2
6	7
7	8
8	9
9	10
10
11	1
13	14
14	24
*/

--STEP 4, treating the lower cells as a parent, use a recursive query to find the root of the tree; the lowest cell in the basin.
-- the cell's basin is the connect_by_root value; the rest are for troubleshooting
create or replace view day09_part2_7 as
select
  level as n
  , id
  , down_id
  , SYS_CONNECT_BY_PATH(id,'/') str
  , connect_by_root id basin
from day09_part2_6
start with down_id is null
connect by down_id = prior id ;
select * from day09_example_7;
/*
N	ID	DOWN_ID	STR	BASIN
1	2		/2	2
2	1	2	/2/1	2
3	11	1	/2/1/11	2
1	10		/10	10
2	9	10	/10/9	10
3	8	9	/10/9/8	10
4	7	8	/10/9/8/7	10

    select
1)    level as n
      , id
      , down_id
2)    , SYS_CONNECT_BY_PATH(id,'/') str
3)    , connect_by_root id basin
    from day09_part2_6
4)  start with down_id is null
5)  connect by down_id = prior id ;

I described the logic as going from a leaf cell up to the root. This query actually goes the other way.
This is the "connect by" version of recursive queries.
Personally I usually find them confusing if the connection clause becomes too complicated.
  In that case, I prefer a recursive view because it starts with a base result set and then has a section that iterates over the results.

4)  start with down_id is null
I'm using the lowest cells as the root nodes, the first level.
1)    level as n
The first rows found are considered level 1. The next pass is level 2, after that 3, etc.
5)  connect by down_id = prior id ;
"connect by" is used to determing the this level of results.
"prior" is an operator that allows the current row to refer to a prior level's results.
In this case, we're looking for rows where their down_id match the previous level's id.

2)    , SYS_CONNECT_BY_PATH(id,'/') str
3)    , connect_by_root id basin
N	ID	DOWN_ID	STR	BASIN
1	2		/2	2
2	1	2	/2/1	2
3	11	1	/2/1/11	2

2) shows the path from this row to the root. It displays the root to next node down to the current node.
Row id 11 then is 2 <- 1 <- 11
3) skips the path and just shows the root node.

Most of the output isn't necessary. The problem only needs the rows to print their root node.
*/

--STEP 5, count the number of cells leading to the same root.
-- top three basin sizes
select basin, count(*)
from day09_part2_7
group by basin
order by count(*) desc
fetch first 3 rows only;
/*
BASIN	COUNT(*)
8782	100
6838	97
4919	96
*/ 

--STEP 6, cheat by manually multiplying the top 3 numbers.
/*
Oracle doesn't supply an aggregate multiply function. select multiply(basin) from ... isn't avaliable.
I could fake it with log/sum()/exp but that introduces integer -> float presision loss.
I've done it before so I'm fine with skipping that excercise here.

931200
*/
