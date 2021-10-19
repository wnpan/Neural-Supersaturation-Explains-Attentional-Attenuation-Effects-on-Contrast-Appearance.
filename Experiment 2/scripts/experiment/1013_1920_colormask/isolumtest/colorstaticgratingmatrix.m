
%%2018/12/25 �˶���դ����դ��ͻȻonset/offset
%%2018/9/25�ú��������˶��Ĺ�դ
%% 
%  driftgratingmatrix2(frame_rate,background,o_size,o_Speriod,o_speed,o_phase,o_contrast,o_orientation,o_blur,o_rampwidth...
%                                  gap,i_size,i_Speriod,i_speed,i_phase,i_contrast,i_orientation,i_blur,i_rampwidth)
%  frame_rate=59;%��Ļˢ����
%  background=128;%background,��դ��������
%  o_size=200; %o_size,���ܹ�դ��С������
%  o_Speriod=20;%o_Speriod,���ܹ�դ�Ŀռ����ڣ�����
%  o_speed=0;%o_tf,���ܹ�դ�ƶ��ٶȣ���λ pixels/�룬��ֵΪ�������˶�����ֵ�෴
%  o_phase=0;%o_phase,���ܹ�դ����λ
%  o_contrast=0.5;%o_contrast,���ܹ�դ�ĶԱȶ�
%  o_orientation=0;%o_orientation,���ܹ�դ�ĳ���
%  o_blur=10;%o_blur,���ܹ�դ��Ե������ģ��������
%  o_duration; %���ܹ�դ������ʱ�䣬��λms
%  

%  gap=10;%��������֮��ļ��
%  
%  i_size=80; %i_size,�����դ��С������
%  i_Speriod=20;%i_Speriod,�����դ�Ŀռ����ڣ�����
%  i_speed=0;%i_tf,���ܹ�դ�ƶ��ٶȣ���λ pixels/��,��ֵΪ�������˶�����ֵ�෴
%  i_phase=0;%i_phase,�����դ����λ
%  i_contrast=0.5;%i_contrast,�����դ�ĶԱȶ�
%  i_orientation=0;%i_orientation,�����դ�ĳ���
%  i_blur=10;%i_blur,�����դ��Ե������ģ��������
%  i_duration; %�����դ������ʱ�䣬��λms

%%2015 10 19
%�ú������������Ĺ�դ����դ�����ܹ�դ�����Ĺ�դ��ɣ�����֮�����һ��gap�������դ�ı�Ե����ģ����
%���ĺ����ܹ�դ�Ĵ�С���ռ�Ƶ�ʡ�����ʱ��Ƶ�ʡ���λ���Աȶȡ����򡢱�Եģ���������Ȳ�������ֱ�ӵ��ڡ�
 
function output=colorstaticgratingmatrix(frame_rate,background,o_size,o_Speriod,o_speed,o_phase,o_contrast,o_orientation,o_blur,o_duration,...
                                  gap,i_size,i_Speriod,i_speed,i_phase,i_contrast,i_orientation,i_blur,i_duration,GRratio)
   
o_frames=(o_duration/(1000/frame_rate));
i_frames=(i_duration/(1000/frame_rate));
                             
frames=round(max([o_frames i_frames])); %�̼����ֵ�֡��
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[x,y]=meshgrid((1-o_size/2):(o_size/2),(1-o_size/2):(o_size/2));%�̼��Ĵ�С
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




