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
  level as n
  , id
  , down_id
  , SYS_CONNECT_BY_PATH(id,'/') str
  , connect_by_root id basin
from day09_part2_6
start with down_id is null
connect by down_id = prior id ;


*/


--STEP 5, count the number of cells leading to the same root.
--STEP 6, cheat by manually multiplying the top 3 numbers.
