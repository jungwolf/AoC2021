# Day 02 - Tracking state
## A word on state.
### Sets, kind of, don't take my word for it
(Relational databases)[https://en.wikipedia.org/wiki/Relational_database] are modeled on relational algebra. There's a lot of set theory in there. However, RDBMS are created with commercial intent. Oracle is exceedingly happy to break theory if it'll attract more customers. Still, theory let's one prove correctness, some companies like that, and SQL started with set manipulation as a guiding principle.

SQL was also created with an eye towards describing the solution to get an answer instead of defining the algorithm to find the answer. "What are the employee details for Bob?" "What is the total cost for this order?" "Who works in this department?" Most importantly, "If somebody works for marketing, lower their salary by 10%." Easy things to write in SQL. Other things, not so easy.

### Why keeping state in sql is hard.
First off, I could be doing it wrong. So there is that.

SQL isn't a procedural language. It works on one or more sets of data and returns a set of data. Sets don't have order; order isn't part of the computation. You can display the results in an order but that's after the computation is complete. **State** is a value that can change during processing, at least the way I'm thinking about it, but natively SQL just gives you the results in an atomic action. There are methods to allow processing in order because companies want to sell usable systems, but those aren't simple, syntactically.

### Back to analytic functions.
I think of analytic functions as a layer sitting on top of the core sql commands. You get this set and analytics lets you do processing on the set. They often allow you to generate a state-like column from row to row.

They are still set-ish in behavior. A procedural languange let's you grab a value and twist it around to your will. Analytics are much more limited.

## Where I stop ruminating and get to the puzzle and hand.
