% Script: ClassificationErrorPhysics.m
%
% Author: Kurt Nelson and Sam Maticka
%
% Purpose: This script computes the classification error for the physical
% model. It runs numTest trails because the computed error is sensitive to
% the data splitting.
%%
clear;clc;close all;
load('../../DataFiles/data.mat')
addpath('../functions');
%% Variables
numTest = 1000; % number of trails to test
%%
% Extract 3-way interaction term
X = X_train(:,4);
y = y_train;
uniqueY = unique(y);
%% Test physical model
for trial = 1:numTest % run multiple trails because error is sensitive to splitting
    % Resplit data finding two random indices for each unique volume tested
    for i = 1:length(uniqueY)
        numSample(i) = length(find(y == uniqueY(i)));
        tempInd = randsample(numSample(i),2)+find(y == uniqueY(i),1, 'first')-1;
        if i == 1
            testInd = tempInd;
        else
            testInd = [testInd; tempInd];
        end
    end
    
    % Split data into traning and test data
    trainInd = true(length(y),1);
    trainInd(testInd)=false;
    X_test = X(testInd,:);
    y_test = y(testInd);
    
    X_train = X(trainInd,:);
    y_train = y(trainInd);
    
    error_all(trial) = PhysMdl_log(X_train,y_train,X_test,y_test)/length(testInd); % compute error
end
MeanError = mean(error_all); % classification error