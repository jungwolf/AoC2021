/*
Using the example input to show the process. It works for Part1 input as well.


Given a hightmap, find all the local minima. Example:
2199943210
3987894921
9856789892
8767896789
9899965678
This has 4 points that are lower than all the points around them.
X as ->, Y as \/: (2,1) (10,1) (3,3) (7,5)
How to find those points?

Data is in a table day09_example, with a lineno and linevalue:
(1,'2199943210')
(2,'3987894921')
(3,'9856789892')
(4,'8767896789')
(5,'9899965678')

STEP 1, generate (x,y,height) rows from the input.
STEP 2, calculate the height different between cells in each direction.
STEP 3, find local minimums (minima?)
STEP 4, calculate final answer
*/

STEP 1, generate (x,y,height) rows from the input.

-- this is a little tricky
/*
select e.lineno y, n.rn x, n.cv value
from day09_example e
1),lateral(
2)   select column_value cv
3)     ,rownum rn
4)   from table(
5)       string2rows(
6)           e.linevalue
         )
     )
   ) n
;

5)       string2rows(
This is a helper function I wrote to split strings into a table of varchar2. "Table of ..." is a complex data type with its own special syntax.
In this case, one row for each character. For example, 2199943210 -> row '2', row '1', row '9', etc.
The rows are returned in order as they are generated in the function.
BIG CAVEAT: this is not guarenteed behavior between releases, although it has been stable for multiple major releases so far.
  So don't use it in production code. 

4)   from table(
table() syntax lets a sql query treat the "table of ..." type as a row source, like a view or table.
It returns one column, named column_value. My function returns a table of varchar2, so column_value data type is varchar2.
So, it is basically a single column view (column_value varchar2(4000))

2)   select column_value cv
I like to give it an alias
3)     ,rownum rn
The BIG CAVEAT above lets me use psuedocolumn rownum to assign position.
Every rows ource has its own rownum sequence, best to give it an alias to avoid confusion.

1),lateral(
5)       string2rows(
6)           e.linevalue
This is a correlated join, allowing the left table to join with its own row, one-to-one.
For example, if the left table has a varchar2 column linevalue, the right lateral joined table can use the linevalue column too.
That's why my string2rows(e.linevalue) function works on the appropriate row from the left table.
I'm sure it can do more but that's my use so far.
One of the best things I learned this year.
*/

create or replace view day09_example_1 as
select e.lineno y, n.rn x, n.cv value
from day09_example e
  ,lateral(select column_value cv, rownum rn from table(string2rows(e.linevalue))) n
;
/*
Y	X	VALUE
1	1	2
1	2	1
1	3	9
...
2	1	3
2	2	9
2	3	8
...
2	10	1
...
*/

STEP 2, calculate the height different between cells in each direction.

-- use lag to find the differences in the 4 adjacent cells
-- a good example to show analytical functions can process different data sets even for the same row
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

STEP 3, find local minimums (minima?)

-- My "diff" values are a little funny, in that they are the amount you subtract to get the next position.
-- Example, current height 2 going to height 9, the diff is 2-9=-7. From 2, computing the next value is 2-(-7)=9.
-- That means a local minimum has negative values for all diff columns, meaning AND between the conditions.
-- The sides are not supposed to change the output, and lag to a side is null, so nulls are treated as a negative number. Shorthand for ( (diff is null) or (diff < 0) ).
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

STEP 4, calculate final answer

-- The "threat" is height + 1, so sum up the (values+1)
select sum(value+1)
from day09_example_2
where nvl(diff_pre_x,-1) < 0
  and nvl(diff_pre_y,-1) < 0
  and nvl(diff_post_x,-1) < 0
  and nvl(diff_post_y,-1) < 0
order by y,x
/
-- 15
