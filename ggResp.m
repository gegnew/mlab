function [RespMat] = ggResp(gdata)
%   g.egnew 2018.03.07
%% function [RespMat] = ggResp(gdata)
%   ggResp takes table from gratrevDelta.m and returns a response matrix
%   This is ~1300x faster than ggRespMat
%   
%  INPUT
%       gdata - table produced by gratrevDelta
%
%  OUTPUT
%       RespMat - matrix of dimensions [sf, ori, ph, gsamplesize] ordered
%           from param(1:end); i.e. RespMat(1,1,1,1) = first sf, first ori,
%           first phase, and first sample
%       avgRate
%       avgRateph
%       SEM
%       MedRate
%       gsamplesize -  sample size for each condition
%       gSTD - standard deviation for each type of response

%% 

ori=(unique(gdata.Ori))';
ph= (unique(gdata.Phase))';
sf=(unique(gdata.SF))'; 

z = fliplr(combvec(ph, ori, sf)');

%% build y, index vector
for i = 1:length(sf)
    find(z(:,1)==sf(i));
    y(ans,1) = i;
    for j = 1:length(ori)
        find(z(:,2)==ori(j));
        y(ans,2) = j;
        for k = 1:length(ph)
            find(z(:,3)==ph(k));
            y(ans,3) = k;
        end
    end
end
%% get gsamplesize
for i=1:length(sf)
    for j=1:length(ori)
        for k=1:length(ph)
            repsMat(i,j,k)=sum(gdata.SF==sf(i) & gdata.Ori==ori(j) & gdata.Phase==ph(k)); % checks for rotation and image number for entry and assigns it to matrix
            %k=k+1;
        end
        %j=j+1;
    end
    %i=i+1;
end
gsamplesize=min(repsMat(:)); %returns the minimum amount of image displays during for a cell during a curvplay experiment

%% build response matrix
RespMat = [];
tempMat=[];
for i = 1:length(z)
    j = y(i,1);
    k = y(i,2);
    l = y(i,3);
    idx = gdata.SF==z(i,1) & gdata.Ori==z(i,2) & gdata.Phase==z(i,3);
    temptable = gdata(idx,:);
    if isempty(temptable) == 1 % if there is no matching orientation combo, Resp = zeros
        RespMat(j,k,l,1:gsamplesize)=[0;0;0];
        continue
    end
    tempMat=temptable.Response(1:gsamplesize);
    RespMat(j,k,l,1:gsamplesize)=tempMat;

end

avgRate=mean(RespMat, 4); %mean firing rate for the matrix
avgRateph=mean(avgRate,3);
SEM=std(RespMat, 0, 4)./gsamplesize; %Standard Error of the Mean
MedRate=median(RespMat, 4); %median fire rate
gSTD=std(RespMat, 0, 4); % standard deviation

end