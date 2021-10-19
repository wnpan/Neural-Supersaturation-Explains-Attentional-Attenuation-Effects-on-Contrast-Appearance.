%% 20180925 motion surround suppression
% 2020/9/9 ��ԭ������������ӷ���ƽ�⣬���Դ��������䣨���򲻲����������
%          last edit by pwn
%% column 1 trial number
%% column 2 staircase��ţ�1 2
%% column 3 GRratio
%% column 4 �ж������1Ϊ���� -1Ϊ����
%% column 5 ��դ��λ�ı仯����1Ϊ����0 90 180 270�� -1Ϊ����0 -90 -180 -270��
%% column 6 ��ɫ��������or����=�ж����*�仯����1Ϊ���ӣ�-1Ϊ����
              


function isolumtest_buildmatrix(subjectid)
    % ��ȡ��ǰm�ļ�����·������ȡ�����ļ�paramatrix
    p = mfilename('fullpath');
    [filepath,~,~] = fileparts(p);
    filepath = strcat(filepath,'/Isolumtest_data/',subjectid,'_paramatrix');
try
    load(filepath);
    disp('the file already exist!')
catch
    
    StaircaseNum=[1 2];%ÿ��condition��2��staircase
    phase_orienting = [1 -1];
    trialpercondition=20;
    
    [x1,x2]=ndgrid(StaircaseNum,phase_orienting);
    
    %%%%%%%%%���ɲ�������%%%%%%%%%%%
    col=5;%��������һ��5��
    combinedpara = [x1(:),x2(:)];    
    paramatrixtemp0=zeros(length(combinedpara(:,1)),col);
    paramatrixtemp0(:,2)=combinedpara(:,1);
    paramatrixtemp0(:,5)=combinedpara(:,2);
    
    paramatrix0=[];
    for j=1:trialpercondition
        paramatrix0=[paramatrix0;paramatrixtemp0];
    end
    
    paramatrix=[];
    [pointer,index]=Shuffle(paramatrix0(:,1));%%%���Ҵ̼��Ĵ���
    for i=1:length(paramatrix0(:,1))
        paramatrix(i,:)=paramatrix0(index(i),:);
    end
    
    paramatrix(:,1)=[1:length(paramatrix(:,1))]';
    
    clear StaircaseNum
    clear combinedpara
    clear paramatrixtemp0
    clear paramatrix0
    clear pointer
    clear trialpercondition
    clear i
    clear j
    clear col
    clear index
    
    save(filepath,'paramatrix');
end
%
%
