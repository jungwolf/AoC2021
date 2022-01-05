/* Day 12: Passage Pathing
Today's puzzle gives us a description of a cave system with the connections between each cave.
For example:
start-A
start-b
A-c
A-b
b-d
A-end
b-end
Starting at start, how many distinct paths are there to end?
There are a few limitations.
* Uppercase named caves can be visited any number of times.
* Lowercase named caves can only be visited once.
  * Except one lowercase named cave can be visited twice.

Full rules here: https://adventofcode.com/2021/day/12.

I assume the dataset is sane, such as no duplicates, no UPPER-UPPER connections to avoid infinite loops, etc.

PART 1: Create a view of the data in a useable form.
PART 2: Everything else.

*/

-- PART 1: Create a view of the data in a useable form. ------------------------------

/* Input is in a table like normal, example inserts:
insert into day12_part1 (lineno, linevalue) values (day12_line_sq.nextval,'MN-dc');
insert into day12_part1 (lineno, linevalue) values (day12_line_sq.nextval,'end-yw');
*/

-- First order of business is split each line into two columns of cave names.
create or replace view day12_part2_v1 as
select
  substr(linevalue,1,instr(linevalue,'-')-1) cave1
  , substr(linevalue,instr(linevalue,'-')+1) cave2
from day12_part1
/
select * from day12_part2_v1 order by cave1, cave2;
/*
CAVE1	CAVE2
DG	dc
MN	ah
MN	dc
...
*/

-- I'm going to find it easier to use the input as a list of (from,to) paths.
-- The input as presented gives one direction, so this view adds the reverse direction.
create or replace view day12_part2_v2 as
select cave1 cavefrom, cave2 caveto from day12_part2_v1
union all
select cave2, cave1 from day12_part2_v1
/
select * from day12_part2_v2 order by cavefrom, caveto;
/*
CAVEFROM	CAVETO
MN	ah
ah	MN
MN	start
start	MN
...
*/

-- Finally, I remove the rows that allow returning to start or leaving end.
create or replace view day12_part2_v3 as
select cavefrom, caveto from day12_part2_v2
where cavefrom != 'end' and caveto != 'start'
/
select * from day12_part2_v3 order by cavefrom, caveto;
/*
CAVEFROM	CAVETO
MN	ah
ah	MN
start	MN
...
*/


-- PART 2: Everything else. ------------------------------
