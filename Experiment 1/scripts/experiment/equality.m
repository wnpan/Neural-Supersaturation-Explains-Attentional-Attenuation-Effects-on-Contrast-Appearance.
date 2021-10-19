function equality(subjectid,start,over,beep)
%%  equality +stair (cRef = 0.6)
% last edit by PWN 2020/6/13
% ����λ�������޸ģ�ʹ��ÿ��trial����λ��ͬ��tiral����λ���
%beep - �Ƿ���跴����&�Ƿ���Ϣ

global inc background white
%% %%%%%%%%%%%%%%%%%%%%%%%%%% ������Ļ %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
HideCursor;
% Screen('Preference', 'SkipSyncTests', 1);
screenNumber=max(Screen('Screens'));

% ��Ļ��ɫ
white=WhiteIndex(screenNumber);
black=BlackIndex(screenNumber);
grey=round((white+black)/2);
if grey == white
    grey=white / 2;
end
inc = abs(white-grey);
background=grey;
wait_color = white/4;

% ��һ����Ļ
[w,rect]=Screen('OpenWindow',screenNumber,background);

% ��Ļ�����趨
AssertGLSL;                                                                 % Make sure this GPU supports shading at all
load('newclut');
load('oldclut');
Screen('LoadNormalizedGammaTable',screenNumber,newclut);                    % write CLUTs, screen normalization
Screen(w,'BlendFunction',GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);             % Enable alpha blending for typical drawing of masked textures
priorityLevel=MaxPriority(w);
Priority(priorityLevel);

% ��Ļˢ��Ƶ��
frameRate=Screen('FrameRate',w);
frameDura=1000/frameRate;
if  round(frameRate)~=100                                                  % ȷ��ˢ��Ƶ����85hz�����������
    quit
end

% ��Ļ�ߴ�
xcenter=rect(3)/2;                                                          % ��Ļ���ĺ�����
ycenter=rect(4)/2;


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%% ���巴Ӧ���� %%%%%%%%%%%%%%%%%%%%%%%%%%%
KbName('UnifyKeyNames');
key_f=KbName('f');
key_j=KbName('j');

key_q=KbName('q');
space=KbName('space');


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%% �̼������趨 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% size
% �̼���С
pixelPerDegree = round(degree2pixel(1));
sizeCue = round(degree2pixel(0.3));
sizeFix = round(degree2pixel(0.2));
% linethickness = round(degree2pixel(0.1));
% sizeFixArea = round(degree2pixel(2));
r = 1;
sizeGrating = round(degree2pixel(r));  % �뾶
cueColor = black;

Adaption_r = 1.2;
Adaption_sizeGrating = round(degree2pixel(Adaption_r));

%% destinations
% ע�ӵ��λ��
% desFix = [xcenter-sizeFix/2,ycenter-sizeFix/2,xcenter+sizeFix/2,ycenter+sizeFix/2];

% desFix(1,:) = [xcenter-sizeFix xcenter+sizeFix xcenter xcenter];
% desFix(2,:) = [ycenter ycenter ycenter-sizeFix ycenter+sizeFix];
desFix = [xcenter,ycenter];

% gratings % 1 �� 2 ��
eccentricity_grating = round(degree2pixel(4)); % ���ľ���
desCenter(:,:,1) = [xcenter-eccentricity_grating-sizeGrating ycenter-sizeGrating...
    xcenter-eccentricity_grating+sizeGrating ycenter+sizeGrating]; % left
desCenter(:,:,2) = [xcenter+eccentricity_grating-sizeGrating ycenter-sizeGrating...
    xcenter+eccentricity_grating+sizeGrating ycenter+sizeGrating]; % right

%
Adaption_desCenter(:,:,1) = [xcenter-eccentricity_grating-Adaption_sizeGrating ycenter-Adaption_sizeGrating...
    xcenter-eccentricity_grating+Adaption_sizeGrating ycenter+Adaption_sizeGrating]; % left
Adaption_desCenter(:,:,2) = [xcenter+eccentricity_grating-Adaption_sizeGrating ycenter-Adaption_sizeGrating...
    xcenter+eccentricity_grating+Adaption_sizeGrating ycenter+Adaption_sizeGrating]; % left
% cue��λ��
eccentricity_cue = round(degree2pixel(r+0.5)); % ���ľ���
desCue(:,:,1) = [xcenter-eccentricity_grating ycenter-eccentricity_cue]; % left
desCue(:,:,2) = [xcenter ycenter]; % neutral
desCue(:,:,3) = [xcenter+eccentricity_grating ycenter-eccentricity_cue]; % right
% desCue(:,:,2) = [xcenter ycenter]; % center
% desCue(:,:,3) = [xcenter+eccentricity2 ycenter-eccentricity1]; % right


