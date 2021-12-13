create or replace view day07_example_v1 as
with input as (select '16,1,2,0,4,2,7,1,2,14' value from dual)
select to_number(regexp_substr(value,'[^,]+', 1, level)) item from input
connect by regexp_substr(value, '[^,]+', 1, level) is not null;

select * from day07_example_v1;
select min(item) from day07_example_v1;
select max(item) from day07_example_v1;

with minmax as (select min(item) minvalue, max(item) maxvalue from day07_example_v1)
select * from minmax;

with minmax as (select min(item) minvalue, max(item) maxvalue from day07_example_v1)
, t (position,maxposition) as (
    select minvalue position, maxvalue maxposition from minmax
    union all
	select position+1, maxposition from t
	where position<maxposition
	)
select * from t;


with minmax as (select min(item) minvalue, max(item) maxvalue from day07_example_v1)
, t (position,maxposition) as (
    select minvalue position, maxvalue maxposition from minmax
    union all
	select position+1, maxposition from t
	where position<maxposition
	)
select position, item from t, day07_example_v1;


create or replace view day07_example_v2 as
select item, count(*) the_count from day07_example_v1 group by item;

with minmax as (select min(item) minvalue, max(item) maxvalue from day07_example_v2)
, t (position,maxposition) as (
    select minvalue position, maxvalue maxposition from minmax
    union all
	select position+1, maxposition from t
	where position<maxposition
	)
select * from t;

create or replace view day07_example_v3 as
with minmax as (select min(item) minvalue, max(item) maxvalue from day07_example_v2)
, t (destination,maxposition) as (
    select minvalue destination, maxvalue maxposition from minmax
    union all
	select destination+1, maxposition from t
	where destination<maxposition
	)
select destination, item position, the_count from t,day07_example_v2;
select * from day07_example_v3;

select destination, position, the_count, abs(destination-position)*the_count fuel from day07_example_v3;

select destination, sum(abs(destination-position)*the_count) fuel 
from day07_example_v3
group by destination
order by fuel ;

select destination, sum(abs(destination-position)*the_count) fuel 
from day07_example_v3
group by destination
order by fuel fetch first 1 rows only;
-- answer only
