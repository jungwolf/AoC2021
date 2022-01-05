drop table day12_part1;
drop sequence day12_line_sq;
create table day12_part1 (lineno number, linevalue varchar2(4000));
create sequence day12_line_sq;

insert into day12_part1 (lineno, linevalue) values (day12_line_sq.nextval,'yw-MN');
insert into day12_part1 (lineno, linevalue) values (day12_line_sq.nextval,'wn-XB');
insert into day12_part1 (lineno, linevalue) values (day12_line_sq.nextval,'DG-dc');
insert into day12_part1 (lineno, linevalue) values (day12_line_sq.nextval,'MN-wn');
insert into day12_part1 (lineno, linevalue) values (day12_line_sq.nextval,'yw-DG');
insert into day12_part1 (lineno, linevalue) values (day12_line_sq.nextval,'start-dc');
insert into day12_part1 (lineno, linevalue) values (day12_line_sq.nextval,'start-ah');
insert into day12_part1 (lineno, linevalue) values (day12_line_sq.nextval,'MN-start');
insert into day12_part1 (lineno, linevalue) values (day12_line_sq.nextval,'fi-yw');
insert into day12_part1 (lineno, linevalue) values (day12_line_sq.nextval,'XB-fi');
insert into day12_part1 (lineno, linevalue) values (day12_line_sq.nextval,'wn-ah');
insert into day12_part1 (lineno, linevalue) values (day12_line_sq.nextval,'MN-ah');
insert into day12_part1 (lineno, linevalue) values (day12_line_sq.nextval,'MN-dc');
insert into day12_part1 (lineno, linevalue) values (day12_line_sq.nextval,'end-yw');
insert into day12_part1 (lineno, linevalue) values (day12_line_sq.nextval,'fi-end');
insert into day12_part1 (lineno, linevalue) values (day12_line_sq.nextval,'th-fi');
insert into day12_part1 (lineno, linevalue) values (day12_line_sq.nextval,'end-XB');
insert into day12_part1 (lineno, linevalue) values (day12_line_sq.nextval,'dc-XB');
insert into day12_part1 (lineno, linevalue) values (day12_line_sq.nextval,'yw-XN');
insert into day12_part1 (lineno, linevalue) values (day12_line_sq.nextval,'wn-yw');
insert into day12_part1 (lineno, linevalue) values (day12_line_sq.nextval,'dc-ah');
insert into day12_part1 (lineno, linevalue) values (day12_line_sq.nextval,'MN-fi');
insert into day12_part1 (lineno, linevalue) values (day12_line_sq.nextval,'wn-DG');

commit;

create or replace view day12_part2_v1 as
select
  substr(linevalue,1,instr(linevalue,'-')-1) node1
  , substr(linevalue,instr(linevalue,'-')+1) node2
from day12_part1
/

select * from day12_part2_v1 order by node1, node2;

create or replace view day12_part2_v2 as
select node1, node2 from day12_part2_v1
union all
select node2, node1 from day12_part2_v1
/

select * from day12_part2_v2 order by node1, node2;

create or replace view day12_part2_v3 as
select node1, node2 from day12_part2_v2
where node1 != 'end' and node2 != 'start'
/

select * from day12_part2_v3 order by node1, node2;


select count(*) from (
  with t (node1,node2,lvl,current_path,numvisits,maxvisits) as (
    select node1, node2, 1 lvl
      ,case when node2=lower(node2) then node1||','||node2 else node1 end current_path
      , 0 numvisits
      , 0 maxvisits
    from day12_part2_v3
    where node1='start'

    union all

    select v3.node1, v3.node2, t.lvl+1
      , case when v3.node2=lower(v3.node2) then t.current_path||','||v3.node2 else t.current_path end
      , case when v3.node2=lower(v3.node2) then regexp_count(t.current_path||','||v3.node2,lower(v3.node2)) else 0 end
      , decode(t.maxvisits,2,2,t.numvisits) maxvisits
    from t, day12_part2_v3 v3
    where 1=1
      and t.node2=v3.node1
      and lvl = lvl
      and ( (t.numvisits < 2)
         or (t.numvisits = 2 and t.maxvisits < 2) )
  )
  select * from t
  where node2 = 'end'
)
/
-- 122134, taking 1m 34s.
