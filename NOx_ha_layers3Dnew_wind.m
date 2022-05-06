% Hour-Average Concentration of NOx(unit:ppbV) from Simulation...
% on Several Layers
% in a 3D View
% Date: 2022-04-24
% Edited by Evan
% ==================================
clc
clear
close all

Program_Starts_at=datetime('now')

%% Read Data
% ==================================
% Read Gridfile
% ==================================
DataPath='F:/Data/caseSG/';
Grid='CN9';
GridName='CN9GD_98X74'; % Note here to modify
GridFile = string(DataPath)+'GRIDCRO2D_2021076.nc'; % Note here to modify
close

lat = ncread(GridFile,'LAT');
lon = ncread(GridFile,'LON');  

% ==================================
% Read Shapefile
% ==================================

% Read province line
GD=shaperead('D:/files/Master/02学术/Boundary/地形边界/Gdbound/gdboudiv_arc.shp');
HK=shaperead('D:/files/Master/02学术/Boundary/行政边界/HK/HK.shp');
MC=shaperead('D:/files/Master/02学术/Boundary/行政边界/MC/MC.shp');
bou1_4lx=[GD(:).X];
bou1_4ly=[GD(:).Y];
bou1_4mx=[HK(:).X];
bou1_4my=[HK(:).Y];
bou1_4nx=[MC(:).X];
bou1_4ny=[MC(:).Y];
mapzl=ones(size(bou1_4lx));
mapzm=ones(size(bou1_4mx));
mapzn=ones(size(bou1_4nx));

% ==================================
% Read WRF & CMAQ Output
% ==================================

wrfFile=string(DataPath)+'wrf/wrfout_d02.nc'; % timestep=145,032200-032800
uwind = ncread(wrfFile,'U'); % uwind(lon_grid=223,lat_grid=162,layer=38,time=145)
vwind = ncread(wrfFile,'V'); % vwind(lon_grid=222,lat_grid=163,layer=38,time=145)
uwind_L1=squeeze(uwind(1:222,:,1,1:144)); % L1=1000hPa; uwind_L1(222,162,144)
uwind_L2=squeeze(uwind(1:222,:,19,1:144)); % L2=850hPa
uwind_L3=squeeze(uwind(1:222,:,23,1:144)); % L3=700hPa
uwind_L4=squeeze(uwind(1:222,:,28,1:144)); % L4=500hPa
uwind_L5=squeeze(uwind(1:222,:,32,1:144)); % L5=300hPa
vwind_L1=squeeze(vwind(:,1:162,1,1:144)); % L1=1000hPa; vwind_L1(222,162,144)
vwind_L2=squeeze(vwind(:,1:162,19,1:144)); % L2=850hPa
vwind_L3=squeeze(vwind(:,1:162,23,1:144)); % L3=700hPa
vwind_L4=squeeze(vwind(:,1:162,28,1:144)); % L4=500hPa
vwind_L5=squeeze(vwind(:,1:162,32,1:144)); % L5=300hPa
uwind_L1=reshape(uwind_L1,222,162,24,6);
uwind_L2=reshape(uwind_L2,222,162,24,6);
uwind_L3=reshape(uwind_L3,222,162,24,6);
uwind_L4=reshape(uwind_L4,222,162,24,6);
uwind_L5=reshape(uwind_L5,222,162,24,6);
vwind_L1=reshape(vwind_L1,222,162,24,6);
vwind_L2=reshape(vwind_L2,222,162,24,6);
vwind_L3=reshape(vwind_L3,222,162,24,6);
vwind_L4=reshape(vwind_L4,222,162,24,6);
vwind_L5=reshape(vwind_L5,222,162,24,6);

lon_u = ncread(wrfFile,'XLONG');
lat_u = ncread(wrfFile,'XLAT');

%%
% ncFile=string(DataPath)+'COMBINE_ACONC_'+string(GridName)+'_202103_simple.nc'; % Note here to modify
cmaqFile=string(DataPath)+'COMBINE_ACONC_'+string(GridName)+'_202103_vertical.nc';

NOx = ncread(cmaqFile,'NOX'); % NOx(lon,lat,layer,tstep)
NOx_L1 = squeeze(NOx(:,:,1,:)); % L1=1000hPa
NOx_L2 = squeeze(NOx(:,:,19,:)); % L2=850hPa
NOx_L3 = squeeze(NOx(:,:,23,:)); % L3=700hPa
NOx_L4 = squeeze(NOx(:,:,28,:)); % L4=500hPa
NOx_L5 = squeeze(NOx(:,:,32,:)); % L5=300hPa
nDays = size(NOx,4)/24; % get the length of tstep to calculate days number
NOx_L1 = reshape(NOx_L1,98,74,24,nDays); % NOx(lon,lat,hour,day)
NOx_L2 = reshape(NOx_L2,98,74,24,nDays); % NOx(lon,lat,hour,day)
NOx_L3 = reshape(NOx_L3,98,74,24,nDays); % NOx(lon,lat,hour,day)
NOx_L4 = reshape(NOx_L4,98,74,24,nDays); % NOx(lon,lat,hour,day)
NOx_L5 = reshape(NOx_L5,98,74,24,nDays); % NOx(lon,lat,hour,day)

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
gd=zeros(98,74);
for i=1:21
    gd=gd+prdmat{i};
