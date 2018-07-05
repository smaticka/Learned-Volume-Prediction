% Script: Test_Krange_KNN.m
%
% Author: Kurt Nelson and Sam Maticka
%
% Purpose: This script compares the MSE error from K-nearest neighbors
% using different number of neighbors. For each k-value tested, forward
% selection with cross-validation is used to identify the best number of
% features. Multiple trials are also ran for each k-value because the
% results are somewhat sensitive to data splitting.
%%
clear;clc;close all;
load('../../DataFiles/data.mat')
addpath('../functions');

%% Parameters
numK       = 1:8;     % number of neighbors to consider
numTrial   = 1:200;   % number of trails to run on
numKfold   = 10;      % number of cross-validation folds used in feature selection
featuresIn = [1,2,3]; % features forced to be included in fit (Hierarchical principle)

%% Setup Data
X = X_train(:,2:end);
y = y_train;
y = y';

% Add interaction terms
X = addInteractions(X);
[m, n] = size(X);


%% Perform Feature selection using linear regression and LOOCV
% Model feature selection performing k-fold cross validation

for trial=numTrial
    trial
    for ii=numK
        % specify the k-nearest model used. Had to write seperate model for
        % each beacuase variables cannot be passed to sequentialfs.
        if ii==1
            model = @KNNfit_reg;
        elseif ii==2
            model = @KNNfit_reg2;
        elseif ii==3
            model = @KNNfit_reg3;
        elseif ii==4
            model = @KNNfit_reg4;
        elseif ii==5
            model = @KNNfit_reg5;
        elseif ii==6
            model = @KNNfit_reg6;
        elseif ii==7
            model = @KNNfit_reg7;
        elseif ii==8
            model = @KNNfit_reg8;
        end
        
        
        %% create possible feature sets
        % Rename and remove intercept feature
        
        % Perform feature selection and requires that all of the original features are included
        opts = statset('display','off');
        
        % Perform feature selection employing Hierarchical principle (keep features 1:3 in)
        [fs1,history1] = sequentialfs(model,X,y,'cv',numKfold,...
                         'keepin',featuresIn,'nfeatures',n,'options',opts);
        sse1 = min(history1.Crit);  % sum of squared error from the best fit (sse=mse, since 1 test point)
        
        % Compute the mean squared error predicted. the lowest of the 4 is the k chosen
        minCV(trial,ii) = min(history1.Crit);
    end
end

meanMinCV = mean(minCV);

fig1 = figure;%('visible', 'off');
fig1.PaperUnits = 'centimeters';
fig1.PaperPosition = [0 0 8 4];
set(gca,'box','on')
plot(numK(2:end),meanMinCV(2:end),'linewidth',1)
ylab = ylabel('CV');
set(ylab,'interpreter','Latex','FontSize',8)
xlab = xlabel('Number of Neighbors');
set(xlab,'interpreter','Latex','FontSize',8)
set(gca,'FontSize',6)
print('./Figures/eps/neighborTesting','-depsc')
print('./Figures/jpegs/neighborTesting','-djpeg','-r600')