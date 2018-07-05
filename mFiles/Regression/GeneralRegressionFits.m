% Script: GeneralRegressionFits.m
%
% Author: Kurt Nelson and Sam Maticka
%
% Purpose: This script fits and test different parametric and nonparametric
% regression models. When fitting models, all two-way interactions and the
% three-way interaction term resulting from the three fundamental features
% are considered. Foward search with 10-fold cross-validation is used to
% select the best set of features. Mean squared error, root mean squared
% error, and convidence intervals are computed. There is also an option
% (specified by testDataSize) to test whether or not the data size is large
% enough. To test data sample size, the data is subsampled at different
% sizes, then split 70/30 and fit. Plots of the mean squared error vs
% sample size are created to see if the training and test errors have
% converged.
%
% Model fits available 1) Ordinary least squares 2) Lasso regression 3)
% Ridge regression 4) Locally weighted least squares 5) Percent difference
% least squares 6) K-nearest neighbors 7) Physics based model
%
clear;clc;close all;
load('../../DataFiles/data.mat')
addpath('./functions');

%% Variables
% Model to fit - options 'OLS', %'Lasso', 'Ridge', 'wt_percentDiff', 'Physical', 'wt_local', and 'KNN' 
modelType = 'OLS';
testDataSize = 1;       % Include data size test or not
numTrials = 5;          % number of trails to average MSE for feature selection
tablespoon_to_cup = 16; % tablespoon to cups conversion
numKfold = 10;          % number of folds for cross validation
featuresIn = [1,2,3];   % features forced to be included in fit (Hierarchical principle)

RoundPrediction = 0; % choose to round the output of linear regression

%% create possible feature sets
% Rename and remove intercept feature
X = X_train(:,2:end);
y = y_train;
y = y';

% Add interaction terms
X = addInteractions(X);
[mAll, nAll] = size(X);

%% Perform Feature selection using linear regression and LOOCV
%  Perform feature selection and requires that all of the original features are included
opts = statset('display','iter');
switch modelType
    case 'OLS'
        model = @OLSfit;
    case 'Lasso'
        model = @Lassofit;
    case 'Ridge'
        model = @Ridgefit;
    case 'wt_percentDiff'
        model = @wt_percentDiff_fit;
    case 'wt_local'
        model = @wt_local_fit;
    case 'KNN'
        model = @KNNfit_reg6;
    case 'Physical'
        model = @PhysMdl;
    otherwise
        warning('Unexpected model type!')
end

if ~strcmp(modelType,'Physical')
    for trail = 1:numTrials % run forward feature selection
        
        % Perform feature selection and require fundamental features
        [fs1,history1] = sequentialfs(model,X,y,'cv',numKfold,...
            'keepin',featuresIn,'nfeatures',nAll,'options',opts);
        sse1 = min(history1.Crit); % sum of squared error from the best fit
        CVerror(trail,:) = history1.Crit;
        
        % Perform feature selection with no requirments
        %[fs2,history2] = sequentialfs(model,X,y,'cv',numKfold,...
        %    'nfeatures',nAll,'options',opts);
        % sse2 = min(history2.Crit); % sum of squared error from the best fit
        % Compute the mean squared error predicted from physics and model (note: for the model it should be the same as above)
    end
else
    for trail = 1:numTrials % compute cross validation error if physical model is selected
        CVerror(trail) = mean(crossval(model,X(:,4),y,'kfold',numKfold)/numKfold);
    end
end

%Compute mean and standard errors for the cross-validation error;
if ~strcmp(modelType,'Physical') % for all but non physical model
    MSE_mean = mean(CVerror); % mean MSE from all trails
    [minMSE, indMin] = min(MSE_mean); % index of minimum MSE from forward selection
    std_MSE = std(CVerror(:,indMin)); % standard deviation of MSE from all trails
    SE_MSE = std_MSE/sqrt(numTrials); % standard error for MSE
    
    % Same as above but for RMSE
    RMSEerror = sqrt(CVerror);
    RMSE_mean = mean(RMSEerror);
    minRMSE =  RMSE_mean(indMin);
    std_RMSE = std(RMSEerror(:,indMin));
    SE_RMSE =1.95*std_RMSE/sqrt(numTrials);
    
    Xfeatures = X(:,history1.In(indMin,:)); % features for best fit model
else
    [minMSE, indMin] = min(mean(CVerror)); % index of minimum MSE from forward selection
    std_MSE = std(CVerror); % standard deviation of MSE from all trails
    SE_MSE = 1.95*std_MSE/sqrt(numTrials);  % standard error for MSE
    
    % Same as above but for RMSE
    RMSEerror = sqrt(CVerror);
    RMSE_mean = mean(RMSEerror);
    minRMSE = RMSE_mean;
    std_RMSE = std(RMSEerror);
    SE_RMSE = std_RMSE/sqrt(numTrials);
    
    Xfeatures = X(:,4);
    SE = std(CVerror)/sqrt(numTrials);
end