%% durations
% cue
cueDura = 70;
cueFrames = round(cueDura/frameDura);

% gratingDura
gratingDura = 40;
gratingFrames = round(gratingDura/frameDura);

% testDura = 200;
% testFrames = round(testDura/frameDura);

% blankDura = 50
SOA = 120;
blankDura = SOA-cueDura;
blankFrames = round(blankDura/frameDura);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%% grating %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ��դ�Աȶ�
cRef = 0.6;
minc = 0.2920;
maxc = 0.9696;
% cRef = 0.4;
% minc = 0.179735;
% maxc = 0.890235;
cTest0 = [minc maxc];
stepdir0 = [1 -1];

% �ռ�Ƶ��spatial frequency
cyclePerDegree = 4;
period = pixelPerDegree/cyclePerDegree; % how many pixels in one cycle
sf = 1/period;
angleRef = 0;
angleTest = 0;

% cAdaption = 0.6;
Adaption_cyclePerDegree = 4;
Adaption_sf = Adaption_cyclePerDegree/pixelPerDegree;
Adaption_cyclePerDegree_sigma = 0.1;
Adaption_sf_sigma = Adaption_cyclePerDegree_sigma/pixelPerDegree;
Adaption_angle = 0;
Adaption_angle_sigma = Inf;%��ȫ�������
Adaption_boundary = 0.5;
%% %%%%%%%%%%%%%%%%%%%% eye tracking setup %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% eye tracker setup
%%����֮ǰ��ʼ�����ڣ��ر� ɾ�����ܴ��ڵĴ��ڣ�
% IOPort('closeall');
%
% %%��������
% % [handle, errmsg] = IOPort('OpenSerialPort', 'com3','BaudRate=256000 ReceiveTimeout=0.3');
% [handle, errmsg] = IOPort('OpenSerialPort', 'com3','BaudRate=512000 ReceiveTimeout=0.2');
% IOPort('Purge',handle); %������ж�д����������
% %%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%1 ����StimRD��stimuli ready���ź� �̼�������׼����
% StimRD='R';
% [nwritten, when, errmsg] = IOPort('Write', handle, StimRD);

% %%2 ����Tobii������׼�����ź�
% while KbCheck; end
% TobReSig=0;
% qkey=KbName('q');
% keycode=zeros(1,256);
% while ~keycode(qkey) && ~TobReSig
%     [data, when, errmsg] = IOPort('Read', handle,0,1);
%     IOPort('Purge',handle); %������ж�д����������
%     tobiiready=char(data);
%     [keydown secs keycode]=KbCheck;
%
%     if strcmp(tobiiready,'R')==1
%         fprintf('Tobii is ready! \n');
%         fprintf('------------------------------------------\n');
%         TobReSig=1;
%     else
%         [nwritten, when, errmsg] = IOPort('Write', handle, StimRD);
%         fprintf('%f Waiting for Tobii getting ready. \n', when);
%         WaitSecs(1);
%     end
% end



%% %%%%%%%%%%%%%%%%%%%%%%%  ����buildmatrix %%%%%%%%%%%%%%%%%%%%%%%%%
% buildmatrixSOA(subjectid,SOA);
filename = ['data/',subjectid,'_paramatrix'];
load(filename);

blockNum = 8;
npblock = length(paramatrix(:,1))/blockNum;

% npblock = length(paramatrix(:,1));

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%% ѭ���ṹ %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Screen('Flip',w); % ��߾���

for index = start:over
    
    trialtype = paramatrix(index,2); % 1~30
    initialdir = (paramatrix(index,13)+3)/2;
    
    indexDesCue = paramatrix(index,3)+2;%-1 0 1��1 2 3
    indexDesRef = (paramatrix(index,4)+3)/2;%-1  1��1 2
    indexDesTest = (paramatrix(index,5)+3)/2;%-1  1��1 2
    
    fixDura = paramatrix(index,7);
    fixFrames = round(fixDura/frameDura);
    
%     cyclePerDegree = paramatrix(index,8);
%     period = pixelPerDegree/cyclePerDegree; % how many pixels in one cycle
%     sf = 1/period;
    
    cAdaption = paramatrix(index,8);
