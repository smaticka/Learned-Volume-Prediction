
load('QCdata2.mat')

figure;

movN = 80;

P = QCdata(movN).SpDiffNorm;
N = length(P);

subplot(3,1,1);

for i = 1:N
    clf
    subplot(3,1,1);plot(P);hold on;
    plot(i,P(i),'.r');
    plot(QCdata(movN).indexes(3),P(QCdata(movN).indexes(3)),'.g','markersize',20)
    plot(QCdata(movN).indexes(4),P(QCdata(movN).indexes(4)),'.g','markersize',20)
    
    subplot(3,1,2:3);
    imshow(S(i).cdata);
    pause(.01)
end
