drop table day10_example;
drop sequence day10_line_sq;
create table day10_example (lineno number, linevalue varchar2(4000));
create sequence day10_line_sq;

insert into day10_example (lineno, linevalue) values (day10_line_sq.nextval,'[({(<(())[]>[[{[]{<()<>>');
insert into day10_example (lineno, linevalue) values (day10_line_sq.nextval,'[(()[<>])]({[<{<<[]>>(');
insert into day10_example (lineno, linevalue) values (day10_line_sq.nextval,'{([(<{}[<>[]}>{[]{[(<()>');
insert into day10_example (lineno, linevalue) values (day10_line_sq.nextval,'(((({<>}<{<{<>}{[]{[]{}');
insert into day10_example (lineno, linevalue) values (day10_line_sq.nextval,'[[<[([]))<([[{}[[()]]]');
insert into day10_example (lineno, linevalue) values (day10_line_sq.nextval,'[{[{({}]{}}([{[{{{}}([]');
insert into day10_example (lineno, linevalue) values (day10_line_sq.nextval,'{<[[]]>}<{[{[{[]{()[[[]');
insert into day10_example (lineno, linevalue) values (day10_line_sq.nextval,'[<(<(<(<{}))><([]([]()');
insert into day10_example (lineno, linevalue) values (day10_line_sq.nextval,'<{([([[(<>()){}]>(<<{{');
insert into day10_example (lineno, linevalue) values (day10_line_sq.nextval,'<{([{{}}[<[[[<>{}]]]>[]]');
commit;

