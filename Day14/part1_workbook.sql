-- bigger and better!
-- except it doesn't work because the resulting string goes over 4000 characters.
-- I knew that would happen once I saw the input, but I had to try anyway.
-- hmm, maybe I can get it to work with an easy change to clob
-- probably not, but let's see

-- no, that didn't work; pl/sql can handle up to 32k varchar2 but the sql engine still thinks that's unreasonable.
-- new prcedure at the bottom if you are interested.

select * from day14_part1;

-- could do lineno = 1 but this one doesn't assume the sequence starts with 1
create or replace view day14_polymer_template as
select linevalue template from day14_part1
order by lineno fetch first 1 rows only;

select * from day14_polymer_template;
-- NNCB

create or replace view day14_pair_insertion as
select 
  substr(linevalue,1,2) basepair
  , substr(linevalue,length('XX -> ')+1,1) newchar
from day14_part1
where instr(linevalue,'->') > 0
/
select * from day14_pair_insertion;
/*
CH	B
HH	N
CB	H
NH	C
etc.
*/

-- I used a recursive query to build the result for 1 step. But then I couldn't figure out how to repeat that for the next step.
-- I didn't want to waste that effort so I threw it into a procedure.
-- It runs the sql interation times

-- create a real table so I can put the results back into it.
drop table day14_polymer_template_t;
create table day14_polymer_template_t as
select * from day14_polymer_template;
commit;

create or replace procedure day14_process_polymer(interations number) as
  new_polymer varchar2(4000);
begin
  for i in 1..interations loop
    with 
      t as (select template from day14_polymer_template_t)
    , q (template,t_pair,basepair,newchar,new_template,new_string) as (
        select t.template
          , substr(t.template,1,2) t_pair
          , pi.basepair
          , pi.newchar
          , substr(t.template,2) new_template
          , substr(t.template,1,1) || pi.newchar new_string
        from t, day14_pair_insertion pi
        where substr(t.template,1,2) = pi.basepair
        union all
        select q.new_template
          ,substr(q.new_template,1,2)
          , pi.basepair
          , pi.newchar
          , substr(q.new_template,2)
          , q.new_string || substr(q.new_template,1,1) || pi.newchar
        from q, day14_pair_insertion pi
        where substr(q.new_template,1,2) = pi.basepair
    )
    select new_string||new_template into new_polymer from q
    order by length(new_string) desc fetch first 1 rows only;

    update day14_polymer_template_t set template = new_polymer;
  end loop;
  commit;
end;
/

drop table day14_polymer_template_t;
create table day14_polymer_template_t as
select * from day14_polymer_template;
commit;

-- ok
exec day14_process_polymer(7);
-- error!
exec day14_process_polymer(8);











drop table day14_polymer_template_t;
create table day14_polymer_template_t (template clob);
insert into day14_polymer_template_t 
select template from day14_polymer_template;
commit;
select template from day14_polymer_template_t;

create or replace procedure day14_process_polymer(interations number) as
  new_polymer varchar2(30000);
begin
  select template into new_polymer from day14_polymer_template_t;
  for i in 1..interations loop
    with 
      t as (select new_polymer template from dual)
    , q (template,t_pair,basepair,newchar,new_template,new_string) as (
        select t.template
          , substr(t.template,1,2) t_pair
          , pi.basepair
          , pi.newchar
          , substr(t.template,2) new_template
          , substr(t.template,1,1) || pi.newchar new_string
        from t, day14_pair_insertion pi
        where substr(t.template,1,2) = pi.basepair
        union all
        select q.new_template
          ,substr(q.new_template,1,2)
          , pi.basepair
          , pi.newchar
          , substr(q.new_template,2)
          , q.new_string || substr(q.new_template,1,1) || pi.newchar
        from q, day14_pair_insertion pi
        where substr(q.new_template,1,2) = pi.basepair
    )
    select new_string||new_template into new_polymer from q
    order by length(new_string) desc fetch first 1 rows only;

    update day14_polymer_template_t set template = new_polymer;
  end loop;
  commit;
end;
/

exec day14_process_polymer(10);
/*
[Error] Execution (86: 1): ORA-01489: result of string concatenation is too long
ORA-06512: at "xxx.DAY14_PROCESS_POLYMER", line 6
ORA-06512: at line 1
*/
