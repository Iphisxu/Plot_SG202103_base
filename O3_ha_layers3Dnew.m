% Hour-Average Concentration of O3(unit:ppbV) from Simulation...
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
% Read CMAQ Output
% ==================================

% ncFile=string(DataPath)+'COMBINE_ACONC_'+string(GridName)+'_202103_simple.nc'; % Note here to modify
ncFile=string(DataPath)+'COMBINE_ACONC_'+string(GridName)+'_202103_O33d.nc';

O3 = ncread(ncFile,'O3'); % O3(lon,lat,layer,tstep)
O3_L1=squeeze(O3(:,:,1,:)); % L1=1000hPa
O3_L2=squeeze(O3(:,:,19,:)); % L1=850hPa
O3_L3=squeeze(O3(:,:,23,:)); % L2=700hPa
O3_L4=squeeze(O3(:,:,28,:)); % L3=500hPa
O3_L5=squeeze(O3(:,:,32,:)); % L3=300hPa
nDays = size(O3,4)/24; % get the length of tstep to calculate days number
O3_L1 = reshape(O3_L1,98,74,24,nDays); % O3(lon,lat,hour,day)
O3_L2 = reshape(O3_L2,98,74,24,nDays); % O3(lon,lat,hour,day)
O3_L3 = reshape(O3_L3,98,74,24,nDays); % O3(lon,lat,hour,day)
O3_L4 = reshape(O3_L4,98,74,24,nDays); % O3(lon,lat,hour,day)
O3_L5 = reshape(O3_L5,98,74,24,nDays); % O3(lon,lat,hour,day)

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

for i=1:nDays
    for j=1:24
% i=3;j=10;
        figure
        set(gcf,'position',[100 100 700 600],'visible','off');
        ax=axes('color','none');
        % layer1=1000hPa
        plot3(bou1_4lx,bou1_4ly,0*mapzl,'color','k','linewidth',0.5);
        hold on
        plot3(bou1_4mx,bou1_4my,0*mapzm,'color','k','linewidth',0.5);
        hold on
        plot3(bou1_4nx,bou1_4ny,0*mapzn,'color','k','linewidth',0.5);
        hold on
        s1=surf(ax,lon,lat,z_L1,O3_L1(:,:,j,i).*gd);
        shading flat
        hold on
        % layer2=850hPa
        plot3(bou1_4lx,bou1_4ly,3*mapzl,'color','k','linewidth',0.5);
        hold on
        plot3(bou1_4mx,bou1_4my,3*mapzm,'color','k','linewidth',0.5);
        hold on
        plot3(bou1_4nx,bou1_4ny,3*mapzn,'color','k','linewidth',0.5);
        hold on
        s2=surf(ax,lon,lat,z_L2,O3_L2(:,:,j,i).*gd);
        shading flat
        % layer3=700hPa
        plot3(bou1_4lx,bou1_4ly,6*mapzl,'color','k','linewidth',0.5);
        hold on
        plot3(bou1_4mx,bou1_4my,6*mapzm,'color','k','linewidth',0.5);
        hold on
        plot3(bou1_4nx,bou1_4ny,6*mapzn,'color','k','linewidth',0.5);
        hold on
        s3=surf(ax,lon,lat,z_L3,O3_L3(:,:,j,i).*gd);
        shading flat
        % layer4=500hPa
        plot3(bou1_4lx,bou1_4ly,9*mapzl,'color','k','linewidth',0.5);
        hold on
        plot3(bou1_4mx,bou1_4my,9*mapzm,'color','k','linewidth',0.5);
        hold on
        plot3(bou1_4nx,bou1_4ny,9*mapzn,'color','k','linewidth',0.5);
        hold on
        s4=surf(ax,lon,lat,z_L4,O3_L4(:,:,j,i).*gd);
        shading flat
        % layer5=300hPa
        plot3(bou1_4lx,bou1_4ly,12*mapzl,'color','k','linewidth',0.5);
        hold on
        plot3(bou1_4mx,bou1_4my,12*mapzm,'color','k','linewidth',0.5);
        hold on
        plot3(bou1_4nx,bou1_4ny,12*mapzn,'color','k','linewidth',0.5);
        hold on
        s5=surf(ax,lon,lat,z_L5,O3_L5(:,:,j,i).*gd);
        shading flat

        % set axis and colorbar
        caxis([0,100]);
        xlim([109 118]);
        % ylim([]);
        zlim([0 13]);
        color=colormap(turbo);
        hc=colorbar('ytick',0:20:100,'fontsize',10);
        ylabel(hc,'ppbv','fontsize',10);
        set(gca,'Ytick',[20:1:25]);
        set(gca,'Xtick',[109:1:118]);
        set(gca,'ztick',[0:3:13],'zticklabel',[1000 850 700 500 300]);
        xlabel(gca,'Longitude(°E)','FontSize',10);
        ylabel(gca,'Latitude(°N)','FontSize',10);
        zlabel(gca,'Pressure(hPa)','FontSize',10);
        grid on
        view([-8 19.8]);

        if (j>=1)&&(j<=16) 
            hour=[8:23];
            title(['O_3-','2021-03-',num2str(i+22-1),'-',num2str(hour(j))],'fontsize',12);
            Now_printing_figure_on=['2021-03-',num2str(i+22-1),'-',num2str(hour(j))]
            path = ['D:/files/Master/02学术/Case/Shaog03/figure_layer/3Dnew/O3_','2021-03-',num2str(i+22-1),'-',num2str(hour(j))]; % Note here to modify
            print(gcf,'-dtiff','-r600',path)
        else
            hour=[0:7];
            title(['O_3-','2021-03-',num2str(i+22),'-',num2str(hour(j-16))],'fontsize',12);
            Now_printing_figure_on=['2021-03-',num2str(i+22),'-',num2str(hour(j-16))]
            path = ['D:/files/Master/02学术/Case/Shaog03/figure_layer/3Dnew/O3_','2021-03-',num2str(i+22),'-',num2str(hour(j-16))]; % Note here to modify
            print(gcf,'-dtiff','-r600',path)
        end
    end
end

Program_Ends_at=datetime('now')
