function [data_all,y,PSE_sf,R2_ALL]= SubjectsAll_EJfittingresult
%mat_all所有 被试的数据整合
%mat_all = {subjectid1,DotsToBeDeletedMat1;...}
%该程序会以第一个被试的第一张图的蓝线的横纵坐标作为横纵坐标画图，请务必保证该线条没有被删点
mat_all = {'0615_yuda',[ ];...
    '0618_zhaoyuwan',[];...
    '0620_tianziyu',[];...
    '0619_wangsheng',[];...
    '0618_yewen',[];...
    '0619_liangyi',[];...
    '0620_xuanhongzhou',[];...
    '0619_maokaiwen',[];...
    '0620_ZHAOZIYI',[];...
    '0623_donghanchen',[];...
%     '0616_huangshuyue',[];...
                };
num = [1 2 3 4];
condition = [-1 0 1];
data_all = {};

%计算四张图十二条曲线的y的均值
for  i = 1:size(mat_all,1)
    [data_all{i},StimStrength]=All_EJfittingresult(mat_all{i,1}, num, condition, mat_all{i,2});
    close;
end
x_standard = data_all{1}{2,3}{1}{1};
trialcount_standard = data_all{1}{2,5}{1}{1};
y ={};
trialcount = {};
accuracy = {};
accuracy_sem = {};
for i = 1:size(num,2)%四种sf
    y_sf = {};
    trialcount_sf = {};
    accuracy_sf = {};
    accuracy_sf_sem = {};
    for j = 1:size(condition,2)%三条曲线
        x_sf_con={};
        y_sf_con={};
        trialcount_sf_con = {};
        accuracy_sf_con = {};
        for s = 1:size(mat_all,1)
            x_sf_con{s}= data_all{s}{2,3}{i}{j};
            y_sf_con{s}= data_all{s}{2,4}{i}{j};
            trialcount_sf_con{s} = data_all{s}{2,5}{i}{j};
            accuracy_sf_con{s} = data_all{s}{2,6}{i}{j};
        end
        y_point = [];%存储每个被试在每个x值上的y值
        trialcount_point = [];
        accuracy_point = [];
        y_sf_con_average = [];
        trialcount_sf_con_average = [];%存储平均值
        accuracy_sf_con_average = [];
        accuracy_sf_con_sem = [];
        for k = 1:size(x_standard,1)%每一个数据点
            for s = 1:size(mat_all,1)
                if ~isempty(y_sf_con{s}(x_sf_con{s}==x_standard(k)))
                    y_point(s) = y_sf_con{s}(x_sf_con{s}==x_standard(k));
                end
            end
            y_sf_con_average(k) = mean(y_point);
        end
        y_sf{j} = y_sf_con_average;
        for k = 1:size(trialcount_standard,1)
            for s = 1:size(mat_all,1)
                    trialcount_point(s) = trialcount_sf_con{s}(k);
                    accuracy_point(s) = accuracy_sf_con{s}(k);
            end
%             trialcount_sf_con_average(k) = mean(trialcount_point,'omitnan');
%             accuracy_sf_con_average(k) = mean(accuracy_point,'omitnan');
%             accuracy_sf_con_sem(k) = std(accuracy_point,'omitnan')/...
%                 sqrt(numel(accuracy_point(~isnan(accuracy_point)))-1);%标准误的计算要求数据至少为两个及以上
            trialcount_sf_con_average(k) = mean(trialcount_point);
            accuracy_sf_con_average(k) = mean(accuracy_point);
            accuracy_sf_con_sem(k) = std(accuracy_point)/...
                sqrt(numel(accuracy_point(~isnan(accuracy_point)))-1);%标准误的计算要求数据至少为两个及以上
        end
        trialcount_sf{j} = trialcount_sf_con_average;
        accuracy_sf{j} = accuracy_sf_con_average;
        accuracy_sf_sem{j} = accuracy_sf_con_sem;
    end
    y{i} = y_sf;
    trialcount{i} = trialcount_sf;
    accuracy{i} = accuracy_sf;
    accuracy_sem{i} = accuracy_sf_sem;
end

%计算PSE的均值
for s = 1:size(mat_all,1)
    if s ==1
        PSE_sum = data_all{s}{2,2};
    else
        PSE_sum = PSE_sum+data_all{s}{2,2};
    end
end
PSE_average = PSE_sum./size(mat_all,1);

%计算PSE的标准误差
if  size(mat_all,1)~=1
    for s = 1:size(mat_all,1)
        if s ==1
            PSE_S2 = (data_all{s}{2,2}-PSE_average).^2;
        else
            PSE_S2 = PSE_S2+(data_all{s}{2,2}-PSE_average).^2;%样本方差
        end
        PSE_sf(s,:,:) = data_all{s}{2,2};
        R2_ALL(s,:,:) = data_all{s}{2,1}
    end
    PSE_S2 = PSE_S2/(size(mat_all,1)-1);
    PSE_SEM = sqrt(PSE_S2/size(mat_all,1));
else
    PSE_SEM = 0;
end

%开始画图
for i = 1:size(num,2)%四种sf
    for j = 1:size(condition,2)%三条曲线
        if j==1
            linecolorr=[1 0 0];
            dotcolorr=[0.8 0.4 0.4];
        elseif j==2
            linecolorr=[0 1 0];
            dotcolorr=[0.4 0.8 0.4];
        elseif j==3
            linecolorr=[0 0 1];
            dotcolorr=[0.5 0.5 0.8];
        end
        subplot(2,2,i);
        plot(x_standard,y{i}{j}','LineWidth',2,'Color',linecolorr)
        hold on;
        scatter(StimStrength,accuracy{i}{j},trialcount{i}{j}*5,'ro','MarkerFaceColor',dotcolorr,'MarkerEdgeColor','none')
        hold on;
        errorbar(StimStrength,accuracy{i}{j},accuracy_sem{i}{j},'ro','LineWidth',1,'Color',dotcolorr);
        hold on;
        axis([-inf inf 0 inf]);
        
        maxEJratio=max(y{i}{j});%y方向的最大值
        PSEindex=find(y{i}{j}==maxEJratio);
        PSE=x_standard(PSEindex);%找到对应的x
        % line([min(RespAccuracy) Threshold],[ThreP ThreP],'color',[0.5 0.5 0.5])

%         PSE = PSE_average(j,i);

        line([PSE PSE],[maxEJratio 0],'color',dotcolorr)
        text(PSE,0.05,num2str(PSE,'%4.3g'))  
    end
end

% %画第五张图
% subplot(2,3,5);
% errorbar(sf+0.01,PSE_average(1,:),PSE_SEM(1,:),'LineWidth',1,'Color',[1 0 0]);
% hold on
% subplot(2,3,5);
% errorbar(sf+0.015,PSE_average(2,:),PSE_SEM(2,:),'LineWidth',1,'Color',[0 1 0]);
% hold on
% subplot(2,3,5);
% errorbar(sf+0.02,PSE_average(3,:),PSE_SEM(3,:),'LineWidth',1,'Color',[0 0 1]);
% hold on

