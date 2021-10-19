function [imageMatrix,mean_luminance,Michelson_contrast] = TextureNoiseMask(image_r,RMS_contrast,angle,angle_sigma,sf_cpp,sf_sigma_cpp,boundary)
%last edit by PWM 2020/6/13
%   使用logGaborNoise生成原始黑白noise矩阵，并在此函数调整成实验呈现的模式
%输入的sf为cpp单位，size为一张图片所拥有的像素点

global inc background white

%一像素多少周期*image_pixel=一张图多少周期
sf_cpi=sf_cpp*(2*image_r);
%标准差的处理与峰值相同
sf_sigma_cpi = sf_sigma_cpp*(2*image_r);
im = rand(2*image_r+1);
IfPlot = false;

[~,~,thisImageNorm] = LogGaborNoise(im,sf_cpi,sf_sigma_cpi,angle,angle_sigma,IfPlot);

% thisImageNorm = thisImageNorm.*2-mean(mean(thisImageNorm.*2));
thisImageNorm = thisImageNorm.*2-1;
mean_luminance = mean(mean(thisImageNorm));
while abs(mean_luminance)>0.05%平均亮度超过一定水平（0.05）时，重新生成noise
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

