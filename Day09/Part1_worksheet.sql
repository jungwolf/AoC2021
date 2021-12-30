create or replace view day09_part1_1 as
select e.lineno y, n.rn x, n.cv value
from day09_part1 e
  ,lateral(select column_value cv, rownum rn from table( string2rows(e.linevalue))) n
;

create or replace view day09_part1_2 as
select x
  ,y
  ,value
  ,value-lag(value) over (partition by y order by x) diff_pre_x
  ,value-lag(value) over (partition by y order by x desc) diff_post_x
  ,value-lag(value) over (partition by x order by y) diff_pre_y
  ,value-lag(value) over (partition by x order by y desc) diff_post_y
from day09_part1_1
/

select sum(value+1)
from day09_part1_2
where nvl(diff_pre_x,-1) < 0
  and nvl(diff_pre_y,-1) < 0
  and nvl(diff_post_x,-1) < 0
  and nvl(diff_post_y,-1) < 0
order by y,x
/
