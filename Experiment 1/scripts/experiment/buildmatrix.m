function buildmatrix(subjectid)
%% buildmatrix for equality task  (cRef = 0.6)

% written on 2020/6/14 by pwn
% 20191111 by pwn 增加了try命令防止覆盖
% 20191119 用于适应光栅实验
% 20191119 用于适应光栅实验-定义noise对比度

% column01 sequence number

% column02 trial type [cueValidity3*dir2*NC3=18]
% column03 cue location [-1=left, 0=neutral, 1=right]
% column04 ref location [-1=left 1=right]
% column05 test location [-1=left 1=right]
% column06 cue validity [1=ref cued,0=no cue, -1=test cued]

% column07 fixDura [1000ms]
% column08 noise_contrast(RMS contrast) [0 0.07 0.14 0.21]

% column09 test contrast(%)
% column10 test contrast(log)

% column11 response [1=same, -1=different]
% column12 RT

% column13 initial direction
% column14 next step direction 

% column16 noise mean luminance
% column17 noise Michelson_contrast

try
    filename = ['data/',subjectid,'_paramatrix'];
    load(filename);
    disp('the file already exist!')
catch
%% parameter setting
col = 17;

des_cue = [-1 0 1];
des_ref = [-1 1];
cue_validity = [-1 0 1];
fixdura = 1000;
noise_contrast = [0 0.07 0.14 0.21];
dir = [-1 1];

%% randomize
[x1,x2,x3,x4] = ndgrid(des_cue,des_ref,noise_contrast,dir);                     % a matrix of randomized parameters
combinedpara = [x1(:),x2(:),x3(:),x4(:)];                                   % combined together

paramatrix = zeros(length(combinedpara(:,1)),col);
paramatrix(:,3) = combinedpara(:,1);%cue location
paramatrix(:,4) = combinedpara(:,2);%ref location
paramatrix(:,5) = -combinedpara(:,2);%test location
paramatrix(:,6) = combinedpara(:,1).*combinedpara(:,2);%cue validity
paramatrix(:,8) = combinedpara(:,3);%noise_contrast(NC)
paramatrix(:,13) = combinedpara(:,4);%initial direction

paramatrix = sortrows(paramatrix,[4,6,8,13]);%刺激呈现不同位置仍放入相同编号
for i = 1:size(des_ref,2)*size(cue_validity,2)*size(noise_contrast,2)*size(dir,2)
    index = mod(i,size(cue_validity,2)*size(noise_contrast,2)*size(dir,2));
    if index ==0
        index = size(cue_validity,2)*size(noise_contrast,2)*size(dir,2);
    end
    paramatrix(i,2) = index; %1~10 ref cued;11~20 no cue;21~30 test cued
end
                
type_num = 40; 
paramatrix = repmat(paramatrix,type_num,1);              
                                                         
matrix = paramatrix;         
length0 = length(paramatrix);
randIndex = randperm(length0);
for r = 1:length0
    paramatrix(r,:) = matrix(randIndex(r),:);
end
paramatrix = sortrows(paramatrix,[8]);%block设计
block_sum = length0/length(noise_contrast);%每个block的trials
randIndex = randperm(length(noise_contrast));
matrix = paramatrix;  
for r = 1:length(noise_contrast)
    paramatrix(((r-1)*block_sum+1):r*block_sum,:) = matrix(((randIndex(r)-1)*block_sum+1):randIndex(r)*block_sum,:);
end

paramatrix(:,7) = fixdura;
paramatrix(:,1) = 1:length(paramatrix(:,1));

%% save
filename = ['data/',subjectid,'_paramatrix'];
save(filename,'paramatrix');
clear 
end
end

