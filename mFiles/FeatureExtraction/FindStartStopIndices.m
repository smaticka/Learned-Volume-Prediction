% this script finds the indices for the frames containing the stream flow
% start and stop.
function[QCdata] = FindStartStopIndices(S,QCdata,movieNum,valPaperThresh,valMinThresh,numStartThresh,streamStartThresh,streamEndThresh)
% Function: FindStartStopIndices.m
%
% Purpose: Finds the indices for the frames containing the stream flow
% start and stop, and stores frames around these indicies.
%
% Inputs:
% 1) S - structure containing frames
% 2) QCdata - structure containing pixel intensity differences
% 3) movieNum - index for movie number being processed
% 4) valPaperThresh - threshold for pixel intensity difference for defining
% when paper label leaves frame.
% 5) numStartThresh - number of frames the start stream threshold must be
% exceeed by
% 6) streamStartThresh - threshold for pixel intensity difference defining stream start
% 7) streamEndThresh - threshold for pixel intensity difference defining
% stream end
%
% Outputs:
% 1) QCdata(movieNum).indexes - indicies for 1 before first pour frame, first
% pour frame, last pour frame, and one after last pour frame.
% 2) QCdata(movieNum).Im0  - frame before pour enters video
% 3) QCdata(movieNum).Im1  - frame the pour enters video
% 4) QCdata(movieNum).Im2  - frame after the pour first enters video
% 5) QCdata(movieNum).ImE0 - frame before the pour first exits video
% 6) QCdata(movieNum).ImE1 - frame pour first exits video
% 7) QCdata(movieNum).ImE2 - frame after the pour first exits video

%% Finds indicies for when stream enters and leaves view
indBefore = find(QCdata(movieNum).SpDiffNorm > valPaperThresh,1,'first'); %random index when paper is infront of camera
indFirstLow = indBefore + find(QCdata(movieNum).SpDiffNorm(indBefore:end) < valMinThresh,1,'first')-1;

NormRunMin = zeros(length(QCdata(movieNum).SpDiffNorm),1);
for i = indFirstLow:length(QCdata(movieNum).SpDiffNorm)-numStartThresh
    NormRunMin(i) = min(QCdata(movieNum).SpDiffNorm(i:i+numStartThresh-1));
end

indS1 = find(NormRunMin > streamStartThresh,1,'first');
indS2 = indS1+1;

indE1 = indS1 + find(QCdata(movieNum).SpDiffNorm(indS1:end) < streamEndThresh,1,'first')-1;

QCdata(movieNum).indexes = [indBefore, indFirstLow, indS1, indE1];

%% Saves images around first and last stream appearance for QC
QCdata(movieNum).Im0 = S(indS1-1).cdata;
QCdata(movieNum).Im1 = S(indS1).cdata;
QCdata(movieNum).Im2 = S(indS2).cdata;

QCdata(movieNum).ImE0 = S(indE1-1).cdata;
QCdata(movieNum).ImE1 = S(indE1).cdata;
QCdata(movieNum).ImE2 = S(indE1+1).cdata;
