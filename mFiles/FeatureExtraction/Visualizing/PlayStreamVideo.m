
for i = 1:length(RedStreamIm)
    
    clf;
    subplot(4,1,1);plot([1,size(Lall,1)],[sqrt(Ls2),sqrt(Ls2)]);hold on;
                     plot(Lall,'k','linewidth',1);
                     plot(i,Lall(i,1),'.r','markersize',15);
                     ylabel('# Pixels')
                     legend('L_{Movie Ave}','j^{th} cut','L_{j^{th} Frame}')
                 
    subplot(4,1,2:4);
                   Iplot = RedStreamIm(i).cdata;
                   imagesc(Iplot);colormap('gray');hold on;
                   for j=1:length(rowi)
                       plot([1,size(Iplot,2)],[rowi(j),rowi(j)],'g')
                       plot([points(i,j,1),points(i,j,2)],[rowi(j),rowi(j)],'r','linewidth',3)
                           
                   end
                   
                  plot([coli,coli],[1,size(Iplot,1)],'g')
                  daspect([1,1,1])
                  

                   
   
    frame = getframe(hand);
    im = frame2im(frame);
    [imind,cm]= rgb2ind(im,256);
    
    % write to gif file
    if i == 1
        imwrite(imind,cm,filename,'gif', 'Loopcount',inf);
    else
        imwrite(imind,cm,filename,'gif','WriteMode','append');
    end
    
    
end




