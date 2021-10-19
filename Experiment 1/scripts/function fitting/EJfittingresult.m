%Equality Judgment task fitting
function output=EJfittingresult(subjectid,condition,curvecolor)

 load([subjectid '_paramatrix']);
%condition='i';

rawdata=[];
StrthRsp=[];


if condition=='v';
   conditionnumber=1;
 elseif condition=='i'
   conditionnumber=-1;
 elseif condition=='n'
   conditionnumber=0;
end
   
   
rawdata(:,1)=paramatrix(find(paramatrix(:,2)==conditionnumber & paramatrix(:,3)<=4),9);%%stim strength
rawdata(:,2)=paramatrix(find(paramatrix(:,2)==conditionnumber & paramatrix(:,3)<=4),11);%%response

% rawdata(:,1)=cell2mat(paramatrix(:,4));
% rawdata(:,2)=cell2mat(paramatrix(:,5));
rawdata=round(rawdata*100000)/100000;
StrthRsp(:,1)= unique(rawdata(:,1)); %�̼��ĵȼ���

for i=1:length(StrthRsp(:,1))
    StrthRsp(i,2)=length(find(rawdata(:,1)==StrthRsp(i,1)&rawdata(:,2)==1));%correct trials
    StrthRsp(i,3)=length(find(rawdata(:,1)==StrthRsp(i,1)));%total trials
end
%StrthRsp(:,1)=StrthRsp(:,1);
StrthRsp(:,4)=StrthRsp(:,2)./StrthRsp(:,3);

StimStrength=StrthRsp(:,1);
RespAccuracy=StrthRsp(:,4);
TrialCount=StrthRsp(:,3);
%curvecolor='b';% r g b k
output=fittinggaussian(StimStrength,RespAccuracy,TrialCount,curvecolor);



%%�ú����������θ�˹�ֲ��������
%%StimStrength �̼�ǿ��
%%RespAccuracy ��Ӧ��ȷ��
%%TrialCount ÿ���̼����trial��
%%curvecolor ������ɫ r g b k������ɫѡ��
function output=fittinggaussian(StimStrength,RespAccuracy,TrialCount,curvecolor)
%StimStrength
%%%%%%%%%%%%%%��ϸ�˹�ֲ�����%%%%%%%%%%%%%%%%
x = log10(min(StimStrength)):0.001:log10(max(StimStrength));

%Threshold0= (log10(min(StrthRsp(:,1)))+ log10(max(StrthRsp(:,1))))/2;
tempindex=find(TrialCount==max(TrialCount));
Threshold0=log10(StimStrength(tempindex(1)));%��trial������ǿ����Ϊ�����ʼ����
%Threshold0=log10(4);%��trial������ǿ����Ϊ�����ʼ����
slope0=0.3;
amp0=3;
beta0 = [Threshold0 slope0 amp0];

fun=@(beta,x) beta(3)*exp(-((x-beta(1))./(beta(2)*sqrt(2))).^2);

% %2014�汾matlab�������
% wnlm = fitnlm(log10(StimStrength),RespAccuracy,fun,beta0,'weight',TrialCount);
% yfit = predict(wnlm,x');

%%2011��֮ǰ�汾matlab�������
[wnlm r2] = nlinfit(log10(StimStrength),RespAccuracy,fun,beta0);
% StimStrength
% RespAccuracy
% TrialCount
yfit=fun(wnlm,x');


%%%%%%%%%%%%%%�� ͼ%%%%%%%%%%%%%%%%%%%%%%%%%
%ͼ�ε���ɫ
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
plot(10.^x,yfit,'LineWidth',2,'Color',linecolorr)
scatter(StimStrength,RespAccuracy,TrialCount*5,'ro','MarkerFaceColor',dotcolorr,'MarkerEdgeColor','none')

maxEJratio=max(yfit);%y��������ֵ
PSEindex=find(yfit==maxEJratio);
PSE=10^x(PSEindex);%�ҵ���Ӧ��x
% line([min(RespAccuracy) Threshold],[ThreP ThreP],'color',[0.5 0.5 0.5])
line([PSE PSE],[maxEJratio 0],'color',dotcolorr)
text(PSE,0.05,num2str(PSE,'%4.3g'))

output=wnlm;

%plot(exp(x),yfit1,'r',exp(x),yfit2,'k',exp(x),yfit3,'b','LineWidth',2);
%legend('test cued','center cued','ref cued');