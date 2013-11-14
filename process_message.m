function process_message(~,e)
    
    %convert json string to struct
    message_struct = loadjson(char(e.message)); 

   
    raw = base64decode(message_struct.imageBase64, '', 'java'); 
    
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
    
    % Draw bounding boxes
    if(~isempty(message_struct.bb))
        %disp('Received Bounding Box:')
        %disp(message_struct.bb)
        
        hold on
    
        x = abs(str2num(message_struct.bb.xcoord))*w;
        y = abs(str2num(message_struct.bb.ycoord))*h;
        wbb = abs(str2num(message_struct.bb.width))*w;
        hbb = abs(str2num(message_struct.bb.height))*h;

        rectangle('Position', [x y wbb hbb], 'LineWidth',2, 'EdgeColor','b')

        hold off
    
    end
    
end

