%%zlf ZJU
%%2015-12-03
%%staircase procedure����ֵ
%%strengthmatrix,�̼�ǿ�Ⱦ���
%%responsematrix����Ӧ���� 0=different,1=same
%%minstrength����С�̼�
%%maxstrength����̼� ������С�̼������̼�ǿ�� ȷ��������С=�̼�����1/10(��λlog���������Զ���log��ʽ���ڴ̼�ǿ��)
%%initialstrength���̼�ǿ�ȳ�ʼֵ

function [stimulusstrength,stepdir]=equalitystair(strengthmatrix,responsematrix,dirmatrix,minstrength,maxstrength,initialstrength)
%

% strengthmatrix=tempstrength;
% responsematrix=tempresponse;
% minstrength=0.01;
% maxstrength=0.08;
% initialstrength=0.08;



step=abs(log(maxstrength*100)-log(minstrength*100))/10;

index=length(find(strengthmatrix~=0));                                      %��ǰ��trial��ţ������һ��ǿ�Ȳ�Ϊ0��trial��

if index == 0                                                                 %��һ��trial
    stimulusstrength=initialstrength;
    if initialstrength==maxstrength
        stepdir=-1;                                                         %�ڶ���trial����
        
    elseif initialstrength==minstrength
        stepdir=1;                                                          %�ڶ���trial����
    end  
    
elseif index == 1;
     stepdir=dirmatrix(index);                                              %�ڶ���trial�ı仯����
     stimulusstrength=exp(log(strengthmatrix(index)*100)+stepdir*step)/100; %�ڶ���trial��ǿ�� 
    
else
    if responsematrix(index)==-1 && responsematrix(index-1)==1              %ѡ����same��Ϊdifferent�����߷���ת
        stepsign=-1;
    else
        stepsign=1;                                                         %���߷��򲻱䣨���������ж�Ϊsame-same; different-different;different-same)
    end
    
    if round(strengthmatrix(index)*100)== round(maxstrength*100) || ...
        round(strengthmatrix(index)*100)==round(minstrength*100)
        stepsign=-1;                                                        %����ʲôѡ�񣬴ﵽ����ֵʱ�����߷���ת
    end
    
    stepdir=dirmatrix(index)*stepsign;                                      %��һ��trial�ı仯����
    stimulusstrength=exp(log(strengthmatrix(index)*100)+stepdir*step)/100; %��һ��trial��ǿ�� 
    
end

end