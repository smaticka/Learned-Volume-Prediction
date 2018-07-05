% Script: ProcessVideo.m
%
% Author: Kurt Nelson and Sam Maticka
%
% Purpose: This script uses basic image processing to extract three
% fundamental features (pour duration, front speed, and stream area) from
% videos of a poured liquid. The script does the following: 1) Finds the
% start and stop frames of the pour by monitoring pixel intensity
% differences between images, 2) computes the speed of the stream by
% tracking the front as it first enters the video, 3) uses edge detection
% to determine the stream width at multiple heights, which is then averged
% and squared to estimate the streams cross-sectional area. The script
% also determines a pixel to length conversion so that all features have
% units of seconds or cm.
%
% Outputs:
% 1) FitData.mat - contains features (stored in X) and volumes for each
% video (stored in y)
% 2) QCdata.mat -  contains stop and stop indicies and images for stream
% pour. This is used for data quality control
%
clear;clc;close all
tic

%% Define parameters for processing video
video_folder = '../../../Videos/FilmSession_Dec2/'; % folder storing videos

% Flags
plotImages   = true;   % plot images
saveQCdata   = false;  % save QC data
saveFeatures = false;  % save X and y, which contain features and responses

Nave = 5; % number of frames to averge over for background subtraction

% Threshold values for finding start and stop of stream
streamStartThresh = 6;   % threshold: defining stream start
numStartThresh    = 10;  % # of forward frames streamStartThresh must be exceeded
valPaperThresh    = 25;  % threshold: finding frame when paper label is moving
valMinThresh      = 2;   % threshold: finding point after paper label leaves view but before stream
streamEndThresh   = 1.8; % threshold: when stream ends

% Values for ruler calculation
rulerLength = 4;
redTol      = 50;
running     = 30;

% Threshold value for increasing contrast
contrastThresh = 15; 

% threshold width of stream
WidthThreshLow  = .12;  % cm, lower limit of lengths to include
WidthThreshHigh = 3;    % cm, upper limit of lengths. only flag if bigger than this

% parameters for dilation
se90 = strel('line', 3, 90);
se0  = strel('line', 3, 0);

%% Locate Videos to be processed
movies = dir([video_folder '*.MOV']); % all *.MOV files


%% Vector of volumes
% vector containing volume for individual volumes tested during
% experiments. The vector is ordered by time. This should be automated in
% the future by using computer vision to recognize the volume indicated by
% the index card used to label each pour.
ytemp = [ones(10,1)*0.25; ones(10,1)*0.5; ones(12,1)*0.75; ones(11,1)*1;...
    ones(12,1)*1.25; ones(13,1)*1.5; ones(11,1)*1.75; ones(12,1)*2; ones(12,1)*2.25;...
    ones(10,1)*2.5];

