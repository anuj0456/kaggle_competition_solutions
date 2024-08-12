# Winning approach by Master Exploder

Team Members - Marcin Mucha, Marek Cygan

REF: https://www.kaggle.com/competitions/packing-santas-sleigh/discussion/6934#38027

THE MAIN SCHEME

To begin with, we are packing “from the top” and aim for zero ordering penaly, but that is probably the case with most solutions. This way, we essentially need to put batches of presents at the same ground level.

The main scheme is identical to what Alfonso described. If you look at the stack of presents from the side, you see something like this.

E
EED
CDD
CCB
ABB
AA

Here, each letter corresponds to one “layer”. As you can see each layer consists of two areas. One, closer to the edge, has tall items. The other, more central, has short items. There is also
always what we call an _island_, which is the area occupied by previous layers’ tall items. This area is unaccesible to the current layer.

Denote the maximum height of the tall part of a layer by h1 and the height of the short part by h2. Then h2 of the next layer is h1-h2 of the previous layer. Other than that (and h1 >= h2) there are no constraints on these numbers.

This is the basic idea, but there are a lot of details left out:
\*How do we choose h1 and h2 for each layer (in fact only h1, because h2 is implied by the previous layer) ?

- How do we decide how large each part is and which items go to which part?
- How do we actually pack the items?

CHOOSING H1

Looking at each layer separately, very different choices could be _locally_ best for different layers. Sometimes you want h1 = 250, other times something like h1 = 150 could actually be best (BTW: We ignore the last 300 000 presents in this discussion, since they are mostly irrelevant for the score). However, you need to always take into account the fact that current h1-h2 is next layer’s h2. If we force the next layer to have h2 = 50 or h2 = 180, this could end up very badly. The stable solution is h2 equal to approx. 120-125 and h1 to 240-250. If, on the other hand, you go to, say h2 = 50, then it is very likely that next turn it will be h2 = 200 (approx) and then again 50 and so on, a sort of oscillation that usually ends up with bad scores. Our algorithm is trying to choose the best h1, but at the same time avoids straying too far from the stable solution, by penalizing h1-h2 away from 125. How exactly do we choose the best h1? We go over all possibilities from 220 to 250, skipping those that do not correspond to any items.

WHICH ITEMS GO THE THE TALL PART

Once we decide on h1 for a layer, we need to decide on which items go to the tall part. Some items have all 3 dimensions > h2, and these have to go to the tall part. Some have all dimensions <= h2 and these we would like to put into the short part (it is not always the case though, see later). Some items have some dimensions > h2 and some <= h2. These could go either way. For each such item we compute the ratio of the _tall volume_ and _short volume_ and use it to decide. _Tall volume_ is the volume of the present with its largest dimension <= h1 substituted by h1. This is essentially the volume occupied by this box if we put in the tall part, since some of the space will be wasted. Similarly we define the _short volume_. Intuitively if the ratio _tall volume_ / _short volume_ is small, the item should probably end up in the tall part.

How many items should go to the tall part? We essentially again try all possibilities (or perhaps a lot of possibilities, see later).

THE SNAKE, OR HOW WE PACK THE ITEMS

Let us first describe a generic packing algorithm and then how it is used in the tall/short scheme.
Note that here we are packing rectangles and not actual presents. Each rectangle has some height and some width. We first rotate all items in the x-y plane so that their heights are larger than their widths. This has two effects:

- it makes items more _similar_ to each other, which in general makes packing easier,
- we are packing items in rows, having them rotated this way makes it easier to hit the right/left edge exactly.
  We then sort items by height.
  Next we start going from left to right and putting each item next to the previous one as high as possible. When we hit the border, we continue from that border in the opposite direction. This is done to maintain a more or less horizontal _skyline_. This is the basic scheme.

We are using some additional ideas in the actual solution.

First of all, the algorithm as described leaves out a lot of space at the edges. To fix that we do the following. We take the last 4 items that fit before the edge and the first 4 items that do not fit and we try all possible combinations to find the one that gets closest to the edge. That is 256 combinations total, but you can go over them fast by using the standard meet-in-the-middle approach. In this approach you divide the items into two groups of 4, compute all combinations in each group, sort these two lists and then go over them simultanously. With this improvement the algorithm is actually very good at hitting the border almost exactly.

