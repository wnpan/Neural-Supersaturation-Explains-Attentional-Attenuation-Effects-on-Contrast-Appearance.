function [mat_subject,StimStrength]=All_EJfittingresult(subjectid, num, condition, DotsToBeDeletedMat)
%12 34 56 78 910阶梯法相反，其他条件相同
%个位数-test cued 十位数-neutral 二十位数-ref-cued
%red-test cued; green-neutral; blue-ref cued
%valid = ref cued; invaild = test cued
%num-查看指定空间频率的结果
%mat column1~5 sf row1~3 ref cued neutral test cued
%DotsToBeDeletedMat = [num conditionnumber DotsToBeDeleted;...]用来删除拟和不好的点
%num = 第几张图 conditionnumber哪条曲线 DotsToBeDeleted哪些点

%last edit by pwn 2020/10/15
%适用于相等判断任务的无偏估计

%输出mat_subject→包括函数拟合结果；PSE;X;Y;权重；正确率六块
%元胞构成→四张图四组→三种条件三组（1 test cued 2 neutral 3 standard cued）
%PS：X为指数坐标，画图时需要转化为10^x

cycle_num = 0;%用来统计循环了几次

PSE_mat = zeros(3,4);
yfit_mat_subject = {};
output_mat_subject = [];
TrialCount_mat_subject = {};
RespAccuracy_mat_subject = {};%储存每个被试的值
x_mat_subject= {};
for i =num
    rawdata=[];
    StrthRsp=[];
    IFisu = [0];
    cycle_num = cycle_num+1;
    
    load([subjectid '_paramatrix']);
    
    paramatrix = paramatrix(paramatrix(:,8)==IFisu(i),:);
    yfit_mat= {};
    output_mat = [];
    TrialCount_mat = {};
    RespAccuracy_mat = {};%储存每条曲线的值
    x_mat = {};
    for conditionnumber = condition
        if conditionnumber == 1
            curvecolor = 'b';
        elseif conditionnumber == 0
            curvecolor = 'g';
        else
            curvecolor = 'r';
        end
        
        rawdata(:,1)=paramatrix(find(paramatrix(:,6)==conditionnumber),9);%%stim strength
        rawdata(:,2)=paramatrix(find(paramatrix(:,6)==conditionnumber),11);%%response
        
        % rawdata(:,1)=cell2mat(paramatrix(:,4));
        % rawdata(:,2)=cell2mat(paramatrix(:,5));
        rawdata=round(rawdata*100000)/100000;
        StrthRsp(:,1)= unique(rawdata(:,1)); %刺激的等级数
        
        for k=1:length(StrthRsp(:,1))
            StrthRsp(k,2)=length(find(rawdata(:,1)==StrthRsp(k,1)&rawdata(:,2)==1));%correct trials
            StrthRsp(k,3)=length(find(rawdata(:,1)==StrthRsp(k,1)));%total trials
        end
        %StrthRsp(:,1)=StrthRsp(:,1);
        StrthRsp(:,4)=StrthRsp(:,2)./StrthRsp(:,3);
        
        StimStrength=StrthRsp(:,1);
        RespAccuracy=StrthRsp(:,4);
        TrialCount=StrthRsp(:,3);
        
        if ~isempty(DotsToBeDeletedMat)
            DotsToBeDeleted = DotsToBeDeletedMat(DotsToBeDeletedMat(:,1)==i, 2:end);
            DotsToBeDeleted = DotsToBeDeleted(DotsToBeDeleted(:,1)==conditionnumber, 2:end);
        else
            DotsToBeDeleted = [];
        end
        
        StimStrength(DotsToBeDeleted,:)=nan;%删除拟合不好的点
        RespAccuracy(DotsToBeDeleted,:)=nan;
        TrialCount(DotsToBeDeleted,:)=nan;
        
        %curvecolor='b';% r g b k
        if size(num,2)<=3
        subplot(2,2,cycle_num);
        elseif size(num,2)==4
            subplot(2,3,cycle_num);
        end
        [fitresult,gof,PSE,x,yfit]=fittinggaussian(StimStrength,RespAccuracy,TrialCount,curvecolor);
            PSE_mat(conditionnumber+2,i) = PSE;
            output_mat(size(output_mat,2)+1) = gof.rsquare;
            yfit_mat{size(yfit_mat,2)+1} = yfit;
            RespAccuracy_mat{size(RespAccuracy_mat,2)+1} = RespAccuracy;
            TrialCount_mat{size(TrialCount_mat,2)+1}  = TrialCount;
            x_mat{size(x_mat,2)+1} = x';
    end
    yfit_mat_subject{i} =yfit_mat;
    output_mat_subject(:,i) = output_mat;
    TrialCount_mat_subject{i} = TrialCount_mat;
    RespAccuracy_mat_subject{i} = RespAccuracy_mat;
    x_mat_subject{i} = x_mat;
