# Winning approach by Master Exploder

Team Members - [@Marcin Mucha](https://github.com/mamucha), [@Marek Cygan](https://github.com/marekcygan)

REF: https://www.kaggle.com/competitions/helping-santas-helpers/discussion/12441

## Summary

In this post we present the approach used by our team: Master Exploder.

Before we proceed with the description of our approach let us contribute to the "how long did your program take" discussion. Our early solution, that implemented the basic approach described below (and scored slightly more than 1.3\*10^9), run around 5s on a Dell 6420 laptop. It uses C++ and preprocesses the input file (only size and realease time in minutes since 2014-1-1 0:0 is retained). Also, critically, it uses a find-union based queue for predecessor search on toys (i.e. it can find the largest toy not greater than given size, or remove a single toy), which is much much faster than STL's set.

The final solution took much longer, due to 2 factors:

- We needed to solve 4 different Integer Linear Programs (using Xpress Optimizer from the FICO package), the last one was rather large and finding a reasonable solution took about 3h
- Generating the oscilations (see below) was done using a hill climbing algorithm, and that thing can easily be run for a week and still improve (yes, it is that slow). Our final solution was generated much faster than that, but that is only because we made some significant improvements to other pieces and started the search too late.

Below we provide a very brief description of our approach. The source code with some more explanations will follow in a few days.

One disclaimer before we proceed: This text is not a description of a final solution, but rather a description of a process of arriving at the final solution. In particular, some of the assumptions made in the early parts of the text are lifted in the later parts, in order to gain some tiny improvements to the score.

## GENERAL THOUGHTS

Let us start with a few general observations:

- The arrival times do not matter, except in the first year. We need to process the first year separate, and otherwise completely ignore the arrival times.
- It seems that there are two resources: time and elves. However it is really not the case. First of all, you always want to use 900 elves, because of the log in the objective function, so elves are not effectively a resource. There is another resource however, and that is: small toys. Small toys can be used to accelarate elves, so that they can solve the large tasks more effectively.
- To a large extent you can ignore off-time and only think about working hours. A toy that takes t minutes at a given rate is going to take t minutes of working hours no matter what. The only reason off-time is important is that it determines the change in elf's rating (and of course the final toy for each elf is a special case, but that is really minor).

## BASIC APPROACH

Here are the basic premises of our approach:

- We want to speed up the largest toys, the larger the toy the more want to speed it up.
- We want to attempt to use up all the speed up toys efficiently, one important realization is that in general we want to produce the speed up toys as slowly as possible without going over 600 minutes. For example, the best way to use a toy of size 1200 is to produce it at speed x2. This is MUCH better that producing it at speed, say, 3x. This is because in the first case you are accelerating for a longer period of time.
- Our basic approach was: for each toy, determine the target rating we want for that toy and try to achieve it by using a sequence of small toys (which we call a speedup run, or just run). We later abandonded this for more complicated solutions, but in some form this was present in our code until the very end.
- The target rating formula was of the form rating=sqrt(SIZE/C), where C was sth like 133000. The reason for this is as follows: At first glance it might seem that you want to assign ratings so that each toy runs for more or less the same time. This would lead to a formula like this: rating=SIZE/C. However, this is not a good idea. This is because speeding up a slow elf is much more efficient than speeding up a fast elf. If you do the math here, you end up with the sqrt formula.
- If you try doing the above, the big toys will run at rating about 0.6. This is not ideal, since we have many toys with sizes like 1000 or 2000. These can be used to speed up way above this target. So we try to generate speedup runs that go as far as possible until those larger toys are out, and only then settle for the target run formula.
- Once you have these runs that go up to a rating of 4 or slightly smaller, you might be tempted to simply assign them to the largest toys. However there are better things to do with them. Here is the key observation: Suppose the rating is exactly 4.0. Instead of producing a very large toy (say of size 22k), it is in fact better to first work for 34 hours producing a toy of size 34 _ 60 _ 4 = 8160, which cuts the productivity down to 4.0 _ 1.02^20 _ 0.9^14 = 1.36, and only then produce a very large toy. This observation also works for ratings smaller than 4.0, and in general you always aim for almost exactly 34 hours and then the final rating is a about a third of the initial one.
- While you are at a rating of 4.0 or close to it, you want to "clear" the toys thatare slightly larger than 2400 (actually we can go up to about 3500) by performing what we call oscillations. Basically (a) produce a larger toy, this reduces the rating (b) produce a smaller toy, increasing back the rating (c) repeat. During the oscillations, you need to remember that small toys are the real resource here, and not time. You should almost always wait until the next work-day starts if before starting a new toy. This is true even if it is, say,
  10am.
- Finally, let us tackle the "first year problem". The basic approach would be to just let the elves do as much work as possible during that time, without using any speed-up toys. In fact using toys < 2800 is also not a good idea, since these toys CAN be used to speed up elves, even though they cannot be done in one day. A more advanced solution to the first year is as follows:
  We split the elves into two groups. 760 elves produce all available toys of size from the range [3400,9000], their productivity immediately drops to 0.25 and stays at this level till the end of this phase. The remaining 140 elves does not waste their 1.0 default productivity and wait for toys of size between 21500 and 22000 arrive, which happens in December 2014. The reason this
  is better is that toys in range [2700,3400] are handled very efficiently in oscillations anyway.
  On the other hand, saving 140 elves' productivity of 1.0 to produce large toys has significant value.

## HARDCORE APPROACH

Our final solution in some sense does what has been described in a previous section. However to save as many days as we could, we tried optimizing every single choice made in this approach. Here is the basic workflow of our approach:

## LONG RUNS

We start with constructing runs which reach productivity above 4.0 / 1.02^10, i.e. at most one day away from productivity 4.0. In our final submission we have used 39000 of such runs (chosen experimentally). Those runs are computed by generating an Integer Linear Program (ILP) and solving
it in FICO Xpress, as follows. We represent current productivity of an elf as an integer from the range [0,8400], which is the number of minutes spent so far on toys production - we assume that all the minutes are during sanctioned hours, which allows for this discretization of the rating space. Note that 0.25 ^ 1.02^(8400) equals roughly 4.0. We design a graph where from state r \in [0,8400] we have an edge to a state r' (labelled with toy s), if r'-r = ceil(s /rate), where rate = 0.25 \* 1.02^(r/60). In such a graph we look for an integral flow of size 39000 from state 0 to states in [7801,8400]. We also impose additional constraint of not using more edges labeled with s than the number of toys s available. Our goal here is to generate 39000 runs and lose as little speed-up as possible. We measure the speed-up lost by introducing a penalty. For a toy of size s we consider the duration d of its production, as well as the optimal duration dOpt which is min(600,d/0.25). The penalty for producing toy s in d minutes is dOpt-d. We minimize the total penalty over all toys used. This problem can be easily cast as ILP, but it is a huge ILP. To reduce its size, we make an additional assumption. We do not allow dOpt-d to be larger than 10, except for toys which fit completely in the first 600 minuts (first day of speed up). The reason for this exception is the following: to produce speed-up toys with large sizes on small penalty, we need the right "offset" (because we minimize the penalty, most toys take almost exactly 600 minutes, but for some toys to be produced efficiently we need to be at, say 1534 minutes). So the first day is there to allow the run to obtain a specific offset w.r.t. 600 minutes. Here is a typical run we get from the ILP:

143 2 181 221 269 328 400 488 595 725 884 1077 1313 1601 1952

Note the size 2 toy here. The number of minutes spent on speeding up during the first day is 579, this is not achievable with a single toy. This is the "offset" we need to produce the remaining speed-up toys with duration close to 600 minutes.
Finally, we impose an additional (much smaller) penalty for every toy of size <= 20 used. This is not based on any calculations, but we believe these toys are useful later on, and runs generated in this way indeed worked better.

## OSCILLATIONS

After performing a long run, elf's productivity is high - it is at least 3.28. Now our strategy is to oscillate, i.e., produce toys of medium size (say between 2000 and 3500) and when our productivity drops significantly we rebuild it using toys of size [600,2000]. We extend runs to form oscillations by a local search algorithm which swaps toys between oscillations and tries to form optimal order of an oscillation. Each oscillation also ends with a medium sized toy that takes around 34 hours to produce as mentioned before.

## ASSIGNING LONG RUNS TO ELVES

We now perform these long runs extended with oscillations. That is we take from a queue the first available elf and assign it a long run with an oscillation, then use toys of size in [3500,6000] to adjust the offset of the elf (each run has its "perfect" starting offset), and perform the run.

## MID RUNS

When all long runs with oscillations are done, there are still toys left:

- small toys, with sizes <= around 650
- large toys, with sizes >= around 3500, and <= around 22000
  We want to use the small toys to speed up the large ones. We divide this tasks into two subtasks. The first one is using the larger small toys (151) efficiently. Here we use an ILP very similar to the one for big runs to generate so called mid runs. The main difference is that we try to maximize the total time spent in these larger small toys. This simultanously guarantees (kind of)
  that we use all of them AND that they are used efficiently.

## SMALL RUNS

After we generate all the midruns, we are left with toys with sizes <= 150. To generate the ILP for the runs made of these toys we use a different ILP. We now turn to the actual objective of the problem, which is the total runtime. We use a flow formulation as before, but now we add additional sinks at every productivity r. These sinks let the flow go from node r to a specific large item S. The contribution of such flow to the objective of the ILP is equal to the gain (in minutes) we obtain from producing item S after speeding up for r minutes. This program is too large to be solved efficiently, so we reduce the number of sinks by assuming that each large item will be produced at the speed which is close (say, +-50) to the the target rating for this item. However, at this point it turned out the our sqrt(size/C) target function is no longer accurate enough, so we designed an improved one. What we did is we assumed a fixed U - marginal utility per hour of small toys (chosen experimentally) and for each large item size we used binary search to find the speed-up length at which adding an extra speed-up hour gains exactly U minutes of production time.

This ILP generates runs as long as 1450 minutes. On the other hand, some midruns have length 600 minutes. Therefore we insert these short midruns to the ILP as extra edges, in order to allow the ILP to optimally decide which run should be used for which item.

One funny issue here is the following: it is not optimal to produce larger items at higher speed! We only realized it after actually solving the ILPs. Here is an example of what our ILP does:

run 18967 on 1287 minute speedup, and
run 18874 on 1289 minute speedup

You can verify that this is 1 minute better than doing it the other way round because of round-ups. This does not influence the final score significantly, but it does a bit :)

