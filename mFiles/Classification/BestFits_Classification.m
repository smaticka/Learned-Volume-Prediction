% Script: BestFits_Classification.m
%
% Author: Kurt Nelson and Sam Maticka
%
% Purpose: This script trains our best model (softmax) and the physical
% model on the train data, then tests them on the held out test data.
%%
clear;clc;close all;
load('../../DataFiles/data.mat')
addpath('../functions');

%% create possible feature sets
% Remove intercept
Xtrain = X_train(:,2:end);
Xtest = X_test(:,2:end);

% make volume predictions integers
ytrain = y_train*4;
ytrain = ytrain';
ytest  = y_test*4;
ytest  = ytest';

% Add interaction terms
Xtrain = addInteractions(Xtrain);
Xtest = addInteractions(Xtest);

% Select features
Xfeatures_train = Xtrain(:,[1:6]); % based on feature selection in GeneralClassificationFits.m
Xfeatures_test  = Xtest(:,[1:6]);

% Test Physical model
scale = sum(ytrain/4)./(sum(Xtrain(:,4))); % Scaling for physics prediction
ypred = scale*Xtest(:,4);

ypred = round(ypred*4);
MeanClassError_phys_test = sum(ypred~=ytest)/length(ytest); % misclassification error

% Train softmax model
mdl  = mnrfit(Xfeatures_train,ytrain,'model','ordinal');
% Test softmax model on test data
prob = mnrval(mdl,Xfeatures_test,'model','ordinal'); % n x k
[~,ypredTest] = max(prob,[],2);
MeanClassError_test = sum(ytest(:)~=ypredTest(:))/length(ytest); % misclassification error











