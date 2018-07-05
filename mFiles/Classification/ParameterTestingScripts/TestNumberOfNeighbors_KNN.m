% Script: TestNumberOfNeighbors_KNN.m
%
% Author: Kurt Nelson and Sam Maticka
%
% Purpose: This script compares the classification error from K-nearest
% neighbors using different number of neighbors. For each k-value tested,
% forward selection with cross-validation is used to identify the best
% number of features. Multiple trials are also ran for each k-value because
% the results are somewhat sensitive to data splitting.
%% Variables
numK = 1:8; % number of neighbors to consider
numTrial = 1:200; % number of trails to run on
numKfold  = 9; % number of cross-validation folds used in feature selection
featuresIn = [1,2,3]; % features forced to be included in fit (Hierarchical principle)

%% Setup data
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
%% Perform Feature selection using cross validation
opts = statset('display','off');

for trial=numTrial
    trial
    
    for i=numK % run through all models
        if i==1
            model = @KNNfit;
        elseif i==2
            model = @KNNfit2;
        elseif i==3
            model = @KNNfit3;
        elseif i==4
            model = @KNNfit4;
        elseif i==5
            model = @KNNfit5;
        elseif i==6
            model = @KNNfit6;
        elseif i==7
            model = @KNNfit7;
        elseif i==8
            model = @KNNfit8;
        end
        
        
        
        % Perform feature selection employing Hierarchical principle (keep features 1:3 in)
        [fs1,history1] = sequentialfs(model,X,y,'cv',numKfold,...
            'keepin',featuresIn,'nfeatures',n,'options',opts);
        sse1 = min(history1.Crit);  % sum of squared error from the best fit (sse=mse, since 1 test point)
        
        
        % Compute the mean squared error predicted. the lowest of the 4 is the k chosen
        minCV(trial,i) = min(history1.Crit);
    end
end

%% Plot classification error vs number of neighbors
meanMinCV = mean(minCV);
fig1 = figure;%('visible', 'off');
fig1.PaperUnits = 'centimeters';
fig1.PaperPosition = [0 0 8 4];
set(gca,'box','on')
plot(numK(1:2:end),meanMinCV(1:2:end),'linewidth',1)
ylab = ylabel('CV');
set(ylab,'interpreter','Latex','FontSize',8)
xlab = xlabel('Number of Neighbors');
set(xlab,'interpreter','Latex','FontSize',8)
set(gca,'FontSize',6)
print('./Figures/eps/neighborTesting','-depsc')
print('./Figures/jpegs/neighborTesting','-djpeg','-r600')