A question one could ask is: why do we need to ILP, one for mid runs and one for small runs? In principle we do not. We would prefer to put everything in the small runs ILP, as its objective function directly models the problems objective function. Why not do it? The short answer is: the program would be too large.
The longer answer:

- There are 1500 nodes in the small runs ILP, if we include the items larger than 150, we need 4200 nodes.
- In the small runs ILP, for every big item size we generate sinks that correspond to its target rating +- a small delta, say 50. The large items that use mid runs run way above their target ratings. We do not know how to model this well without blowing up the size of the ILP. That is also why in mid runs there are no sinks, we simply assign runs to items monotonically.

## EULER TOUR METHOD

Now we are faced with a problem of executing all the small runs (each extended with a single large item), as well as all the moderate size items that are not sped up (with sizes in [3500,8000]). The problem here is that each run has some specific time offsets in [0,599] at which it can be executed with minimal waiting time. If it is run at other offsets this waiting time is much bigger. We need to split the runs in 900 groups, one for each elf, so that they require more or less equal time, and so that the waiting time is as small as possible. We model this as another ILP. This time we take [0,599] as the nodeset. Each run corresponds to a set of (potential) edges, these are pairs (start,end) that correspond to executing this run with starting offset 'start' and ending offset 'end'. For efficiency reasons we only consider those pairs, where unneccessary waiting time is no larger than some threshold value (10).
Mid size toys never incur waiting time, and each such toy can be started at any offset o and ends at offset (o+4\*size)%600. We now want to choose, for each run and each mid size toy, a starting offset, so that the resulting graph is as close to Eulerian as possible. This is modelled using a natural ILP. Once we get the solution, wee add dummy edges to make the graph truly Eulerian, find the Euler tour and cut it into 900 roughly equal pieces.

Note: this ILP is the hard one, it takes up to 3h find a reasonable solution!

## EQUALIZER

The pieces found by the Euler tour method described above are roughly equal, but still quite different in sizes. We now assign each piece to one of the elves, compute the finish times for all elves, and use a simple local search algorithm to equalize the tours. This is done by swapping mid size items (they all run at 0.25 rating) with lengths that have the same remainder modulo 150. This does not disturb any offsets and allows us to equalize all elves to within a single day.

## FINAL TOYS

Each elf also receives a final toy with size > 20k (the sizes of these toys are almost but not exactly equal, since equalizer produces close but not exactly equal finishing times). These toys can be thought of as running at 2.4x speed because they can run at night with no rest afterwards. We could and should speed up these toys, slightly. We did not do it though.

## FORCED LOSS

The small runs produced by the small run ILP may sometimes have a rather large 'forced loss'. This is the minimum number of minutes lost by waiting when executing the run. At the very last moment we implemented a method to slightly reduce this loss by attempting to swap pairs of items in a run and checking whether this improves the total runtime of the run.

Solution Code: [@Code](1st_Rank_Solution_Code.7z)