%     cAdaption = 1;
   
    indexMatrix = paramatrix(find(paramatrix(:,2)==trialtype),1); % �õ���trialtype��trial���к�
    % the first trial
    if paramatrix(indexMatrix,9)==0 % test contrast matrix
        paramatrix(index,9) = cTest0(initialdir);
        paramatrix(index,10) = log(cTest0(initialdir)*100);
        paramatrix(index,14) = stepdir0(initialdir);
    end
    
    cTest = paramatrix(index,9);
    
    phase = rand(1)*2*pi;
    MatrixTest = TextureCenter(sizeGrating,angleTest,cTest,sf,phase);
    test = Screen('MakeTexture',w, MatrixTest);
    MatrixRef = TextureCenter(sizeGrating,angleRef,cRef,sf,phase);
    ref = Screen('MakeTexture',w, MatrixRef);
    gratingTexture = [test ref];
    desGrating = reshape([desCenter(:,:,indexDesTest) desCenter(:,:,indexDesRef)],4,2);
    [MatrixAdaptionGrating,AdaptionGrating_luminance,AdaptionGrating_Michelson_contrast] =  ...
        TextureNoiseMask(Adaption_sizeGrating,cAdaption, ...
        Adaption_angle,Adaption_angle_sigma,Adaption_sf, ...
        Adaption_sf_sigma,Adaption_boundary);
    paramatrix(index,16) = AdaptionGrating_luminance;%��¼noise���ȣ��ں���ķ����п��ܻ�����
    paramatrix(index,17) = AdaptionGrating_Michelson_contrast;%��¼Michelson�Աȶȣ��ں���ķ����п��ܻ�����
