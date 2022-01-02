drop table day11_part1;
drop sequence day11_line_sq;
create table day11_part1 (lineno number, linevalue varchar2(4000));
create sequence day11_line_sq;

insert into day11_part1 (lineno, linevalue) values (day11_line_sq.nextval,'8271653836');
insert into day11_part1 (lineno, linevalue) values (day11_line_sq.nextval,'7567626775');
insert into day11_part1 (lineno, linevalue) values (day11_line_sq.nextval,'2315713316');
insert into day11_part1 (lineno, linevalue) values (day11_line_sq.nextval,'6542655315');
insert into day11_part1 (lineno, linevalue) values (day11_line_sq.nextval,'2453637333');
insert into day11_part1 (lineno, linevalue) values (day11_line_sq.nextval,'1247264328');
insert into day11_part1 (lineno, linevalue) values (day11_line_sq.nextval,'2325146614');
insert into day11_part1 (lineno, linevalue) values (day11_line_sq.nextval,'2115843171');
insert into day11_part1 (lineno, linevalue) values (day11_line_sq.nextval,'6182376282');
insert into day11_part1 (lineno, linevalue) values (day11_line_sq.nextval,'2384738675');
commit;
