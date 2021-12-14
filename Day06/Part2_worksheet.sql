-- same problem, just different day.
-- fishies have a simple rotating lifecycle: 6..0 -> give birth -> 6..0, etc. A newborn catches its breath for two days: 8..0 -> birth -> 6..0, etc.
-- nine states, so track the number of fishies at the same state.

-- parse the input string
-- this barely works, the string is not quite 4000 characters

-- when regex is this easy it is a crime not to use it. The regex match strings are '0', '4', etc.
-- simple helper view to keep me from having to print '3.....4' mulitple times
--     with a as (select '3...4' value from dual)
	   
create or replace view day06_part1 as
with a as (select '3,5,1,5,3,2,1,3,4,2,5,1,3,3,2,5,1,3,1,5,5,1,1,1,2,4,1,4,5,2,1,2,4,3,1,2,3,4,3,4,4,5,1,1,1,1,5,5,3,4,4,4,5,3,4,1,4,3,3,2,1,1,3,3,3,2,1,3,5,2,3,4,2,5,4,5,4,4,2,2,3,3,3,3,5,4,2,3,1,2,1,1,2,2,5,1,1,4,1,5,3,2,1,4,1,5,1,4,5,2,1,1,1,4,5,4,2,4,5,4,2,4,4,1,1,2,2,1,1,2,3,3,2,5,2,1,1,2,1,1,1,3,2,3,1,5,4,5,3,3,2,1,1,1,3,5,1,1,4,4,5,4,3,3,3,3,2,4,5,2,1,1,1,4,2,4,2,2,5,5,5,4,1,1,5,1,5,2,1,3,3,2,5,2,1,2,4,3,3,1,5,4,1,1,1,4,2,5,5,4,4,3,4,3,1,5,5,2,5,4,2,3,4,1,1,4,4,3,4,1,3,4,1,1,4,3,2,2,5,3,1,4,4,4,1,3,4,3,1,5,3,3,5,5,4,4,1,2,4,2,2,3,1,1,4,5,3,1,1,1,1,3,5,4,1,1,2,1,1,2,1,2,3,1,1,3,2,2,5,5,1,5,5,1,4,4,3,5,4,4' value from dual)
select
REGEXP_COUNT (value,'0') f0
,REGEXP_COUNT (value,'1') f1
,REGEXP_COUNT (value,'2') f2
,REGEXP_COUNT (value,'3') f3
,REGEXP_COUNT (value,'4') f4
,REGEXP_COUNT (value,'5') f5
,REGEXP_COUNT (value,'6') f6
,REGEXP_COUNT (value,'7') f7
,REGEXP_COUNT (value,'8') f8
from a;


-- use a table to avoid the odd view behavior;

create table day06_part1_t as select * from day06_part1;
select * from day06_part1_t;
/*
F0	F1	F2	F3	F4	F5	F6	F7	F8
0	83	51	56	60	50	0	0	0
*/

-- sorry about the terrible names
-- the process is simple
-- given row n, generate row n+1 by shifting each column right (r8 goes to r7, r7 goes to r6, ... r1 goes to r0), but r8 and r6 are special.
--   Also, parents are "returned" as r6. So, r6 is really (r7+r0).
with t (r0,r1,r2,r3,r4,r5,r6,r7,r8,theday) as (
  select
    f0 r0, f1 r1, f2 r2, f3 r3, f4 r4, f5 r5, f6 r6, f7 r7, f8 r8
    , 0 theday
  from day06_part1_t
  union all
  select
    r1, r2, r3, r4, r5, r6, r7+r0, r8, r0
    , theday+1
  from t
  where theday <= 256
)
select theday
  , r0+r1+r2+r3+r4+r5+r6+r7+r8 fishies  from t
where theday in (80,256)
/

-- luckily number type can handle larger numbers; one of the reasons general computing is slower on a DB but it helps reduce the likelihood of silently truncating data; safety first!