%     Left_AdaptionGrating = Screen('MakeTexture',w, Left_MatrixAdaptionGrating/AdaptionGratingNum);
%     Right_AdaptionGrating = Screen('MakeTexture',w, Right_MatrixAdaptionGrating/AdaptionGratingNum);
    Left_AdaptionGrating = Screen('MakeTexture',w, MatrixAdaptionGrating);
    Right_AdaptionGrating = Screen('MakeTexture',w, MatrixAdaptionGrating);
    Adaption_gratingTexture = [Left_AdaptionGrating Right_AdaptionGrating];
    Adaption_desGrating = reshape([Adaption_desCenter(:,:,1) Adaption_desCenter(:,:,2)],4,2);
    
    
    %% %%%%%%%%%%%%%%%%%% ����ע�ӵ㣬�ȴ����԰��¿ո����ʼ���� %%%%%%%%%%%%%%%%%
    %     Screen('FillRect', w, 100, desFix);
    %     Screen('DrawLines',w,desFix,linethickness,black,[],1);
    Screen('DrawDots',w,desFix,sizeFix,wait_color,[],1);
    Screen('Flip', w);
    WaitSecs(0.2);
    [keyisdown,secs,keycode] = KbCheck;
    while keycode(space) == 0
        KbWait;
        [keyisdown,secs,keycode] = KbCheck;
        WaitSecs(0.001);
        
        % ��q���˳�
        if keycode(key_q)
            ShowCursor;
            Priority(0);
            Screen('LoadNormalizedGammaTable',screenNumber,oldclut);
            Screen('CloseAll');
            %             ExpOver='O';
            %             [nwritten, when, errmsg] = IOPort('Write', handle, ExpOver);
            %             fprintf('%f Experiment Over!!�� \n',when);
            %             IOPort('closeall');
            ShowCursor; %
            return
        end
    end
    
    %     %%3 ����StaRec�źţ�Ҫ���۶��ǿ�ʼ��¼�۶�����
    %     StartRecord='B';
    %     [nwritten, when, errmsg] = IOPort('Write', handle, StartRecord);
    %     fprintf('Trial %i.\n',index);
    %     fprintf('%f Ask Tobii to begin to record. \n',when);
    
    %     %%4 ���ִ̼�
    %     fprintf('Presenting Stimuli ....... \n');
    %
    % ���ո�ʼ
    if keycode(space)
        
        % 1. ע�ӵ����
        for r = 1:fixFrames
            %             Screen('FillRect', w, black, desFix);
            Screen('DrawTextures', w,Adaption_gratingTexture,[],Adaption_desGrating); % gratings
            Screen('DrawDots',w,desFix,sizeFix,black,[],1);
            Screen('Flip',w);
        end
        
        
        % 2. cue����
        for r = 1:cueFrames
            Screen('DrawDots',w,desCue(:,:,indexDesCue),sizeCue,cueColor,[],1);
            Screen('DrawTextures', w,Adaption_gratingTexture,[],Adaption_desGrating); % gratings
            %             Screen('FillRect', w, black, desFix);
            %             Screen('DrawLines',w,desFix,linethickness,black,[],1);
            Screen('DrawDots',w,desFix,sizeFix,black,[],1);
            Screen('Flip', w);
        end
        
        % 3. blank
        for r = 1:blankFrames
            %             Screen('FillRect', w, black, desFix);
            %             Screen('DrawLines',w,desFix,linethickness,black,[],1);
            Screen('DrawTextures', w,Adaption_gratingTexture,[],Adaption_desGrating); % gratings
            Screen('DrawDots',w,desFix,sizeFix,black,[],1);
            Screen('Flip',w);
        end
        
        % 4. �̼�����
        for r = 1: gratingFrames
            Screen('DrawTextures', w,gratingTexture,[],desGrating); % gratings
            %             Screen('FillRect', w, black, desFix);
            %             Screen('DrawLines',w,desFix,linethickness,black,[],1);
            Screen('DrawDots',w,desFix,sizeFix,black,[],1);
            start_time = Screen('Flip',w);
        end
    end
    
    %     %%5 Tobii ֹͣ��¼
    %     StopRecord='S';
    %     [nwritten, when, errmsg] = IOPort('Write', handle, StopRecord);
    %     fprintf('%f Ask Tobii to stop recording. \n',when);
    
    %% %%%%%%%%%%%%%%%%%%%%%%%%% ��¼��Ӧ ������%%%%%%%%%%%%%%%%%%%%%%%%%%
    key = 0;
    
    while key == 0
        %         Screen('FillRect', w, black, desFix);
        %         Screen('DrawLines',w,desFix,linethickness,black,[],1);
        Screen('DrawDots',w,desFix,sizeFix,black,[],1);
        Screen('Flip',w);
        
        % ��Ӧ��¼
        [keyisdown, secs, keycode] =  KbCheck;
        over_time=GetSecs;
        WaitSecs(0.001);
        paramatrix(index,12) = (over_time-start_time)*1000;
        
        if keycode(key_f)
            key = 1;
            paramatrix(index,11) = 1;                                        % same response
            break
        elseif keycode(key_j)
            key = 1;
            paramatrix(index,11) = -1;                                       % different response
            break
        end
    end
    
    Screen('DrawDots',w,desFix,sizeFix,wait_color,[],1);
    Screen('Flip',w);
    
    if beep == true
        if round(cRef*100) == round(cTest*100)
            if paramatrix(index,11)==-1
                Beeper(800);
            end
        elseif round(cTest*100)<=47 || round(cTest*100)>=76
            if  paramatrix(index,11)==1
                Beeper(400);
            end
        end
    end
    
    
    %% %% next trial %%%
    
    contrastMatrix = paramatrix(indexMatrix,9);
    responseMatrix = paramatrix(indexMatrix,11);
    dirMatrix = paramatrix(indexMatrix,14);
    [cTest2,stepdir2] = equalitystair(contrastMatrix,responseMatrix,dirMatrix,minc,maxc,cTest0(initialdir));
    index1=length(find(contrastMatrix~=0));      %��ǰ��trial��ţ������һ��ǿ�Ȳ�Ϊ0��trial��
    if index1 < size(contrastMatrix,1)
        index2 = indexMatrix(index1+1);              % next sequence index of this type
        paramatrix(index2,9) = cTest2;
        paramatrix(index2,10) = log(cTest2*100);
        paramatrix(index2,14) = stepdir2;
    end
    
    %     %%6�����۶�������
    %     fprintf('%f Receiving data .......\n',when);
    %     XYPositionTimepoint=ReceiveEyemoveData(handle);
    %     PositionTime{index}=XYPositionTimepoint;
    %     save(['fixData/',subjectid,'_FixData'],'PositionTime','rect')
    %     % WaitSecs(1);
    %     fprintf('------------------------------------------\n');
    
    %% save
    save(filename,'paramatrix');
    
    % ��Ϣ
    if mod(index,npblock)==0 && index~=over && ~beep
        Screen('DrawText',w,'Take A Rest',xcenter-80,ycenter, [0 0 0]);
        Screen('Flip',w);
        WaitSecs(5);
        KbWait;
    elseif index==over
        %         ExpOver='O';
        %         [nwritten, when, errmsg] = IOPort('Write', handle, ExpOver);
        %         fprintf('%f Experiment Over!!�� \n',when);
        %         IOPort('closeall');
        
        Screen('DrawText',w,'The end. Thank You! ',xcenter-150,ycenter, [0 0 0]);
        Screen('Flip',w);
        WaitSecs(1);
        KbWait;
        break
    end
    
    Screen('close',gratingTexture);                                         % close screen
    
end

%% %%%%%%%%%%%%%%%%%%%%%% �رմ���%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Priority(0);
Screen('LoadNormalizedGammaTable',screenNumber,oldclut);
Screen('CloseAll');
ShowCursor; % ��ʾ���

end









