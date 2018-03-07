function [] = replicate_stimuli(pfg, pfc, lat, winsize)
%   gegnew, 01/26/2018
%% notes and to-do
% lat and winsize for gratrevDelta.m below
% pfg = dbfind('/auto/data/critters/bert/2018/2018-01-09/bert1001.gratrev.003');
% pfc = dbfind('auto/data/critters/bert/2018/2018-01-09/bert1001.curvplay.002');

%% generate a replica stimulus set from gratrev and curvplay data
%	Data structure comprising the stimulus set for any given trial.
%   This stimulus set, built from existing data, will be used
%   later to convolve with a model of neurons in an attempt to marry up
%   gratrev response data with curvplay response data.
%
% INPUT
%   lat - latency for gratrevDelta.m
%   winsize - window size for gratrevDelta.m
%   gratrev - gratrev data from gratrevDelta.m
%   pfg - dbfind('filename.gratrev'), i.e. dbfind('bert1001.gratrev')
%   pfc - dvfind('filename.curvplay')
%   sigma - receptive field radius, from pf.rec(1).params.radius
%                 Note that this is pf.rec(1).params.rfsigma for ggratrev
% 
%   OUTPUT
%   rep_stims.mat file - struct containing Gratrev and Curvplay replicas

%Note:
% Need to use gratrev, not ggratrev, because SF is messed up in ggratrev.
% i.e., the following does not work:
% pf = dbfind('/auto/data/critters/bert/2018/2018-01-09/bert1001.ggratrev.001');

% Instead use:
%pf = dbfind('bert1001.gratrev');

%% get gratrev data from gratrevDelta.m
gratrev = gratrevDelta(pfg, lat, winsize); % need to make lat, winsize regular
% initialize variables
g = []; % final stack of stimuli
oris = gratrev{:,1};
skip=[]; % passnumber for orientations already saved
rep_stims = struct('Gratrev', [], 'Curvplay', []);

for i = 1:height(gratrev)
    tic

    if any(skip==oris(i))
        continue
    else
       %% Screen Coordinate System
        [x, y] = meshgrid(-699:700); % Screen Coordinate System that matches images in file
      %% generate gabor
       % ori: degrees
        % ph: degrees
        % sf: cycles/pixel (ie, 1/(pixels/cycle))
        % A: 0-11% A: 0-1 1% A: 0-1 1% A: 0-1 1% A: 0-1 
        % sigma: pixels
        sigma = pfg.rec(1).params.radius;
        ori = gratrev{i,1};
        sf = gratrev{i,2};
        ph = gratrev{i,3};
        xpos= 0; % x position of the center of the receptive field
        ypos= 0; % y position of the center of the receptive field
        w= +inf;
        A= 1;
        d= ((x - xpos).^2 + (y - ypos).^2).^0.5; % using model neuron xpos    
        u= ((x - xpos) * cos(ori)) - ((y - ypos) * sin(ori)); % using model neuron ypos
        envelope = exp(-(d.^2) ./ (2*sigma^2)) ./ (2 * pi * sigma^2);
        envelope = envelope ./ max(envelope(:));
        gabor = (A * cos(2.0 * pi * sf * u + ph)) .* envelope;
        gabor((abs(x-xpos) > (w/2) | abs(y-ypos) > (w/2))) = 0;
       
        g{i} = gabor;
        var(i,:) = {ori, sf, ph};
        skip(i) = [gratrev{i,1}];

    end
        t(i) = toc;
end
g = g(~cellfun('isempty',g))';
var(all(cellfun(@isempty,var),2),:)=[];
var(:,4) = g;
grat = cell2struct(var, {'Ori', 'SF', 'Phase','Gabor'},2);
rep_stims.Gratrev = grat;

tt= ['The total time to to generate all stimuli is ', num2str(sum(t)), ' seconds.'];
disp(tt)

%% get curvplay image stack
curvplay = predcurvdata(pfc, 50, 50); %curvdata.m could also be used...? (see Adam)
%curvplay = curvdata(lf, 50, 50);
%% resize/rotate images, multiply by envelope
curvplay.Presp=zeros(height(curvplay),1);

rotation = [];
var = {};
for i = 1:height(curvplay) %preallocate rotations
    rotation(i) = curvplay.Rotation(i);
end

pass = []; %passnumber for rotations already recorded

for f = 1:height(curvplay)
    if any(pass==rotation(f))
        continue
    else
    
    name=strcat('/auto/data/stimuli/jackson/parabolas_bold/', curvplay{f,2});
    im_name = strcat(curvplay{f,2});
    image=imread(name);
    image=rgb2gray(image);

    image=imresize(image, [1400 1400]);
    image=imrotate(image, rotation(f), 'bilinear', 'crop');
    image=mean(im2double(image), 3);
    image=1-image; 
    B= image<=0.5;
    image(B)= 0.5;
    image= image.*2-1;
    noise = 0.1 .* (2*rand(size(image))-1); %add noise
    stim= image + noise; %with noise
    stim= stim.* envelope;
    %imshow(stim)
    pass(f) = [rotation(f)];
    var(f,:) = {im_name, rotation(f)};
    end
    
    c{f} = stim;
end
c = c(~cellfun('isempty',c))';
var(all(cellfun(@isempty,var),2),:)=[];
var(:,3) = c;
curv = cell2struct(var, {'Image', 'Rotation', 'CurvStim'},2);
rep_stims.Curvplay = grat;

save('replica_stimuli','rep_stims')

end

