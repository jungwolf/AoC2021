/*
-- basins from example

..999.....
.9...9.9..
9.....9.9.
.....9...9
9.999.....

Find the three largest basins and multiply their sizes together. In the above example, this is 9 * 14 * 9 = 1134.
*/

-- splits values into x,y coordinates, and assigns a unique id
create or replace view day09_example_4 as
select e.lineno y, n.rn x, n.cv value, rownum id
from day09_example e
  ,lateral(select column_value cv, rownum rn from table( string2rows(e.linevalue))) n
;
select * from day09_example_4;

-- calculate differences between adjacent cells
create or replace view day09_example_5 as
select x
  ,y
  ,id
  ,value
  ,value-lag(value) over (partition by y order by x) diff_pre_x
  ,value-lag(value) over (partition by y order by x desc) diff_post_x
  ,value-lag(value) over (partition by x order by y) diff_pre_y
  ,value-lag(value) over (partition by x order by y desc) diff_post_y
from day09_example_4
order by x,y
/
select * from day09_example_5;

-- all cells (besides 9) drain into a basin eventually
-- use differences to find a neighbor "lower" cell
-- any one lower cell eventually leads to the drain so just find the first
create or replace view day09_example_6 as
select
  id
  ,case
    when diff_pre_x > 0 then lag(id) over (partition by y order by x)
    when diff_post_x > 0 then lag(id) over (partition by y order by x desc)
    when diff_pre_y > 0 then lag(id) over (partition by x order by y)
    when diff_post_y > 0 then lag(id) over (partition by x order by y desc)
  end down_id
from day09_example_5
where value!=9;
select * from day09_example_6;
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
-- drains have null down_id, so start with nulls and find rows pointing back to that basin

-- the cell's basin is the connect_by_root value; the rest are for troubleshooting
create or replace view day09_example_7 as
select
  level as n
  , id
  , down_id
  , SYS_CONNECT_BY_PATH(id,'/') str
  , connect_by_root id basin
from day09_example_6
start with down_id is null
connect by down_id = prior id ;

-- top three basin sizes
select basin, count(*) 
from day09_example_7
group by basin
order by count(*) desc
fetch first 3 rows only;
/*
BASIN	COUNT(*)
23	14
47	9
10	9
*/
-- oracle doesn't have an aggregate multiply function; you can fake it using logs, but here I'll just multiply them by hand... :(
-- 1134
----------------------------------------------------------------
-- so part2 on input data


create or replace view day09_part2_4 as
select e.lineno y, n.rn x, n.cv value, rownum id
from day09_part1  e
  ,lateral(select column_value cv, rownum rn from table( string2rows(e.linevalue))) n
;
select * from day09_part2_4;

-- calculate differences between adjacent cells
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

-- all cells (besides 9) drain into a basin eventually
-- use differences to find a neighbor "lower" cell
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
-- drains have null down_id, so start with nulls and find rows pointing back to that basin

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

--931200
