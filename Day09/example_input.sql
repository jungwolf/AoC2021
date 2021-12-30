drop table day09_example;
drop sequence day09_line_sq;
create table day09_example (lineno number, linevalue varchar2(4000));
create sequence day09_line_sq;


insert into day09_example (lineno, linevalue) values (day09_line_sq.nextval,'2199943210');
insert into day09_example (lineno, linevalue) values (day09_line_sq.nextval,'3987894921');
insert into day09_example (lineno, linevalue) values (day09_line_sq.nextval,'9856789892');
insert into day09_example (lineno, linevalue) values (day09_line_sq.nextval,'8767896789');
insert into day09_example (lineno, linevalue) values (day09_line_sq.nextval,'9899965678');
commit;
