-- sub in the formal for sum(1..distance) as fuel

select destination, sum(abs(destination-position)*(abs(destination-position)+1)/2*the_count) fuel 
from day07_part1_v3
group by destination
order by fuel fetch first 1 rows only;
