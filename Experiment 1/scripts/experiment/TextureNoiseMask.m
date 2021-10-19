function [imageMatrix,mean_luminance,Michelson_contrast] = TextureNoiseMask(image_r,RMS_contrast,angle,angle_sigma,sf_cpp,sf_sigma_cpp,boundary)
%last edit by PWM 2020/6/13
%   ʹ��logGaborNoise����ԭʼ�ڰ�noise���󣬲��ڴ˺���������ʵ����ֵ�ģʽ
%�����sfΪcpp��λ��sizeΪһ��ͼƬ��ӵ�е����ص�

global inc background white

%һ���ض�������*image_pixel=һ��ͼ��������
sf_cpi=sf_cpp*(2*image_r);
%��׼��Ĵ������ֵ��ͬ
sf_sigma_cpi = sf_sigma_cpp*(2*image_r);
im = rand(2*image_r+1);
IfPlot = false;

[~,~,thisImageNorm] = LogGaborNoise(im,sf_cpi,sf_sigma_cpi,angle,angle_sigma,IfPlot);

% thisImageNorm = thisImageNorm.*2-mean(mean(thisImageNorm.*2));
thisImageNorm = thisImageNorm.*2-1;
mean_luminance = mean(mean(thisImageNorm));
while abs(mean_luminance)>0.05%ƽ�����ȳ���һ��ˮƽ��0.05��ʱ����������noise
    im = rand(2*image_r+1);
    [~,~,thisImageNorm] = LogGaborNoise(im,sf_cpi,sf_sigma_cpi,angle,angle_sigma,IfPlot);
    
    % thisImageNorm = thisImageNorm.*2-mean(mean(thisImageNorm.*2));
    thisImageNorm = thisImageNorm.*2-1;
    mean_luminance = mean(mean(thisImageNorm));
end

Michelson_contrast = RMS_contrast/(std2(background+inc*thisImageNorm)...
    /mean(mean(background+inc*thisImageNorm)));

[x,y] = meshgrid(-image_r:image_r,-image_r:image_r);

cpdboundary = round(degree2pixel(boundary));
maskMatrix1 = cos(2*pi/cpdboundary*(image_r-sqrt(x.^2+y.^2))+pi)/2+1/2;
maskMatrix2 = sign(sign((image_r).^2-x.^2-y.^2)+1);
maskMatrix3 = sign(sign(-(image_r-cpdboundary/2).^2+x.^2+y.^2)+1);
maskMatrix4 = sign(sign((image_r-cpdboundary/2).^2-x.^2-y.^2)+1);
maskMatrix = min(maskMatrix1.*maskMatrix2.*maskMatrix3+maskMatrix4,1);

imageMatrix = background+inc*thisImageNorm.*Michelson_contrast.*maskMatrix;

circle = white.*(x.^2 + y.^2 <= (image_r)^2+1);
imageMatrix(:,:,2) = 0;
imageMatrix(1:2*image_r+1,1:2*image_r+1,2) = circle;

end

