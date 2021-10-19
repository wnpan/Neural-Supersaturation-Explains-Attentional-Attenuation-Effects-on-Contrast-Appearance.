 function [Gratio,output]=fittingresult(subjectid)
% 读取当前m文件所在路径，读取数据文件paramatrix
p = mfilename('fullpath');
[filepath,~,~] = fileparts(p);
filepath = strcat(filepath,'/Isolumtest_data/',subjectid,'_paramatrix');
 
load(filepath);

rawdata=[];
StrthRsp=[];
curvecolor='r';

rawdata(:,1)= paramatrix(:,3)%stim strength
rawdata(:,2)= paramatrix(:,6)%response

rawdata=round(rawdata*100000)/100000;
StrthRsp(:,1)= unique(rawdata(:,1)); %刺激的等级数

for i=1:length(StrthRsp(:,1))
    StrthRsp(i,2)=length(find(rawdata(:,1)==StrthRsp(i,1)&rawdata(:,2)==1));%corret trials
    StrthRsp(i,3)=length(find(rawdata(:,1)==StrthRsp(i,1)));%total trials
end

StrthRsp(:,4)=StrthRsp(:,2)./StrthRsp(:,3);

StimStrength=StrthRsp(:,1);
RespAccuracy=StrthRsp(:,4);
TrialCount=StrthRsp(:,3);

linestyle='-';
[Gratio,output]=fittingsigmoid(StimStrength,RespAccuracy,TrialCount,curvecolor,linestyle);



%%该函数用于s形曲线拟合
%%StimStrength 刺激强度
%%RespAccuracy 反应正确率
%%TrialCount 每个刺激点的trial数
%%curvecolor 曲线颜色 r g b k四种颜色选择
function [Gratio,output]=fittingsigmoid(StimStrength,RespAccuracy,TrialCount,curvecolor,linestyle)
%StimStrength
%%%%%%%%%%%%%%拟合s形曲线%%%%%%%%%%%%%%%%
x = log10(min(StimStrength)):0.001:log10(max(StimStrength));

%Threshold0= (log10(min(StrthRsp(:,1)))+ log10(max(StrthRsp(:,1))))/2;
tempindex=find(TrialCount==max(TrialCount));
Threshold0=log10(StimStrength(tempindex(1)));%以trial数最多的强度作为拟合起始参数
%Threshold0=log10(4);%以trial数最多的强度作为拟合起始参数
slope0=0.3;
beta0 = [Threshold0 slope0];
fun = @(beta,x)(1+erf(((x-beta(1))/beta(2))/sqrt(2)))/2; %%chancelevel=0情况
%fun = @(beta,x)((1+erf(((x-beta(1))/beta(2))/sqrt(2)))/2)*0.5+0.5; %%chance level=0.5情况
%fun = @(beta,x)((1+erf(((x-beta(1))/beta(2))/sqrt(2)))/2)*0.75+0.25; %%chance level=0.25情况

% %2014版本matlab拟合命令
% wnlm = fitnlm(log10(StimStrength),RespAccuracy,fun,beta0,'weight',TrialCount);
% yfit = predict(wnlm,x');

%%2011或之前版本matlab拟合命令
[wnlm r2] = nlinfit(log10(StimStrength),RespAccuracy,fun,beta0);
% StimStrength
% RespAccuracy
% TrialCount
yfit=fun(wnlm,x');


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
plot(10.^x,yfit,'LineWidth',2,'Color',linecolorr,'LineStyle',linestyle)
scatter(StimStrength,RespAccuracy,TrialCount*5,'ro','MarkerFaceColor',dotcolorr,'MarkerEdgeColor','none')

ThreP=0.5;%阈值处的正确率
ThreIndex=find(abs(yfit-ThreP)==min(abs(yfit-ThreP)));
Threshold=10^x(ThreIndex);%找到对应的阈值
line([min(StimStrength) Threshold],[ThreP ThreP],'color',[0.5 0.5 0.5])
line([Threshold Threshold],[ThreP 0],'color',dotcolorr)
text(Threshold,0.05,num2str(Threshold,'%4.3g'))

% line([0.3 0.3],[0 1],'color',[0.5 0.5 0.5])

xlabel('GRratio')
ylabel('% of Correct Response')
Gratio = Threshold;

output=wnlm;


%plot(exp(x),yfit1,'r',exp(x),yfit2,'k',exp(x),yfit3,'b','LineWidth',2);
%legend('test cued','center cued','ref cued');

