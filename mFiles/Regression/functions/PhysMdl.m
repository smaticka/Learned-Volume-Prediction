function criterion = PhysMdl(X_train,y_train,X_test,y_test)
% Function: PhyMdl
%
% Purpose: Fit the physical model on train data. Then test on
% test data. The function outputs the sum of squared errors.
%
% Inputs:
% 1) X_train - training data features
% 2) y_train - training data response
% 3) X_test - test data features
% 4) y_test - test data response

% Outputs:
% 1) criterion - sum of squared error on the test data
scale = nanmean(y_train)./nanmean(X_train); %Scaling for physics prediction
ypred = scale*X_test; % prediction on test data
criterion = sum((y_test-ypred).^2);    % specify the criterion to evaluate model performance. sum of squared error.
end

