
%% Print an image in 300ppi with white background

function writeFig300ppi(figNo, fileName)

    figureNameTif = [fileName, char('.tif')];

    %make the backgroung white
    set(figNo,'color','w');

    %get a frame of the image
    f=getframe(figNo);

    colormap(f.colormap);

    %print image with 300ppi resolution
    imwrite(f.cdata, figureNameTif, 'Resolution', 300); 
end