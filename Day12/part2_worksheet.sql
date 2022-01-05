create or replace view day12_example_v1 as
select substr(linevalue,1,instr(linevalue,'-')-1) node1
  , substr(linevalue,instr(linevalue,'-')+1) node2
from day12_example
union all
select substr(linevalue,instr(linevalue,'-')+1) node1
  , substr(linevalue,1,instr(linevalue,'-')-1) node2
from day12_example
/
select * from day12_example_v1;

-- only allow moving away from start and entering end
create or replace view day12_example_v2 as
select * from day12_example_v1 where node1 != 'end' and node2 != 'start';
select * from day12_example_v2;


-- this used to work, but now not (v2.node2=lower(v2.node2) and instr(t.current_path,v2.node2)>0) isn't permissive enough
-- one and only one lower letter cave can be visited twice
with t (node1,node2,lvl,current_path) as (
  select node1, node2, 1 lvl, node1||','||node2 current_path
  from day12_example_v2
  where node1='start'

  union all

  select v2.node1,v2.node2,t.lvl+1,t.current_path||','||v2.node2
  from t, day12_example_v2 v2
  where t.node2=v2.node1
  -- and lvl < 8 -- prevent runaway...
  and not (v2.node2=lower(v2.node2) and instr(t.current_path,v2.node2)>0)
)
select * from t
where node2 = 'end'
order by current_path;

-- maybe track once a lower cave was visited twice?

with t (node1,node2,lvl,current_path,twovisits) as (
  select node1, node2, 1 lvl, node1||','||node2 current_path, 0 twovisits
  from day12_example_v2
  where node1='start'

  union all

  select
    v2.node1
    ,v2.node2
    ,t.lvl+1
    ,t.current_path||','||v2.node2
--    ,instr(t.current_path,v2.node2) twovisits
    ,regexp_count(t.current_path,v2.node2) twovisits
  from t, day12_example_v2 v2
  where t.node2=v2.node1
--  and lvl < 5 -- prevent runaway...
  and not (v2.node2=lower(v2.node2) and regexp_count(t.current_path,v2.node2)>0)
)
select * from t
where node2 = 'end'
order by current_path;

-- probably needd something like case(maxvisits,2,2,1,regx...,0,regx...)...

-- things got a little nutty
-- 122134, taking 1m 34s.
select count(*) from (
with t (node1,node2,lvl,current_path,numvisits,maxvisits) as (
  select node1, node2, 1 lvl
--    , node1||','||node2 current_path
,case when node2=lower(node2) then node1||','||node2 else node1 end current_path
    , 0 numvisits, 0 maxvisits
  from day12_part1_v2
  where node1='start'

  union all

  select
    v2.node1
    ,v2.node2
    ,t.lvl+1
--    ,t.current_path||','||v2.node2
, case when v2.node2=lower(v2.node2) then t.current_path||','||v2.node2 else t.current_path end
--    ,regexp_count(t.current_path||','||v2.node2,lower(v2.node2)) numvisits
, case when v2.node2=lower(v2.node2) then regexp_count(t.current_path||','||v2.node2,lower(v2.node2)) else 0 end
    ,decode(t.maxvisits,2,2,t.numvisits) maxvisits
  from t, day12_part1_v2 v2
  where 1=1
    and t.node2=v2.node1
    and lvl = lvl
--    and lvl < 15
--  and lvl < 11000 -- prevent runaway...
    and ( (t.numvisits < 2) or (t.numvisits = 2 and t.maxvisits < 2) )
)
select * from t
where node2 = 'end'
--where lvl=9
)
/
-- 122134
