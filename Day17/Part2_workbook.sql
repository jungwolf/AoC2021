/*
Unfortunately churning through all the possibilites will be a chore.
so let's see if sql can lend us a hand
target area: x=277..318, y=-92..-53
We know from part 1 that finding the first t that can reach a target x square is: t = ivx + 0.5 +- sqrt( (ivx + 0.5)^2 - 2*targetx )
Limited by t <= ivx, so usually or maybe always the + root is out of bounds.
Can we go the other way around? That is, if I know targetx, can I find the minimum ivx that will reach it?
But then again, I'm already letting the DB do the heavy work. Searching through all x=0 to 318 and y=-92 to 92 possiblities isn't a problem
So let's see.

I need to generate 2 sequences. Let's go to the standards.
