function[Sp,Im1o,Im2o] = RemoveBackground(S, Sp, QCdata, movieNum, Nave)
% Function: RemoveBackground.m
%
% Purpose: This script finds the average of Nave frames prior to the initial
% stream-containing frame and removes it from all frames. It is removing
% the background from each image.
%
% Inputs:
% 1) S - color frames of movie
% 2) Sp - black and white frames of movie
% 3) QCdata - structure to pixel intensity differnce
% 4) movieNum - index for movie number being processed
% 5) Nave - number of frames to averge over for background removal
%
% Outputs:
% 1) Sp - background removed black and white frames
% 2) Im1o - background removed black and white frame right before stream
% enters
% 3) Im2o - background removed black and white frame when stream first
% enters
%%
% Find average of N shots before the start
s = nan(Nave,size(QCdata(movieNum).Im1,1),size(QCdata(movieNum).Im1,2));
for i = 1:Nave
    s(i,:,:) = imcomplement(rgb2gray(S(QCdata(movieNum).indexes(3)-i).cdata));
end
ImAve = uint8(squeeze(mean(s,1)));

% remove average from each still frame
for i = 1:size(Sp,2)
    Sp(i).cdata = Sp(i).cdata - ImAve;
end

% background removed
Im1o = squeeze(Sp(QCdata(movieNum).indexes(3)).cdata);
Im2o = squeeze(Sp(QCdata(movieNum).indexes(3)+1).cdata);