end
    
mat_subject = {'R2','PSE','x','y','trialcount','accuracy';...
    output_mat_subject,PSE_mat,x_mat_subject,yfit_mat_subject,TrialCount_mat_subject,RespAccuracy_mat_subject};

    if size(num,2)==4
        subplot(2,3,5);
        plot(IFisu,PSE_mat(1,:),'LineWidth',2,'Color',[1 0 0]);
        hold on 
        subplot(2,3,5);
        plot(IFisu,PSE_mat(2,:),'LineWidth',2,'Color',[0 1 0]);
        hold on
        subplot(2,3,5);
        plot(IFisu,PSE_mat(3,:),'LineWidth',2,'Color',[0 0 1]);
        hold on 
    elseif size(num,2)==3
        subplot(2,2,4);
        plot(IFisu,PSE_mat(1,:),'LineWidth',2,'Color',[1 0 0]);
        hold on 
        subplot(2,2,4);
        plot(IFisu,PSE_mat(2,:),'LineWidth',2,'Color',[0 1 0]);
        hold on
        subplot(2,2,4);
        plot(IFisu,PSE_mat(3,:),'LineWidth',2,'Color',[0 0 1]);
        hold on 
    end

%%该函数用于相等判断任务-scaled skewd normal function曲线拟合
%%StimStrength 刺激强度
%%RespAccuracy 反应正确率
%%TrialCount 每个刺激点的trial数
%%curvecolor 曲线颜色 r g b k四种颜色选择
function [fitresult,gof,PSE,x,yfit]=fittinggaussian(StimStrength,RespAccuracy,TrialCount,curvecolor)

%StimStrength
%%%%%%%%%%%%%%拟合高斯分布曲线%%%%%%%%%%%%%%%%
x =min(StimStrength):0.001:max(StimStrength);

% %Threshold0= (log10(min(StrthRsp(:,1)))+ log10(max(StrthRsp(:,1))))/2;
tempindex=find(TrialCount==max(TrialCount));
Threshold0=StimStrength(tempindex(1));%以trial数最多的强度作为拟合起始参数

% 无偏拟合命令
% amp0*exp(-((x-Threshold0)./(slope0*sqrt(2))).^2)即高斯分布，后面乘的是偏态系数校正后的高斯累积函数，详情查看函数phi
fitType = fittype('amp0*exp(-((x-Threshold0)./(slope0*sqrt(2))).^2).*(7186705221432913*2^(1/2)*pi^(1/2)*(erf((2^(1/2)*(x-Threshold0)./slope0.*gama0)/2) + 1))/36028797018963968' ,...
     'dependent',{'y'},'independent',{'x'},...
     'coefficients',{'amp0', 'Threshold0', 'slope0','gama0'});
opts = fitoptions( 'Method', 'NonlinearLeastSquares','weights',TrialCount);

opts.Lower = [0 0 0 -3];
opts.StartPoint = [1, StimStrength(tempindex(1)),0.3,1];
opts.Upper = [2 1 100 0];

[fitresult, gof] = fit( StimStrength, RespAccuracy, fitType, opts );
yfit = fitresult(x);
% %%2011或之前版本matlab拟合命令

% [wnlm r2] = nlinfit(log10(StimStrength),RespAccuracy,fun,beta0);
% % StimStrength
% % RespAccuracy
% % TrialCount
% yfit=fun(wnlm,x');

%%%%%%%%%%%%%%画 图%%%%%%%%%%%%%%%%%%%%%%%%%
%图形的颜色
if curvecolor=='r'
    linecolorr=[1 0 0];
    dotcolorr=[0.8 0.4 0.4];
elseif curvecolor=='g'
    linecolorr=[0 1 0];
    dotcolorr=[0.4 0.8 0.4];
elseif curvecolor=='b'
    linecolorr=[0 0 1];
    dotcolorr=[0.5 0.5 0.8];
else
    linecolorr=[0 0 0];
    dotcolorr=[0.4 0.4 0.4];
end

hold on
plot(x,yfit,'LineWidth',2,'Color',linecolorr)
scatter(StimStrength,RespAccuracy,TrialCount*5,'ro','MarkerFaceColor',dotcolorr,'MarkerEdgeColor','none')

maxEJratio=max(yfit);%y方向的最大值
PSEindex=find(yfit==maxEJratio);
PSE= x(PSEindex);%找到对应的x
% line([min(RespAccuracy) Threshold],[ThreP ThreP],'color',[0.5 0.5 0.5])
line([PSE PSE],[maxEJratio 0],'color',dotcolorr)
text(PSE,0.05,num2str(PSE,'%4.3g'))

%plot(exp(x),yfit1,'r',exp(x),yfit2,'k',exp(x),yfit3,'b','LineWidth',2);
%legend('test cued','center cued','ref cued');
