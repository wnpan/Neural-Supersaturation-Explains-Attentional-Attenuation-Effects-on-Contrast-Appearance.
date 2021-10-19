%% 2019.12.21
%%Minimal-motion techniqueƥ�������ɫ���������ȣ��ⶨGRratio
%%Chenzhangshan
%%�ο�����INVOLVEMENT OF MIDDLE TEMPORAL AREA (MT) IN THE PROCESSING OF CHROMATIC MOTION��2004��
%%����ʹ��buildmatrix.m�����������Ϊsubjectid_paramatrix.mat

%% 2020.9.11
% edit by pwn in 606
% �޸���ԭ����������ɫ��Ӧʵ��,�������˶������ƽ��
% 606 ����ʾ���������������Խ���

%% 2020.9.15
% �޸�Ϊ������դ���ܶ�ط�д�Ĳ������ۣ����ܻή�ͳ�������Ч�ʣ����դ���ֵ�ʱ��ʹ��������drawtexture��

function IsolumtestMinimalmotion(subjectid,red,green,eccentricity,size,sf,contrast,boundary,Gratio_range)

% if nargin < 1
%     subjectid = 'test';
%     red = 128;%Rͨ����
%     green = 40;
%     eccentricity = 4;
%     size = 3;%��դ��С
%     sf = 0.5;%��դƵ��
%     contrast = 0.95;%��դ�Աȶ�
%     boundary = 0.5;%��դ����ģ���߽�
%     Gratio_range = [0.5 0.05];%Gratio�ĵ��ڷ�Χ
% elseif 1<= nargin < 2
%     red = 128;%Rͨ����
%     green = 40;
%     eccentricity = 4;
%     size = 3;%��դ��С
%     sf = 0.5;%��դƵ��
%     contrast = 0.95;%��դ�Աȶ�
%     boundary = 0.5;%��դ����ģ���߽�
%     Gratio_range = [0.5 0.05];%Gratio�ĵ��ڷ�Χ
% end

HideCursor;
p = mfilename('fullpath');
[filepath,~,~] = fileparts(p);
filepath = strcat(filepath,'/Isolumtest_data/',subjectid,'_paramatrix');

load(filepath);

maxstrength(1)=Gratio_range(1); %GRratio�趨���ֵ
minstrength(1)=Gratio_range(2); %GRratio�趨��Сֵ
initialstrength(1,:)=[minstrength(1) maxstrength(1)];
stairtype='1u1d';
GRratio=green/red; %��ʼ����ɫGRratio

[window,windowRect]=Screen('OpenWindow', 0, [red red*GRratio 0]);%�򿪻�ɫ������Ļ
[xcenter,ycenter]=WindowCenter(window);
Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
frame_rate=Screen('FrameRate',window);
framedur=1000/frame_rate;%��λms

%%
%%%%%%����̼�����%%%%%%
pixelfor1degree=degree2pixel(1);%1�ȶ�������
FixDuration=500;%ע�ӵ����ʱ��ms
Fix_size = 0.2*pixelfor1degree;
FixationRect=CenterRect([0 0 Fix_size Fix_size],windowRect);%%ע�ӵ�λ��
FixLum=0;%ע�ӵ�ĻҶ�
KbName('UnifyKeyNames');
esc=KbName('escape');
right=KbName('RightArrow');
left=KbName('LeftArrow');
keycode=zeros(1,256);

%%%%��դ��ز���
contrast1=contrast;%�ڰ׹�դ�Աȶ�95%
contrast2=contrast;%���̹�դ�Աȶ�95%
SpatialPeriod1=1/sf*pixelfor1degree; %1cycles/degree, �ڰ׹�դÿ�����ڵ�������
SpatialPeriod2=1/sf*pixelfor1degree; %1cycles/degree, ���̹�դÿ�����ڵ�������
durationtime=70 ;%ÿ����դ���ֵ�ʱ��
num=4;%��֡��դ����ظ��Ĵ���,ÿ��ѭ��280ms