%% Training vs test error for different dataset sizes - this is to test for convergence
if testDataSize
    sampleSizesTested = 20:10:length(y); % data sample sizes to test
    count =1;
    for numTrys = 1:40 % Does splitting multiple times because initial error is sensitive to the split
        numTrys
        count =1;
        for sampleSize = sampleSizesTested
            % split data
            [Xsubset,idx] = datasample(Xfeatures,sampleSize,'replace',false);
            ysubset = y(idx);
            [trainInd,~,testInd] = dividerand(sampleSize,.7,0,.3);
            
            %Setup training and test data
            Xtrain = Xsubset(trainInd,:);
            ytrain = ysubset(trainInd,:);
            Xtest = Xsubset(testInd,:);
            ytest = ysubset(testInd,:);
            
            %fit model model to test data and compute SSE and MSE for both
            %trainig and test data
            %Note: all functions below output the sum of squared error, not
            %MSE.
            switch modelType
                case 'OLS'
                    SSE_test =  OLSfit(Xtrain,ytrain,Xtest,ytest);
                    SSE_train = OLSfit(Xtrain,ytrain,Xtrain,ytrain);
                case 'Lasso'
                    SSE_test = Lassofit(Xtrain,ytrain,Xtest,ytest);
                    SSE_train = Lassofit(Xtrain,ytrain,Xtrain,ytrain);
                case 'Ridge'
                    SSE_test = Ridgefit(Xtrain,ytrain,Xtest,ytest);
                    SSE_train = Ridgefit(Xtrain,ytrain,Xtrain,ytrain);
                case 'wt_percentDiff'
                    SSE_test = wt_percentDiff_fit(Xtrain,ytrain,Xtest,ytest);
                    SSE_train = wt_percentDiff_fit(Xtrain,ytrain,Xtrain,ytrain);
                case 'wt_local'
                    SSE_test = wt_local_fit(Xtrain,ytrain,Xtest,ytest);
                    SSE_train = wt_local_fit(Xtrain,ytrain,Xtrain,ytrain);
                case 'KNN'
                    SSE_test  = KNNfit_reg3(Xtrain,ytrain,Xtest,ytest);
                    SSE_train = KNNfit_reg3(Xtrain,ytrain,Xtrain,ytrain);
                case 'Physical'
                    SSE_test  = PhysMdl(Xtrain,ytrain,Xtest,ytest);
                    SSE_train = PhysMdl(Xtrain,ytrain,Xtrain,ytrain);
                otherwise
                    warning('Unexpected model type!')
            end
            
            [mtrain,ntrain] = size(Xtrain);
            [mtest,ntest] = size(Xtest);
           
            % divide by number of training examples to compute MSE
            trainError(count,numTrys) = SSE_train/mtrain;
            % divide by number of test examples to compute MSE
            testError(count,numTrys)  = SSE_test/mtest;
            count = count+1;
        end
    end
    testError = mean(testError,2); % computes mean MSE test error
    trainError = mean(trainError,2); % computes mean MSE train error
end

%% Plot stuff
if ~strcmp(modelType,'Physical') % plot MSE plot for feature selection
    fig1 = figure;%('visible', 'off');
    fig1.PaperUnits = 'centimeters';
    fig1.PaperPosition = [0 0 8 4];
    set(gca,'box','on')
    plot(length(featuresIn):nAll,MSE_mean,'linewidth',1)
    ylab = ylabel('$CV_{\mathrm{MSE}}$');
    set(ylab,'interpreter','Latex','FontSize',10)
    xlab = xlabel('Number of features');
    set(xlab,'interpreter','Latex','FontSize',10)
    set(gca,'FontSize',8)
    %print('./Figures/eps/featureSelectionWLS','-depsc')
    %print('./Figures/jpegs/featureSelectionWLS','-djpeg','-r600')
end

if testDataSize % plot data size convergence
    fig2 = figure;%('visible', 'off');
    fig2.PaperUnits = 'centimeters';
    fig2.PaperPosition = [0 0 8 4];
    set(gca,'box','on')
    plot(sampleSizesTested,trainError,'r','linewidth',1)
    hold
    plot(sampleSizesTested,testError,'k','linewidth',1)
    ylab = ylabel('MSE');
    set(ylab,'interpreter','Latex','FontSize',10)
    xlab = xlabel('Data sample size');
    set(xlab,'interpreter','Latex','FontSize',10)
    set(gca,'FontSize',8,'xlim',[30 200])
    leg = legend('training error', 'development error');
    set(leg,'interpreter','Latex','FontSize',8)
    print('./Figures/eps/dataSampleSizeWLS','-depsc')
    print('./Figures/jpegs/dataSampleSizeWLS','-djpeg','-r600')
    
    if strcmp(modelType,'Lasso')
        %Normalize variables
        [Xfeatures,mu, s] = normalizeVars(Xfeatures);
        [B,FitInfo] = lasso(Xfeatures,y,'CV',10);
        
        fig3 = figure;%('visible', 'off');
        lassoPlot(B,FitInfo,'PlotType','CV');
        print('./Figures/eps/LassoCV','-depsc')
        print('./Figures/jpegs/LassoCV','-djpeg','-r600')
        
        fig4 = figure;%('visible', 'off');
        lassoPlot(B,FitInfo,'PlotType','Lambda','XScale','log');
        print('./Figures/eps/LassoBetas','-depsc')
        print('./Figures/jpegs/LassoBetas','-djpeg','-r600')
    end
end