# Day 02 - Tracking state
## A word on state.
### Sets, kind of, don't take my word for it
[Relational databases](https://en.wikipedia.org/wiki/Relational_database) are modeled on relational algebra. There's a lot of set theory in there. However, RDBMS are created with commercial intent. Oracle is exceedingly happy to break theory if it'll attract more customers. Still, theory let's one prove correctness, some companies like that, and SQL started with set manipulation as a guiding principle.

SQL was also created with an eye towards describing the solution to get an answer instead of defining the algorithm to find the answer. "What are the employee details for Bob?" "What is the total cost for this order?" "Who works in this department?" Most importantly, "If somebody works for marketing, lower their salary by 10%." Easy things to write in SQL. Other things, not so easy.

### Why keeping state in sql is hard.
First off, I could be doing it wrong. So there is that.

SQL isn't a procedural language. It works on one or more sets of data and returns a set of data. Sets don't have order; order isn't part of the computation. You can display the results in an order but that's after the computation is complete. **State** is a value that can change during processing, at least the way I'm thinking about it, but natively SQL just gives you the results in an atomic action. There are methods to allow processing in order because companies want to sell usable systems, but those aren't simple, syntactically.

### Back to analytic functions.
I think of analytic functions as a layer sitting on top of the core sql commands. You get this set and analytics lets you do processing on the set. They often allow you to generate a state-like column from row to row.

They are still set-ish in behavior. A procedural languange let's you grab a value and twist it around to your will. Analytics are much more limited.

## Where I stop ruminating and get to the puzzle on hand
### Part1
#### Puzzle description
It seems like the submarine can take a series of commands like forward 1, down 2, or up 3:

forward X increases the horizontal position by X units.
down X increases the depth by X units.
up X decreases the depth by X units.
Note that since you're on a submarine, down and up affect your depth, and so they have the opposite result of what you might expect.

The submarine seems to already have a planned course (your puzzle input). You should probably figure out where it's going. For example:
forward 5
down 5
forward 8
up 3
down 8
forward 2
Your horizontal position and depth both start at 0. 

#### Parse the input
I create tables to hold  puzzle input. Using sqlldr or an external table is more frustrating than helpful, for various reasons. Since tables are sets, lineno preserves the ordered property of a sequencial text file.
```sql
create table day02_part1 (lineno number, linevalue varchar2(4000));
create sequence day02_line_sq;
insert into day02_part1 (lineno, linevalue) values (day02_line_sq.nextval,'forward 1');
insert into day02_part1 (lineno, linevalue) values (day02_line_sq.nextval,'down 5');
-- etc
```

First order of business is parsing the input. I need the direction and the distance, which are seperated by a space.
```sql
create view day02_part1_v1 as
select
  lineno
  , substr(linevalue,1,a-1) direction
  , to_number(substr(linevalue,a+1)) distance
from (
  select lineno, linevalue, instr(linevalue,' ') a
  from day02_part1
)
/
```
The inline view gives me the location of the space. This makes the substr() calls a lot easier to read. to_number() gives the right type so I'm not dealing with fickle implicite type conversion.
#### Add it up
'forward' changes horizontal position. 'up'/'down' changes depth. These are delta values so I can add them up without regard to the order. I'll create a view to separate out the x/y values.
```sql
create or replace view day02_part1_v2 as
select decode(direction, 'forward',distance, 0) x
  , decode(direction, 'down',distance, 'up',-distance, 0) y
from day02_part1_v1
;
```
decode() is basically a case statement. In fact sql has a case statement, I'm just used to using decode. The syntax is decode(expression, search1,return1 \[,search2,return2] \[,default]). It returns the first match, default if it is defined, or a null.

Each row gives a 0,value or value,0. I'm can use all the rows I need so I'm fine with it.

Time to get the answer.
```sql
select sum(x) horizontal, sum(y) depth, sum(x)*sum(y) answer
from day02_part1_v2;
```
No state, no problem. What a great segue into part2.
### Part 2
#### Puzzle description
In addition to horizontal position and depth, you'll also need to track a third value, aim, which also starts at 0.
The commands also mean something entirely different than you first thought:

down X increases your aim by X units.
up X decreases your aim by X units.
forward X does two things:
It increases your horizontal position by X units.
It increases your depth by your aim multiplied by X.
#### Parse it
The view does the same thing as part1. I'm changing the name anyway. Also changing direction to command. Distance isn't quite right, but I don't have a better name.
```sql
create or replace view day02_part2_v1 as
select
  lineno
  , substr(linevalue,1,a-1) command
  , to_number(substr(linevalue,a+1)) distance
from (
  select lineno, linevalue, instr(linevalue,' ') a
  from day02_part1
)
/
```

#### Work the problem.
I know I want to split out the forward command from the up/down command. This is the same logic from part1, with different names.
```sql
create or replace view day02_part2_v2 as
select lineno step
  , decode(command,'forward',distance,0) forward
  , decode(command,'down',distance,'up',-distance,0) aim_delta
from day02_part2_v1
;
```

