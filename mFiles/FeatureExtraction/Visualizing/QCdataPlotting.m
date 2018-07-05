clear;clc;close all;
load('QCdata2.mat')

fig1 = figure;
fig1.PaperUnits = 'centimeters';
fig1.PaperPosition = [0 0 25 25];
set(gca,'box','on')
clf
ha = tight_subplot(5,1,[0.03 .02],[.07 .04],[.06 .05]);

count = 1;
xlim = [0 225];
ylim = [0 80];

for numFig = 1:numel(QCdata)
    if mod(numFig,3) == 1
        axes(ha(count))
        
        if count == 5
            xlab = xlabel('frame');
            set(xlab,'interpreter','Latex','FontSize',12)
            set(gca,'xlim',xlim,'ylim',ylim)
        else
            set(gca,'xticklabel',[],'xlim',xlim,'ylim',ylim)
        end
        ylab = ylabel('$|\Delta (\hbox{pixels})|_{2}$');
        set(ylab,'interpreter','Latex','FontSize',12)
        set(gca,'FontSize',12)
        hold on
        count = count+1;
    end
    plot(1:length(QCdata(numFig).SpDiffNorm),QCdata(numFig).SpDiffNorm,'linewidth',1)
    plot(QCdata(numFig).indexes(3),QCdata(numFig).SpDiffNorm(QCdata(numFig).indexes(3)),'.k','markersize',20)
    plot(QCdata(numFig).indexes(4),QCdata(numFig).SpDiffNorm(QCdata(numFig).indexes(4)),'.k','markersize',20)
end

print('./Figures/eps/2normDiff','-depsc')
print('./Figures/jpegs/2normDiff','-djpeg','-r600')

%%Start Check
count = 1;
for numFig = 1:numel(QCdata)
    fig = figure;
    fig.PaperUnits = 'centimeters';
    fig.PaperPosition = [0 0 12 7];
    set(gca,'box','on')
    clf
    ha = tight_subplot(1,3,[0.03 .02],[.07 .04],[.06 .05]);
    
    axes(ha(1))
    imshow(QCdata(numFig).Im0)
    
    axes(ha(2))
    imshow(QCdata(numFig).Im1)
    
    axes(ha(3))
    imshow(QCdata(numFig).Im2)
    
    print(['./Figures/eps/StartCheck1/StartFrames' num2str(count)],'-depsc')
    print(['./Figures/jpegs/StartCheck1/StartFrames' num2str(count)],'-djpeg','-r600')
    
    count = count+1;
    close all;
end

%%Start Check 2
count = 1;
for numFig = 1:numel(QCdata)
    fig = figure;
    fig.PaperUnits = 'centimeters';
    fig.PaperPosition = [0 0 8 7];
    set(gca,'box','on')
    clf
    ha = tight_subplot(1,2,[0.03 .02],[.07 .04],[.06 .05]);
    
    axes(ha(1))
    imshow(QCdata(numFig).BW1fill)
    
    axes(ha(2))
    imshow(QCdata(numFig).BW2fill)
    
    print(['./Figures/eps/StartCheck2/EndFrames' num2str(movieNum)],'-depsc')
    print(['./Figures/jpegs/StartCheck2/EndFrames' num2str(movieNum)],'-djpeg','-r600')
    
    count = count+1;
    close all;
end

% %%Start Check 2
% count = 1;
% for numFig = 1:numel(QCdata)
% fig = figure;
% fig.PaperUnits = 'centimeters';
% fig.PaperPosition = [0 0 12 7];
% set(gca,'box','on')
% clf
% ha = tight_subplot(1,3,[0.03 .02],[.07 .04],[.06 .05]);
%
%  axes(ha(1))
%  imshow(QCdata(numFig).Im0)
%
%  axes(ha(2))
%  imshow(QCdata(numFig).Im1)
%
%  axes(ha(3))
%  imshow(QCdata(numFig).Im2)
%
%  print(['./Figures/eps/EndCheck/EndFrames' num2str(count)],'-depsc')
%  print(['./Figures/jpegs/EndCheck/EndFrames' num2str(count)],'-djpeg','-r600')
%
%  count = count+1;
%  close all;
% end
