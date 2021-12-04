select * from day03_example order by lineno;
/*
LINENO	LINEVALUE
1	00100
2	11110
3	10110
4	10111
5	10101
6	01111
7	00111
8	11100
9	10000
10	11001
11	00010
12	01010
*/

-- let's see if the small test works on the example set

create or replace view d03_example_v1 as
with t (lineno, position, linevalue, digit, remainder) as (
select lineno, 1 position, linevalue, substr(linevalue,1,1) digit, substr(linevalue,2) remainder from day03_example
union all
select lineno, position+1 , linevalue, substr(remainder,1,1) digit, substr(remainder,2) remainder from t
where remainder is not null
)
select * from t
;
select * from d03_example_v1 order by lineno, position;
-- it looks right. next one

create or replace view d03_example_v2 as
select lineno, position, decode(digit, '1',1, '0',-1) negative_means_0 from d03_example_v1;
select * from d03_example_v2 order by lineno, position;
-- it looks right. next one

create or replace view d03_example_v3 as
select position, decode(sign(sum(negative_means_0)), 1,1, -1,0) digit
from d03_example_v2
group by position;
select * from d03_example_v3 order by position;
-- so far, so good

create or replace view d03_example_v4 as
select sum(power(2,pwr)) gamma, max(pwr) for_epsilon from (
  select digit, rownum-1 pwr from (
    select digit from d03_example_v3 order by position
  )
)
where digit = 1
/
select * from d03_example_v4;
-- this is where it goes wrong

  select digit, rownum-1 pwr from (
    select digit from d03_example_v3 order by position
  )
/
-- ah! forgot to reverse position
  select digit, rownum-1 pwr from (
    select digit from d03_example_v3 order by position desc
  )
/


create or replace view d03_example_v4 as
select sum(power(2,pwr)) gamma, max(pwr)+1 for_epsilon from (
  select digit, rownum-1 pwr from (
    select digit from d03_example_v3 order by position desc
  )
)
where digit = 1
/
select * from d03_example_v4;


select gamma, epsilon, gamma*epsilon answer from (
select gamma, power(2,for_epsilon)-gamma-1 epsilon
from d03_example_v4
);

-- hmm, all the powers off by one stuff looks fragile
-- I'll try again

create or replace view d03_example_v3 as
select position
 , decode(sign(sum(negative_means_0)), 1,1, -1,0) digitforgamma
 , decode(sign(sum(negative_means_0)), 1,0, -1,1) digitforepsilon
from d03_example_v2
group by position;
select * from d03_example_v3 order by position;

create or replace view d03_example_v4 as
select sum(power(2,pwr)*digitforgamma) gamma, sum(power(2,pwr)*digitforepsilon) epsilon from (
  select digitforgamma, digitforepsilon, rownum-1 pwr from (
    select digitforgamma, digitforepsilon from d03_example_v3 order by position desc
  )
)
/
select * from d03_example_v4;

select gamma, epsilon, gamma*epsilon answer from d03_example_v4;
