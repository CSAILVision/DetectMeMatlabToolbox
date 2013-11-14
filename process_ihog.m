function process_ihog(~,e)
   
    raw = base64decode(char(e.message), '', 'java'); 
    
    % decode image stream using Java
    jImg = javax.imageio.ImageIO.read(java.io.ByteArrayInputStream(raw));
    h = jImg.getHeight;
    w = jImg.getWidth;
    
    % set dimensions of the current handle
    hfig = gcf;
    pos = get(hfig, 'Position');
    if(pos(1,3) ~= w)
        pos(1,3) = w;
        pos(1,4) = h;
        set(hfig, 'Position', pos);
    end

    p = typecast(jImg.getData.getDataStorage, 'uint8');
    img = permute(reshape(p, [3 w h]), [3 2 1]);
    img = img(:,:,[3 2 1]);
    image(img)
    
    %send it back
    
    
end

