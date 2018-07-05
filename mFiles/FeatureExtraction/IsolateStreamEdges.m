function[Ls2,RedStreamIm,QCdata,Lall,rowi,coli,points] = IsolateStreamEdges(S, QCdata, movieNum, WidthThreshLow,WidthThreshHigh,contrastThresh,tapeColumnInd,se90,se0,Im1o,Im2o)
% Function: IsolateStreamEdges.m
%
% Purpose:  This script isolates the stream by finding the edges of the stream after
% enhancing, finding edges, dilating/smoothing edges, and filling in the
% stream. It then computes a representative area by averaging stream widths
%
% Inputs:
% 1) S - structure containing frames
% 2) QCdata - structure to store black and white images
% 3) movieNum - index for movie number being processed
% 4) WidthThreshLow - minimum stream length accepted for averaging
% 5) WidthThreshHigh - maximum stream length accepted for averaging
% 6) contrastThresh - black and white contrast threshold for defining where
% stream is
% 

% Outputs:
% 1) Ls2 - estimate for stream cross-sectional area
% 2) RedStreamIm - Red frames for video
% 3) QCdata - stores black and white images for first and second frame the
% stream enters. Frames show detected edges
%%
% convert threshold limit from cm to pixels
PixWidthLow  = WidthThreshLow/QCdata(movieNum).lenPerPix;  % pixels, lower limit of lengths to include
PixWidthHigh = WidthThreshHigh/QCdata(movieNum).lenPerPix; % pixels, upper limit of lengths. only flag if bigger than this

% create structure to store new data
RedStreamIm = struct('cdata',zeros(size(S(100).cdata(:,:,1)),'uint8'),'colormap',[]);

% Get background image to remove
Iback = squeeze(S(QCdata(movieNum).indexes(2)).cdata(:,:,1));

% Row indices to pull length scales from
VertRatio = 2.2; % only analyze top 1/VertRatio of frame
NumLines  = 20; % approximate number of lines to take lengths from
dr    = ceil(size(Iback,1)/VertRatio/NumLines);  % row index interval
rowi  = 5:dr:size(Iback,1)/VertRatio; % row indices to take length samples from  

% Column limit to search for bright areas
coli = tapeColumnInd + 80;  % chop left third of image (change based on set up)

% loop through 1 frames after the start to finish of stream
cnti  = 0; % number of frame Lengths recorded
cntj  = 0; % number of cs-cut Lengths recorded
cntf  = 0; % number of flags to count. flag for a large stream width
L2i   = 0; % initiate L squared
iter  = 0; % number of loops performed (index for storing) 
Lall  = nan(QCdata(movieNum).indexes(4)-QCdata(movieNum).indexes(3),length(rowi)); 
Lrow  = nan(QCdata(movieNum).indexes(4)-QCdata(movieNum).indexes(3),length(rowi),size(Iback,1));
points = nan(QCdata(movieNum).indexes(4)-QCdata(movieNum).indexes(3),length(rowi),2); % start and end points in line of stream

for i = QCdata(movieNum).indexes(3)+1:QCdata(movieNum).indexes(4)
    iter = iter+1;
    
    % pull individual frame
    Imi = squeeze(S(i).cdata(:,:,1)); % Red of RGB image
    
    % Remove background image
    Imi = Iback - Imi;
   
    cntj = 0;
    L2j  = 0; % initiate L squared for frame average
    % Find width of bright areas passed ruler (can maybe vectorize)
    for j=1:length(rowi)
        % find areas outsie of bright parts
        ind  = find(Imi(rowi(j),coli:end) < contrastThresh);
        if isempty(ind)|| length(ind)==1
            continue
        else
        % find gap between the dark areas (width of bright area)
        dind = diff(ind);
        
        % Pull the widest area in the row cross-section (presumably the stream)
        [Lj,mind]   = max(dind); % length for the jth cut in the ith frame
        
        % Record start and stop location of width line recorded
        points(iter,j,:) = [coli+ind(mind),coli+ind(mind+1)];
        
        % Only include widths greater than threshold value
        if Lj < PixWidthLow
            continue % don't add anything to the mean
        else
            if Lj > PixWidthHigh % make flag of movie number and frame with big length
                cntf = cntf +1;
                LengthFlag.(sprintf('%s',['MovieNum',num2str(movieNum)])).frameNum(cntf) = i;
                LengthFlag.(sprintf('%s',['MovieNum',num2str(movieNum)])).LengthCM(cntf) = Lj*lenPerPix;
            end
            L2j = L2j + Lj^2;
            cntj = cntj + 1;
            Lall(iter,j) = Lj;
        end
        
        % Store widths of all bright areas
        Lrow(iter,j,1:length(dind)) = dind;
        end
        
    end
    
    % only add frame-average to total average if lengths were recorded
    if cntj==0
        continue
    else
        L2i = L2i + L2j/cntj; % add the average of the j cuts to the running frame average
        cnti = cnti+1;
    end
    
    % Store Final image
    RedStreamIm(iter).cdata = Imi;

end

Ls2 = L2i/cnti; % the average L^2 (units: pixels^2)

% Make more contrasted. 
Im1en = Im1o;
Im2en = Im2o;
Im1en(Im1o>=contrastThresh) = 256;    Im1en(Im1o<contrastThresh) = 0;
Im2en(Im2o>=contrastThresh) = 256;    Im2en(Im2o<contrastThresh) = 0;
% 0:   black
% 256: white (stream and noise)


%% Find Edges
BW1 = edge(Im1en,'Canny',.95);
BW2 = edge(Im2en,'Canny',.95);

%% Dilate the image (for 2 images, this section takes .7 seconds)
BW1dil = imdilate(BW1, [se90 se0]);
BW2dil = imdilate(BW2, [se90 se0]);

BW1dil(1,:)=true;
BW2dil(1,:)=true;

%% fill holes
BW1fill = imfill(BW1dil, 'holes');
BW2fill = imfill(BW2dil, 'holes');

    %% Save images for QC check of front speed calculation
QCdata(movieNum).BW1fill = BW1fill;
QCdata(movieNum).BW2fill = BW2fill;

