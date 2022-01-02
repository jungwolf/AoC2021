select * from day11_example;

create or replace view day11_example_1 as
select e.lineno y, n.rn x, n.cv value
from day11_example e
  ,lateral(select column_value cv, rownum rn from table( string2rows(e.linevalue))) n
;
select * from day11_example_1;

-- split out to x,y,value
/*
Y	X	VALUE
1	1	5
1	2	4
1	3	8
1	4	3
1	5	1
*/

You can model the energy levels and flashes of light in steps. During a single step, the following occurs:

First, the energy level of each octopus increases by 1.
Then, any octopus with an energy level greater than 9 flashes.
  This increases the energy level of all adjacent octopuses by 1, including octopuses that are diagonally adjacent.
	If this causes an octopus to have an energy level greater than 9, it also flashes.
	This process continues as long as new octopuses keep having their energy level increased beyond 9.
	(An octopus can only flash at most once per step.)
Finally, any octopus that flashed during this step has its energy level set to 0, as it used all of its energy to flash.

