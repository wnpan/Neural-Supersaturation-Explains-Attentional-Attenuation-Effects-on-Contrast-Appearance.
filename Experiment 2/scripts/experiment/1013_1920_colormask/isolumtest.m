%% last edit by pwn at 2020/9/15
% ����汾��������դ
% ��΢�������ں���ƽ�⣬����ʱ��ɫ��ֵĬ��Ϊ128
% ������ֵ�洢��/isolumtest/Isolumtest_data

function [red,green] = isolumtest(subjectid,red,green,eccentricity,size,sf,contrast,boundary,Gratio_range)

addpath('isolumtest/')
addpath('practice/')

if nargin < 1
    subjectid = 'test';
    red = 128;%Rͨ����
    green = 40;
    eccentricity = 4;
    size = 3;%��դ��С
    sf = 2;%��դƵ��cycle/degree
    contrast = 0.95;%��դ�Աȶ�
    boundary = 0.5;%��դ����ģ���߽�
    Gratio_range = [0.5 0.05];%Gratio�ĵ��ڷ�Χ
elseif 1<= nargin < 2
    red = 128;%Rͨ����
    green = 40;
    eccentricity = 4;
    size = 3;%��դ��С
    sf = 2;%��դƵ��cycle/degree
    contrast = 0.95;%��դ�Աȶ�
    boundary = 0.5;%��դ����ģ���߽�
    Gratio_range = [0.5 0.05];%Gratio�ĵ��ڷ�Χ
end

isolumtest_buildmatrix(subjectid);
IsolumtestMinimalmotion(subjectid,red,green,eccentricity,size,sf,contrast,boundary,Gratio_range);
[Gratio,output] = fittingresult(subjectid);
green = Gratio*red;
end