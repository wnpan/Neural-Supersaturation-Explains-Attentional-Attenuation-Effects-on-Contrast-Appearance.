%% 2019.12.21
%%Minimal-motion technique匹配红绿颜色的主观亮度，测定GRratio
%%Chenzhangshan
%%参考文献INVOLVEMENT OF MIDDLE TEMPORAL AREA (MT) IN THE PROCESSING OF CHROMATIC MOTION（2004）
%%请先使用buildmatrix.m创建矩阵，另存为subjectid_paramatrix.mat

%% 2020.9.11
% edit by pwn in 606
% 修改于原程序，用于颜色适应实验,增加了运动方向的平衡
% 606 新显示器，无需亮度线性矫正

%% 2020.9.15
% 修改为两个光栅，很多地方写的并不美观，可能会降低程序运行效率（如光栅呈现的时候使用了两次drawtexture）

function IsolumtestMinimalmotion(subjectid,red,green,eccentricity,size,sf,contrast,boundary,Gratio_range)

% if nargin < 1
%     subjectid = 'test';
%     red = 128;%R通道亮
%     green = 40;
%     eccentricity = 4;
%     size = 3;%光栅大小
%     sf = 0.5;%光栅频率
%     contrast = 0.95;%光栅对比度
%     boundary = 0.5;%光栅外周模糊边界
%     Gratio_range = [0.5 0.05];%Gratio的调节范围
% elseif 1<= nargin < 2
%     red = 128;%R通道亮
%     green = 40;
%     eccentricity = 4;
%     size = 3;%光栅大小
%     sf = 0.5;%光栅频率
%     contrast = 0.95;%光栅对比度
%     boundary = 0.5;%光栅外周模糊边界
%     Gratio_range = [0.5 0.05];%Gratio的调节范围
% end

HideCursor;
p = mfilename('fullpath');
[filepath,~,~] = fileparts(p);
filepath = strcat(filepath,'/Isolumtest_data/',subjectid,'_paramatrix');

load(filepath);

maxstrength(1)=Gratio_range(1); %GRratio设定最大值
minstrength(1)=Gratio_range(2); %GRratio设定最小值
initialstrength(1,:)=[minstrength(1) maxstrength(1)];
stairtype='1u1d';
GRratio=green/red; %初始背景色GRratio

[window,windowRect]=Screen('OpenWindow', 0, [red red*GRratio 0]);%打开黄色背景屏幕
[xcenter,ycenter]=WindowCenter(window);
Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
frame_rate=Screen('FrameRate',window);
framedur=1000/frame_rate;%单位ms

%%
%%%%%%定义刺激参数%%%%%%
pixelfor1degree=degree2pixel(1);%1度多少像素
FixDuration=500;%注视点呈现时间ms
Fix_size = 0.2*pixelfor1degree;
FixationRect=CenterRect([0 0 Fix_size Fix_size],windowRect);%%注视点位置
FixLum=0;%注视点的灰度
KbName('UnifyKeyNames');
esc=KbName('escape');
right=KbName('RightArrow');
left=KbName('LeftArrow');
keycode=zeros(1,256);

%%%%光栅相关参数
contrast1=contrast;%黑白光栅对比度95%
contrast2=contrast;%红绿光栅对比度95%
SpatialPeriod1=1/sf*pixelfor1degree; %1cycles/degree, 黑白光栅每个周期的像素数
SpatialPeriod2=1/sf*pixelfor1degree; %1cycles/degree, 红绿光栅每个周期的像素数
durationtime=70 ;%每个光栅呈现的时间
num=4;%四帧光栅组合重复的次数,每个循环280ms

desCenter(:,:,1) = [xcenter-eccentricity-size/2 ycenter-size/2 ...
    xcenter-eccentricity+size/2 ycenter+size/2]; % left
desCenter(:,:,2) = [xcenter+eccentricity-size/2 ycenter-size/2 ...
    xcenter+eccentricity+size/2 ycenter+size/2]; % right

%%
%%%%实验开始之前呈现注视点
while KbCheck; end
Screen('FillOval',window,FixLum,FixationRect);%fixation
Screen('DrawText',window,'Press any key to begin',FixationRect(1)-160,600-100,[0 0 0]);%提示开始
Screen('Flip', window);
KbWait;

