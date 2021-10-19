
%%2018/12/25 运动光栅，光栅是突然onset/offset
%%2018/9/25该函数生成运动的光栅
%% 
%  driftgratingmatrix2(frame_rate,background,o_size,o_Speriod,o_speed,o_phase,o_contrast,o_orientation,o_blur,o_rampwidth...
%                                  gap,i_size,i_Speriod,i_speed,i_phase,i_contrast,i_orientation,i_blur,i_rampwidth)
%  frame_rate=59;%屏幕刷新率
%  background=128;%background,光栅背景亮度
%  o_size=200; %o_size,外周光栅大小，像素
%  o_Speriod=20;%o_Speriod,外周光栅的空间周期，像素
%  o_speed=0;%o_tf,外周光栅移动速度，单位 pixels/秒，正值为从左到右运动，负值相反
%  o_phase=0;%o_phase,外周光栅的相位
%  o_contrast=0.5;%o_contrast,外周光栅的对比度
%  o_orientation=0;%o_orientation,外周光栅的朝向
%  o_blur=10;%o_blur,外周光栅边缘的正弦模糊像素数
%  o_duration; %外周光栅持续的时间，单位ms
%  

%  gap=10;%中央外周之间的间隔
%  
%  i_size=80; %i_size,中央光栅大小，像素
%  i_Speriod=20;%i_Speriod,中央光栅的空间周期，像素
%  i_speed=0;%i_tf,外周光栅移动速度，单位 pixels/秒,正值为从左到右运动，负值相反
%  i_phase=0;%i_phase,中央光栅的相位
%  i_contrast=0.5;%i_contrast,中央光栅的对比度
%  i_orientation=0;%i_orientation,中央光栅的朝向
%  i_blur=10;%i_blur,中央光栅边缘的正弦模糊像素数
%  i_duration; %中央光栅持续的时间，单位ms

%%2015 10 19
%该函数生成闪动的光栅，光栅由外周光栅和中心光栅组成，二者之间相隔一个gap，内外光栅的边缘都被模糊化
%中心和外周光栅的大小、空间频率、闪动时间频率、相位、对比度、朝向、边缘模糊像素数等参数都可直接调节。
 
function output=colorstaticgratingmatrix(frame_rate,background,o_size,o_Speriod,o_speed,o_phase,o_contrast,o_orientation,o_blur,o_duration,...
                                  gap,i_size,i_Speriod,i_speed,i_phase,i_contrast,i_orientation,i_blur,i_duration,GRratio)
   
o_frames=(o_duration/(1000/frame_rate));
i_frames=(i_duration/(1000/frame_rate));
                             
frames=round(max([o_frames i_frames])); %刺激呈现的帧数
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[x,y]=meshgrid((1-o_size/2):(o_size/2),(1-o_size/2):(o_size/2));%刺激的大小
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




