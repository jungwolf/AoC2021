-- bigger and better!
select * from day14_example;

-- could do lineno = 1 but this one doesn't assume the sequence starts with 1
create or replace view day14_polymer_template as
select linevalue template from day14_example
order by lineno fetch first 1 rows only;

select * from day14_polymer_template;
-- NNCB

create or replace view day14_pair_insertion as
select 
  substr(linevalue,1,2) basepair
  , substr(linevalue,length('XX -> ')+1,1) newchar
from day14_example
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

exec day14_process_polymer(10);

select * from day14_polymer_template_t;
-- the output is very long

select column_value, count(*) 
from table(select string2rows(template) from day14_polymer_template_t) 
group by column_value;
/*
B	1749
C	298
H	161
N	865
*/
select column_value
  ,the_count
  ,min(the_count) over () first
  ,max(the_count) over () last
  , max(the_count) over () - min(the_count) over () diff 
from ( 
select column_value, count(*) the_count
from table(select string2rows(template) from day14_polymer_template_t) 
group by column_value
);

/*
B	1749	161	1749	1588
C	298	161	1749	1588
H	161	161	1749	1588
N	865	161	1749	1588
*/
-- 1588 it is

