clc;
clear all; 

%% load data
%--加载自定义色标
load('C:\Example\mycolor.mat');

%---------排放点位信息
plon = 115; plat = 37; pz = 0; s= 100;

%------------ 读入地图信息
infoP=shapeinfo('C:\Example\city.shp');
ChinaP=shaperead('C:\Example\city.shp');
bou2_4px=[ChinaP(:).X];
bou2_4py=[ChinaP(:).Y];
maph = zeros(size(bou2_4px));

%------------读入网格经纬度、高度信息
load('C:\Example\lonlat.mat');
h = [0.05 0.16 0.3 0.47 0.68 0.93 1.22 1.57 1.99 2.5];
lon = repmat(lon,1,1,10);
lat = repmat(lat,1,1,10);
height= repmat(h,300,1,249);%---与经纬度维度统一
height = permute(height,[1 3 2]);
lon = double(lon);
lat = double(lat);

%--------------读入pm2.5数据
load('C:\Example\pm25.mat');
pm25 (pm25 ==0) = nan; %----将所有需剔除数据位置找出并替换为nan，便于呈现透视烟羽效果

%% plot 
    figure;
    set(gcf,'position',[200,100,900,300])
    plot3(bou2_4px,bou2_4py,maph,'color','k','linewidth',0.5); %----地图
    hold on
    scatter(plon,plat,s,'filled','r','p'); %----排放点
    
    xslice = 121:2:181;  %--------切片位置，对应上面经纬度在矩阵中的位置
    yslice = 82:2:142;
    
    for i= 1:31 %-----循环切片图
        h1 =  surf(squeeze(lon(:,xslice(i),:)),squeeze(lat(:,xslice(i),:)), ...
        squeeze(height(:,xslice(i),:)),squeeze(pm25(:,xslice(i),:)),'FaceAlpha','interp','Facecolor','interp');
        alpha(h1,'color'); %-----------根据数值调整透明度
        shading interp;
        h2 =  surf(squeeze(lon(yslice(i),:,:)),squeeze(lat(yslice(i),:,:)), ...
        squeeze(height(yslice(i),:,:)),squeeze(pm25(yslice(i),:,:)),'FaceAlpha','interp','Facecolor','interp');
        alpha(h2,'color'); %-----------根据数值调整透明度
        shading interp;
    end

    ch=colorbar('horiz'); %----设置colorbar
    set(ch,'position',[0.72 0.08 0.2 0.06]);
    caxis([0,15]); 
    colormap(newjet);

    %----设置图片视角及坐标轴
    view(-30,40);
    xstring = {'114','115','116','117'};
    ystring = {'36','37','38','39'};
    zstring = {'0','0.5','1'};
    axis([114 117 36 39 0 1]); %----set the range of axis
    set(gca,'xlim',[114 117],'xtick',[114:1:117],'xcolor','k');
    ylabel('Lat(\circN)','FontSize',14,'Fontname','Times new roman'); %'Rotation',-22
    xlabel('Lon(\circE)','FontSize',14,'Fontname','Times new roman');
    text(113.9,39,1.15,'km','FontSize',14,'Fontname','Times new roman');
    set(gca,'YTicklabel',ystring,'FontName','Times New Roman','FontSize',12);
    set(gca,'XTicklabel',xstring,'FontName','Times New Roman','FontSize',12);
    set(gca,'ZTicklabel',zstring,'FontName','Times New Roman','FontSize',12);
    grid on;
    hold off;
  