end
for i=1:98
    for j=1:74
        if gd(i,j)==0
            gd(i,j)=NaN;
        end
    end
end
gd(42,37)=1;


%% Plot figure
% ==================================
% Plot
% ==================================
z_L1=0*ones(98,74);
z_L2=3*ones(98,74);
z_L3=6*ones(98,74);
z_L4=9*ones(98,74);
z_L5=12*ones(98,74);
z0=0*ones(222,162);
z_wind_L1=0*ones(222,162);
z_wind_L2=3*ones(222,162);
z_wind_L3=6*ones(222,162);
z_wind_L4=9*ones(222,162);
z_wind_L5=12*ones(222,162);
scale=1;

for i=1:nDays
    for j=1:24
% i=6;j=10;
        figure
        set(gcf,'position',[0 0 700 500],'visible','off');
        ax=axes('color','none');
        % layer1=1000hPa
        plot3(bou1_4lx,bou1_4ly,0*mapzl,'color','k','linewidth',0.5);
        hold on
        plot3(bou1_4mx,bou1_4my,0*mapzm,'color','k','linewidth',0.5);
        hold on
        plot3(bou1_4nx,bou1_4ny,0*mapzn,'color','k','linewidth',0.5);
        hold on
        s1=surf(ax,lon,lat,z_L1,NOx_L1(:,:,j,i).*gd);
        shading flat
        hold on
        w1=quiver3(lon_u(1:5:222,1:5:162),lat_u(1:5:222,1:5:162),z_wind_L1(1:5:222,1:5:162),...
        uwind_L1(1:5:222,1:5:162,j,i),vwind_L1(1:5:222,1:5:162,j,i),z0(1:5:222,1:5:162),scale);
        hold on
        % layer2=850hPa
        plot3(bou1_4lx,bou1_4ly,3*mapzl,'color','k','linewidth',0.5);
        hold on
        plot3(bou1_4mx,bou1_4my,3*mapzm,'color','k','linewidth',0.5);
        hold on
        plot3(bou1_4nx,bou1_4ny,3*mapzn,'color','k','linewidth',0.5);
        hold on
        s2=surf(ax,lon,lat,z_L2,NOx_L2(:,:,j,i).*gd);
        shading flat
        hold on
        quiver3(lon_u(1:5:222,1:5:162),lat_u(1:5:222,1:5:162),z_wind_L2(1:5:222,1:5:162),...
        uwind_L2(1:5:222,1:5:162,j,i),vwind_L2(1:5:222,1:5:162,j,i),z0(1:5:222,1:5:162),scale);
        hold on

        % set axis and colorbar
        caxis([0,30]);
        xlim([109 118]);
        ylim([20 26]);
        zlim([0 4]);
        color=colormap(turbo);
        hc=colorbar('ytick',0:6:30,'fontsize',10);
        ylabel(hc,'ppbv','fontsize',10);
        set(gca,'Ytick',[20:1:25]);
        set(gca,'Xtick',[109:1:118]);
        set(gca,'ztick',[0:3:5],'zticklabel',[1000 850]);
        xlabel(gca,'Longitude(°E)','FontSize',10);
        ylabel(gca,'Latitude(°N)','FontSize',10);
        zlabel(gca,'Pressure(hPa)','FontSize',10);
        grid off
        % view([-8 19.8]);
        view([-8.4 24]);

        if (j>=1)&&(j<=16) 
            hour=[8:23];
            title(['NOx-','2021-03-',num2str(i+22-1),'-',num2str(hour(j))],'fontsize',12);
            Now_printing_figure_on=['2021-03-',num2str(i+22-1),'-',num2str(hour(j))]
            path = ['F:/Figure/CaseSG3/fig_add/NOx_layer_wind/NOx_','2021-03-',num2str(i+22-1),'-',num2str(hour(j))]; % Note here to modify
            print(gcf,'-dtiff','-r600',path)
        else
            hour=[0:7];
            title(['NOx-','2021-03-',num2str(i+22),'-',num2str(hour(j-16))],'fontsize',12);
            Now_printing_figure_on=['2021-03-',num2str(i+22),'-',num2str(hour(j-16))]
            path = ['F:/Figure/CaseSG3/fig_add/NOx_layer_wind/NOx_','2021-03-',num2str(i+22),'-',num2str(hour(j-16))]; % Note here to modify
            print(gcf,'-dtiff','-r600',path)
        end
    end
end

Program_Ends_at=datetime('now')
