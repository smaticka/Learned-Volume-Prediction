function criterion = PhysMdl_log(X_train,y_train,X_test,y_test)
% Function: PhysMdl
%
% Purpose: This function fits the physical model to the test data, then computes
% the sum of the misclassified values.
%
% Inputs:
% 1) X_train - training data features
% 2) y_train - training data response
% 3) X_test - test data features
% 4) y_test - test data response

% Outputs:
% 1) criterion - sum of misclassified values

scale = nanmean(y_train./X_train'); %Scaling for physics prediction
ypred = scale*X_test;

ypred = round(ypred*4)/4;
criterion = sum(y_test(:)~=ypred(:)); % sum of misclassified values.
end

