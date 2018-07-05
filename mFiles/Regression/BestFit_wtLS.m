% Script: BestFit_wtLS.m
%
% Author: Kurt Nelson and Sam Maticka
%
% Purpose: This script test the best fit weighted least squares model on
% the training data by computing the test root mean squared error (RMSE). 
% It also computes the test RMSE for the physical model for comparison.
%
%% This script uses 10-fold cross validation to test the bandwidth parameter for local
%  weighted regression.
close all; clear;clc

load('../../DataFiles/data.mat')
addpath('../functions');

%% Perform Feature selection using linear regression and LOOCV
% Model feature selection performing k-fold cross validation
bandwidth    = 2.2; % best fit bandwidth parameter - determined from "BandwidthTesting_wtOLS.m"
featuresKeep = [1,2,3,4,5,9,10];% X features to keep - determined from "GeneralRegressionFits.m" using forward selection

% Remove intercept term
X_test  = X_test(:,2:end);
X_train = X_train(:,2:end);

% Adds Interaction terms
X_test  = addInteractions(X_test);
X_train = addInteractions(X_train);

% Keep only desired features
X_train = X_train(:,featuresKeep);
X_test  = X_test(:,featuresKeep);

%% Physical Prediction as baseline model
scale = nanmean(y_train./X_train(:,4)'); % Scaling for physics prediction
ypred = scale*X_test(:,4);
RMSE_physical  = sqrt(mean((y_test-ypred').^2));

%% Normalize data
[mTest,nTest]   = size(X_test);
[mTrain,nTrain] = size(X_train);
[X_train,mu, s] = normalizeVars(X_train);

for ii = 1:nTest
    X_test(:,ii) = X_test(:,ii)-mu(ii);
    X_test(:,ii) = X_test(:,ii)./s(ii);
end

%% Compute test RMSE for weighted least squares
SSE = 0; % sum of squared errors

for ii = 1:mTest %loop through test examples and compute the sum or squared error
    
    % computing weights for example i
    temp = X_train-repmat(X_test(ii,:),mTrain,1);
    
    for jj = 1:mTrain
        w(jj) = temp(jj,:)*temp(jj,:)';
    end
    
    w = exp(-w/(2*bandwidth^2)); % weights to use in model
    
    mdl = fitlm(X_train,y_train,'linear','weights',w); % fit a weighted least squares model
    ypred(ii) = predict(mdl,X_test(ii,:));   % use model to predict on new test data
    SSE = SSE + (y_test(ii)-ypred(ii)).^2;   % specify the criterion to evaluate model performance
end

RMSE_wtLS = sqrt(SSE/mTest);


% %% Check to see if round our best regression model does better than our 
% %  best classification model
% 
% % Round to nearest integer category, then revert back to 1/4 c increments
% classPred = round(4*ypred)/4; 
% % Calculate average missclassification error
% MissClassError = sum(y_test(:)~=classPred(:))./length(y_test);
% 
% % compare WLS to classification results
% figure;subplot(1,2,1);
%     plot(ypred,y_test,'.k','markersize',20);hold on;
%     plot([0,2.5],[0,2.5],'-.k');
%     axis square;
%     grid on; grid minor
%     legend(['MSE error: ',num2str(RMSE_wtLS)],'Perfect Fit','location','NW');
%     xlabel('Actual Volume (c)');
%     ylabel('Predicted Volume (c)');
%     title('WLS')
%    
%     subplot(1,2,2);
%     plot(classPred,y_test,'.k','markersize',20);hold on;
%     plot([0,2.5],[0,2.5],'-.k');
%     axis square
%     legend(['missclassification error: ',num2str(MissClassError)],'location','NW')
%     title('Classification: Rounded WLS Prediction')
%     grid on; grid minor
% 




