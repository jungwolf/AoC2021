/*
Unfortunately churning through all the possibilites will be a chore.
so let's see if sql can lend us a hand
target area: x=277..318, y=-92..-53
We know from part 1 that finding the first t that can reach a target x square is: t = ivx + 0.5 +- sqrt( (ivx + 0.5)^2 - 2*targetx )
Limited by t <= ivx, so usually or maybe always the + root is out of bounds.
Can we go the other way around? That is, if I know targetx, can I find the minimum ivx that will reach it?
But then again, I'm already letting the DB do the heavy work. Searching through all x=0 to 318 and y=-92 to 92 possiblities isn't a problem
So let's see.

I need to generate 2 sequences. Let's go to the standards. Taking the lazy way out; it stops making rows eventually.
SELECT ROWNUM n FROM ALL_OBJECTS WHERE ROWNUM <= 318
SELECT ROWNUM-92-1 n FROM ALL_OBJECTS WHERE ROWNUM <= (92+92+1)
*/
with x as (SELECT ROWNUM x FROM ALL_OBJECTS WHERE ROWNUM <= 318)
, y as (SELECT ROWNUM-92-1 y FROM ALL_OBJECTS WHERE ROWNUM <= (92+92+1))
select x,y from x,y;

with x as (SELECT ROWNUM x FROM ALL_OBJECTS WHERE ROWNUM <= 318)
, y as (SELECT ROWNUM-92-1 y FROM ALL_OBJECTS WHERE ROWNUM <= (92+92+1))
select count(*) from x,y;
-- only 58830 rows, we got this

create or replace view day17_part2_v1 as
with x as (SELECT ROWNUM x FROM ALL_OBJECTS WHERE ROWNUM <= 318)
, y as (SELECT ROWNUM-92-1 y FROM ALL_OBJECTS WHERE ROWNUM <= (92+92+1))
select x,y from x,y;

-- whoops, forgot steps
with x as (SELECT ROWNUM x FROM ALL_OBJECTS WHERE ROWNUM <= 318)
, y as (SELECT ROWNUM-92-1 y FROM ALL_OBJECTS WHERE ROWNUM <= (92+92+1))
, t as (SELECT ROWNUM t FROM ALL_OBJECTS WHERE ROWNUM <= 318)
select count(*) from x,y,t;
-- 18707940
-- well, still doable

create or replace view day17_part2_v1 as
with x as (SELECT ROWNUM x FROM ALL_OBJECTS WHERE ROWNUM <= 318)
, y as (SELECT ROWNUM-92-1 y FROM ALL_OBJECTS WHERE ROWNUM <= (92+92+1))
, t as (SELECT ROWNUM t FROM ALL_OBJECTS WHERE ROWNUM <= 318)
select x,y,t from x,y,t;

/* let's see, ignoring step 0
px(t) = (ivx*2+1-t)/2*t, for t>0 and t<ivx
px(t) = (ivx+1)/2*ivx,   for t>=ivx
px is irritating...
py(t) = (ivy*2+1-t)/2*t
let's ignore px limit for a moment
*/
select x,y,t
from day17_part2_v1
/

select count(*)
from day17_part2_v1
where 1=1 
  and (y*2+1-t)/2*t between -53 and 92
/
--269346

select count(*)
from day17_part2_v1
where 1=1 
 and (y*2+1-t)/2*t between -53 and 92
  and (x*2+1-t)/2*t between 0 and 318
/
-- 76225

select count(*)
from day17_part2_v1
where 1=1 
 and (y*2+1-t)/2*t between -53 and 92
 and (
   case x<t then (x*2+1-t)/2*t between -53 and 92
   else (x*2+1-x)/2*x between -53 and 92
 )
/
-- it didn't like that syntax
-- how about
select count(*)
from day17_part2_v1
where 1=1 
 and (y*2+1-t)/2*t between -53 and 92
 and (
   (t<x and (x*2+1-t)/2*t between -53 and 92 )
   or (t>=x and ((x*2+1-x)/2*x between -53 and 92))
 )
/
-- 7489
-- no, too high

-- going back to the example
-- target area: x=20..30, y=-10..-5
create or replace view day17_example_v1 as
with x as (SELECT ROWNUM x FROM ALL_OBJECTS WHERE ROWNUM <= 30)
, y as (SELECT ROWNUM-10-1 y FROM ALL_OBJECTS WHERE ROWNUM <= (10-5+1))
, t as (SELECT ROWNUM t FROM ALL_OBJECTS WHERE ROWNUM <= 30)
select x,y,t from x,y,t;

select count(*)
from day17_example_v1
where 1=1 
 and (y*2+1-t)/2*t between -10 and -5
 and (
   (t<x and (x*2+1-t)/2*t between 20 and 30 )
   or (t>=x and ((x*2+1-x)/2*x between 20 and 30))
 )
/
-- 119, higher than 112

-- dups!
select count(*) from (
select unique x||','||y
from day17_example_v1
where 1=1 
 and (y*2+1-t)/2*t between -10 and -5
 and (
   (t<x and (x*2+1-t)/2*t between 20 and 30 )
   or (t>=x and ((x*2+1-x)/2*x between 20 and 30))
 )
)
/
-- 112


select count(*) from (
select unique x,y
from day17_part2_v1
where 1=1 
 and (y*2+1-t)/2*t between -53 and 92
 and (
   (t<x and (x*2+1-t)/2*t between 277 and 318 )
   or (t>=x and ((x*2+1-x)/2*x between 277 and 318))
 )
)
/
-- 9607, too high


-- it really really helps if you read the problem text correctly
create or replace view day17_part2_v1 as
with x as (SELECT ROWNUM x FROM ALL_OBJECTS WHERE ROWNUM <= 318)
, y as (SELECT ROWNUM-92-1 y FROM ALL_OBJECTS WHERE ROWNUM <= (92+92+1))
, t as (SELECT ROWNUM t FROM ALL_OBJECTS WHERE ROWNUM <= 318)
select x ivx, y ivy,t from x,y,t;

select count(*) from (
select unique ivx, ivy
from day17_part2_v1
where 1=1 
 and (ivy*2+1-t)/2*t between -92 and -53
 and ( (t<ivx  and (ivx*2+1-t)/2*t between 277 and 318)
       or
       (t>=ivx and (ivx+1)/2*ivx between 277 and 318)
      )
)
/
-- 2709
