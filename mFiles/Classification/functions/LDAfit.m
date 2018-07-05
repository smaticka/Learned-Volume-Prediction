function criterion = LDAfit(X_train,y_train,X_test,y_test)
% Function: LDAfit
%
% Purpose: This function fits a LDA model to the test data, then computes
% the sum of the misclassified values. 
%
% Inputs:
% 1) X_train - training data features
% 2) y_train - training data response
% 3) X_test - test data features
% 4) y_test - test data response

% Outputs:
% 1) criterion - sum of squared error on the test data
%% Combine then split data
[X_train,y_train,X_test,y_test] = combineThenSplit(X_train,y_train,X_test,y_test);

lda = fitcdiscr(X_train,y_train,'DiscrimType','linear'); %  GDA, assumes normal distribution
[ypred,~,~] = predict(lda,X_test);

criterion = sum(y_test(:)~=ypred(:)); % sum of misclassified values
end

