drop table day11_example;
drop sequence day11_line_sq;
create table day11_example (lineno number, linevalue varchar2(4000));
create sequence day11_line_sq;


insert into day11_example (lineno, linevalue) values (day11_line_sq.nextval,'5483143223');
insert into day11_example (lineno, linevalue) values (day11_line_sq.nextval,'2745854711');
insert into day11_example (lineno, linevalue) values (day11_line_sq.nextval,'5264556173');
insert into day11_example (lineno, linevalue) values (day11_line_sq.nextval,'6141336146');
insert into day11_example (lineno, linevalue) values (day11_line_sq.nextval,'6357385478');
insert into day11_example (lineno, linevalue) values (day11_line_sq.nextval,'4167524645');
insert into day11_example (lineno, linevalue) values (day11_line_sq.nextval,'2176841721');
insert into day11_example (lineno, linevalue) values (day11_line_sq.nextval,'6882881134');
insert into day11_example (lineno, linevalue) values (day11_line_sq.nextval,'4846848554');
insert into day11_example (lineno, linevalue) values (day11_line_sq.nextval,'5283751526');

commit;
