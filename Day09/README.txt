/*
Given a hightmap, find all the local minima. Example:
2199943210
3987894921
9856789892
8767896789
9899965678
This has 4 points that are lower than all the points around them.
X as ->, Y as \/: (2,1) (10,1) (3,3) (7,5)
How to find those points?

My approach is to break them out to (x,y) rows with the value (height).

Data is in a table day09_example, with a lineno and linevalue:
(1,'2199943210')
(2,'3987894921')
(3,'9856789892')
(4,'8767896789')
(5,'9899965678')
*/

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
This is a helper function I wrote to split strings into a table of strings. "Table of strings" is a complex data type with its own special syntax.
In this case, one row for each character. For example, 2199943210 -> row '2', row '1', row '9', etc.
The rows are returned in order as they are generated in the function.
BIG CAVEAT: this is not guarenteed behavior between releases, although it has been stable for multiple major releases so far.
  So don't use it in production code. 

4)   from table(
table() syntax lets a sql query treat the "table of ..." type as a row source, like a view or table.
It returns one column, named column_value. This is a table of varchar2, so column_value data type is varchar2.
So, it is basically a single column view (column_value varchar2(4000))

2)   select column_value cv
I like to give it an alias
3)     ,rownum rn
The BIG CAVEAT above lets me use psuedocolumn rownum to assign position.
Every rowsource has its own rownum sequence, best to give it an alias to avoid confusion.

1),lateral(
5)       string2rows(
6)           e.linevalue
One of the best things I learned this year.
This is a correlated join, allowing the left table to join with its own row, one-to-one.
For example, if the left table has a varchar2 column linevalue, the right lateral joined table can use the linevalue column too.
That's why my string2rows(e.linevalue) function works on the appropriate row from the left table.
I'm sure it can do more but that's my use so far.
*/
create or replace view day09_example_1 as
select e.lineno y, n.rn x, n.cv value
from day09_example e
  ,lateral(select column_value cv, rownum rn from table( string2rows(e.linevalue))) n
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
