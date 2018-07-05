
% Script: PlotAndSplitData.m
%
% Author: Kurt Nelson and Sam Maticka
%
% Purpose: This script removes bad data, creates plots to visulaize the
% data, then splits good data into training and test data and saves it.
%
% Outputs:
% 1) data.mat - contains test and training data
%
close all; clear;clc;
data_folder = '../../DataFiles/'; % path to where processed data file features are
load([data_folder 'FitData_All.mat']) % data containing features and actual volumes for each pour
load([data_folder 'movieLabel_All.mat']) % movie labels for QC purposes
cuppcm3 = .00422675; % cups per cm^3

% switch
saveGoodData = false; % choose whether to save reduced data set

% badData gives movie numbers that will be removed. These indicies indicate
% outliers or features that were erroneously extracted. This should be
badData = [8443; 8446; 8447; 8457;...
    8463; 8467; 8476;...
    8486; 8489; 8490; 8502;...
    8510; 8511; 8513; 8520;...
    8524; 8530; 8538; 8559; 8571; 8376;
    8528; 8529; ...
    8658; 8662; 8666; 8669; 8671; 8672;...
    8674; 8686; 8695; 8699;8704; 8706;...
    8708; 8709; 8710; 8724; 8725; 8729; 8733; 8734; 8735;...
    8738; 8740; 8741; 8746; 8747; 8750; 8737];

%From first filming 8376
%Consider removing  8526; 8541;
%Errors associated with an incorrect ruler, front velocity, and length scale are below
%Bad ruler = 8458; 8461; 8462; 8472; 8496; 8507; 8509; 8510 (bad start too)
%Bad velocity = 8476; 8486; 8489; 8490; 8520 (bad start too); 8559;
%Bad length scale = 8513; 8511; 8463; 8446;

%From 3rd Filming
%Bad ruler = none
%Bad velocity = 8658; 8662; 8666; 8669; 8671; 8672; 8674; 8686; 8695; 8699;
%8704; 8706; 8708; 8709; 8710; 8724; 8725; 8735; 8741; 8746; 8747; 8750;
%8737;
%Bad length scale =
%Bad duration = 8729; 8733; 8734; 8735; 8738; 8740 8747; 8750;

%% Data Cleaning - finds indicies for good and bad data
count  = 1;
count2 = 1;
for i = 1:length(movieLabel)
    if isempty(find(badData==movieLabel(i),1))
        goodInd(count)=i;
        count=count+1;
    else
        badInd(count2)=i;
        count2 = count2+1;
    end
end

%% create subsets of data, useable and nonusable. Nan out back values
Xbad = X(badInd,:);
ybad = y(badInd);

Xgood = X(goodInd,:);
ygood = y(goodInd);
MovLabelgood = movieLabel(goodInd);

%Replace bad data with NaN's - keep NaN values in to retrain
%proper indexing for identifying bad features.
X(badInd,:) = NaN;
y(badInd)   = NaN;

%% Compute physics based prediction
Vol   = pi/4*X(:,4)*cuppcm3;
scale = nanmean(y'./Vol); % Scaling for physics prediction
yPhs  = scale*Vol;

featureDescription = {'Duration (s)','Speed (cm/s)','L^2_{ave} (cm^2)',...
    'L^2*Speed*Duration'};

%% Feature plots against label
fig1 = figure;
for i = 1:size(X,2)-1
    subplot(5,1,i);plot(X(:,i),'k');ylabel(featureDescription{i});
end
subplot(5,1,4);plot((Vol'-y)./y,'k');ylabel('% Error for Vol')
subplot(5,1,5);plot((yPhs'-y)./y,'k');ylabel('% Error for Scaled Vol')
xlabel('Movie Number')

fig2 = figure;
for i = 1:size(X,2)
    subplot(2,2,i);plot(y,X(:,i),'*k');hold on;ylabel(featureDescription{i});
    plot(ybad,Xbad(:,i),'*r');
end
legend('Good Data','Bad Data','First Filming','location','NW')
xlabel('Actual Volume (cups)')

%% Data fittig

% Remove NaN's for Ordinary least squares prediction
X = X(goodInd,:);
y = y(goodInd);

yPhs = yPhs(goodInd);
X(:,end) = pi/4*X(:,end)*cuppcm3;
X = [ones(size(X,1),1),X];

% Ordinary least squares optimum theta
theta = inv(X'*X)*X'*y';

yhat = X*theta;

%Percent error calculations
OLSerror = abs(yhat - y')./y'*100;
meanOLSerror = mean(OLSerror);

physicsError = abs(yPhs - y')./y'*100;
meanPhysicsError = mean(physicsError);


%% Prediction plots
fig3 = figure;
plot(y,yhat,'.b',y,yPhs,'.r',[0, 2.5],[0 2.5],'k','markersize',10)
xlabel('Measured Volume (cups)'); ylabel('Predicted Volume (cups)')
leg = legend('OLS prediction','Physics');

%% plot Features against each other
figure;
cnt = 0;
for i = 1:4
    for j = 1:4
        cnt = cnt+1;
        subplot(4,4,cnt);plot(X(:,i+1),X(:,j+1),'.k'); % X1 is intercept.
        xlabel(['X',num2str(i)])
        ylabel(['X',num2str(j)])
    end
end


%% split and save test and training data

% sort data
[y, ind] = sort(y);
X = X(ind,:);
uniqueY = unique(y);

% Find two random indices for each unique volume tested
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
movieLabel_test = movieLabel(testInd);
X_train = X(trainInd,:);
y_train = y(trainInd);
movieLabel_train = movieLabel(trainInd);

if saveGoodData
    save('data.mat','X_train','y_train','X_test','y_test','movieLabel_train','movieLabel_test')
end



