-- Sorry, .md was taking too long to write

/*
My approach is brute force.
1) find the number of crabs at a position
2) the lowest fuel-cost destination will be somewhere between (inclusive) the minimum and maximum positions.
3) for each destination, calculate the fuel costs for all the crabs
4) pick the lowest fuel cost
*/


-- Turning the input into a useful structure is often one of the hardest parts to these puzzles.
-- I finally put together a relatively flexible method to turn input strings into rows

-- This create a new type, a list of varchar2 entries. Tables can now have columns of this type, making a table of tables.
--   Not may first choice for a work solution, the logical concept seems better served by a child table.
--   Useful here.
create or replace type varchar2_tbl as table of varchar2(4000);
/

-- This function peels off the first string up to a delimiter than calls itself.
-- I wrote this last year. Looks like it only handles single character delimiters. I have some ideas to make it more generic but not today.
--   in sql a varchar2 can be up to 4000 characters, but in pl/sql it can be 32k(-1?). I haven't checked if p_string is limited by the sql or pl/sql size.
create or replace function string2rows (p_string varchar2, p_delimiter varchar2) return varchar2_tbl as
  l_vtab varchar2_tbl := varchar2_tbl();
  i number;
begin
  l_vtab.extend;
  i:= instr(p_string,p_delimiter);
  if i = 0 then
    l_vtab(1):=p_string;
  else
    l_vtab(1):=substr(p_string,1,i-1);
    l_vtab := l_vtab multiset union all string2rows(substr(p_string,i+1),p_delimiter);
  end if;
  return l_vtab;
end;
/
-- l_vtab varchar2_tbl := varchar2_tbl();
--   Creates a local table of varchars. varchar2_tbl() is a constructor automatically created with the type. Generates an empty type.
-- l_vtab.extend;
--   Adds a row to the table
-- l_vtab := l_vtab multiset union all string2rows(substr(p_string,i+1),p_delimiter);
--   Basically, use the recursive call to generate all the other entries. Now, add those entries to the current table.
--   "multiset union all", in Oracle, set operators by default dedub the entries. "all" tells it no.

