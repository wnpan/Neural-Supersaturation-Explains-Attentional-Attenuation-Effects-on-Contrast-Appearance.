function [imageMatrix,mean_luminance,Color_contrast] = TextureColorNoiseMask(image_r,RMS_contrast,angle,angle_sigma,sf_cpp,sf_sigma_cpp,boundary,red,green,Ifisoluminance)
%last edit by PWM 2020/7/4
%   使用logGaborNoise生成原始红绿noise矩阵，并在此函数调整成实验呈现的模式
%   根据Ifisoluminance参数，调节生成的noise是否为等亮度noise
%输入的sf为cpp单位，size为一张图片所拥有的像素点
%对noise的平均亮度要求更为严格0.05→0.01

global inc background white

%一像素多少周期*image_pixel=一张图多少周期
sf_cpi=sf_cpp*(2*image_r+1);
%标准差的处理与峰值相同
sf_sigma_cpi = sf_sigma_cpp*(2*image_r+1);
im = rand(2*image_r+1);
IfPlot = false;

[~,~,thisImageNorm] = LogGaborNoise(im,sf_cpi,sf_sigma_cpi,angle,angle_sigma,IfPlot);

% thisImageNorm = thisImageNorm.*2-mean(mean(thisImageNorm.*2));
thisImageNorm = thisImageNorm.*2-1;
mean_luminance = mean(mean(thisImageNorm));
while abs(mean_luminance)>0.01%平均亮度超过一定水平（0.01）时，重新生成noise
    im = rand(2*image_r+1);
    [~,~,thisImageNorm] = LogGaborNoise(im,sf_cpi,sf_sigma_cpi,angle,angle_sigma,IfPlot);
    
    % thisImageNorm = thisImageNorm.*2-mean(mean(thisImageNorm.*2));
    thisImageNorm = thisImageNorm.*2-1;
    mean_luminance = mean(mean(thisImageNorm));
end
%R通道的亮度与G通道相同
Color_contrast = RMS_contrast/(std2(1+thisImageNorm)...
    /mean(mean(1+thisImageNorm)));

% Color_contrast = 1;

%将矩阵转换为RGB三通道矩阵

R = thisImageNorm.*red;
G = Ifisoluminance.*thisImageNorm.*green;%呈现两种不同的noise
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

