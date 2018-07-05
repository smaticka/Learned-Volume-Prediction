function[S, Sp, QCdata, dt] = PullFramesFromMov(video_folder,movieNum,movies,QCdata)
% Function: PullFramesFromMov.m
%
% Purpose:  This script pulls all of the frames from the .mov file and
% stores them in a 2 structures.
%
% Inputs:
% 1) video_folder - path to folder containing videos
% 2) QCdata - structure to pixel intensity differnce
% 3) movieNum - index for movie number being processed
% 4) movies - vector containing movie names in video_folder
%
% Outputs:
% 1) S - color frames of movie
% 2) Sp - black and white frames of movie
% 3) QCdata - stores pixel intensity differnce
% stream enters. Frames show detected edges
% 4) dt - time between frames
%%

disp(['Movie ', num2str(movieNum), ' out of ', num2str(numel(movies))])

% Get movie specs
vidObj = VideoReader([video_folder movies(movieNum).name]);
fps    = vidObj.FrameRate; % frames/second
dt     = 1/fps;            % seconds between frames
N      = floor(vidObj.Duration/dt); % number of frames

% create movie structure array to store stills
S = struct('cdata',zeros(vidObj.Height,vidObj.Width,3,'uint8'),'colormap',[]);
Sp = S;
SpDiffNorm = zeros(1,numel(Sp));
k = 1;

% idea: to store less, find initial frame in loop and only store after
% first frame. likewise, stop storing when last frame found
while hasFrame(vidObj)
    S(k).cdata  = readFrame(vidObj);
    Sp(k).cdata = imcomplement(rgb2gray(S(k).cdata));
    
    if k>1
        QCdata(movieNum).SpDiffNorm(k) =  norm(im2double(Sp(k).cdata)-...
            im2double(Sp(k-1).cdata)); %2-norm of differnce between two grayscale frames
    end
    
    k = k+1;
end
