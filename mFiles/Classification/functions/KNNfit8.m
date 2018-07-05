function criterion = KNNfit8(X_train,y_train,X_test,y_test)
% Function: KNNfit8
%
% Purpose: Fit K-nearest neighbors with k = 8 on train data. Then test on
% test data. The function outputs the sum of the incorrect estimates. Also,
% data is combined then resamples so that 2 examples from each label are
% considered. Sequentialfs is nolonger performing true cross validation.
% Instead it is using bootstrapping without replacement. NOTE: I made
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
%% Combine then split data
[X_train,y_train,X_test,y_test] = combineThenSplit(X_train,y_train,X_test,y_test);

%normalize data
[mTest,nTest]=size(X_test);
[X_train,mu, s] = normalizeVars(X_train);
for i = 1:nTest 
    X_test(:,i) = X_test(:,i)-mu(i);
    X_test(:,i) = X_test(:,i)./s(i);
end

mdl = fitcknn(X_train,y_train,'Distance','euclidean','BreakTies','nearest');
mdl.NumNeighbors = 8;

[ypred,~,~] = predict(mdl,X_test);

criterion = sum(y_test(:)~=ypred(:)); % sum of misclassified values
end

