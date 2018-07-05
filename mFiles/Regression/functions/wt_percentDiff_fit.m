function criterion = wt_percentDiff_fit(X_train,y_train,X_test,y_test)
% Function: wt_percentDiff
%
% Purpose: Fit weighted least squares, where the weight is chosen so the
% minimization is on the percent differnce. Then test on test data. The
% function outputs the sum of squared errors.
%
% Inputs:
% 1) X_train - training data features
% 2) y_train - training data response
% 3) X_test - test data features
% 4) y_test - test data response

% Outputs:
% 1) criterion - sum of squared error on the test data
%
% train and create a linear regression model using the expected value as the weight
mdl = fitlm(X_train,y_train,'linear','weights',y_train); 
ypred = predict(mdl,X_test);         % use model to predict on new test data
criterion = sum((y_test-ypred).^2);  % specify the criterion to evaluate model performance. sum of squared error.
end

