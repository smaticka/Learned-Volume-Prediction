function [X] = addInteractions(X)
% Function: addInteractions
%
% Purpose: Qdds all two-way and three-way interactions to X
%
% Inputs:
% 1) X - containing only fundamental features
%
% Outputs:
% 1) X - now containing all 2-way and 3-way interactions
%%
%Adds columns to X so that all second order terms of original features are included
X(:,5) = X(:,1).^2; %square of duration
X(:,6) = X(:,2).^2; %square of front speed
X(:,7) = X(:,3).^2; %square of area

%Adds all two-way interaction terms to X
X(:,8) = X(:,1).*X(:,2); %duration and front speed
X(:,9) = X(:,1).*X(:,3); %duration and area
X(:,10) = X(:,2).*X(:,3); %front speed and area
end

