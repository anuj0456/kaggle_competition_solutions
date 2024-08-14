# Winning approach by Alfonso Nieto-Castanon

Team Members - Alfonso Nieto-Castanon

REF: https://www.kaggle.com/competitions/packing-santas-sleigh/discussion/6934#38027

Approach was mostly a simple layer-based 2D packing strategy but with a slightly more convoluted way of defining the "layers". In particular, in each layer I had three different areas:

1. Some portion of the 1000 x 1000 board (the lightest-gray blocks in the right of the figure) was formed by blocks that had been already placed from lower layers. The height of all these already-placed blocks was below some value H1 (typically between 100 to 150) above this layer baseline height. Of course I could not place any new blocks within this area for this "layer".

2. Some other portion of the board (the darkest blocks in the left of the figure), typically in the opposite side to area A, formed by new blocks placed in this layer with heights greater than H1 (typically ranging between 100/150 to 250)

3. The remaining portion of the board (the mid-gray blocks in the middle of the figure), formed by new blocks placed in this layer with heights smaller than or equal to H1

After filling a layer, my next layer baseline height would be H1 units above the current layer (since all blocks in areas A and C had heights below H1), and the space occupied by the blocks in area-B formed the new area-A of the next layer (since those blocks had heights above the new baseline height of the new layer). There was some additional details in how one would choose to rotate the blocks to assign them to areas B or C, or how to avoid this sequential process across layers from getting into complicated configurations, but this was the core of the relatively-simple algorithm.

In any way, I will be writing a much more detailed description of the algorithm and publishing my code in a while, I just wanted to give a brief "heads-up" description of my general approach since I will be traveling the next couple of days.

Also I would like to congratulate everyone who participated and made this such a fun competition. And special congratulations to:

1. the Master Exploder team for a ridiculously impressive score, I seriously thought that score was impossible to achieve! my best guess is that you might have used some form of linear programming approach but I am really eager to hear what you have done!

2. to wleite for their Rudolph prize, very impressive holding on to the first position for pretty much the entire competition, and still a very close "fight" until its very last minutes!; also very curious to hear about your own approach!

3. to Abhishek for their impressive "magic", it was a fun ride, and by the way, you never told us how that was done?, my best guess is that you either used negative numbers or non-integer numbers for the block positions since I believe none of those were checked by the validation code, but I understand if a magician prefers to keep his secrets :)

4. and finally to the Mathworks team for creating an extraordinarily well-thought problem, the huge variety of possible approaches made this an incredibly interesting competition!
