%%Yongchun Cai ZJU
%%2019-7-23�޸���1u2d��1u3d �е����ϵ�step������������
%%2015-11-06
%%staircase procedure����ֵ
%%staircasetype,���ݵ����ͣ��ַ������룬1u1d��1u2d��1u3d
%%strengthmatrix,�̼�ǿ�Ⱦ���
%%responsematrix����Ӧ����
%%minstrength����С�̼�
%%maxstrength����̼� ������С�̼������̼�ǿ�� ȷ��������С����С�����Ǵ�С�̼�����1/9(��λlog���������Զ���log��ʽ���ڴ̼�ǿ��)
%%initialstrength���̼�ǿ�ȳ�ʼֵ

function stimulusstrength=updownstaircase(staircasetype,strengthmatrix,responsematrix,minstrength,maxstrength,initialstrength)
% 
% staircasetype='1u2d';
% strengthmatrix=tempstrength;
% responsematrix=tempresponse;
% minstrength=0.01;
% maxstrength=0.08;
% initialstrength=0.08;



minstep=abs(log10(maxstrength)-log10(minstrength))/11;
maxstep=minstep*8;

currentpoint=length(find(strengthmatrix~=0));%��ǰ��trial��ţ������һ��ǿ�Ȳ�Ϊ0��trial��
if currentpoint==0
   stimulusstrength=initialstrength; %stair�ĵ�һ��trial
else
   switch staircasetype
      
      %%%%%%%%%%%%%%%1��1�½��ݷ�%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
      case '1u1d'
          if responsematrix(currentpoint)==0
             stepsign=1; %�������󣬴̼�ǿ������
          elseif responsematrix(currentpoint)==1
             stepsign=-1; %������ȷ���̼�ǿ���½�
          end
           
          if currentpoint==1
             stimulusstrength=10^(log10(strengthmatrix(currentpoint))+stepsign*maxstep);
          else
             currentstep=abs(log10(strengthmatrix(currentpoint))-log10(strengthmatrix(currentpoint-1)));%��ǰ��step
             if responsematrix(currentpoint-1)==responsematrix(currentpoint)
                stimulusstrength=10^(log10(strengthmatrix(currentpoint))+stepsign*currentstep);
               elseif responsematrix(currentpoint-1)~=responsematrix(currentpoint)
                stimulusstrength=10^(log10(strengthmatrix(currentpoint))+stepsign*max([currentstep/2 minstep]));
             end
          end
          
      %%%%%%%%%%%%%%%1��2�½��ݷ�%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      case '1u2d'
         if currentpoint==1
             if responsematrix(currentpoint)==0
                stepsign=1; %�������󣬴̼�ǿ������
             else
                stepsign=0; %������ȷ���̼�ǿ�Ȳ���
             end
             stimulusstrength=10^(log10(strengthmatrix(currentpoint))+stepsign*maxstep);
          else
             %ȷ��step�ķ��� 
             if responsematrix(currentpoint)==0
                  stepsign=1;
               elseif responsematrix(currentpoint-1)==1&&responsematrix(currentpoint)==1&&abs(log10(strengthmatrix(currentpoint-1))-log10(strengthmatrix(currentpoint)))<0.1*minstep %����ǿ�Ƚӽ������ʱ
                   stepsign=-1;
               else
                  stepsign=0;
             end
             
             %�������step��С
             laststep=0;
             kk=1;
             while abs(laststep)<0.1*minstep && (currentpoint-kk)>0 
               laststep=log10(strengthmatrix(currentpoint))-log10(strengthmatrix(currentpoint-kk));
               kk=kk+1;
             end
             
             %����stimulusstrength
             if laststep==0 %stair�տ�ʼ����û��step
                 currentstep=maxstep;
                 stimulusstrength=10^(log10(strengthmatrix(currentpoint))+stepsign*currentstep);
             else
                 currentstep=abs(laststep);
                 if sign(laststep)==sign(stepsign) %��֮ǰ��step����һ�£�step����
                    stimulusstrength=10^(log10(strengthmatrix(currentpoint))+stepsign*currentstep);
                  elseif  sign(laststep)~=sign(stepsign) %��֮ǰ��step�����෴��step���룬ֱ��minstep
                    stimulusstrength=10^(log10(strengthmatrix(currentpoint))+stepsign*max([currentstep/2 minstep]));
                 end       
             end
         end 
       
       %%%%%%%%%%%%%%%1��3�½��ݷ�%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       case '1u3d' 
           last1point=currentpoint-1;
           last2point=currentpoint-2;
           if last1point<1||last2point<1
               if responsematrix(currentpoint)==0
                 stepsign=1; %�������󣬴̼�ǿ������
                else
                 stepsign=0; %������ȷ���̼�ǿ�Ȳ���
               end
               stimulusstrength=10^(log10(strengthmatrix(currentpoint))+stepsign*maxstep);
           else
               %ȷ��step����
               if responsematrix(currentpoint)==0
                   stepsign=1;
                elseif responsematrix(last1point)==1&&responsematrix(last2point)==1&&responsematrix(currentpoint)==1 && abs(log10(strengthmatrix(last2point))-log10(strengthmatrix(currentpoint)))<0.1*minstep %����ǿ�Ƚӽ������ʱ
                   stepsign=-1;
                else
                   stepsign=0;
               end
         
               %�������step��С
               laststep=0;
               kk=1;
               while abs(laststep)<0.1*minstep && (currentpoint-kk)>0
                 laststep=log10(strengthmatrix(currentpoint))-log10(strengthmatrix(currentpoint-kk));
                 kk=kk+1;
               end
               
               %����stimulusstrength
               if laststep==0 %stair�տ�ʼ����û��step
                  currentstep=maxstep;
                  stimulusstrength=10^(log10(strengthmatrix(currentpoint))+stepsign*currentstep);
                else
                  currentstep=abs(laststep);
                  if sign(laststep)==sign(stepsign) %��֮ǰ��step����һ�£�step����
                     stimulusstrength=10^(log10(strengthmatrix(currentpoint))+stepsign*currentstep);
                   elseif  sign(laststep)~=sign(stepsign) %��֮ǰ��step�����෴��step���룬ֱ��minstep
                     stimulusstrength=10^(log10(strengthmatrix(currentpoint))+stepsign*max([currentstep/2 minstep]));
                  end       
               end
               
           end
       %%%%%%%%%%%%%%%%%%%%%%%
   end
          
end


%%%���ƴ̼���Χ��minstrength��maxstrength֮��
stimulusstrength=max([minstrength stimulusstrength]);
stimulusstrength=min([maxstrength stimulusstrength]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    