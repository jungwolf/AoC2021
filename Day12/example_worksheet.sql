select * from day12_example;

-- treat each cave as a node and the connects as edges
-- actually, let's make that directed links, it ends up being easier then trying to have special node1<->node2 logic
-- union (all) the two different orders

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


select level
, node1, node2
,sys_connect_by_path(node1,'/')
,sys_connect_by_path(node1,'/')||'/'||node2 full_path
from day12_example_v1
start with node1='start'
connect by nocycle node1 = prior node2;

select * from (
select level
, node1, node2
,sys_connect_by_path(node1,'/')
,sys_connect_by_path(node1,'/')||'/'||node2 full_path
from day12_example_v1
start with node1='start'
connect by nocycle node1 = prior node2
)
where node2 = 'end';

with t (node1,node2,lvl,current_path) as (
  select node1, node2, 1 lvl, node1 current_path
  from day12_example_v2
  union all
  select '-','-',0,'-'
  from t
  where 0=1
)
select * from t;

with t (node1,node2,lvl,current_path) as (
  select node1, node2, 1 lvl, node1||','||node2 current_path
  from day12_example_v2
  where node1='start'

  union all

  select v2.node1,v2.node2,t.lvl+1,t.current_path||','||v2.node2
  from t, day12_example_v2 v2
  where t.node2=v2.node1 and lvl < 3
)
select * from t;

with t (node1,node2,lvl,current_path) as (
  select node1, node2, 1 lvl, node1||','||node2 current_path
  from day12_example_v2
  where node1='start'

  union all

  select v2.node1,v2.node2,t.lvl+1,t.current_path||','||v2.node2
  from t, day12_example_v2 v2
  where t.node2=v2.node1 and lvl < 3
  and not (v2.node2=lower(v2.node2) and instr(t.current_path,v2.node2)>0)
)
select * from t;

with t (node1,node2,lvl,current_path) as (
  select node1, node2, 1 lvl, node1||','||node2 current_path
  from day12_example_v2
  where node1='start'

  union all

  select v2.node1,v2.node2,t.lvl+1,t.current_path||','||v2.node2
  from t, day12_example_v2 v2
  where t.node2=v2.node1 and lvl < 8
  and not (v2.node2=lower(v2.node2) and instr(t.current_path,v2.node2)>0)
)
select * from t;

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




---------------------------------------------------
drop table day12_example;
drop sequence day12_line_sq;
create table day12_example (lineno number, linevalue varchar2(4000));
create sequence day12_line_sq;

insert into day12_example (lineno, linevalue) values (day12_line_sq.nextval,'dc-end');
insert into day12_example (lineno, linevalue) values (day12_line_sq.nextval,'HN-start');
insert into day12_example (lineno, linevalue) values (day12_line_sq.nextval,'start-kj');
insert into day12_example (lineno, linevalue) values (day12_line_sq.nextval,'dc-start');
insert into day12_example (lineno, linevalue) values (day12_line_sq.nextval,'dc-HN');
insert into day12_example (lineno, linevalue) values (day12_line_sq.nextval,'LN-dc');
insert into day12_example (lineno, linevalue) values (day12_line_sq.nextval,'HN-end');
insert into day12_example (lineno, linevalue) values (day12_line_sq.nextval,'kj-sa');
insert into day12_example (lineno, linevalue) values (day12_line_sq.nextval,'kj-HN');
insert into day12_example (lineno, linevalue) values (day12_line_sq.nextval,'kj-dc');
commit;


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
create or replace view day12_example_v2 as
select * from day12_example_v1 where node1 != 'end' and node2 != 'start';
select * from day12_example_v2;

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

-- 19 paths, correct




---------------------------------------------------
drop table day12_example;
drop sequence day12_line_sq;
create table day12_example (lineno number, linevalue varchar2(4000));
create sequence day12_line_sq;

insert into day12_example (lineno, linevalue) values (day12_line_sq.nextval,'fs-end');
insert into day12_example (lineno, linevalue) values (day12_line_sq.nextval,'he-DX');
insert into day12_example (lineno, linevalue) values (day12_line_sq.nextval,'fs-he');
insert into day12_example (lineno, linevalue) values (day12_line_sq.nextval,'start-DX');
insert into day12_example (lineno, linevalue) values (day12_line_sq.nextval,'pj-DX');
insert into day12_example (lineno, linevalue) values (day12_line_sq.nextval,'end-zg');
insert into day12_example (lineno, linevalue) values (day12_line_sq.nextval,'zg-sl');
insert into day12_example (lineno, linevalue) values (day12_line_sq.nextval,'zg-pj');
insert into day12_example (lineno, linevalue) values (day12_line_sq.nextval,'pj-he');
insert into day12_example (lineno, linevalue) values (day12_line_sq.nextval,'RW-he');
insert into day12_example (lineno, linevalue) values (day12_line_sq.nextval,'fs-DX');
insert into day12_example (lineno, linevalue) values (day12_line_sq.nextval,'pj-RW');
insert into day12_example (lineno, linevalue) values (day12_line_sq.nextval,'zg-RW');
insert into day12_example (lineno, linevalue) values (day12_line_sq.nextval,'start-pj');
insert into day12_example (lineno, linevalue) values (day12_line_sq.nextval,'he-WI');
insert into day12_example (lineno, linevalue) values (day12_line_sq.nextval,'zg-he');
insert into day12_example (lineno, linevalue) values (day12_line_sq.nextval,'pj-fs');
insert into day12_example (lineno, linevalue) values (day12_line_sq.nextval,'start-RW');


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

-- 226 paths, correct
