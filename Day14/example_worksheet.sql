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
etc
*/

-- first step, find the first template pair and match to basepair
-- plus set up extra information to iterate
with t as (select template from day14_polymer_template)
select t.template
  , substr(t.template,1,2) t_pair
  , pi.basepair
  , pi.newchar
  , substr(t.template,2) new_template
  , substr(t.template,1,1) || pi.newchar new_string
from t, day14_pair_insertion pi
where substr(t.template,1,2) = pi.basepair
/


-- iterate!
with 
  t as (select template from day14_polymer_template)
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
select new_string||new_template from q
order by length(new_string) desc fetch first 1 rows only;

-- but... now I need to iterate over that...
-- I don't know of a good way to continue. It isn't a function where I can replace t with the new value...
-- 19c has sql macros but I don't know how to use them yet; not ready to dive into them yet.

