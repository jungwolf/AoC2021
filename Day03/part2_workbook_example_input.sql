-- I'm already pulling things apart in ways that seem helpful. So, hopefully this will be easy. Ha!

create or replace view d03_example2_v1 as
with t (lineno, position, linevalue, digit, remainder) as (
select lineno, 1 position, linevalue, substr(linevalue,1,1) digit, substr(linevalue,2) remainder from day03_example
union all
select lineno, position+1 , linevalue, substr(remainder,1,1) digit, substr(remainder,2) remainder from t
where remainder is not null
)
select * from t
;

-- look at it from the position point of view
select * from d03_example2_v1 order by position, lineno;

-- well, time to get analytical again

select lineno,position,linevalue,digit,remainder from d03_example2_v1;
