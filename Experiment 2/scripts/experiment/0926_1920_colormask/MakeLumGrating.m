function gratingmatrix = MakeLumGrating(size,angle,contrast,R,G,B,sf,phase,boundary)
% last edit by PWM 12-16
% 用于生成等色彩亮度光栅

[x,y] = meshgrid(-size:size,-size:size);                                    % 形成一个正方形的栅格

a1=cos(angle*pi/180)*2*pi*sf;                               % 改变栅格的朝向 
b1=sin(angle*pi/180)*2*pi*sf;
% phase = rand(1)*2*pi;
gratingMatrix = sin(a1*x+b1*y+phase);                                       % 将栅格分布正弦化,相位随机

cpdboundary = round(degree2pixel(boundary));  % 余弦模糊的周期是1度 33pixels
maskMatrix1 = cos(2*pi/cpdboundary*(size-sqrt(x.^2+y.^2))+pi)/2+1/2;
maskMatrix2 = sign(sign((size).^2-x.^2-y.^2)+1);
maskMatrix3 = sign(sign(-(size-cpdboundary/2).^2+x.^2+y.^2)+1);
maskMatrix4 = sign(sign((size-cpdboundary/2).^2-x.^2-y.^2)+1);
maskMatrix = min(maskMatrix1.*maskMatrix2.*maskMatrix3+maskMatrix4,1);
% maskMatrix = maskMatrix1.*maskMatrix2.*maskMatrix3+maskMatrix4;

gratingmatrix(:,:,1)=R*(1+sin(a1*x+b1*y+phase)*contrast.*maskMatrix.*(x.^2 + y.^2 <= (size)^2+1));       %R
                                    
gratingmatrix(:,:,2)=G*(1+sin(a1*x+b1*y+phase)*contrast.*maskMatrix.*(x.^2 + y.^2 <= (size)^2+1));    %G 

gratingmatrix(:,:,3)=B*(1+sin(a1*x+b1*y+phase)*contrast.*maskMatrix.*(x.^2 + y.^2 <= (size)^2+1));                                         %B

end
