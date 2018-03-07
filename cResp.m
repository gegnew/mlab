function [RespMat] = cResp(cdata)
%   g.egnew 2018.03.06
%% function [RespMat] = cResp(cdata)
%   cResp takes table from curvdata.m and returns a response matrix
%   This is ~3600x faster than cRespMat
%
%  INPUT
%       cdata - table produced by curvdata
%
%  OUTPUT
%       RespMat - matrix of dimensions [sf, ori, ph, gsamplesize] ordered
%           from param(1:end); i.e. RespMat(1,1,1,1) = first sf, first ori,
%           first phase, and first sample
%       avgRate
%       avgRateph
%       SEM
%       MedRate
%       samplesize -  sample size for each condition
%       gSTD - standard deviation for each type of response

rotations = fliplr(unique(cdata.Rotation)');% rotation amouts for curvplay file, 16 units long
curvcoef= unique(cdata.CurveCoefficient)'; %coefficients assigned to each image, 11 units long
imageNum= unique(cdata.ImageFile)'; % numbers assigned to image files used for curvplay.  Only pulls out stroke width 20 and parabola images.

z = fliplr(combvec(curvcoef, rotations)');

for i = 1:length(rotations)
    find(z(:,1)==rotations(i));
    y(ans,1) = i;
    for j = 1:length(curvcoef)
        find(z(:,2)==curvcoef(j));
        y(ans,2) = j;
        end
end
%% get samplesize

repsMat=zeros(length(imageNum),length(rotations)); %used to calculate the number of repetitions for each cell rows are coef/images numbers and columns are rotations

for i=1:length(imageNum)
    for k=1:length(rotations)
        repsMat(i,k)=sum(cdata.Rotation(:)==rotations(k) & cdata.ImageFile==imageNum(i)); % checks for rotation and image number for entry and assigns it to matrix
    end
end
samplesize=min(repsMat(:)); %returns the minimum amount of image displays during for a cell during a curvplay experiment

%% build response matrix
RespMat = [];
tempMat=[];
for i = 1:length(z)
    j = y(i,1); %rotations
    k = y(i,2); %curvcoef
    idx = cdata.Rotation==z(i,1) & cdata.CurveCoefficient==z(i,2);
    temptable = cdata(idx,:);
    if isempty(temptable) ==1 % if there is no matching orientation combo, Resp = zeros
        RespMat(k,j,1:samplesize)=[0;0];
        continue
    end
    tempMat=temptable.Response(1:samplesize);
    RespMat(k,j,1:samplesize)=tempMat;

end

avgRate=mean(RespMat, 4); %mean firing rate for the matrix
avgRateph=mean(avgRate,3);
SEM=std(RespMat, 0, 4)./samplesize; %Standard Error of the Mean
MedRate=median(RespMat, 4); %median fire rate
gSTD=std(RespMat, 0, 4); % standard deviation



end
