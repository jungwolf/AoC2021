/*
target area: x=277..318, y=-92..-53
generate the candidates.
For various reasons while working through part 1, I named the initial velocities ivx and ivy.
The maximum legal initial x velocity hits the edge of the box at 318. I'm pretty sure I can find the minimum value that can reach 277 but I'm happy with the DB figuring that out.
The maximum legal initial y velocity also hits the farthest edge of the box. Up mirrors down so I'll just run through the full range, abs(-92) down to -92.
At most, ivy 92 will take 92 steps up, 92 back to y=0, and then vy=-93 so next goes past the box. t up to 318 is overkill.
*/
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

