create or replace view day12_part1_v1 as
select substr(linevalue,1,instr(linevalue,'-')-1) node1
  , substr(linevalue,instr(linevalue,'-')+1) node2
from day12_part1
union all
select substr(linevalue,instr(linevalue,'-')+1) node1
  , substr(linevalue,1,instr(linevalue,'-')-1) node2
from day12_part1
/
select * from day12_part1_v1;

-- only allow moving away from start and entering end
create or replace view day12_part1_v2 as
select * from day12_part1_v1 where node1 != 'end' and node2 != 'start';
select * from day12_part1_v2;

with t (node1,node2,lvl,current_path) as (
  select node1, node2, 1 lvl, node1||','||node2 current_path
  from day12_part1_v2
  where node1='start'

  union all

  select v2.node1,v2.node2,t.lvl+1,t.current_path||','||v2.node2
  from t, day12_part1_v2 v2
  where t.node2=v2.node1
  -- and lvl < 8 -- prevent runaway...
  and not (v2.node2=lower(v2.node2) and instr(t.current_path,v2.node2)>0)
)
select * from t
where node2 = 'end'
order by current_path;

-- 4241 rows
