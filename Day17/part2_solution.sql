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

