function [X_train,y_train,X_test,y_test] = combineThenSplit(X_train,y_train,X_test,y_test)
% Function: combineThenSplit
%
% Purpose: Combines data then splits it for classification problems so 2
%classifications per unique sample are in test set.
%
% Inputs:
% 1) X_train - training data features
% 2) y_train - training data response
% 3) X_test - test data features
% 4) y_test - test data response

% Outputs: 
% 1) X_train - training data features (2 samples from each class are data)
% 2) y_train - training data response (2 samples from each class are data)
% 3) X_test - test data features (2 samples from each class are data)
% 4) y_test - test data response (2 samples from each class are data)
%% Combining data that sequentialfs splits;
X = [X_test; X_train];
y = [y_test; y_train];

%% Sorting and finding unique index
[y, ind] = sort(y);
X = X(ind,:);
uniqueY = unique(y);

%% Resplit data finding two random indices for each unique volume tested
for i = 1:length(uniqueY)
     numSample(i) = length(find(y == uniqueY(i)));
     tempInd = randsample(numSample(i),2)+find(y == uniqueY(i),1, 'first')-1;
     if i == 1
        testInd = tempInd;
     else
         testInd = [testInd; tempInd];
     end
end

%% Split data into traning and test data
trainInd = true(length(y),1);
trainInd(testInd)=false;
X_test = X(testInd,:);
y_test = y(testInd);

X_train = X(trainInd,:);
y_train = y(trainInd);
end
