function criterion = KNNfit_reg2(X_train,y_train,X_test,y_test)
% Function: KNNfit_reg2
%
% Purpose: Fit K-nearest neighbors with k = 2 on train data. Then test on
% test data. The function outputs the sum of squared errors. NOTE: We made
% different functions for each K-nearest model because they are passed to
% sequentialfs, so the k-value could not be passed as a parameter. 
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

%% Perform k-nearest
%find the nearest neighbor in X_train for each point in X_test
Ind = knnsearch(X_train,X_test,'k',2);

ypred = y_train(Ind); % find all predictions of y_test
ypred = mean(ypred,1); % take mean of all predictions of y_test

criterion = sum((y_test(:)-ypred(:)).^2);    % specify the criterion to evaluate model performance. sum of squared error.
end
