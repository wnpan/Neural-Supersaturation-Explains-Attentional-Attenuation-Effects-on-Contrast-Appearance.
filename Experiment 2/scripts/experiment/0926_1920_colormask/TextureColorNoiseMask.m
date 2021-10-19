function [imageMatrix,mean_luminance,Color_contrast] = TextureColorNoiseMask(image_r,RMS_contrast,angle,angle_sigma,sf_cpp,sf_sigma_cpp,boundary,red,green,Ifisoluminance)
%last edit by PWM 2020/7/4
%   ʹ��logGaborNoise����ԭʼ����noise���󣬲��ڴ˺���������ʵ����ֵ�ģʽ
%   ����Ifisoluminance�������������ɵ�noise�Ƿ�Ϊ������noise
%�����sfΪcpp��λ��sizeΪһ��ͼƬ��ӵ�е����ص�
%��noise��ƽ������Ҫ���Ϊ�ϸ�0.05��0.01

global inc background white

%һ���ض�������*image_pixel=һ��ͼ��������
sf_cpi=sf_cpp*(2*image_r+1);
%��׼��Ĵ������ֵ��ͬ
sf_sigma_cpi = sf_sigma_cpp*(2*image_r+1);
im = rand(2*image_r+1);
IfPlot = false;

[~,~,thisImageNorm] = LogGaborNoise(im,sf_cpi,sf_sigma_cpi,angle,angle_sigma,IfPlot);

% thisImageNorm = thisImageNorm.*2-mean(mean(thisImageNorm.*2));
thisImageNorm = thisImageNorm.*2-1;
mean_luminance = mean(mean(thisImageNorm));
while abs(mean_luminance)>0.01%ƽ�����ȳ���һ��ˮƽ��0.01��ʱ����������noise
    im = rand(2*image_r+1);
    [~,~,thisImageNorm] = LogGaborNoise(im,sf_cpi,sf_sigma_cpi,angle,angle_sigma,IfPlot);
    
    % thisImageNorm = thisImageNorm.*2-mean(mean(thisImageNorm.*2));
    thisImageNorm = thisImageNorm.*2-1;
    mean_luminance = mean(mean(thisImageNorm));
end
%Rͨ����������Gͨ����ͬ
Color_contrast = RMS_contrast/(std2(1+thisImageNorm)...
    /mean(mean(1+thisImageNorm)));

% Color_contrast = 1;

%������ת��ΪRGB��ͨ������

R = thisImageNorm.*red;
G = Ifisoluminance.*thisImageNorm.*green;%�������ֲ�ͬ��noise
B = thisImageNorm.*0;

[x,y] = meshgrid(-image_r:image_r,-image_r:image_r);

cpdboundary = round(degree2pixel(boundary));
maskMatrix1 = cos(2*pi/cpdboundary*(image_r-sqrt(x.^2+y.^2))+pi)/2+1/2;
maskMatrix2 = sign(sign((image_r).^2-x.^2-y.^2)+1);
maskMatrix3 = sign(sign(-(image_r-cpdboundary/2).^2+x.^2+y.^2)+1);
maskMatrix4 = sign(sign((image_r-cpdboundary/2).^2-x.^2-y.^2)+1);
maskMatrix = min(maskMatrix1.*maskMatrix2.*maskMatrix3+maskMatrix4,1);

imageMatrix(:,:,1) = (red + R.*Color_contrast).*maskMatrix+(1-maskMatrix)*background(1);
imageMatrix(:,:,2) = (green + G.*Color_contrast).*maskMatrix+(1-maskMatrix)*background(2);
imageMatrix(:,:,3) = (background(3) + B.*Color_contrast).*maskMatrix+(1-maskMatrix)*background(3);

% imageMatrix(:,:,1) = (background + thisImageNorm*inc.*Color_contrast).*maskMatrix+(1-maskMatrix)*background;
% imageMatrix(:,:,2) = (background + thisImageNorm*inc.*Color_contrast).*maskMatrix+(1-maskMatrix)*background;
% imageMatrix(:,:,3) = (background + thisImageNorm*inc.*Color_contrast).*maskMatrix+(1-maskMatrix)*background;

circle = white.*(x.^2 + y.^2 <= (image_r)^2+1);
imageMatrix(:,:,4) = 0;
imageMatrix(1:2*image_r+1,1:2*image_r+1,4) = circle;

end

