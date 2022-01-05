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

-- I'm going to find it easier to use the input as a list of (cave,next_cave) paths.
-- The input as presented gives one direction, so this view adds the reverse direction.
create or replace view day12_part2_v2 as
select cave1 cave, cave2 next_cave from day12_part2_v1
union all
select cave2, cave1 from day12_part2_v1
/
select * from day12_part2_v2 order by cave, next_cave;
/*
CAVE	NEXT_CAVE
MN	ah
ah	MN
MN	start
start	MN
...
*/

-- Finally, I remove the rows that allow returning to start or leaving end.
create or replace view day12_part2_v3 as
select cave, next_cave from day12_part2_v2
where cave != 'end' and next_cave != 'start'
/
select * from day12_part2_v3 order by cave, next_cave;
/*
CAVE	NEXT_CAVE
MN	ah
ah	MN
start	MN
...
*/


-- PART 2: Everything else. ------------------------------
/*
I'm approaching this with a recursive query. That seemed intuitive, and I'm not sure sql can be done non-recursively.
Rough logic:
1) Start with the start cave.
2) Join to available move list where all the cave values are 'start'.
3) Filter out any rows violating the number of cave visits limit. This is the new working set of rows.
4) Join the working set to the available move list where a previous cave value is equal to a next_cave value.
5) Back to 3) until there are no more rows from 4).
6) Count up all rows that reached next_cave = end.

Step 4) generates rows that will be filtered out by 3).
  * It also naturally filters completed paths because no rows have cave=end.
Step 3) is tricky, it needs some kind of memory.
  * Keep a list of all caves visited, and search through it for double visits.
  * How to allow one exception?

Solution, then I'll go back to explain a few things.
122134 paths, taking 1m 34s.
*/

select count(*) from (
  with t (cave,next_cave,lvl,current_path,numvisits,maxvisits) as (
    select cave, next_cave, 1 lvl
      ,case when next_cave=lower(next_cave) then cave||','||next_cave else cave end current_path
      , 0 numvisits
      , 0 maxvisits
    from day12_part2_v3
    where cave='start'

    union all

    select v3.cave, v3.next_cave, t.lvl+1
      , case when v3.next_cave=lower(v3.next_cave) then t.current_path||','||v3.next_cave else t.current_path end
      , case when v3.next_cave=lower(v3.next_cave) then regexp_count(t.current_path,v3.next_cave)+1 else 0 end
      , decode(t.maxvisits,2,2,t.numvisits) maxvisits
    from t, day12_part2_v3 v3
    where 1=1
      and t.next_cave=v3.cave
      and lvl = lvl
      and ( (t.numvisits < 2)
         or (t.numvisits = 2 and t.maxvisits < 2) )
  )
  select * from t
  where next_cave = 'end'
)
/


/*
Normal recursive view, has the normal pattern:
with t (COLUMNS) as (
  select COLUMNS from SOMETHING
  union all
  select SAME#OFCOLUMNS from T where ...
)
select ... from t...

Let's look at the second half of the UNION ALL, because it shows how we generate the next set of moves from the current set of caves.
1)    select v3.cave cave, v3.next_cave next_cave, t.lvl+1 lvl
2)      , case when v3.next_cave=lower(v3.next_cave) then t.current_path||','||v3.next_cave else t.current_path end current_path
3)      , case when v3.next_cave=lower(v3.next_cave) then regexp_count(t.current_path,v3.next_cave)+1 else 0 end numvisits
4)      , decode(t.maxvisits,2,2,t.numvisits) maxvisits
5)    from t, day12_part2_v3 v3
6)    where 1=1
7)      and t.next_cave=v3.cave
8)      and lvl = lvl
9)      and ( (t.numvisits < 2)
10)         or (t.numvisits = 2 and t.maxvisits < 2) )


t has the current list of paths. T.cave is the current cave.
day12_part2_v3 has the list of all available moves for any cave.
5)    from t, day12_part2_v3 v3
6)    where ...    -- **** please ignore 1=1, it is a little syntax trick to let me add or remove where clauses easily during development
7)      and t.next_cave=v3.cave
For every row in T, use next_cave to find the valid caves for the next round.

The select clause builds the values used by the next query. They will have column names defined by the original "with t ()" clause.
0)  with t (cave,next_cave,lvl,current_path,numvisits,maxvisits) as (

1a)    select v3.cave cave
1b)      , v3.next_cave next_cave
1c)      , t.lvl+1 lvl
I can remove t.cave in 1a). It turns out I never use it. It was useful for troubleshooting, however.
t.lvl is basically not used. I use it as a shortcut that I'll explain in 8).
1b) is important. v3.next_cave -> t.next_cave, so the *next* round can find its next moves.

2)      , case
            when v3.next_cave=lower(v3.next_cave)
              then t.current_path||','||v3.next_cave 
            else t.current_path
           end current_path
This generates the list of caves visited. I use it to enforce the cave visit rules. The rules only care about lowercase named caves.
  So, when v3.next_cave=lower(v3.next_cave) let's me ignore the uppercase named caves.
  current_path is part of the "memory" kept from pass to pass.

3)      , case 
            when v3.next_cave=lower(v3.next_cave)
              then regexp_count(t.current_path,v3.next_cave)+1
            else 0
          end numvisits
regexp_count(t.current_path,v3.next_cave)+1 counts how many times its already visited a cave. Add 1 because this is another visit to the cave.
  Again, ignore uppercase caves by using when v3.next_cave=lower(v3.next_cave).

4)      , decode(t.maxvisits,2,2,t.numvisits) maxvisits
This lets me know if I've already visited a lowercase cave twice. It is the second piece of "memory".
  Once maxvisits is set to 2, all next moves will also have 2. 

Almost at the end.
9)      and ( (t.numvisits < 2)
10)         or (t.numvisits = 2 and t.maxvisits < 2) )
If the current cave has only been visited once, it is legal.
If the current cave has been visited twice, is it the first such cave? If so, it is also legal.

