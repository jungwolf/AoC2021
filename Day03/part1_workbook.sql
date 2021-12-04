select * from day03_part1 order by lineno;

-- let's see if the example process works on part1
-- spoiler, it does!

create or replace view d03_part1_v1 as
with t (lineno, position, linevalue, digit, remainder) as (
select lineno, 1 position, linevalue, substr(linevalue,1,1) digit, substr(linevalue,2) remainder from day03_part1
union all
select lineno, position+1 , linevalue, substr(remainder,1,1) digit, substr(remainder,2) remainder from t
where remainder is not null
)
select * from t
;
select * from d03_part1_v1 order by lineno, position;
-- it looks right. next one

create or replace view d03_part1_v2 as
select lineno, position, decode(digit, '1',1, '0',-1) negative_means_0 from d03_part1_v1;
select * from d03_part1_v2 order by lineno, position;
-- it looks right. next one


create or replace view d03_part1_v3 as
select position
 , decode(sign(sum(negative_means_0)), 1,1, -1,0) digitforgamma
 , decode(sign(sum(negative_means_0)), 1,0, -1,1) digitforepsilon
from d03_part1_v2
group by position;
select * from d03_part1_v3 order by position;

create or replace view d03_part1_v4 as
select sum(power(2,pwr)*digitforgamma) gamma, sum(power(2,pwr)*digitforepsilon) epsilon from (
  select digitforgamma, digitforepsilon, rownum-1 pwr from (
    select digitforgamma, digitforepsilon from d03_part1_v3 order by position desc
  )
)
/

select gamma, epsilon, gamma*epsilon answer from d03_part1_v4;
/*
GAMMA	EPSILON	ANSWER
2663	1432	3813416
*/
