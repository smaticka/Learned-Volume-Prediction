function criterion = Ridgefit(X_train,y_train,X_test,y_test)
% Function: wt_percentDiff
%
% Purpose: Fit ridge regression on the train data. Then test on test
% data. The function outputs the sum of squared errors.
%
% Inputs:
% 1) X_train - training data features
% 2) y_train - training data response
% 3) X_test - test data features
% 4) y_test - test data response

% Outputs:
% 1) criterion - sum of squared error on the test datatuning = 0.31;

tuning = 0.31; % ridge parameter determined from "tuningParaTesting_Ridge.m"
beta = ridge(y_train,X_train,tuning,0);
ypred = X_test*beta(2:end)+beta(1);
criterion = sum((y_test-ypred).^2);    % specify the criterion to evaluate model performance. sum of squared error.
end