%% Image Processing
QCdata = struct([]);
for movieNum = 70:93 %1:numel(movies)
    % Extract movie frames and store frames in a structure (S: grayscale; Sp: invert of S)
    % QCdata.SpDiffNorm: norm of difference between consecutive frames   
    [S, Sp, QCdata, dt] = PullFramesFromMov(video_folder,movieNum,movies,QCdata);
    
    % Finds 1st 2 frames of stream in view and last frame of stream in view
    % indS1, indS2, indE1, respectively.    
    [QCdata] = FindStartStopIndices(S,QCdata,movieNum,valPaperThresh,valMinThresh,numStartThresh,streamStartThresh,streamEndThresh);
    % QCdata(movieNum).indexes: contains indices
    % Saves frames buffering stream start and stop events.
    % QCdata(movieNum).Im## holds each image
    
    % Rewrites Sp after removing background from each frame
    % stores 1st 2 stream frames Im1o and Im2o for plotting
    [Sp,Im1o,Im2o] = RemoveBackground(S, Sp, QCdata, movieNum, Nave);
    
    % Finds length of pixel and location of ruler in frame
    [lenPerPix,tapeColumnInd,xRight,tape1End,tape2Start,runningMaxBack] = FindPixelLength(S,QCdata,movieNum,rulerLength);
    QCdata(movieNum).lenPerPix = lenPerPix;
    
    % Find representative area for stream
    [Ls2,RedStreamIm,QCdata,Lall,rowi,coli,points] = IsolateStreamEdges(S, QCdata, movieNum, WidthThreshLow,WidthThreshHigh,contrastThresh,tapeColumnInd,se90,se0,Im1o,Im2o);
    % average length scale (pixels) squared: Ls2
    % Final images are stored in new structure, RedStreamIm
    % Lall, is the length from all frames and all cuts
    % coli is column index to search to the right of. rowi is the row index
    % of each slice to take a length from
    
    
    %% Compute front speed
    [m1,n1] = find(QCdata(movieNum).BW1fill==1);
    [m2,n2] = find(QCdata(movieNum).BW2fill==1);
    pixDif  = max(m2)-max(m1);
    frontSpeed = pixDif*lenPerPix/dt;
    
    %% Convert length squared to true length
    Ls2true = Ls2*lenPerPix^2;
    
    %% Calculate Duration
    Duration = (QCdata(movieNum).indexes(4)-QCdata(movieNum).indexes(3))*dt;
    
    %% Calculate Volume Proxy (interaction term)
    Vol = Ls2true*frontSpeed*Duration;
    
    %% Create feature matrix X and output vector y
    X(movieNum,1) = Duration; %first column of X is stream duration
    X(movieNum,2) = frontSpeed; %second column of X is front speed
    X(movieNum,3) = Ls2true; % third column of X is a representative length scale
    X(movieNum,4) = Vol; %fourth column of X theoretical volume estimate
    
    %% Fill y vector
    y(movieNum) = ytemp(movieNum);
    
    %% Plot: start/stop frames, velocity edges used, ruler calibration
    if plotImages
        %Figure for stream start/stop check
        Fig1 = figure;%('visible', 'off');
        subplot(2,2,1);imshow(QCdata(movieNum).Im0);
        subplot(2,2,2);imshow(QCdata(movieNum).Im1);
        subplot(2,2,3);imshow(QCdata(movieNum).ImE1);
        subplot(2,2,4); 
        P = QCdata(movieNum).SpDiffNorm;
        plot(P);
        hold on;
        plot(QCdata(movieNum).indexes(3),P(QCdata(movieNum).indexes(3)),'.g','markersize',20)
        plot(QCdata(movieNum).indexes(4),P(QCdata(movieNum).indexes(4)),'.g','markersize',20)
        ylab = ylabel('$\Delta$ Intensity');
        set(ylab,'interpreter','Latex','FontSize',10)
        xlab = xlabel('Frame');
        set(xlab,'interpreter','Latex','FontSize',10)
            
         print(['./Figures/jpegs/DurationCheck/durationCheck' movies(movieNum).name(end-7:end-4)],...
            '-djpeg','-r600')
        
        %Figure for velocity check
        fig2 = figure;%('visible', 'off');
        subplot(2,2,1);imshow(QCdata(movieNum).Im1);
        subplot(2,2,2);imshow(QCdata(movieNum).Im2);
        subplot(2,2,3);imshow(QCdata(movieNum).BW1fill);
        subplot(2,2,4);imshow(QCdata(movieNum).BW2fill);
         print(['./Figures/jpegs/VelocityCheck/velCheck' movies(movieNum).name(end-7:end-4)],...
             '-djpeg','-r600')
        
        %Figure for ruler check
        fig3 = figure;%('visible', 'off');
        fig.PaperUnits = 'centimeters';
        fig.PaperPosition = [0 0 8 7];
        set(gca,'box','on')
        clf
        ha = tight_subplot(1,2,[0.03 .02],[.07 .04],[.06 .05]);
        
        axes(ha(1));
        imshow(S(QCdata(movieNum).indexes(2)).cdata)
        hold on;
        plot([xRight(tape1End) xRight(tape2Start)],[tape1End tape2Start],'b','linewidth',1)
        
        axes(ha(2));
        imshow(runningMaxBack)
        hold on;
        plot(xRight,1:length(xRight),'r','linewidth',1)
         print(['./Figures/jpegs/RulerCheck/RulerLength' movies(movieNum).name(end-7:end-4)],'-djpeg','-r600')
        
         close all;
    end
    %%
end
toc

if saveQCdata
    save('QCdata_3rdFilm.mat','QCdata')
end

if saveFeatures
    save('FitData_3rdFilm.mat','X','y')
end
 