if o_blur==0 && i_blur==0
   %当没有模糊边时，不进行模糊边相关的计算，减少程序运算时间
   %%boundary2 外周环形区域%%%%%
   r_s=round(o_size/2);%外周光栅半径
   r_c=round(i_size/2);%中央光栅半径
   bound2_1=sign(sign(r_s.^2-x.^2-y.^2)+1);%外周光栅的圆形边
   bound2_2=sign(sign(-(r_c+gap).^2+x.^2+y.^2)+1);%中央光栅的圆形边
   boundary2=bound2_1.*bound2_2;%外周环形区域
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%

   %%%boundary3 中央圆形区域%%%%
    boundary3=1-sign(sign(-(r_c).^2+x.^2+y.^2)+1);%中央光栅的圆形边
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%

    
else
    
  %中央光栅正弦递增边%%%%%%%%
   r_c=round(i_size/2);%中央光栅半径
   rampperiod=2*i_blur;%中央光栅正弦ramp的周期
   bound1_i_1=(sin(2*pi*(1/rampperiod)*(sqrt(x.^2+y.^2)-r_c)-pi/2)+1)/2;%中央圆盘的余弦递减边
   bound1_i_2=sign(sign((r_c).^2-x.^2-y.^2)+1);
   bound1_i_3=sign(sign(-(r_c-rampperiod/2).^2+x.^2+y.^2)+1);
   bound1_i_4=sign(sign((r_c-rampperiod/2).^2-x.^2-y.^2)+1);
   bound1_i=bound1_i_1.*bound1_i_2.*bound1_i_3+bound1_i_4;
   bound1_i=min(bound1_i,1);
  %%%%%%%%%%%%%%%%%%%%%%%%%%

  %外周光栅内侧余弦递减边＋gap
  rampwidth_s=2*o_blur;%外周光栅内边正弦ramp的周期
  bound1_o_1=(sin(2*pi*(1/rampwidth_s)*(sqrt(x.^2+y.^2)-r_c-gap)-pi/2)+1)/2;
  bound1_o_2=sign(sign(-(r_c+gap).^2+x.^2+y.^2)+1);
  bound1_o_3=sign(sign((r_c+rampwidth_s/2+gap).^2-x.^2-y.^2)+1);
  bound1_o_4=sign(sign(-(r_c+rampwidth_s/2+gap).^2+x.^2+y.^2)+1);
  bound1_o=bound1_o_1.*bound1_o_2.*bound1_o_3+bound1_o_4;
  bound1_o=min(bound1_o,1);
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %boundary1=bound1_i+bound1_o;

  %%boundary2 外周环形区域%%%%%
  r_s=round(o_size/2);%外周光栅半径
  bound2_1=sign(sign(r_s.^2-x.^2-y.^2)+1);%外周光栅的圆形边
  bound2_2=sign(sign(-r_c.^2+x.^2+y.^2)+1);%中央光栅的圆形边
  boundary2=bound2_1.*bound2_2.*bound1_o;%外周环形区域，内环边有gap+ramp模糊
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%

  %%%boundary3 中央圆形区域%%%%
  bound3=sign(sign((r_c).^2-x.^2-y.^2)+1);%中央光栅的圆形边
  boundary3=bound3.*bound1_i;%中央圆形区域，外边有ramp模糊
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%time window
TimePoints=1:frames; %frame 点
CenterPoint=round((1+frames)/2); %时间窗的中心点
i_timewindow=((TimePoints-CenterPoint).^2)<=(i_frames/2)^2;
o_timewindow=((TimePoints-CenterPoint).^2)<=(o_frames/2)^2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%朝向 空间频率等%%%%%%%%%%%%%%%
    angle_s=o_orientation;%外周光栅朝向，单位 度
    angle_c=i_orientation;%中央光栅朝向, 单位 度
    ang_s=angle_s*pi/180;%转换 度 为 弧度
    ang_c=angle_c*pi/180;%转换 度 为 弧度
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
   gratingmatrix(:,:,1,jj)=background*(1+o_timewindow(jj)*con_s*cos(aa_s*x+bb_s*y+o_phase-o_speed*jj/frame_rate).*boundary2+ ... %外周光栅
                                        i_timewindow(jj)*con_c*cos(aa_c*x+bb_c*y+i_phase-i_speed*jj/frame_rate).*boundary3);    %中央光栅
                                    
   gratingmatrix(:,:,2,jj)=GRratio*background*(1+o_timewindow(jj)*con_s*cos(aa_s*x+bb_s*y+o_phase+pi-o_speed*jj/frame_rate).*boundary2+ ... %外周光栅
                                        i_timewindow(jj)*con_c*cos(aa_c*x+bb_c*y+i_phase+pi-i_speed*jj/frame_rate).*boundary3);    %中央光栅 
   
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
% Screen('DrawTexture', window,gratings,[],[100 100 300 300]);%光栅
% tt(ii)=Screen('Flip', window);
% end
% 
% 
% Screen('CloseAll')
% 
% 

