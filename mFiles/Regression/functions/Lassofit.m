function criterion = Lassofit(X_train,y_train,X_test,y_test)
% Function: Lassofit
%
% Purpose: Fit Laso regression on train data. Then test on
% test data. The function outputs the sum of squared errors. 
%
% Inputs:
% 1) X_train - training data features
% 2) y_train - training data response
% 3) X_test - test data features
% 4) y_test - test data response

% Outputs:
% 1) criterion - sum of squared error on the test data
%%
%% Normalize data
[~,nTest]=size(X_test);
[X_train,mu, s] = normalizeVars(X_train);
for i = 1:nTest %normalize test data
    X_test(:,i) = X_test(:,i)-mu(i);
    X_test(:,i) = X_test(:,i)./s(i);
end

[B,FitInfo] = lasso(X_train,y_train,'CV',10);  % train and create a linear regression model
ypred = X_test*B(:,FitInfo.Index1SE)+FitInfo.Intercept(FitInfo.Index1SE);           % use model to predict on new test data
criterion = sum((y_test-ypred).^2);    % specify the criterion to evaluate model performance. sum of squared error.
end

