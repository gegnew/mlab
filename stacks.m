

%% initialize data structure
stims = struct('Gratrev', [], 'Curvplay', []);

%% initialize variable for gabor
[x, y] = meshgrid(-699:700); % Screen Coordinate System that matches images in file
xpos= 0; % x position of the center of the receptive field
ypos= 0; % y position of the center of the receptive field
w= +inf;
A= 1;
ori = [0:15:165];
sf = [0.0042, 0.0084, 0.0168, 0.0336, 0.0672, 0.1345, 0.2689];
ph = [0:90:270];
var = {};
d= ((x - xpos).^2 + (y - ypos).^2).^0.5; % using model neuron xpos    

%% generate gabor stack
for i = 1:11
    for j = 1:7
        for k  = 1:4            
            u= ((x - xpos) * cos(ori(i))) - ((y - ypos) * sin(ori(i)));
            gabor = (A * cos(2.0 * pi * sf(j) * u + ph(k)));%.* envelope;
            var = cat(1, var, {ori(i), sf(j), ph(k), gabor});
        end
    end
end
stims.Gratrev = cell2struct(var, {'Ori', 'SF', 'Phase','Gabor'},2);

%% generate curvplay stack
imnum = (1:2:21);
name = [];
rotation = [ -337.5000
 -315.0000
 -292.5000
 -270.0000
 -247.5000
 -225.0000
 -202.5000
 -180.0000
 -157.5000
 -135.0000
 -112.5000
  -90.0000
  -67.5000
  -45.0000
  -22.5000
         0];
     param = {};
for i = 1:length(imnum)
    name=strcat('/auto/data/stimuli/jackson/parabolas_bold/image-0000', sprintf('%02d', imnum(i)), '.png');
    image=imread(name);
    image=rgb2gray(image);
    image=imresize(image, [1400 1400]);
    for j = 1:length(rotation)
        image=imrotate(image, rotation(j), 'bilinear', 'crop');
        image=mean(im2double(image), 3);
        image=1-image; 
        B= image<=0.5;
        image(B)= 0.5;
        image= image.*2-1;
        noise = 0.1 .* (2*rand(size(image))-1); %add noise
        stim= image + noise; %with noise
        
        param = cat(1, param, {name, rotation(j), stim});
    end
end

stims.Curvplay = cell2struct(param, {'Image', 'Rotation', 'CurvStim'},2);


save('bare_stimuli','stims', 'd', 'x', 'y', 'xpos', 'ypos', 'gabor')