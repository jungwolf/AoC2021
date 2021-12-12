with a as (select '3,4,3,1,2' from dual)
select * from a;

-- change line containing individual fish to count of fish in a state
-- input is just a single string so I'm skipping the "table as file input" stage
-- simple built-in regex function that counts matches
-- HUGE limitation is the ability to dynamically declare the number of columns in a view

create or replace view day06_example as
with a as (select '3,4,3,1,2' value from dual)
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

-- select the original row values from input
-- theday starts with 0, based on the problem description
-- totfish probably should have gone into the main select clause; it isn't needed for the recursive view work
with t (r0,r1,r2,r3,r4,r5,r6,r7,r8,totfish,theday) as (
    select
      f0 r0, f1 r1, f2 r2, f3 r3, f4 r4, f5 r5, f6 r6, f7 r7, f8 r8
      ,f0+f1+f2+f3+f4+f5+f6+f7+f8 totfish
      , 0 theday
    from day06_example
    union all
    select
	  r1, r2, r3, r4, r5, r6, r7+r0, r8, r0
	, r1+r2+r3+r4+r5+r6+r7+r0+r8+r0
	, theday+1
    from t
    where theday <= 100
)
select * from t
where theday = 80
/
