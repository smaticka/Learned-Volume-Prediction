# README

Project Title:
Smart Recipe Measurements with Learned Volume Prediction

Team Members:
1) Samantha Maticka; smaticka@gmail.com
2) Kurt Nelson;      kurtnelson687@gmail.com 

Description:
This is a project for CS229 (Machine Learning, Stanford University). The goal is to predict poured volumes from video footage recorded from an iPhone.

Repository Navigation:
The repository contains files for processing videos to extract features that are used for machine learning, machine learning algorithms for both a regression and classification approach, as well as a project write up and the data files used in the study. Specific locations are as follows:

Data files:               ./DataFiles/*
Feature extraction files: ./mfiles/FeatureExtraction/*
Regression Models:        ./mfiles/Regression/*
Classification Models:    ./mfiles/Classification/*
Project Write up:         ./Latex/*

We also note the Feature extraction scripts require raw video footage as an input. 
Due to file sizes, the recorded videos are not included in this repository. 
If desired, please contact either Kurt or Sam.     



Project Description:
The broader objective of our project is to create a smart recipe recorder and instructor. Essentially, you can either 1) make a recipe-free dish, in which you add ingredients at will and a smart device films and records the recipe, or 2) you can create a saved recipe, where the device tells you when to stop pouring a specified ingredients. We wanted to apply machine learning and computer vision to teach phones how to measure for us. As a first step, our project will focus on volume prediction of a poured liquid.         

Experiments:   Data was collected from a series of experiments where known volumes of dyed water were poured and recorded from an iPhone. Volumes up to 4 cups in ¼ cup increments were be tested, with ~20 videos for each volume. Videos were filmed with a white backdrop for high color contrast. A ruler was included in the backdrop to convert pixel count to length.

Data Processing:   Footage was imported into MATLAB, the background was subtracted, and images were converted to red scale. Pixel intensity thresholds were used to identify stream edges. The average number of pixels spanning the stream for a given pour were used to define the representative length scale. Edges of the streams' fronts and tails were found and tracked to calculate front speed and pour duration. 

Machine Learning Method:   We applied supervised learning to predict poured liquid volumes. Model features included the time duration in which the fluid is poured (T), the poured stream front speed (u), and a representative length scale for the stream width (L). Interaction terms were also included such as (flowrate * time = volume) and all lower order terms to satisfy the hierarchical principle.              


