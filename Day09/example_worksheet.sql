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


