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
