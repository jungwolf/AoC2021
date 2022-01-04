drop table day12_example;
drop sequence day12_line_sq;
create table day12_example (lineno number, linevalue varchar2(4000));
create sequence day12_line_sq;

insert into day12_example (lineno, linevalue) values (day12_line_sq.nextval,'start-A');
insert into day12_example (lineno, linevalue) values (day12_line_sq.nextval,'start-b');
insert into day12_example (lineno, linevalue) values (day12_line_sq.nextval,'A-c');
insert into day12_example (lineno, linevalue) values (day12_line_sq.nextval,'A-b');
insert into day12_example (lineno, linevalue) values (day12_line_sq.nextval,'b-d');
insert into day12_example (lineno, linevalue) values (day12_line_sq.nextval,'A-end');
insert into day12_example (lineno, linevalue) values (day12_line_sq.nextval,'b-end');
commit;