The second problem is that we are not packing a rectangular area. Instead there is a skyline at the bottom that comes from previous layer’s tall part. This has some nasty consequences, since now a rectangle might not fit at some position, but still fit somewhere else. If a rectangle does not fit at the current position (i.e. it overlaps the bottom skyline), we continue along the current direction and try to fit it. If we hit the edge we start going back. Also, while doing this, we actully try rotating by 90 degrees at each position, since this can possibly help.

This second idea seems like a lot of computations but it can be optimized. Namely, in our data structure that implements the skyline, we can look for the next position at which the height of this skyline changes. This allows us to try a relatively small number of locations for each troublesome item.

USING THE SNAKE FOR TWO-PART LAYERS

To use the above algorithm for packing tall/short layers, we first pack the tall layer using this algorithm. This generates a skyline. We then use it again to pack the short layer between two skylines, one coming from the tall part, and one from the previous layer.

We also have another _mode_ in the algorithm where we use a single snake for all items. The only way in which we suggest which items go where is in the order in which they are considered (we call this _longsnake_ in our program).

SINGLE LAYER PACKER AND SOME EXTRA IDEAS

When we have a solution and we want to extend it by a single layer. We try:

- all reasonable choices of h1,
- all reasonable choices of how many presents go to the tall part,
- longsnake and two snakes.
  We also try starting from top right and go the left instead of starting from top left and going to the right. Finally we try some random changes, like rotating a small number of items so that their width is larger than their height.

The idea here is that since we are not using SA or other local search algo, we want to have as many (hopefully different) solutions as possible to give ourselves a chance to find a good one.

THE TOP-LEVEL ALGORITHM

Once we have all these solutions computed (there is quite a lot of them) what do we do with them? The thing is that it is actually pretty hard to figure out which one will turn out best in a couple rounds. So instead of attempting that, we use beam-search. What this means is:

- We keep a pool of, say, 40 best solutions from layer to layer (actually it is enough to keep 10 to see a significant boost in the score comparing to keeping the best solution only).
- In each layer, we try to extend each of these solutions in all possible ways, generating a massive pool of solutions.
- We pick the best ones from these.

How do we pick the best solutions? It is easy to see that the absolute height of the whole packing is not a good idea. Instead, we try to compute the effective space usage for the packing.
This is the ratio of the volume of the presents packed and the volume of space that is used, i.e. no longer accessible for packing (note that this one can have a very weird shape). We sort the solutions by this ratio and pick the best ones. However:

- We do not pick a solution which has both the last h1-h2 and total number of items packed identical to a solution already picked. It is probably better to pick something else for diversity. In particular having a good representation of different h1-h2 is a good idea.
- Solutions with h1-h2 away from 125 are penalized by a factor essentially c^( (h1-h2-125)^2), for some c. This is to discourage the algorithm from picking these solutions unless they are really good.

THE HOME STRETCH

The above is most of the story. However, to get down to 1859 we needed a couple extra tricks. Both of them revolve around packing some extra items into a layer.

SNEAKING

I am borrowing the name from PoolNightBill’s post, we actually used a polish word in our conversations that should probably be translated to “to put under” (it is a single word in polish). Anyway, the idea is the following. Once we decide on how many items we are packing, the value of h1, etc., we look at the last couple items, say 10. We lift the last one as high as possible within its part of the layer. Then we lift the previous one as high as possible, but keeping its bottom below the last one’s bottom, and so on. This creates 10 box-shaped spaces below these items. We are then packing the remaining items into these spaces. After the packing is done, we can treat the lifted box together with all the items under the box as a new single item and execute the snake algorithm with this item instead.

Not only does this increase the packing ratio by getting rid of some of the troublesome items (say 160x160x160 if h1=250 and h2=125). It also groups the small items together to some extent, which often helps the snake since it is quite bad at packing them (gluing small items into a single large one is actually often used in bin packing algorithms).

