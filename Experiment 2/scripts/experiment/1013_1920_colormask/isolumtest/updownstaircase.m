%%Yongchun Cai ZJU
%%2019-7-23修改了1u2d和1u3d 中的向上的step不会减半的问题
%%2015-11-06
%%staircase procedure测阈值
%%staircasetype,阶梯的类型，字符串输入，1u1d、1u2d、1u3d
%%strengthmatrix,刺激强度矩阵
%%responsematrix，反应矩阵
%%minstrength，最小刺激
%%maxstrength，最长刺激 根据最小刺激和最大刺激强度 确定步长大小，最小步长是大小刺激差别的1/9(单位log，即程序自动以log方式调节刺激强度)
%%initialstrength，刺激强度初始值

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

currentpoint=length(find(strengthmatrix~=0));%当前的trial序号（即最后一个强度不为0的trial）
if currentpoint==0
   stimulusstrength=initialstrength; %stair的第一个trial
else
   switch staircasetype
      
      %%%%%%%%%%%%%%%1上1下阶梯法%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
      case '1u1d'
          if responsematrix(currentpoint)==0
             stepsign=1; %按键错误，刺激强度上升
          elseif responsematrix(currentpoint)==1
             stepsign=-1; %按键正确，刺激强度下降
          end
           
          if currentpoint==1
             stimulusstrength=10^(log10(strengthmatrix(currentpoint))+stepsign*maxstep);
          else
             currentstep=abs(log10(strengthmatrix(currentpoint))-log10(strengthmatrix(currentpoint-1)));%当前的step
             if responsematrix(currentpoint-1)==responsematrix(currentpoint)
                stimulusstrength=10^(log10(strengthmatrix(currentpoint))+stepsign*currentstep);
               elseif responsematrix(currentpoint-1)~=responsematrix(currentpoint)
                stimulusstrength=10^(log10(strengthmatrix(currentpoint))+stepsign*max([currentstep/2 minstep]));
             end
          end
          
      %%%%%%%%%%%%%%%1上2下阶梯法%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      case '1u2d'
         if currentpoint==1
             if responsematrix(currentpoint)==0
                stepsign=1; %按键错误，刺激强度上升
             else
                stepsign=0; %按键正确，刺激强度不变
             end
             stimulusstrength=10^(log10(strengthmatrix(currentpoint))+stepsign*maxstep);
          else
             %确定step的方向 
             if responsematrix(currentpoint)==0
                  stepsign=1;
               elseif responsematrix(currentpoint-1)==1&&responsematrix(currentpoint)==1&&abs(log10(strengthmatrix(currentpoint-1))-log10(strengthmatrix(currentpoint)))<0.1*minstep %两次强度接近或相等时
                   stepsign=-1;
               else
                  stepsign=0;
             end
             
             %找最近的step大小
             laststep=0;
             kk=1;
             while abs(laststep)<0.1*minstep && (currentpoint-kk)>0 
               laststep=log10(strengthmatrix(currentpoint))-log10(strengthmatrix(currentpoint-kk));
               kk=kk+1;
             end
             
             %计算stimulusstrength
             if laststep==0 %stair刚开始，还没有step
                 currentstep=maxstep;
                 stimulusstrength=10^(log10(strengthmatrix(currentpoint))+stepsign*currentstep);
             else
                 currentstep=abs(laststep);
                 if sign(laststep)==sign(stepsign) %与之前的step趋势一致，step不变
                    stimulusstrength=10^(log10(strengthmatrix(currentpoint))+stepsign*currentstep);
                  elseif  sign(laststep)~=sign(stepsign) %与之前的step趋势相反，step减半，直到minstep
                    stimulusstrength=10^(log10(strengthmatrix(currentpoint))+stepsign*max([currentstep/2 minstep]));
                 end       
             end
         end 
       
       %%%%%%%%%%%%%%%1上3下阶梯法%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       case '1u3d' 
           last1point=currentpoint-1;
           last2point=currentpoint-2;
           if last1point<1||last2point<1
               if responsematrix(currentpoint)==0
                 stepsign=1; %按键错误，刺激强度上升
                else
                 stepsign=0; %按键正确，刺激强度不变
               end
               stimulusstrength=10^(log10(strengthmatrix(currentpoint))+stepsign*maxstep);
           else
               %确定step方向
               if responsematrix(currentpoint)==0
                   stepsign=1;
                elseif responsematrix(last1point)==1&&responsematrix(last2point)==1&&responsematrix(currentpoint)==1 && abs(log10(strengthmatrix(last2point))-log10(strengthmatrix(currentpoint)))<0.1*minstep %两次强度接近或相等时
                   stepsign=-1;
                else
                   stepsign=0;
               end
         
               %找最近的step大小
               laststep=0;
               kk=1;
               while abs(laststep)<0.1*minstep && (currentpoint-kk)>0
                 laststep=log10(strengthmatrix(currentpoint))-log10(strengthmatrix(currentpoint-kk));
                 kk=kk+1;
               end
               
               %计算stimulusstrength
               if laststep==0 %stair刚开始，还没有step
                  currentstep=maxstep;
                  stimulusstrength=10^(log10(strengthmatrix(currentpoint))+stepsign*currentstep);
                else
                  currentstep=abs(laststep);
                  if sign(laststep)==sign(stepsign) %与之前的step趋势一致，step不变
                     stimulusstrength=10^(log10(strengthmatrix(currentpoint))+stepsign*currentstep);
                   elseif  sign(laststep)~=sign(stepsign) %与之前的step趋势相反，step减半，直到minstep
                     stimulusstrength=10^(log10(strengthmatrix(currentpoint))+stepsign*max([currentstep/2 minstep]));
                  end       
               end
               
           end
       %%%%%%%%%%%%%%%%%%%%%%%
   end
          
end


%%%限制刺激范围在minstrength到maxstrength之内
stimulusstrength=max([minstrength stimulusstrength]);
stimulusstrength=min([maxstrength stimulusstrength]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    