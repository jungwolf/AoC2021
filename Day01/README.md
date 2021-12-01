Day 01 - Analytic functions all the way

Basic sql statements return a set of output. "SELECT ... FROM ..." A lot of optional clauses allow you to restrict the output "WHERE", group output rows "GROUP BY", order the output "ORDER BY", perform aggregate calculations on a grouped row, and even filter out grouped rows based on the resulting value "HAVING". 

Analytic funtions are applied after the full result set is created. From the Oracle Sql reference: "Analytic functions are the last set of operations performed in a query except for the final ORDER BY clause. All joins and all WHERE, GROUP BY, and HAVING clauses are completed before the analytic functions are processed. Therefore, analytic functions can appear only in the select list or ORDER BY clause." They extend the sql language from a row-by-row reporting tool to a full set data crunching MONSTER!

Time to get prosaic. Part1 asks for the number of rows that have a greater value than the previous row. The LAG function returns the value from a previous row. But sql works on sets, so what is the previous row? Analytic functions can have an individual "ORDER BY" clause. Unlike a text file, a table doesn't have an implicit order; for AoC I give each line of the text file an ascending lineno value. For Part1, I retrieve the "previous row" using LAG ordered by lineno.

(I don't know the markup used for .md files yet so sorry for the following. Oh! 4 spaces at the front of a line makes a text box.)

    select lineno, linevalue, to_number(linevalue) - lag(to_number(linevalue),1) over (order by lineno) diff
    from day01_example
    order by lineno;

That's LAG(value expression, offset, default value if offset is outside the result set). "linevalue" is the current row's column value, we don't know "lag(linevalue)" until the "base" sql completes and gives us a result set we can play with. 

    select count(*) from (
      select lineno, linevalue, to_number(linevalue) - lag(to_number(linevalue),1) over (order by lineno) diff
      from day01_part1
    ) where diff > 0;

So there you have it. The edge case is line 1. Sql's null value logic takes care of it; lag of nonexistent line 0 is null, linevalue - null is null, null > 0 is null, line 1 is not included in the count. That worked fine here but keep an eye on null, it isn't friendly.

    .........
    
I thought of a better way to solve Part2. A = D1 + D2 + D3. B = D2 + D3 + D4. A - B => D1 - D4. The two numbers shared between A and B mean you only have to know the diff between D1 an D4.

So, use answer to Part1 but increase the lag to 3.

    select count(*) from (
      select lineno, linevalue, to_number(linevalue) - lag(to_number(linevalue),3) over (order by lineno) diff
      from day01_part1
    ) where diff > 0;

    .........

Previous answer to Part2.

Part2 takes us a level deeper. We're now looking at the sum of 3 lines. The example was pretty clear we shouldn't consider edge cases of the sum of less than 3 lines. So the first thing to do is create that new sum of 3 lines dataset. In this case, instead of looking at previous rows (like in lag) I'll consider the next rows. The last two lines are discarded because they won't have a set of 3.

    select lineno, linevalue
      , count(*) over (order by lineno rows between current row and 2 following) windowcount
      , sum(to_number(linevalue)) over (order by lineno rows between current row and 2 following) windowsum
    from day01_part1;

Add some lag, a little filtering, count and we're done!

    select count(*) from (
      select lineno, windowsum, windowcount
        , windowsum - lag(windowsum,1) over (order by lineno) diff
      from (
        select lineno, linevalue
          , count(*) over (order by lineno rows between current row and 2 following) windowcount
          , sum(to_number(linevalue)) over (order by lineno rows between current row and 2 following) windowsum
        from day01_part1
      )
    )
    where diff > 0
      and windowcount = 3;

Why do I need windowcount? What happened to diff > 0 taking care of the edge cases? I'm looking at you, Mr. Null. Basically, I'm presenting these things as I wrote them. The approach may be sloppy when it comes to consistency. In this case, sum() and minus "-" treat nulls differently. Sum() returns the sum of all not null values OR null if all values are null. "-" returns a null if either value is null. In Part1, testing diff for null removed the line 1 edge case. That's still happening in Part2 with the outer sql, but the inline view has to do something else with the sum() value. Once I had the "over" clause for sum() I realized I can use it for count(\*) as well, and count(\*) will count nulls too. Maybe a little quick'n'dirty but good enough.
