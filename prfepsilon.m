function [] = prfepsilon(animal, day, month, year)

% animal = 'bert';
% date = '2018-02-12';
%% connect to mlabdata database
% mysql('open', 'sql', 'mlab', 'mlab');
% mysql('use mlabdata')
p = struct('exper', [], 'rfx', [], 'rfy', [], 'rfrho', [], 'rfr', []);
rfepsilon = struct('exper', [], 'rfx', [], 'rfy', [], 'rfrho', [], 'rfr', []);
%% check input arguments
% if nargin <2
%     error('Not enough input arguments.')
% end

% if ~exist('day', 'month', 'year')
%     x = input('Please enter sql ID number');
%     [exper, rfx, rfy, rfr] = mysql(['select exper, rfx, rfy, rfr from unit where ID="',x,'"']);
% else
%     date = [sprintf('%d', year), '-', sprintf('%02d', month), '-', sprintf('%02d', day)];
%     [exper, rfx, rfy, rfr] = mysql(['select exper, rfx, rfy, rfr from unit where animal="', animal, '" and date="', date, '"']);
% end
date = [sprintf('%d', year), '-', sprintf('%02d', month), '-', sprintf('%02d', day)];
id = mysql(['select ID from unit where animal="', animal, '" and date="', date, '"']);
id = id(1);
crap = [];

for k = id:5192
    if k == 4880 %pass by "phred" file
        continue
    end
    if k == 4920
        continue
    end
% I'll pass on crap
    [pass, a] = mysql(['select crap, note from unit where animal="', animal, '" and ID="',sprintf('%04d', k), '"']);
    if pass == 1
        continue
    end
% if there is no note:
%     if isempty(a) == 1
%         continue
%     end
    if isempty(a{1}) == 0
    disp(k)
    disp(a)
    reply = input('Is this a crap file? (y/n)     ', 's');
        if reply == 'y'
            crap = [crap, k];
            continue
        elseif reply == 'n'
%         else
%             disp('Unexpected input; please try again.')
%             %return
        end
    end
    % get data:
    [exper, rfx, rfy, rfr] = mysql(['select exper, rfx, rfy, rfr from unit where ID="',sprintf('%04d', k),'"']);

    % pull data from sql
    data = horzcat(exper, num2cell([rfx, rfy, rfr]));
    data(any(cellfun(@(x) numel(x)==1 && isnumeric(x) && isnan(x),data),2),:) = [];

    % build out data struct
    n = size(data);
    n = n(1);
    if n == 0
        continue
    else
        for i = 1:n
            p(i).exper = cellstr(data(i,1));
            p(i).rfx = cell2mat(data(i,2));
            p(i).rfy = cell2mat(data(i,3));
            [theta, rho] = cart2pol(p(i).rfx, p(i).rfy);
            p(i).rfrho = rho;
            p(i).rfr = cell2mat(data(i,4));
        end
    end
    rfepsilon = [rfepsilon, p];

disp(k)
end

figure
hold on
    
%% build scatter plot
x = [];
y = [];
for j = 1:length(rfepsilon)
    x = [x, rfepsilon(j).rfrho];
    y = [y, rfepsilon(j).rfr];
end

% s = scatter(x, y, 4, 'filled');
% [r, m, b] = regression(x,y);
plotregression(x,y);



disp(length(x))
save('prfepsilon.mat', 'x', 'y', 'crap')