create or replace view day07_part1_v1 as
select to_number(column_value) item from table(string2rows('1101,1,29,67,1102,0,1,65,1008,65,35,66,1005,66,28,1,67,65,20,4,0,1001,65,1,65,1106,0,8,99,35,67,101,99,105,32,110,39,101,115,116,32,112,97,115,32,117,110,101,32,105,110,116,99,111,100,101,32,112,114,111,103,114,97,109,10,760,1085,275,960,23,133,190,86,999,298,714,247,509,704,122,1109,713,51,41,1028,59,10,251,0,600,201,103,176,482,204,747,540,57,33,133,90,724,793,294,1618,762,65,1579,4,603,1182,25,12,718,30,1534,614,1021,1175,20,647,201,65,136,798,526,1,1060,70,329,194,54,747,423,349,261,604,133,32,1074,148,177,997,597,703,158,1265,472,277,52,320,467,899,333,750,40,588,311,456,1298,1511,33,1037,946,199,12,1751,221,14,1046,686,552,288,231,926,747,67,105,537,1264,654,539,211,549,294,381,662,6,523,239,48,487,6,575,553,218,1404,160,1196,330,336,1690,215,134,1312,186,1502,377,52,2,479,649,523,330,737,112,40,846,171,102,1614,39,514,438,932,143,443,1270,339,548,230,430,420,521,431,83,517,463,12,517,173,72,45,806,65,280,559,1076,332,162,50,606,1468,15,128,34,77,533,211,1157,789,111,67,308,462,147,1106,215,801,1294,203,98,833,136,136,1363,539,114,365,690,1378,266,1,212,537,283,327,55,96,377,57,899,37,1397,747,341,4,555,72,283,356,70,1410,33,311,1255,382,1076,50,98,314,214,49,281,33,1143,11,1270,396,477,265,156,763,86,595,1182,139,1085,499,1,3,7,90,408,1062,37,1175,56,925,1118,463,93,198,678,839,507,511,151,1081,146,1,553,292,208,384,787,395,360,1587,400,981,22,852,109,342,52,173,439,980,1058,11,282,117,558,652,370,86,81,178,531,309,691,254,183,324,495,511,26,57,1473,19,243,1290,392,362,1533,837,397,207,251,1250,584,700,431,1084,204,89,4,1439,48,1163,100,149,73,426,107,882,868,145,352,434,1445,354,74,1134,166,118,792,722,198,228,157,119,1178,789,947,670,1247,726,28,474,35,137,24,328,152,270,429,368,1113,132,364,32,122,12,1314,227,513,215,96,235,142,230,100,1112,119,308,1590,509,297,494,316,916,816,791,1204,42,660,1207,1170,257,663,120,12,18,1579,1164,110,432,601,397,323,376,656,128,34,215,1572,744,156,1081,330,1084,245,83,620,409,463,1029,1178,952,334,1344,963,109,8,462,174,302,1441,12,16,701,466,1794,620,442,227,165,894,1542,94,261,419,962,1047,1294,400,3,355,394,125,25,674,774,44,22,492,384,44,457,121,188,132,1226,185,991,822,1351,1126,638,258,134,349,204,72,330,1006,124,969,981,586,61,670,0,158,316,794,835,1086,160,506,293,798,77,44,1337,106,602,1459,665,85,364,1328,363,32,796,344,1894,178,742,347,626,267,304,909,130,82,189,284,745,14,50,494,36,113,632,527,140,817,136,1707,1227,792,1774,4,159,1233,85,486,515,917,16,200,333,335,328,640,347,311,1297,1489,1047,653,1,56,157,833,257,1294,237,759,124,453,1205,447,734,976,364,315,656,19,336,42,566,61,73,212,107,747,1033,130,1896,1283,1028,877,336,325,127,762,887,644,965,955,25,562,1042,975,410,346,387,1432,1303,1,257,87,814,1101,1399,38,204,1753,69,201,1347,442,169,272,1593,136,21,1821,200,60,99,76,6,88,1657,1825,539,92,705,1402,297,1309,316,614,84,403,204,45,805,119,67,149,384,179,188,1712,68,226,1430,1137,0,561,515,1233,9,450,657,216,516,197,829,413,53,792,792,432,397,97,120,876,596,287,44,125,37,70,225,27,5,122,1936,14,492,151,1072,464,62,478,1393,35,747,510,100,1242,10,1608,212,281,15,905,81,49,198,318,278,751,219,211,561,33,1787,64,419,1,809,410,228,196,333,261,1,454,1364,637,654,224,107,1573,907,245,129,346,619,111,392,40,273,256,1,807,1594,51,766,1113,21,31,745,1510,204,25,125,124,434,608,546,0,251,81,116,957,973,76,1129,320,368,851,302,711,612,84,218,809,858,1460,818,136,886,1160,1284,531,1617,122,1091,539,231,318,616,148,1366,291,537,1606,1004,317,43,1424,469,1193,500,479,431,470,1316,32,953,593,1162,803,761,60,255,369,1250,275,1534,312,258,36,114,308,672,94,698,231,34,213,168,64,1170,44,1547,246,1607,733,479,87,554,101,68,631,673,231,177,392,627,464,405,415,148,1478,396,1309,445,298,445,428,208,510,371,788,597,635,1230,111,325,121,1173,21,157,576,5,365,319,858,722,259,129,198,555,83,160,1125,467,784,100,706,155,209,446,821,379,732,160,233,114,644,565,106,656,863,354,1246,266,437,41,154',','))
/
-- to_number() because the input is a string and the parsed output items are still string.
-- string2rows('1101,1,...,154',',') returns a single object that is a collection of varchar2 values. That's almost but not quite useful.
-- table() tells Oracle it can treat the table-ish type as a real table/view.
-- So, finally, select * from day07_part1_v1 returns a row of numbers.

-- Count the number of crabs at a position. It is de-crabinizing so I hope they are okay with it.
create or replace view day07_part1_v2 as
select item, count(*) the_count from day07_part1_v1 group by item;

-- I need to consider all the destinations between min position and max position. The line of crabs may have gaps.
-- This recursive query supplies all the rows needed.
create or replace view day07_part1_v3 as
with minmax as (select min(item) minvalue, max(item) maxvalue from day07_part1_v2)
, t (destination,maxposition) as (
    select minvalue destination, maxvalue maxposition from minmax
    union all
    select destination+1, maxposition from t
    where destination<maxposition
  )
select destination, item position, the_count from t,day07_part1_v2;
-- The recursive query needs to know when to stop. It's clunky, but returning the maxposition on each generated row allows the destination<maxposition exit state.
-- I put together two steps into the one view.
-- select ... from t, day07_part1_v2; combines the destination row generator with the crab positions.
-- It generates destinations*positions rows. That's fine, but it can take a long time to display to your client. 

-- Finally, sum up the cost in fuel for each crab moving to the destination.
select destination, sum(abs(destination-position)*the_count) fuel 
from day07_part1_v3
group by destination
order by fuel fetch first 1 rows only;
-- "fetch first 1 rows only" orders the output and limits the output to 1 row.
-- Because min fuel is the first row, that's the answer.
-- This assumes only 1 destination.


-- Part2 changes the fuel cost function.
-- abs(destination-position)*(abs(destination-position)+1)/2
--   basically, 0+1+2+3... = n*(n+1)/2

select destination, sum(abs(destination-position)*(abs(destination-position)+1)/2*the_count) fuel 
from day07_part1_v3
group by destination
order by fuel fetch first 1 rows only;

