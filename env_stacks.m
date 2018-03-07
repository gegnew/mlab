function [] = env_stacks(cell_num, cell_max)

%% problems to fix
%variable 'stims' not being saved; use mat-file version 7.3 or later
% doesn't save any files when there are >1 matching files
% still loading .p2m files

load('bare_stimuli.mat')

if nargin >2
    error('Too many input arguments')
end

if ~exist('cell_max', 'var')
    cell_max = cell_num;
end

%% initialize new data structure 
replicas = struct('Gratrev', [], 'Curvplay', []);


w = +inf;

%% if a range is specified, get all gratrev and curvplay cells in range
if cell_max ~= cell_num
    cells = [];
    curv_cells = [];
    for cell_num = 985:1:991
        gratfile = strcat('bert', sprintf('%04d', cell_num), '.gratrev%');
        %curvfile = strcat('bert', sprintf('%04d', cell_num), '.curvplay%');
        try
            pfg = dbfind(gratfile, 'list', 'all');
            %pfc = dbfind(curvfile, 'list', 'all');
        catch
            warning(['No match.'])
            pfg = 0;
            continue
        end
            cells = [cells; cell_num];
            %curv_cells = [curv_cells; cell_num];
    end
else
    cells = cell_num;
end

%% if only one cell is specified, get envelope from single cell
for j = 1:length(cells)
    try
        pfg = dbfind(strcat('bert', sprintf('%04d', cells(j)), '.gratrev%'));
    catch
        warning(['No match.'])
        continue
    end
    gabor((abs(x-xpos) > (w/2) | abs(y-ypos) > (w/2))) = 0;
    sigma = pfg.rec(1).params.radius;
    envelope = exp(-(d.^2) ./ (2*sigma^2)) ./ (2 * pi * sigma^2);
    envelope = envelope ./ max(envelope(:));
    
%% multiply gabors and curv stims by envelope
    for i = 1:length(stims.Gratrev)
        a = stims.Gratrev(i).Gabor;
        b = a .* envelope;
        replicas(j).Gratrev(i).Gabor = b;
        replicas(j).Gratrev(i).Ori = stims.Gratrev(i).Ori;
        replicas(j).Gratrev(i).SF = stims.Gratrev(i).SF;
        replicas(j).Gratrev(i).Phase = stims.Gratrev(i);
    end
% 
%     for j = 1:length(stims.Curvplay)
%         replicas.Curvplay(j).CurvStim = stims.Curvplay.CurvStim .* envelope;
%     end
end