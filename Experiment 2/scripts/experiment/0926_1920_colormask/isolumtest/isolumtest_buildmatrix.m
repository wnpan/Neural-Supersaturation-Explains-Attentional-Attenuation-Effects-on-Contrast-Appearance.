%% 20180925 motion surround suppression
% 2020/9/9 在原程序基础上增加方向平衡，总试次数量不变（方向不参与阶梯排序）
%          last edit by pwn
%% column 1 trial number
%% column 2 staircase编号：1 2
%% column 3 GRratio
%% column 4 判断情况：1为向左 -1为向右
%% column 5 光栅相位的变化方向：1为正（0 90 180 270） -1为负（0 -90 -180 -270）
%% column 6 绿色亮度增加or减少=判断情况*变化方向：1为增加，-1为减少
              


function isolumtest_buildmatrix(subjectid)
    % 读取当前m文件所在路径，读取数据文件paramatrix
    p = mfilename('fullpath');
    [filepath,~,~] = fileparts(p);
    filepath = strcat(filepath,'/Isolumtest_data/',subjectid,'_paramatrix');
try
    load(filepath);
    disp('the file already exist!')
catch
    
    StaircaseNum=[1 2];%每个condition有2个staircase
    phase_orienting = [1 -1];
    trialpercondition=20;
    
    [x1,x2]=ndgrid(StaircaseNum,phase_orienting);
    
    %%%%%%%%%生成参数矩阵%%%%%%%%%%%
    col=5;%参数矩阵一共5列
    combinedpara = [x1(:),x2(:)];    
    paramatrixtemp0=zeros(length(combinedpara(:,1)),col);
    paramatrixtemp0(:,2)=combinedpara(:,1);
    paramatrixtemp0(:,5)=combinedpara(:,2);
    
    paramatrix0=[];
    for j=1:trialpercondition
        paramatrix0=[paramatrix0;paramatrixtemp0];
    end
    
    paramatrix=[];
    [pointer,index]=Shuffle(paramatrix0(:,1));%%%打乱刺激的次序
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
