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
  substr(linevalue,1,instr(linevalue,'-')-1) cave1
  , substr(linevalue,instr(linevalue,'-')+1) cave2
from day12_part1
/

select * from day12_part2_v1 order by cave1, cave2;

create or replace view day12_part2_v2 as
select cave1 cave, cave2 next_cave from day12_part2_v1
union all
select cave2, cave1 from day12_part2_v1
/

select * from day12_part2_v2 order by cave, next_cave;

create or replace view day12_part2_v3 as
select cave, next_cave from day12_part2_v2
where cave != 'end' and next_cave != 'start'
/

select * from day12_part2_v3 order by cave, next_cave;


select count(*) from (
  with t (cave,next_cave,lvl,current_path,numvisits,maxvisits) as (
    select cave, next_cave, 1 lvl
      ,case when next_cave=lower(next_cave) then cave||','||next_cave else cave end current_path
      , 0 numvisits
      , 0 maxvisits
    from day12_part2_v3
    where cave='start'

    union all

    select v3.cave, v3.next_cave, t.lvl+1
      , case when v3.next_cave=lower(v3.next_cave) then t.current_path||','||v3.next_cave else t.current_path end
      , case when v3.next_cave=lower(v3.next_cave) then regexp_count(t.current_path,v3.next_cave)+1 else 0 end
      , decode(t.maxvisits,2,2,t.numvisits) maxvisits
    from t, day12_part2_v3 v3
    where 1=1
      and t.next_cave=v3.cave
      and lvl = lvl
      and ( (t.numvisits < 2)
         or (t.numvisits = 2 and t.maxvisits < 2) )
  )
  select * from t
  where next_cave = 'end'
)
/
-- 122134, taking 1m 34s.
select * from table(dbms_xplan.display_cursor());
