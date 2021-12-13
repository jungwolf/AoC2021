-- same problem, just different day. Copy from part1.

-- will it work or will it overflow number?
with t (r0,r1,r2,r3,r4,r5,r6,r7,r8,totfish,theday) as (
    select
      f0 r0, f1 r1, f2 r2, f3 r3, f4 r4, f5 r5, f6 r6, f7 r7, f8 r8
      ,f0+f1+f2+f3+f4+f5+f6+f7+f8 totfish
      , 0 theday
    from day06_part1
    union all
    select
	  r1, r2, r3, r4, r5, r6, r7+r0, r8, r0
	, r1+r2+r3+r4+r5+r6+r7+r0+r8+r0
	, theday+1
    from t
    where theday <= 256
)
select * from t
where theday = 256
/

--It worked! 1595779846729



-- use a table to avoid the odd view behavior; this works outside of just  Oracle Live SQL.

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

create table day06_part1_t as select * from day06_part1;
select * from day06_part1_t;
desc day06_part1_t

with t (r0,r1,r2,r3,r4,r5,r6,r7,r8,totfish,theday) as (
    select
      f0 r0, f1 r1, f2 r2, f3 r3, f4 r4, f5 r5, f6 r6, f7 r7, f8 r8
      ,f0+f1+f2+f3+f4+f5+f6+f7+f8 totfish
      , 0 theday
    from day06_part1_t
    union all
    select
	  r1, r2, r3, r4, r5, r6, r7+r0, r8, r0
	, r1+r2+r3+r4+r5+r6+r7+r0+r8+r0
	, theday+1
    from t
    where theday <= 256
)
select * from t
where theday in (80,256)
/