desCenter(:,:,1) = [xcenter-eccentricity-size/2 ycenter-size/2 ...
    xcenter-eccentricity+size/2 ycenter+size/2]; % left
desCenter(:,:,2) = [xcenter+eccentricity-size/2 ycenter-size/2 ...
    xcenter+eccentricity+size/2 ycenter+size/2]; % right

%%
%%%%ʵ�鿪ʼ֮ǰ����ע�ӵ�
while KbCheck; end
Screen('FillOval',window,FixLum,FixationRect);%fixation
Screen('DrawText',window,'Press any key to begin',FixationRect(1)-160,600-100,[0 0 0]);%��ʾ��ʼ
Screen('Flip', window);
KbWait;

rightkey=0;leftkey=0;p=0;i=1;
%%
while i<=80 %ÿ�������ж�80�Σ���fitting������Ͻ��
    
    if mod(i,40)==1
        
        if i~=1
            Screen('DrawText',window,'Please have a rest...',FixationRect(1)-150,FixationRect(2),[0 0 0]);%��ʾ��ʼ
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
    
    %%%%%%�ڰ׹�դ0��%%%%%%
    phase1=0*phase_orienting;
    GratingSize=round(size*pixelfor1degree);

    %grating_frames=round(GratingDuration/framedur);
    o_size=GratingSize; %o_size,��դ��С��ֱ��������
    o_Speriod=SpatialPeriod1;%o_Speriod,��դ�Ŀռ����ڣ�����
    o_speed=0;
    o_phase=phase1;%o_phase,���ܹ�դ����λ
    o_contrast=0;%o_contrast,���ܹ�դ�ĶԱȶ�
    o_orientation=0;%o_orientation,���ܹ�դ�ĳ���
    o_blur=0;%o_blur,���ܹ�դ��Ե������ģ��������
    o_duration=durationtime;
    
    gap=0;%��������֮��ļ�� degree
    
    i_size=GratingSize; %i_size,�����դ��С��ֱ��������
    i_Speriod=SpatialPeriod1;%i_Speriod,�����դ�Ŀռ����ڣ�����
    i_speed=0;%�ٶ�*�˶�����
    i_phase=phase1;%i_phase,�����դ����λ
    i_contrast=contrast1;%i_contrast,��׼��դ�ĶԱȶ�
    i_orientation=0;%i_orientation,�����դ�ĳ���
    i_blur=boundary*pixelfor1degree;%i_blur,�����դ��Ե������ģ��������
    i_duration=durationtime;
    
    %%grating
    gratingmatrix1=staticgratingmatrix(frame_rate,red,o_size,o_Speriod,o_speed,o_phase,o_contrast,o_orientation,o_blur,o_duration,...
        gap,i_size,i_Speriod,i_speed,i_phase,i_contrast,i_orientation,i_blur,i_duration,GRratio);
    
    gratingmatrix1=round(gratingmatrix1);
    
    %%%%%%�ڰ׹�դ180��%%%%%%
    phase3=pi*phase_orienting;
    GratingSize=round(size*pixelfor1degree);
    
    %grating_frames=round(GratingDuration/framedur);
    o_size=GratingSize; %o_size,��դ��С��ֱ��������
    o_Speriod=SpatialPeriod1;%o_Speriod,��դ�Ŀռ����ڣ�����
    o_speed=0;
    o_phase=phase3;%o_phase,���ܹ�դ����λ
    o_contrast=0;%o_contrast,���ܹ�դ�ĶԱȶ�
    o_orientation=0;%o_orientation,���ܹ�դ�ĳ���
    o_blur=0;%o_blur,���ܹ�դ��Ե������ģ��������
    o_duration=durationtime;
    
    gap=0;%��������֮��ļ�� degree
    
    i_size=GratingSize; %i_size,�����դ��С��ֱ��������
    i_Speriod=SpatialPeriod1;%i_Speriod,�����դ�Ŀռ����ڣ�����
    i_speed=0;%�ٶ�*�˶�����
    i_phase=phase3;%i_phase,�����դ����λ
    i_contrast=contrast1;%i_contrast,��׼��դ�ĶԱȶ�
    i_orientation=0;%i_orientation,�����դ�ĳ���
    i_blur=boundary*pixelfor1degree;%i_blur,�����դ��Ե������ģ��������
    i_duration=durationtime;
    
    %%grating
    gratingmatrix3=staticgratingmatrix(frame_rate,red,o_size,o_Speriod,o_speed,o_phase,o_contrast,o_orientation,o_blur,o_duration,...
        gap,i_size,i_Speriod,i_speed,i_phase,i_contrast,i_orientation,i_blur,i_duration,GRratio);
    
    gratingmatrix3=round(gratingmatrix3);
    %%%%%%���ɺ��̹�դ90��%%%%%%
    phase2=pi/2*phase_orienting;
    GratingSize=round(size*pixelfor1degree);
    
    %grating_frames=round(GratingDuration/framedur);
    o_size=GratingSize; %o_size,��դ��С��ֱ��������
    o_Speriod=SpatialPeriod2;%o_Speriod,��դ�Ŀռ����ڣ�����
    o_speed=0;
    o_phase=phase2;%o_phase,���ܹ�դ����λ
    o_contrast=0;%o_contrast,���ܹ�դ�ĶԱȶ�
    o_orientation=0;%o_orientation,���ܹ�դ�ĳ���
    o_blur=0;%o_blur,���ܹ�դ��Ե������ģ��������
    o_duration=durationtime;
    
    gap=0;%��������֮��ļ�� degree
    
    i_size=GratingSize; %i_size,�����դ��С��ֱ��������
    i_Speriod=SpatialPeriod2;%i_Speriod,�����դ�Ŀռ����ڣ�����
    i_speed=0;%�ٶ�*�˶�����
    i_phase=phase2;%i_phase,�����դ����λ
    i_contrast=contrast2;%i_contrast,��׼��դ�ĶԱȶ�
    i_orientation=0;%i_orientation,�����դ�ĳ���
    i_blur=boundary*pixelfor1degree;%i_blur,�����դ��Ե������ģ��������
    i_duration=durationtime;
    
    %%grating
    gratingmatrix2=colorstaticgratingmatrix(frame_rate,red,o_size,o_Speriod,o_speed,o_phase,o_contrast,o_orientation,o_blur,o_duration,...
        gap,i_size,i_Speriod,i_speed,i_phase,i_contrast,i_orientation,i_blur,i_duration,GRratio);
    
    gratingmatrix2=round(gratingmatrix2);
    
    %%%%%%���ɺ��̹�դ270��%%%%%%
    phase4=pi*3/2*phase_orienting;
    GratingSize=round(size*pixelfor1degree);
    
    %grating_frames=round(GratingDuration/framedur);
    o_size=GratingSize; %o_size,��դ��С��ֱ��������
    o_Speriod=SpatialPeriod2;%o_Speriod,��դ�Ŀռ����ڣ�����
    o_speed=0;
    o_phase=phase4;%o_phase,���ܹ�դ����λ
    o_contrast=0;%o_contrast,���ܹ�դ�ĶԱȶ�
    o_orientation=0;%o_orientation,���ܹ�դ�ĳ���
    o_blur=0;%o_blur,���ܹ�դ��Ե������ģ��������
    o_duration=durationtime;
    
    gap=0;%��������֮��ļ�� degree
    
    i_size=GratingSize; %i_size,�����դ��С��ֱ��������
    i_Speriod=SpatialPeriod2;%i_Speriod,�����դ�Ŀռ����ڣ�����
    i_speed=0;%�ٶ�*�˶�����
    i_phase=phase4;%i_phase,�����դ����λ
    i_contrast=contrast2;%i_contrast,��׼��դ�ĶԱȶ�
    i_orientation=0;%i_orientation,�����դ�ĳ���
    i_blur=boundary*pixelfor1degree;%i_blur,�����դ��Ե������ģ��������
    i_duration=durationtime;
    
    %%grating
    gratingmatrix4=colorstaticgratingmatrix(frame_rate,red,o_size,o_Speriod,o_speed,o_phase,o_contrast,o_orientation,o_blur,o_duration,...
        gap,i_size,i_Speriod,i_speed,i_phase,i_contrast,i_orientation,i_blur,i_duration,GRratio);
    
    gratingmatrix4=round(gratingmatrix4);
    
    eccentricity_left=[-eccentricity 0]*pixelfor1degree;%ƫ�ľ�
    eccentricity_right=[eccentricity 0]*pixelfor1degree;%ƫ�ľ�
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
    
    
    %����ÿ��trial��ʼ��ע�ӵ�
    for pp=1:round(FixDuration/framedur)
        Screen('FillOval',window,FixLum,FixationRect);%fixation
        Screen('Flip', window);
    end
    
    for k=1:num %��֡ѭ���ظ�num�Σ�һ��ѭ��280ms
        
        %%grating1
        for pp=1:grating_frames1
            Screen('FillRect',window,[red,red*GRratio,0],[0,0,2*xcenter,2*ycenter]);
            Screen('DrawTexture', window,gratings1(pp),[],GratingRect1);%��դ
            Screen('DrawTexture', window,gratings1(pp),[],GratingRect2);%��դ
            Screen('FillOval',window,FixLum,FixationRect);%fixation
            Screen('Flip',window);
        end
        
        %%grating2
        for pp=1:grating_frames2
            Screen('FillRect',window,[red,red*GRratio,0],[0,0,2*xcenter,2*ycenter]);
            Screen('DrawTexture', window,gratings2(pp),[],GratingRect1);%��դ
            Screen('DrawTexture', window,gratings2(pp),[],GratingRect2);%��դ
            Screen('FillOval',window,FixLum,FixationRect);%fixation
            Screen('Flip',window);
        end
        
        %%grating3
        for pp=1:grating_frames3
            Screen('FillRect',window,[red,red*GRratio,0],[0,0,2*xcenter,2*ycenter]);
            Screen('DrawTexture', window,gratings3(pp),[],GratingRect1);%��դ
            Screen('DrawTexture', window,gratings3(pp),[],GratingRect2);%��դ
            Screen('FillOval',window,FixLum,FixationRect);%fixation
            Screen('Flip',window);
        end
        
        %%grating4
        for pp=1:grating_frames4
            Screen('FillRect',window,[red,red*GRratio,0],[0,0,2*xcenter,2*ycenter]);
            Screen('DrawTexture', window,gratings4(pp),[],GratingRect1);%��դ
            Screen('DrawTexture', window,gratings4(pp),[],GratingRect2);%��դ
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
    while GetSecs-time0>0 %�ñ����ж�
        [keyisdown,secs,keycode]=KbCheck;
        WaitSecs(0.001);
        
        if keycode(right)==1  %һֱ��ȡup����ֱ������̧��
            rightkey=rightkey+1;
        elseif keycode(left)==1  %һֱ��ȡdown����ֱ������̧��
            leftkey=leftkey+1;
        elseif keycode(esc)==1
            Screen('CloseAll');
            
            break;
        end
        
        if keycode(right)==0 & rightkey~=0
            paramatrix(i,4)=1;
            rightkey=0;
            paramatrix(i,6) = (paramatrix(i,4).*paramatrix(i,5)+1)/2;%1 -1 �� 1 0
            i=i+1;
            break;
        elseif keycode(left)==0 & leftkey~=0
            paramatrix(i,4)=-1;
            leftkey=0;
            paramatrix(i,6) = (paramatrix(i,4).*paramatrix(i,5)+1)/2;%1 -1 �� 1 0
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

