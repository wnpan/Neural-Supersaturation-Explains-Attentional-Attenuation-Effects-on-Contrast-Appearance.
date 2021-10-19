%% last edit by pwn at 2020/9/15
% 这个版本有两个光栅
% 用微动法调节红绿平衡，调节时红色数值默认为128
% 测试数值存储于/isolumtest/Isolumtest_data

function [red,green] = isolumtest(subjectid,red,green,eccentricity,size,sf,contrast,boundary,Gratio_range)

addpath('isolumtest/')
addpath('practice/')

if nargin < 1
    subjectid = 'test';
    red = 128;%R通道亮
    green = 40;
    eccentricity = 4;
    size = 3;%光栅大小
    sf = 2;%光栅频率cycle/degree
    contrast = 0.95;%光栅对比度
    boundary = 0.5;%光栅外周模糊边界
    Gratio_range = [0.5 0.05];%Gratio的调节范围
elseif 1<= nargin < 2
    red = 128;%R通道亮
    green = 40;
    eccentricity = 4;
    size = 3;%光栅大小
    sf = 2;%光栅频率cycle/degree
    contrast = 0.95;%光栅对比度
    boundary = 0.5;%光栅外周模糊边界
    Gratio_range = [0.5 0.05];%Gratio的调节范围
end

isolumtest_buildmatrix(subjectid);
IsolumtestMinimalmotion(subjectid,red,green,eccentricity,size,sf,contrast,boundary,Gratio_range);
[Gratio,output] = fittingresult(subjectid);
green = Gratio*red;
end