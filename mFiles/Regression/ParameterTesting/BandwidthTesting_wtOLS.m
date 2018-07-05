% Script: BandwidthTesting_wtOLS.m
%
% Author: Kurt Nelson and Sam Maticka
%
% Purpose: This script uses cross-validation to test and identify the best
% bandwidth parameter for local weighted regression.
%%
close all; clear;clc
load('../../DataFiles/data.mat')
addpath('../functions');

% Parameters
kfold = 10; % number of folds for k-fold cross validation
Xfeatures = [1,2,3,4,7,9,10]; % X features to keep - determined from "GeneralRegressionFits.m" using forward selection
bandwidth_all = [1:0.2:6,10:100]; % bandwidths to test

% Setup data
m = size(X_train,1);
mround = floor(m/kfold); %rounding to make all k=10 folds have the same amount of data

% Extract data so all folds will have the same number of data points, and rename data
X = X_train(1:mround*kfold,2:end);
y = y_train(1:mround*kfold)';

% Add interaction terms
X = addInteractions(X);

X = X(:,Xfeatures); % extract only desired features 

% Create permutation vector
m = size(X,1);
perm = randperm(m);

count= 1;
for bandwidth = bandwidth_all
    CV_error = 0; %this will store the sum of squared error
    for ii = 1:kfold
        testRange = mround*(ii-1)+1:mround*ii; %indicies for leave out set
        
        trainRange = 1:m;
        trainRange(testRange) = []; % training indicies
        
        % Organize training and leaveout data
        Xtest_CV  = X(perm(testRange),:);
        ytest_CV  = y(perm(testRange));
        Xtrain_CV = X(perm(trainRange),:);
        ytrain_CV = y(perm(trainRange));
        
        % Normalize data
        [mTest,nTest]   = size(Xtest_CV);
        [mTrain,nTrain] = size(Xtrain_CV);
        [Xtrain_CV,mu, s] = normalizeVars(Xtrain_CV);
        for jj = 1:nTest % normalize test data
             Xtest_CV(:,jj) =  Xtest_CV(:,jj)-mu(jj);
             Xtest_CV(:,jj) =  Xtest_CV(:,jj)./s(jj);
        end
        
        % loop through test examples and compute sum of squared error
        for kk = 1:mTest 
            % computing weights for example kk
            temp = Xtrain_CV-repmat(Xtest_CV(kk,:),mTrain,1);
            for jj = 1:mTrain
                w(jj) = temp(jj,:)*temp(jj,:)';
            end
            
            w = exp(-w/(2*bandwidth^2)); % weights for wtOLS
            
            mdl = fitlm(Xtrain_CV,ytrain_CV,'linear','weights',w);
            ypred = predict(mdl,Xtest_CV(kk,:));         % use model to predict on new test data
            CV_error =CV_error +(ytest_CV(kk)-ypred).^2;  % specify the criterion to evaluate model performance. sum of squared error.
        end
    end
    CV_error_all(count) = CV_error/m; % compute MSE CV error for tested bandwidth
    count = count+1;
end


% bandwidth with minumim CV error
[minVal, minInd] = min(CV_error_all);
minBand = bandwidth_all(minInd);

fig1 = figure;%('visible', 'off');
fig1.PaperUnits = 'centimeters';
fig1.PaperPosition = [0 0 8 4];
set(gca,'box','on')
plot(bandwidth_all,CV_error_all,'linewidth',1)
ylab = ylabel('CV');
set(ylab,'interpreter','Latex','FontSize',8)
xlab = xlabel('$\tau$');
set(xlab,'interpreter','Latex','FontSize',8)
set(gca,'FontSize',6)
print('./Figures/eps/bandWidthTesting','-depsc')
print('./Figures/jpegs/bandWidthTesting','-djpeg','-r600')