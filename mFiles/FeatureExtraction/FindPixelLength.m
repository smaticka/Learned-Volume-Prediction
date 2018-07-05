
function[lenPerPix,tapeColumnInd,xRight,tape1End,tape2Start,runningMaxBack] = FindPixelLength(S,QCdata,movieNum,rulerLength)
% Function: FindPixelLength.m
%
% Purpose:  This script finds the right edge of the two pieces of green
% tape on the ruler, then computes the gap between the two pieces of tape
% to compute a length to pixel conversion.
%
% Inputs:
% 1) S - color frames of movie
% 2) QCdata - structure to pixel intensity differnce
% 3) movieNum - index for movie number being processed
% 4) rulerLength - length between pieces of green tape on ruler. This is
% used as the reference length.
%
% Outputs:
% 1) lenPerPix - length per pixel conversion
% 2) tapeColumnInd - column index for bottom right corner of top tape piece
% 3) xRight - x coordinate for top tape bottom edge
% 4) tape1End - y corrdinate for top tape bottom edge
% 5) tape2Start - y corrdinate for bottom tape top edge
%%
runningMax = 30; %number of frames to look over for running max
redTol = 50; %threshold: defining stream start

red  = S(QCdata(movieNum).indexes(2)).cdata(:,:,1);


[m,n] = size(red);

clear xRightNans temp
%Finds running max of red intensity looking backwards 
for i = 1:m
    for j =1+runningMax:n
        runningMaxBack(i,j) = max(red(i,j-runningMax:j));
    end
end

%Finds when backwards running max is less than redTol (i.e. tape edge)
xRight = zeros(m,1); %xRight is the x coordinate of the right edge of the tape
for i = 1:m
    if(isempty(find(runningMaxBack(i,runningMax+1:end)<redTol,1,'last')))
        xRight(i) = NaN;
    else
        xRight(i) = find(runningMaxBack(i,runningMax+1:end)<redTol,1,'last')+runningMax;
    end
end


temp(isnan(xRight)) = -1;
tape1Start = find(temp == 0,1,'first'); %finds starting y coordinate of the tape

%Finds mean x value of the vertical tape edge, and sets values more than 25 pixels back from the mean to NaN 
%This removes horizontal tape edges
xRight(xRight<nanmean(xRight(tape1Start+100:tape1Start+150))-25)=NaN; 

xRightNans(isnan(xRight)) = -1;
%Finds bottom right corner of the top tape piece
tape1End = find(xRightNans(tape1Start+100:end) == -1,1,'first')+tape1Start+98;

%Finds  top right corner of bottom tape piece
tape2Start = find(xRightNans(tape1End+100:end) == 0,1,'first')+tape1End+99;

%Computes euclidian distance 
numPix = sqrt((xRight(tape1End)-xRight(tape2Start))^2+(tape1End-tape2Start)^2);

%Computes pixel length
lenPerPix = rulerLength/numPix;

if isnan(lenPerPix)
    lenPerPix = QCdata(movieNum-1).lenPerPix;
end

%stores tape column index for use in IsolateStreamEdges
tapeColumnInd = xRight(tape2Start);