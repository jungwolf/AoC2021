-- let's try something smaller
drop table d03_test;
drop sequence day03_line_sq;
create table d03_test (lineno number, linevalue varchar2(4000));
create sequence day03_line_sq;

insert into d03_test (lineno, linevalue) values (day03_line_sq.nextval,'001');
insert into d03_test (lineno, linevalue) values (day03_line_sq.nextval,'111');
insert into d03_test (lineno, linevalue) values (day03_line_sq.nextval,'101');
commit;

/*
expected gamma '101' or 5
epsilon '010' or 3
answer 3*5 or 15
*/

with t (lineno, power2, linevalue, digit, remainder) as (
select lineno, 1 power2, linevalue, substr(linevalue,1,1) digit, substr(linevalue,2) remainder from d03_test
union all
select lineno, power2+1 , linevalue, substr(remainder,1,1) digit, substr(remainder,2) remainder from t
where remainder is not null
)
select * from t
order by lineno, power2;

-- okay, this is a little dense, spit it up into two views
/*
create or replace view d03_test_v1 as
with t (lineno, power2, linevalue, digit, remainder) as (
select lineno, 1 power2, linevalue, substr(linevalue,1,1) digit, substr(linevalue,2) remainder from d03_test
union all
select lineno, power2+1 , linevalue, substr(remainder,1,1) digit, substr(remainder,2) remainder from t
where remainder is not null
)
select lineno, to_number(power2) power2, decode(digit,'1',1,'0',-1) is_1 from t
;
select * from d03_test_v1 order by lineno, power2
*/

-- recursive view
-- a recursive view has two parts
-- 1) the select statement that creates the base output
-- 1a) this is part of the final result set
-- 1b) send the output to the next part
-- 2) the select statement that processes the previous output
-- 2a) this is part of the final result set
-- 2b) send the output back to 2)
-- The process stops once 2b doesn't produce any more rows

-- both sqls need to have the same number of columns
-- the second sql needs an exit condition; something that will make it eventually return 0 rows
-- an error is generated if the second sql starts generating the same output
-- there is an option to catch the error and return the results before the repeated output

-- my goal here is to transform the input into something that plays to sql's strengths
-- I think splitting each line into the separate digits will help me do some set processing

-- I want to keep the line number for each digit and record the position in the string
-- I also need the digit itself; in this case I'll take the first one
-- Finally, I also need the remainder of the digit string so I can find the next digit
-- eventually I get all the digits, the remainder is null, and I can stop
-- linevalue is there to help me validate the logic
create or replace view d03_test_v1 as
with t (lineno, position, linevalue, digit, remainder) as (
select lineno, 1 position, linevalue, substr(linevalue,1,1) digit, substr(linevalue,2) remainder from d03_test
union all
select lineno, position+1 , linevalue, substr(remainder,1,1) digit, substr(remainder,2) remainder from t
where remainder is not null
)
select * from t
;
-- this shows what happens at each recursion level.
-- it is often helpful to have a column show the recursion level, for debugging. I usually name it rlevel.
-- In this case, the rlevel itself is useful, so i gave it the meaningful name position
select * from d03_test_v1 order by position, lineno;
-- here you can see what is happening to each lineno as it gets processed
select * from d03_test_v1 order by lineno, position;

/*
LINENO	POSITION	LINEVALUE	DIGIT	REMAINDER
1	1	001	0	01
2	1	111	1	11
3	1	101	1	01
1	2	001	0	1
2	2	111	1	1
3	2	101	0	1
1	3	001	1
2	3	111	1
3	3	101	1
*/
-- at this point, digit isn't really a digit but a flag used to eventually decide the digit.
-- I'm going to transform digit into some that'll be easier for another step to decide the value
create or replace view d03_test_v2 as
select lineno, position, decode(digit, '1',1, '0',-1) negative_means_0 from d03_test_v1;

-- I should break this up into 2 steps for a cleaner example
-- sign returns 1,0,-1 depending on the input. In this case, we should never get 0
-- I'm feeding the sign straight into decode to get the number result
create or replace view d03_test_v3 as
select position, decode(sign(sum(negative_means_0)), 1,1, -1,0) digit
from d03_test_v2
group by position;
select * from d03_test_v3;

-- well this is frustrating. position works fine for reconstructing a string, but it is backwards for computing powers of 2.
-- I could go back and reverse the string, or compute the max position and subtract.
-- eh, I'm going to be lazy. Reorder the digits and then sum up the powers of 2.
-- oh, and keep max power of 2 since that's needed to find epsilon
create or replace view d03_test_v4 as
select sum(power(2,pwr)) gamma, max(pwr) for_epsilon from (
  select digit, rownum-1 pwr from (
    select digit from d03_test_v3 order by position
  )
)
where digit = 1
/
select * from d03_test_v4;

-- whatever set of binary digits gamma uses, epsilon uses the other
select gamma, epsilon, gamma*epsilon answer from (
select gamma, power(2,for_epsilon+1)-gamma epsilon
from d03_test_v4
);