rightkey=0;leftkey=0;p=0;i=1;
%%
while i<=80 %每个被试判断80次，用fitting程序拟合结果
    
    if mod(i,40)==1
        
        if i~=1
            Screen('DrawText',window,'Please have a rest...',FixationRect(1)-150,FixationRect(2),[0 0 0]);%提示开始
            Screen('Flip', window);
            while KbCheck; end
            KbWait;
        end
        
    end
    
    strengthmatrix=[];
    responsematrix=[];
    conditions=paramatrix(i,2);%staircase number
    phase_orienting = paramatrix(i,5);
    if i~=1
        strengthmatrix=paramatrix(find(paramatrix(1:i-1,2)==conditions),3);
        responsematrix=paramatrix(find(paramatrix(1:i-1,2)==conditions),6);
    end
    
    paramatrix(i,3)=updownstaircase(stairtype,strengthmatrix,responsematrix,...
        minstrength,maxstrength,initialstrength(mod(conditions,2)+1));
    
    GRratio=paramatrix(i,3);
    
    %%%%%%黑白光栅0度%%%%%%
    phase1=0*phase_orienting;
    GratingSize=round(size*pixelfor1degree);

    %grating_frames=round(GratingDuration/framedur);
    o_size=GratingSize; %o_size,光栅大小，直径，像素
    o_Speriod=SpatialPeriod1;%o_Speriod,光栅的空间周期，像素
    o_speed=0;
    o_phase=phase1;%o_phase,外周光栅的相位
    o_contrast=0;%o_contrast,外周光栅的对比度
    o_orientation=0;%o_orientation,外周光栅的朝向
    o_blur=0;%o_blur,外周光栅边缘的正弦模糊像素数
    o_duration=durationtime;
    
    gap=0;%中央外周之间的间隔 degree
    
    i_size=GratingSize; %i_size,中央光栅大小，直径，像素
    i_Speriod=SpatialPeriod1;%i_Speriod,中央光栅的空间周期，像素
    i_speed=0;%速度*运动方向
    i_phase=phase1;%i_phase,中央光栅的相位
    i_contrast=contrast1;%i_contrast,标准光栅的对比度
    i_orientation=0;%i_orientation,中央光栅的朝向
    i_blur=boundary*pixelfor1degree;%i_blur,中央光栅边缘的正弦模糊像素数
    i_duration=durationtime;
    
    %%grating
    gratingmatrix1=staticgratingmatrix(frame_rate,red,o_size,o_Speriod,o_speed,o_phase,o_contrast,o_orientation,o_blur,o_duration,...
        gap,i_size,i_Speriod,i_speed,i_phase,i_contrast,i_orientation,i_blur,i_duration,GRratio);
    
    gratingmatrix1=round(gratingmatrix1);
    
    %%%%%%黑白光栅180度%%%%%%
    phase3=pi*phase_orienting;
    GratingSize=round(size*pixelfor1degree);
    
    %grating_frames=round(GratingDuration/framedur);
    o_size=GratingSize; %o_size,光栅大小，直径，像素
    o_Speriod=SpatialPeriod1;%o_Speriod,光栅的空间周期，像素
    o_speed=0;
    o_phase=phase3;%o_phase,外周光栅的相位
    o_contrast=0;%o_contrast,外周光栅的对比度
    o_orientation=0;%o_orientation,外周光栅的朝向
    o_blur=0;%o_blur,外周光栅边缘的正弦模糊像素数
    o_duration=durationtime;
    
    gap=0;%中央外周之间的间隔 degree
    
    i_size=GratingSize; %i_size,中央光栅大小，直径，像素
    i_Speriod=SpatialPeriod1;%i_Speriod,中央光栅的空间周期，像素
    i_speed=0;%速度*运动方向
    i_phase=phase3;%i_phase,中央光栅的相位
    i_contrast=contrast1;%i_contrast,标准光栅的对比度
    i_orientation=0;%i_orientation,中央光栅的朝向
    i_blur=boundary*pixelfor1degree;%i_blur,中央光栅边缘的正弦模糊像素数
    i_duration=durationtime;
    
    %%grating
    gratingmatrix3=staticgratingmatrix(frame_rate,red,o_size,o_Speriod,o_speed,o_phase,o_contrast,o_orientation,o_blur,o_duration,...
        gap,i_size,i_Speriod,i_speed,i_phase,i_contrast,i_orientation,i_blur,i_duration,GRratio);
    
    gratingmatrix3=round(gratingmatrix3);
    %%%%%%生成红绿光栅90度%%%%%%
    phase2=pi/2*phase_orienting;
    GratingSize=round(size*pixelfor1degree);
    
    %grating_frames=round(GratingDuration/framedur);
    o_size=GratingSize; %o_size,光栅大小，直径，像素
    o_Speriod=SpatialPeriod2;%o_Speriod,光栅的空间周期，像素
    o_speed=0;
    o_phase=phase2;%o_phase,外周光栅的相位
    o_contrast=0;%o_contrast,外周光栅的对比度
    o_orientation=0;%o_orientation,外周光栅的朝向
    o_blur=0;%o_blur,外周光栅边缘的正弦模糊像素数
    o_duration=durationtime;
    
    gap=0;%中央外周之间的间隔 degree
    
    i_size=GratingSize; %i_size,中央光栅大小，直径，像素
    i_Speriod=SpatialPeriod2;%i_Speriod,中央光栅的空间周期，像素
    i_speed=0;%速度*运动方向
    i_phase=phase2;%i_phase,中央光栅的相位
    i_contrast=contrast2;%i_contrast,标准光栅的对比度
    i_orientation=0;%i_orientation,中央光栅的朝向
    i_blur=boundary*pixelfor1degree;%i_blur,中央光栅边缘的正弦模糊像素数
    i_duration=durationtime;
    
    %%grating
    gratingmatrix2=colorstaticgratingmatrix(frame_rate,red,o_size,o_Speriod,o_speed,o_phase,o_contrast,o_orientation,o_blur,o_duration,...
        gap,i_size,i_Speriod,i_speed,i_phase,i_contrast,i_orientation,i_blur,i_duration,GRratio);
    
    gratingmatrix2=round(gratingmatrix2);
    
    %%%%%%生成红绿光栅270度%%%%%%
    phase4=pi*3/2*phase_orienting;
    GratingSize=round(size*pixelfor1degree);
    
    %grating_frames=round(GratingDuration/framedur);
    o_size=GratingSize; %o_size,光栅大小，直径，像素
    o_Speriod=SpatialPeriod2;%o_Speriod,光栅的空间周期，像素
    o_speed=0;
    o_phase=phase4;%o_phase,外周光栅的相位
    o_contrast=0;%o_contrast,外周光栅的对比度
    o_orientation=0;%o_orientation,外周光栅的朝向
    o_blur=0;%o_blur,外周光栅边缘的正弦模糊像素数
    o_duration=durationtime;
    
    gap=0;%中央外周之间的间隔 degree
    
    i_size=GratingSize; %i_size,中央光栅大小，直径，像素
    i_Speriod=SpatialPeriod2;%i_Speriod,中央光栅的空间周期，像素
    i_speed=0;%速度*运动方向
    i_phase=phase4;%i_phase,中央光栅的相位
    i_contrast=contrast2;%i_contrast,标准光栅的对比度
    i_orientation=0;%i_orientation,中央光栅的朝向
    i_blur=boundary*pixelfor1degree;%i_blur,中央光栅边缘的正弦模糊像素数
    i_duration=durationtime;
    
    %%grating
    gratingmatrix4=colorstaticgratingmatrix(frame_rate,red,o_size,o_Speriod,o_speed,o_phase,o_contrast,o_orientation,o_blur,o_duration,...
        gap,i_size,i_Speriod,i_speed,i_phase,i_contrast,i_orientation,i_blur,i_duration,GRratio);
    
    gratingmatrix4=round(gratingmatrix4);
    
    eccentricity_left=[-eccentricity 0]*pixelfor1degree;%偏心距
    eccentricity_right=[eccentricity 0]*pixelfor1degree;%偏心距
    GratingRect0=CenterRect([0 0 GratingSize GratingSize],windowRect);
    GratingRect1=OffsetRect(GratingRect0,eccentricity_left(1),eccentricity_left(2));%
    GratingRect2=OffsetRect(GratingRect0,eccentricity_right(1),eccentricity_right(2));%
    
    grating_frames1=length(gratingmatrix1(1,1,1,:));
    for pp=1:grating_frames1
        gratings1(pp)=Screen('MakeTexture',window, gratingmatrix1(:,:,:,pp));
        gratings1(pp)=Screen('MakeTexture',window, gratingmatrix1(:,:,:,pp));
    end
    
    grating_frames2=length(gratingmatrix2(1,1,1,:));
    for pp=1:grating_frames2
        gratings2(pp)=Screen('MakeTexture',window, gratingmatrix2(:,:,:,pp));
    end
    
    grating_frames3=length(gratingmatrix3(1,1,1,:));
    for pp=1:grating_frames3
        gratings3(pp)=Screen('MakeTexture',window, gratingmatrix3(:,:,:,pp));
    end
    
    grating_frames4=length(gratingmatrix4(1,1,1,:));
    for pp=1:grating_frames4
        gratings4(pp)=Screen('MakeTexture',window, gratingmatrix4(:,:,:,pp));
    end
    
    
    %呈现每个trial开始的注视点
    for pp=1:round(FixDuration/framedur)
        Screen('FillOval',window,FixLum,FixationRect);%fixation
        Screen('Flip', window);
    end
    
    for k=1:num %四帧循环重复num次，一个循环280ms
        
        %%grating1
        for pp=1:grating_frames1
            Screen('FillRect',window,[red,red*GRratio,0],[0,0,2*xcenter,2*ycenter]);
            Screen('DrawTexture', window,gratings1(pp),[],GratingRect1);%光栅
            Screen('DrawTexture', window,gratings1(pp),[],GratingRect2);%光栅
            Screen('FillOval',window,FixLum,FixationRect);%fixation
            Screen('Flip',window);
        end
        
        %%grating2
        for pp=1:grating_frames2
            Screen('FillRect',window,[red,red*GRratio,0],[0,0,2*xcenter,2*ycenter]);
            Screen('DrawTexture', window,gratings2(pp),[],GratingRect1);%光栅
            Screen('DrawTexture', window,gratings2(pp),[],GratingRect2);%光栅
            Screen('FillOval',window,FixLum,FixationRect);%fixation
            Screen('Flip',window);
        end
        
        %%grating3
        for pp=1:grating_frames3
            Screen('FillRect',window,[red,red*GRratio,0],[0,0,2*xcenter,2*ycenter]);
            Screen('DrawTexture', window,gratings3(pp),[],GratingRect1);%光栅
            Screen('DrawTexture', window,gratings3(pp),[],GratingRect2);%光栅
            Screen('FillOval',window,FixLum,FixationRect);%fixation
            Screen('Flip',window);
        end
        
        %%grating4
        for pp=1:grating_frames4
            Screen('FillRect',window,[red,red*GRratio,0],[0,0,2*xcenter,2*ycenter]);
            Screen('DrawTexture', window,gratings4(pp),[],GratingRect1);%光栅
            Screen('DrawTexture', window,gratings4(pp),[],GratingRect2);%光栅
            Screen('FillOval',window,FixLum,FixationRect);%fixation
            Screen('Flip',window);
        end
    end
    
    Screen('FillRect',window,[red,red*GRratio,0],[0,0,2*xcenter,2*ycenter]);
    Screen('FillOval',window,FixLum,FixationRect);%fixation
    Screen('Flip',window);
    
    
    keyisdown=1;
    while(keyisdown)
        [keyisdown,secs,keycode]=KbCheck;
        WaitSecs(0.001);
    end
    
    time0=GetSecs;
    while GetSecs-time0>0 %让被试判断
        [keyisdown,secs,keycode]=KbCheck;
        WaitSecs(0.001);
        
        if keycode(right)==1  %一直读取up键，直到键盘抬起
            rightkey=rightkey+1;
        elseif keycode(left)==1  %一直读取down键，直到键盘抬起
            leftkey=leftkey+1;
        elseif keycode(esc)==1
            Screen('CloseAll');
            
            break;
        end
        
        if keycode(right)==0 & rightkey~=0
            paramatrix(i,4)=1;
            rightkey=0;
            paramatrix(i,6) = (paramatrix(i,4).*paramatrix(i,5)+1)/2;%1 -1 → 1 0
            i=i+1;
            break;
        elseif keycode(left)==0 & leftkey~=0
            paramatrix(i,4)=-1;
            leftkey=0;
            paramatrix(i,6) = (paramatrix(i,4).*paramatrix(i,5)+1)/2;%1 -1 → 1 0
            i=i+1;
            break;
        end
    end
    if strcmp(subjectid,'test');
        save(filepath, 'paramatrix');
    else
        save(filepath);
    end
    
    WaitSecs(0.5);
    
end

Screen('CloseAll');