if o_blur==0 && i_blur==0
   %��û��ģ����ʱ��������ģ������صļ��㣬���ٳ�������ʱ��
   %%boundary2 ���ܻ�������%%%%%
   r_s=round(o_size/2);%���ܹ�դ�뾶
   r_c=round(i_size/2);%�����դ�뾶
   bound2_1=sign(sign(r_s.^2-x.^2-y.^2)+1);%���ܹ�դ��Բ�α�
   bound2_2=sign(sign(-(r_c+gap).^2+x.^2+y.^2)+1);%�����դ��Բ�α�
   boundary2=bound2_1.*bound2_2;%���ܻ�������
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%

   %%%boundary3 ����Բ������%%%%
    boundary3=1-sign(sign(-(r_c).^2+x.^2+y.^2)+1);%�����դ��Բ�α�
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%

    
else
    
  %�����դ���ҵ�����%%%%%%%%
   r_c=round(i_size/2);%�����դ�뾶
   rampperiod=2*i_blur;%�����դ����ramp������
   bound1_i_1=(sin(2*pi*(1/rampperiod)*(sqrt(x.^2+y.^2)-r_c)-pi/2)+1)/2;%����Բ�̵����ҵݼ���
   bound1_i_2=sign(sign((r_c).^2-x.^2-y.^2)+1);
   bound1_i_3=sign(sign(-(r_c-rampperiod/2).^2+x.^2+y.^2)+1);
   bound1_i_4=sign(sign((r_c-rampperiod/2).^2-x.^2-y.^2)+1);
   bound1_i=bound1_i_1.*bound1_i_2.*bound1_i_3+bound1_i_4;
   bound1_i=min(bound1_i,1);
  %%%%%%%%%%%%%%%%%%%%%%%%%%

  %���ܹ�դ�ڲ����ҵݼ��ߣ�gap
  rampwidth_s=2*o_blur;%���ܹ�դ�ڱ�����ramp������
  bound1_o_1=(sin(2*pi*(1/rampwidth_s)*(sqrt(x.^2+y.^2)-r_c-gap)-pi/2)+1)/2;
  bound1_o_2=sign(sign(-(r_c+gap).^2+x.^2+y.^2)+1);
  bound1_o_3=sign(sign((r_c+rampwidth_s/2+gap).^2-x.^2-y.^2)+1);
  bound1_o_4=sign(sign(-(r_c+rampwidth_s/2+gap).^2+x.^2+y.^2)+1);
  bound1_o=bound1_o_1.*bound1_o_2.*bound1_o_3+bound1_o_4;
  bound1_o=min(bound1_o,1);
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %boundary1=bound1_i+bound1_o;

  %%boundary2 ���ܻ�������%%%%%
  r_s=round(o_size/2);%���ܹ�դ�뾶
  bound2_1=sign(sign(r_s.^2-x.^2-y.^2)+1);%���ܹ�դ��Բ�α�
  bound2_2=sign(sign(-r_c.^2+x.^2+y.^2)+1);%�����դ��Բ�α�
  boundary2=bound2_1.*bound2_2.*bound1_o;%���ܻ��������ڻ�����gap+rampģ��
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%

  %%%boundary3 ����Բ������%%%%
  bound3=sign(sign((r_c).^2-x.^2-y.^2)+1);%�����դ��Բ�α�
  boundary3=bound3.*bound1_i;%����Բ�����������rampģ��
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%time window
TimePoints=1:frames; %frame ��
CenterPoint=round((1+frames)/2); %ʱ�䴰�����ĵ�
i_timewindow=((TimePoints-CenterPoint).^2)<=(i_frames/2)^2;
o_timewindow=((TimePoints-CenterPoint).^2)<=(o_frames/2)^2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%���� �ռ�Ƶ�ʵ�%%%%%%%%%%%%%%%
    angle_s=o_orientation;%���ܹ�դ���򣬵�λ ��
    angle_c=i_orientation;%�����դ����, ��λ ��
    ang_s=angle_s*pi/180;%ת�� �� Ϊ ����
    ang_c=angle_c*pi/180;%ת�� �� Ϊ ����
    fre_s=1/o_Speriod;
    fre_c=1/i_Speriod;
    
    aa_s=2*pi*fre_s*cos(ang_s);
    bb_s=2*pi*fre_s*sin(ang_s);
    aa_c=2*pi*fre_c*cos(ang_c);
    bb_c=2*pi*fre_c*sin(ang_c);
    
    con_s=o_contrast;
    con_c=i_contrast;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
   
for jj=1:frames
   gratingmatrix(:,:,1,jj)=background*(1+o_timewindow(jj)*con_s*cos(aa_s*x+bb_s*y+o_phase-o_speed*jj/frame_rate).*boundary2+ ... %���ܹ�դ
                                        i_timewindow(jj)*con_c*cos(aa_c*x+bb_c*y+i_phase-i_speed*jj/frame_rate).*boundary3);    %�����դ
                                    
   gratingmatrix(:,:,2,jj)=GRratio*background*(1+o_timewindow(jj)*con_s*cos(aa_s*x+bb_s*y+o_phase+pi-o_speed*jj/frame_rate).*boundary2+ ... %���ܹ�դ
                                        i_timewindow(jj)*con_c*cos(aa_c*x+bb_c*y+i_phase+pi-i_speed*jj/frame_rate).*boundary3);    %�����դ 
   
   gratingmatrix(:,:,3,jj)=0;
                                    
end

output=gratingmatrix;

% secs2=GetSecs;
% secs2-secs1



% [window,windowRect]=Screen('OpenWindow', 0, background);
% 
% 
% 
% for ii=1:frames
% gratings=Screen('MakeTexture',window,gratingmatrix(:,:,ii));
% Screen('DrawTexture', window,gratings,[],[100 100 300 300]);%��դ
% tt(ii)=Screen('Flip', window);
% end
% 
% 
% Screen('CloseAll')
% 
% 

