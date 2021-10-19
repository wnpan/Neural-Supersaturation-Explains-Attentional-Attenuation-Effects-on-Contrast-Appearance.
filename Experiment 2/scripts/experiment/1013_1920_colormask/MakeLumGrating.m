function gratingmatrix = MakeLumGrating(size,angle,contrast,R,G,B,sf,phase,boundary)
% last edit by PWM 12-16
% �������ɵ�ɫ�����ȹ�դ

[x,y] = meshgrid(-size:size,-size:size);                                    % �γ�һ�������ε�դ��

a1=cos(angle*pi/180)*2*pi*sf;                               % �ı�դ��ĳ��� 
b1=sin(angle*pi/180)*2*pi*sf;
% phase = rand(1)*2*pi;
gratingMatrix = sin(a1*x+b1*y+phase);                                       % ��դ��ֲ����һ�,��λ���

cpdboundary = round(degree2pixel(boundary));  % ����ģ����������1�� 33pixels
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