How do we pack the items into the boxes below lifted items? One option would probably be to try to assign items to these boxes and reuse the snake, however this seems rather difficult to do. Instead we go from largest items to smallest and try to fit each one in the shortest box it fits in. Within a single box we decide on item’s position using BLF (bottom-left-first). To implement BLF efficiently we use the line-sweep method.

“TO PUT OVER”?

This is the opposite of sneaking. Once packing of a layer is done, we look for a place to pack the next item on top. If that works, we try the next one, and so on. In general this does not give a large improvement, especially once you start sneaking.

MASTER IMPLODER

Yeah, what it says, basically. Drop the whole thing from the top of a really tall building and watch it crash and burn. Just do not forget to submit the solution before it burns down. This last step used to shave off around 400 points, but with all the optimizations in place it lowered the score only a little bit, from 1860036 to 1859938.

DID NOT MAKE THE CUT

In the sneaking step, it sometimes happens that the last item packed (or an item close to the end of the packed batch) is very tall. Since we cannot lift it, we also cannot lift the previous items. In such cases it seems reasonable to actually lift them without lifting the last item (which breaks the ordering by 1 for each lifted item). If you do the math it seems that this idea could lead to some small improvements. However, we never implemented and tried this.

EXCUSE ME, IS YOUR PROGRAM SLOW?

Well, the computation is kind of massive. However, we use C++. And threads. The _generate_a_lot_of_solutions_with_different_parameters_ part parallelizes brilliantly, so this saves a lot of time. The final solution we submitted took around 160 single-thread hours to compute, but you can get a score of around 1880 with only 10 single-thread hours.

A SINGLE PICTURE...

This a single layer's packing viewed from above.

- The yellow part is the island that was left from the previous layer and is now unaccesible.

- The red part is the tall one, and the green one is the short one. The light color is used for taller items and dark color for shorter.

- The pink items are the lifted ones. The blue items are the sneaked items, they are actually below the pink ones.

- The grey items are packed on top of the layer.

- The black color denotes empty space.

SOME REMARKS ON THE SOURCE CODE

First of all this was written very fast and without the full knowledge of what it is going to look like eventually. Therefore, many parts may simply look strange or illogical. That said, here is a short guide on how the code relates to the algo description above plus some other remarks, mainly the less obvious parts:

- POOL_SIZE and NUM_THREADS do what they seem to be doing, but the first one should always be a multiple of the second one.

- Skyline is a structure that maintains an integer function on [0,999] , representing a skyline formed by a set of boxes (in 2D). You can update it with a new box. You can also query max value in an interval. Additionally you get either: (a) the amount of space "wasted" below the box, or (b) how far you have to move the box to be able to place it lower.

- can_pack_2d_first_fit implements the snake. You should ignore the \*\_offset parameters. The subset sum thing is done at the beginning of each row and then at first fail we just bail out of it and switch to single box packing. This is not ideal for sure, did not have time to change it.

- extend_one_box tries to sneak a single box using sweep-line method.

- can_pack_two_regions and (wrapper) pack_two_regions implement the two-part layer idea, the latter has rather fuzzy logic, do not try to analyze it too much

- The beam search is done using History and Log. We actually do not keep entire solutions in beam search. Rather than that we keep the settings that were used to generate each layer (program is fully deterministic) and at the end we simply reproduce all the calls once more. History (this name is totally misleading for historical reasons) actually encodes a state, it contains all the stats, the packing used for last layer, the settings used for this last layer etc. Log is an element of beam search pool, contains the state (History) and the whole settings history. Expanding a single History object is done in expand. However, if this function is given non-empty settings, it only expands a single state corresponding to these settings (this is used at the end). Also, if it add_to_output is set, it generates the corresponding parts of the output (also used at the end).

RUNNING THE CODE

Compiling using make should reproduce the leaderboard result. This has only been tested under linux with gcc. Reading the code is not recommended :) If you try anyway, feel free to ask questions, we will do our best to clarify things.

Solutio: [text](2nd_Rank_Solution_Code)
