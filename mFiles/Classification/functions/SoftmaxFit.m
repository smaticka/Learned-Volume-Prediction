function criterion = SoftmaxFit(X_train,y_train,X_test,y_test)
% Function: SoftmaxFit.m
%
% Purpose: This function fits Softmax to the test data, then computes
% the sum of the misclassified values.
%
% Inputs:
% 1) X_train - training data features
% 2) y_train - training data response
% 3) X_test - test data features
% 4) y_test - test data response

% Outputs:
% 1) criterion - sum of misclassified values

%Splits and recombines data so training set has two of each label
[X_train,y_train,X_test,y_test] = combineThenSplit(X_train,y_train,X_test,y_test);

% fit coefficients, B for a multinomial logistic regression model
B = mnrfit(X_train,y_train,'model','ordinal'); 

% calculates probability for each observation to be 1 of k categories.
prob = mnrval(B,X_test,'model','ordinal'); 
% prob is nxk

% Choose category with highest probability
[~,ypred] = max(prob,[],2); % column index corresponds to category index

% error: ratio of wrongly categorized data
criterion = sum(y_test(:)~=ypred(:));
end
