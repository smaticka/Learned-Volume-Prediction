% Script: tuningParaTesting_Ridge.m
%
% Author: Kurt Nelson and Sam Maticka
%
% Purpose: This script uses cross validation to test and identify the best
% ridge parameter for Ridge regression.
%
close all; clear;
load('../../DataFiles/data.mat')
addpath('../functions');

%% Parameters
exponents = -4:0.1:2; % exponents for ridge parameter
tuning_all = 10.^(exponents); % ridge parameter
kfold = 10; % number of folds for k-fold cross validation
Xfeatures = [1,2,3,4,7,9,10]; % X features to keep - these were determined from "GeneralRegressionFits.m" using forward selection

%% Setup data
[m,~] = size(X_train);
mround = floor(m/kfold); %rounding to make all folds have the same amount of data

% Extract data so all folds will have the same number of data points, and rename data
X=X_train(1:mround*kfold,2:end);
y=y_train(1:mround*kfold)';

% Add interaction terms
X = addInteractions(X);

X = X(:,Xfeatures); % extract only desired features

% Create permutation vector
[m,n] = size(X);
perm = randperm(m);

count= 1;
CV_error_all = zeros(1,length(tuning_all)); % array to store the sum of squared error
for i = 1:kfold
    testRange = mround*(i-1)+1:mround*i; %indicies for leave out set
    
    trainRange = 1:m;
    trainRange(testRange) = []; %training indicies
    
    %Split data for ith k-fold
    Xtest_CV = X(perm(testRange),:);
    ytest_CV = y(perm(testRange));
    Xtrain_CV = X(perm(trainRange),:);
    ytrain_CV = y(perm(trainRange));
    
    [mTest,nTest]=size(Xtest_CV);
    [mTrain,nTrain]=size(Xtrain_CV);
    
    %ridge regression: by default, ridge normalizes variables, but the 0
    %flag at the end rescales the beta values.
    beta = ridge(ytrain_CV,Xtrain_CV,tuning_all,0);
    
    for j = 1:length(tuning_all) %Ridge fits all tuning values, so this loops through and computes the error for each
           ypred = Xtest_CV*beta(2:end,j)+beta(1,j);
           error = sum((ytest_CV-ypred).^2);
           CV_error_all(i,j) = error/mTest;
    end
end
CV_error = mean(CV_error_all);
sigma = std(CV_error_all);

[MinCVval,indMin]=min(CV_error);
minTunning = tuning_all(indMin)


fig1 = figure;%('visible', 'off');
fig1.PaperUnits = 'centimeters';
fig1.PaperPosition = [0 0 8 4];
set(gca,'box','on')
semilogx(tuning_all,CV_error,'k')
hold
errorbar(tuning_all,CV_error,sigma,'rx');
semilogx(tuning_all(indMin),MinCVval,'bo','markersize',2)

ylab = ylabel('CV');
set(ylab,'interpreter','Latex','FontSize',8)
xlab = xlabel('$\lambda$');
set(xlab,'interpreter','Latex','FontSize',8)
%set(gca,'FontSize',6,'ylim',[0.019 0.03])
%print('./Figures/eps/tuningTestRidge','-depsc')
%print('./Figures/jpegs/tuningTestRidge','-djpeg','-r600')
