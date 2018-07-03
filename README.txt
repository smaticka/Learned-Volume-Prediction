# My project's README
This is a project for CS229 (Machine Learning) by Kurt Nelson and Sam Maticka. The goal is predict poured volumes from video footage recorded from and iphone. The project proposal is below.

Fool-Proofing Recipe Measurements
(category = computer vision)

Team Members:
1) Samantha Maticka (SUNet ID = smaticka)
2) Kurt Nelson (SUNet ID = knelson3)

Motivation: Would you rather chew off your pinky finger or be doomed measuring ingredients prepping for recipes the rest of your life? The response is unanimous, no one needs a pinky anyway and the idea of being stuck with the tedious time consuming task of measuring ingredients is cringe worthy. This fact is precisely why recipes from top chefs are unavailable, namely Italian grandmas, because they do not measure…… ever (Nelson & Maticka, 2017)! They just pour some of this, and splash some of that, and produce gastronomical sensations. 

Many of us casual cooks are not able to reproduce winning recipes when applying the Italian Grandma method (IGM), and instead we are left with one-hit-wonders followed by an onslaught of failed recreation attempts that pale in comparison and litter your fridge with dreadful leftovers. Our project seeks to end this dystopia. 

The broader objective of our project is to create a smart recipe recorder and instructor. Essentially, you can either 1) make a recipe-free dish, in which you add ingredients at will and a smart device films and records the recipe, or 2) you can create a saved recipe, where the device tells you when to stop pouring a specified ingredients. 
 	
We therefore propose applying machine learning and computer vision to teach phones how to measure for us. As a first step to solving this burdensome problem, our project will focus on volume prediction of a poured liquid. The world will soon be a better place.          

Machine Learning Method: Our plan is to apply supervised learning to predict poured liquid volumes. We will start simple by training an ordinary least squares model. Model features will include the time duration in which the fluid is poured (T), the poured stream front speed (), and a representative length scale for the stream width (). Interaction terms will also be included such as  (flowrate X time = volume) and all lower order terms to satisfy the hierarchical principle.              

Intended Experiments: Data will be collected from a series of experiments where known volumes of dyed water will be poured and recorded from an iPhone. Volumes up to 4 cups in ¼ cup increments will be tested. For each volume, four duplicate measurements will be made for a total of 64 experiments.

Data Processing: Pouring will be controlled by a fixed apparatus, and videos will be filmed with a white backdrop for high color contrast. A penny will be included in the backdrop to convert pixel count to length. Footage will be imported into MATLAB, the background will be subtracted, and images will be converted to grey scale. Pixel intensity thresholds will then be applied to identify stream edges. The average number of pixels spanning the stream for a given pour will be used to define the representative length scale . The pour duration and front speed will also be exacted from each video. Additional experiments will be run if needed. 

