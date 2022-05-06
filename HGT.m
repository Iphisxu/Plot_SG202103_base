% Terrain Height
% Date: 2022-04-25
% Edited by Evan
% ==================================
clc
clear
close all

Program_Starts_at=datetime('now')

% ==================================
% Read Shapefile
% ==================================

% Read China province line
GD=shaperead('D:/files/Master/02学术/Boundary/地形边界/Gdbound/gdboudiv_arc.shp');
HK=shaperead('D:/files/Master/02学术/Boundary/行政边界/HK/HK.shp');
MC=shaperead('D:/files/Master/02学术/Boundary/行政边界/MC/MC.shp');
bou1_4lx=[GD(:).X];
bou1_4ly=[GD(:).Y];
bou1_4mx=[HK(:).X];
bou1_4my=[HK(:).Y];
bou1_4nx=[MC(:).X];
bou1_4ny=[MC(:).Y];

% ==================================
% Read WRF Output
% ==================================

DataPath='F:/Data/';
wrfFile=string(DataPath)+'wrf/wrfout_d02.nc'; % timestep=145,032200-032800
HGT = ncread(wrfFile,'HGT'); % HGT(lon_grid=222,lat_grid=162,time=145)
HGT = squeeze(HGT(:,:,10));
HGT(HGT==nan)=0;
lat = ncread(wrfFile,'XLAT');
lon = ncread(wrfFile,'XLONG');

% ==================================
% Set Boundary
% ==================================

% SIM
ffbsg={'F:/Data/City_Boundary/Guangd'};
fileFolder=fullfile(ffbsg{1});
dirOutput=dir(fullfile(fileFolder,'*.txt'));
tfile={dirOutput.name};
for i=1:21
     [xx,yy]=textread(fullfile(fileFolder,tfile{i}),'%f%f','delimiter', [',',';']);
     sjxy10=inpolygon(lon,lat,xx,yy);
     sjnan10=sjxy10*1;
     prdmat{i}=sjnan10;
end
gd=zeros(222,162);
for i=1:21
    gd=gd+prdmat{i};
end
for i=1:222
    for j=1:162
        if gd(i,j)==0
            gd(i,j)=NaN;
        end
    end
end
gd(42,37)=1;
%%
% ==================================
% Plot
% ==================================

figure
set(gcf,'position',[100,100,550,360],'visible','on');
m_proj('Mercator','lon',[109 118],'lat',[20 25.6],'rec','on');
% [~,h]=m_contourf(lon,lat,O3_max(:,:,i).*gd*48/22.4,0:25:250);
[~,h]=m_contourf(lon,lat,HGT(:,:).*gd,0:100:1200);
set(h,'edgecolor','none');
hold on

caxis([-50,1200]);
% color=colormap(jet);
% colormap(color(:,:));
hc=colorbar('ytick',-100:100:1200,'fontsize',15);
ylabel(hc,'m','fontsize',15);
% plot China province line
m_plot(bou1_4lx,bou1_4ly,'k','linewidth',0.8);
m_plot(bou1_4mx,bou1_4my,'k','linewidth',0.8);
m_plot(bou1_4nx,bou1_4ny,'k','linewidth',0.8);

m_grid('box','fancy','tickdir','in','xtick',(110:1:118),'ytick',(20:1:26),'fontsize',15,'linestyle','none');
title('Terrain Height','fontsize',17);

% path = ['D:/files/Master/02学术/Case/Shaog03/figure_MO/O3/O3_',datestr(datenum(2021,3,22)+(i-1),'yyyy-mm-dd')]; % Note here to modify
% print(gcf,'-dtiff','-r600',path)


Program_Ends_at=datetime('now')
