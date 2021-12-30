-- expand the input to x,y,value entries
select lineno, linevalue from day09_example;
select string2rows(linevalue) from day09_example;

-- function string2rows generate rows from string using delimiter
-- if null delimiter (default), outputs each character on its own line
-- delimiters can be multicharacter
-- uses a user defined type
-- notice it can only handle inputs up to 4000 characters.
--create or replace type varchar2_tbl as table of varchar2(4000);

select e.linevalue, e.lineno, n.rn, '.', n.cv
from day09_example e
  ,lateral(select column_value cv, rownum rn from table( string2rows(e.linevalue))) n
order by n.rn, n.cv;
/*
LINEVALUE	LINENO	RN	'.'	CV
2199943210	1	1	.	2
3987894921	2	1	.	3
8767896789	4	1	.	8
9899965678	5	1	.	9
9856789892	3	1	.	9
2199943210	1	2	.	1
8767896789	4	2	.	7
9899965678	5	2	.	8
...
*/

create or replace view day09_example_1 as
select e.lineno y, n.rn x, n.cv value
from day09_example e
  ,lateral(select column_value cv, rownum rn from table( string2rows(e.linevalue))) n
;

select * from day09_example_1;
/*
Y	X	VALUE
1	1	2
1	2	1
1	3	9
1	4	9
1	5	9
1	6	4
*/

create or replace view day09_example_2 as
select x
  ,y
  ,value
  ,value-lag(value) over (partition by y order by x) diff_pre_x
  ,value-lag(value) over (partition by y order by x desc) diff_post_x
  ,value-lag(value) over (partition by x order by y) diff_pre_y
  ,value-lag(value) over (partition by x order by y desc) diff_post_y
from day09_example_1
order by x,y
/
/*
X	Y	VALUE	DIFF_PRE_X	DIFF_POST_X	DIFF_PRE_Y	DIFF_POST_Y
1	1	2	 - 	1	 - 	-1
1	2	3	 - 	-6	1	-6
1	3	9	 - 	1	6	1
1	4	8	 - 	1	-1	-1
1	5	9	 - 	1	1	 - 
2	1	1	-1	-8	 - 	-8
2	2	9	6	1	8	1
*/

select * 
from day09_example_2
where nvl(diff_pre_x,-1) < 0
  and nvl(diff_pre_y,-1) < 0
  and nvl(diff_post_x,-1) < 0
  and nvl(diff_post_y,-1) < 0
order by y,x
/
/*
X	Y	VALUE	DIFF_PRE_X	DIFF_POST_X	DIFF_PRE_Y	DIFF_POST_Y
2	1	1	-1	-8	 - 	-8
10	1	0	-1	 - 	 - 	-1
3	3	5	-3	-1	-3	-1
7	5	5	-1	-1	-1	 - 
*/

select sum(value+1)
from day09_example_2
where nvl(diff_pre_x,-1) < 0
  and nvl(diff_pre_y,-1) < 0
  and nvl(diff_post_x,-1) < 0
  and nvl(diff_post_y,-1) < 0
order by y,x
/
-- 15
