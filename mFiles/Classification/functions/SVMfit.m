function criterion = SVMfit(X_train,y_train,X_test,y_test)
% Function: SVMfit
%
% Purpose: This function fits an SVM model to the test data, then computes
% the sum of the misclassified values.
%
% Inputs:
% 1) X_train - training data features
% 2) y_train - training data response
% 3) X_test - test data features
% 4) y_test - test data response

% Outputs:
% 1) criterion - sum of misclassified values

mdl = fitcecoc(X_train,y_train,'verbose',2);
%performs SVM fit using 1 vs all binary learner (each class is postive, and
%all others negative)
ypred = predict(mdl,X_test);           % use model to predict on new test data
criterion = sum(y_test(:)~=ypred(:)); % sum of misclassified values
end