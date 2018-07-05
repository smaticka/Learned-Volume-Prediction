% Script: GeneralClassificationFits.m
%
% Author: Kurt Nelson and Sam Maticka
%
% Purpose: This script fits and test different parametric and nonparametric
% classification models. When fitting models, all two-way interactions and
% the three-way interaction term resulting from the three fundamental
% features are considered. Foward search with 10-fold cross-validation is
% used to select the best set of features. A misclassification error and
% convidence intervals are computed. There is also an option (specified by
% testDataSize) to test whether or not the data size is large enough. To
% test data sample size, the data is subsampled at different sizes, then
% split 70/30 and fit. Plots of the mean squared error vs sample size are
% created to see if the training and test errors have converged.
%
% Models fits available: 1) Softmax, 2) LDA, 3)
% SVM, 4) K-nearest neighbors, 5) Rounded physics based model
%%
clear;clc;close all;
load('../../DataFiles/data.mat')
addpath('../functions');
%% Variables
numTrial = 100; %number of trails for each case
Softmax             = 0;  % logistic regression
LDA                 = 1;  % Gaussian discriminant analysis
SVM                 = 0;  % SVM (doesn't converge for amount of data we have)
Regularized_Softmax = 0;  % regularize with L2 norm (). Not available yet.
K_Nearest_Neighbor  = 0;  % KNN using a single neighbor

%% Check to make sure only only one model is selected
ModelCheck = [Softmax, LDA, SVM, Regularized_Softmax, K_Nearest_Neighbor];
if sum(ModelCheck)~=1
    error('Choose only 1 model')
end
%% Select chosen model type
if Softmax
    model = @SoftmaxFit;
    Model_Label = 'Softmax';
elseif LDA
    model = @LDAfit;
    Model_Label = 'LDA';
elseif SVM
    model = @SVMfit;
    Model_Label = 'SVM';
elseif Regularized_Softmax
    model = @SoftmaxRegularizedfit;
    Model_Label = 'SoftmaxReg';
elseif K_Nearest_Neighbor
    model = @KNNfit3;
    Model_Label = 'KNN';
else
    error('No model selected')
end
%% create possible feature sets
% Rename and remove intercept feature
X = X_train(:,2:end);
y = y_train;
y = y';

%Removing 3 data points so that 9 fold split creates 20 samples in the
%training
for i = [3,46,63]
    X(i,:)=[];
    y(i)=[];
end

% Adds columns to X so that all second order terms of original features are included
X = addInteractions(X);
[m, n] = size(X);


%% Feature selection performing forward search and k-fold cross validation
if SVM==0
    numKfold  = 9;       % if using LOOCV, k=m;
    featuresIn = [1,2,3]; % features forced to be included in fit (Hierarchical principle)
    
    % Perform feature selection and requires that all of the original features are included
    opts = statset('display','off');
    
    if Softmax==1
        y = y.*4; % turn into integers
    end
    % Perform feature selection employing Hierarchical principle (keep features 1:3 in)
    
    for trial = 1:numTrial
        trial
        % Sequential feature selection: performs cross-val on numKfolds, forces
        % alg. to keep in the 3 fundamental features, makes sure the alg. performs
        % over all possible features (doesn't stop at a local min), and display
        % information at each sequential iteration.
        [~,history1] = sequentialfs(model,X,y,'cv',numKfold,...
            'keepin',featuresIn,'nfeatures',n,'options',opts);
        error1(trial,:) = history1.Crit; % sum of squared error from the best fit
        
        % Perform feature selection with no requirments
        [~,history2] = sequentialfs(model,X,y,'cv',numKfold,...
            'nfeatures',n,'options',opts);
        error2(trial,:) = history2.Crit; % sum of squared error from the best fit
        
    end
    % Compute classification error and confidence intervals
    MeanError1 = mean(error1); % classification error
    sigma1 = std(error1); % standard deviation of classification error
    MeanError2 = mean(error2); % classification error
    sigma2 = std(error2); % standard deviation of classification error
    [MinDevError1, indMin] =min(MeanError1);
    MinDevError1 % minimum classification error
    MinDevErrorStd = sigma1(indMin);
    MinDevError95Con = 1.95*MinDevErrorStd/sqrt(numTrial) % 95 percent confidence interval
    
    [minCV, indMinCV] = min(history1.Crit);
    
    % Extracting features that minimize classification error
    [minCV, indMinCV] = min(history1.Crit);
    Xfeatures = X(:,history1.In(indMinCV,:));
end


%% Compute Softmax fit if selected
if Softmax
    Xfeatures = X(:,1:4); % Only use 3 fundamental features and 3-way interaction for softmax
    history1 = [];
    history2 = [];
    
    % setup data
    [trainInd,~,testInd] = dividerand(length(y_train),.7,0,.3);
    Xtrain = Xfeatures(trainInd,:);
    ytrain = y(trainInd,:);
    Xtest = Xfeatures(testInd,:);
    ytest = y(testInd,:);
    
    % Fit softmax
    CatErr_test  = SoftmaxFit(Xtrain,ytrain,Xtest,ytest);
    CatErr_train = SoftmaxFit(Xtrain,ytrain,Xtrain,ytrain);
    mdl  = mnrfit(Xtrain,ytrain,'model','ordinal');
    prob = mnrval(mdl,Xtest,'model','ordinal'); % n x k
    [~,ypredTest] = max(prob,[],2);
    prob = mnrval(mdl,Xtrain,'model','ordinal'); % n x k
    [~,ypredTrain] = max(prob,[],2);
    Train_allError  = sum(y(:)~=ypredTrain_all(:))/length(y);
end


%% Calculate errors
mtrain = size(Xtrain,1);
mtest  = size(Xtest,1);

trainError = CatErr_train/mtrain;
testError  = CatErr_test/mtest;

%% plot stuff

% plot classification error vs number of features
if SVM==0
    fig1 = figure;%('visible', 'off');
    fig1.PaperUnits = 'centimeters';
    fig1.PaperPosition = [0 0 8 4];
    set(gca,'box','on')
    plot(length(featuresIn):n,MeanError1,'linewidth',1)
    hold
    plot(1:n,MeanError2,'linewidth',1)
    ylab = ylabel('CV (Logisitc Regression)');
    set(ylab,'interpreter','Latex','FontSize',8)
    xlab = xlabel('Number of features');
    set(xlab,'interpreter','Latex','FontSize',8)
    set(gca,'FontSize',6)
    leg = legend('Enforcing hierarchical principle', 'Unrestricted');
    set(leg,'interpreter','Latex','FontSize',6)
    print(['./Figures/eps/WriteUp/featureSelection',Model_Label],'-depsc')
    print(['./Figures/jpegs/WriteUp/featureSelection',Model_Label],'-djpeg','-r600')
end

% Plot predicted volume vs actual volume, and color incorrect predictions
% red
if Softmax==1 %convert Softmax back to 1/4
    y = y./4;
    ypredTrain_all = ypredTrain_all./4;
end
predLogical = ypredTrain_all(:)~=y(:);
fig2 = figure;%('visible', 'off');
fig2.PaperUnits = 'centimeters';
fig2.PaperPosition = [0 0 8 4];
set(gca,'box','on')
plot(ypredTrain_all,y,'k.','markersize',15)
hold on;
plot(ypredTrain_all(predLogical),y(predLogical),'r.','markersize',15)

title([Model_Label,'. Training error: ',num2str(Train_allError*100),'%'])
ylab = ylabel('Poured volume (c)');
set(ylab,'interpreter','Latex','FontSize',8)
xlab = xlabel('Predicted volume (c)');
set(xlab,'interpreter','Latex','FontSize',8)
set(gca,'FontSize',6,'ylim',[0 3])
leg = legend('Correct Classification', 'Incorrect Classification','location','NW');
print(['./Figures/eps/WriteUp/classificationError',Model_Label],'-depsc')
print(['./Figures/jpegs/WriteUp/classificationError',Model_Label],'-djpeg','-r600')





