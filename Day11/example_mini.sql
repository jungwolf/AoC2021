drop table day11_mini;
drop sequence day11_line_sq;
create table day11_mini (lineno number, linevalue varchar2(4000));
create sequence day11_line_sq;

insert into day11_mini (lineno, linevalue) values (day11_line_sq.nextval,'11111');
insert into day11_mini (lineno, linevalue) values (day11_line_sq.nextval,'19991');
insert into day11_mini (lineno, linevalue) values (day11_line_sq.nextval,'19191');
insert into day11_mini (lineno, linevalue) values (day11_line_sq.nextval,'19991');
insert into day11_mini (lineno, linevalue) values (day11_line_sq.nextval,'11111');
commit;


select * from day11_mini;

select * from day11_mini;
create or replace view day11_mini_1 as
select e.lineno y, n.rn x, n.cv value
from day11_mini e
  ,lateral(select column_value cv, rownum rn from table( string2rows(e.linevalue))) n
;
select x,y,value,'N' flashed from day11_mini_1;
select level
from dual
connect by level = prior level
where level < 10;


with a as (select rownum-2 delta from (SELECT LEVEL just_a_column FROM dual CONNECT BY LEVEL <= 3))
select x.delta, y.delta from a x,a y where not (x.delta=0 and y.delta=0);
