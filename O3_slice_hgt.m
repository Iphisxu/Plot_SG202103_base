% Hour-Average Concentration of O3(unit:ppbV) from Simulation...
% on Several Layers
% in a 3D View
% Date: 2022-04-26
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
LW = ncread(GridFile,'LWMASK');
for i=1:26
    lon_use(:,:,i)=lon(:,:);
    lat_use(:,:,i)=lat(:,:);
end

HT = squeeze(ncread(GridFile,'HT')); % terrain elevation(98,74)

% ==================================
% Read CMAQ Output
% ==================================

cmaqFile1=string(DataPath)+'COMBINE_ACONC_'+string(GridName)+'_202103_vertical.nc';
cmaqFile2=string(DataPath)+'COMBINE_ACONC_'+string(GridName)+'_202103_uv_vertical.nc';

O3 = ncread(cmaqFile1,'O3'); % O3(lon,lat,layer,tstep)
nDays = size(O3,4)/24; % get the length of tstep to calculate days number
O3 = reshape(O3(:,:,1:26,:),98,74,26,24,nDays); % O3(lon,lat,layer,hour,day)
O3(O3<=60)=nan;
ZH = ncread(cmaqFile1,'ZH'); % (98,74,38,144) mid-layer height above ground
ZH = reshape(ZH(:,:,1:26,1:144),98,74,26,24,nDays);

for i=1:26
    for j=1:24
            for k=1:6
                height(:,:,i,j,k)=(ZH(:,:,i,j,k)+HT)/1000; % unit:km
            end
    end
end

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



%% Plot figure
% ==================================
% Plot
% ==================================

xslice=1:2:98;
yslice=1:2:74;

i=4;j=8;
for i=1:nDays
    for j=1:24
        figure
        set(gcf,'position',[100 100 800 600],'visible','off');
        ax=axes('color','none');
        % boundary
        plot3(bou1_4lx,bou1_4ly,0*mapzl-1,'color','k','linewidth',0.5);
        hold on
        plot3(bou1_4mx,bou1_4my,0*mapzm-1,'color','k','linewidth',0.5);
        hold on
        plot3(bou1_4nx,bou1_4ny,0*mapzn-1,'color','k','linewidth',0.5);
        hold on
        % we use HT here to serve as 'terrain height'
        ht=HT.*LW/1000;
        ht(ht==0)=nan;
        terrain=surf(lon,lat,ht);
        set(terrain,'Facecolor',[1 1 1]);
        hold on

        for k=1:49 % chose by random
            h1=surf(squeeze(lon_use(xslice(k),:,:)),squeeze(lat_use(xslice(k),:,:)),...
            squeeze(height(xslice(k),:,:,j,i)),squeeze(O3(xslice(k),:,:,j,i)),...
            'FaceAlpha','interp','Facecolor','interp');
            alpha(h1,'color');
            shading interp
            hold on
        end
        hold on
        for l=1:37
            h2=surf(squeeze(lon_use(:,yslice(l),:)),squeeze(lat_use(:,yslice(l),:)),...
            squeeze(height(:,yslice(l),:,j,i)),squeeze(O3(:,yslice(l),:,j,i)),...
            'FaceAlpha','interp','Facecolor','interp');
            alpha(h2,'color');
            shading interp
            hold on
        end
        % set axis and colorbar
        caxis([0,120]);
        color=colormap(turbo);
        hc=colorbar('ytick',0:30:120,'fontsize',10);
        ylabel(hc,'ppbv','fontsize',10);

        xlim([109 118]);
        ylim([20 25.6]);
        zlim([-1 4]);
        set(gca,'Ytick',[20:1:25]);
        set(gca,'Xtick',[109:1:118]);
        set(gca,'Ztick',[0:1:5],'Zticklabel',{'0','1000','2000','3000','4000','5000'});
        xlabel(gca,'Longitude(°E)','FontSize',10);
        ylabel(gca,'Latitude(°N)','FontSize',10);
        zlabel(gca,'Height(m)','FontSize',10);

        grid on
        view([-17 20]);

        if (j>=1)&&(j<=16) 
            hour=[8:23];
            title(['O_3-','2021-03-',num2str(i+22-1),'-',num2str(hour(j))],'fontsize',12);
            Now_printing_figure_on=['2021-03-',num2str(i+22-1),'-',num2str(hour(j))]
            path = ['D:/files/Master/02学术/Case/Shaog03/fig_slice_hgt/O3_','2021-03-',num2str(i+22-1),'-',num2str(hour(j))]; % Note here to modify
            print(gcf,'-dtiff','-r600',path)
        else
            hour=[0:7];
            title(['O_3-','2021-03-',num2str(i+22),'-',num2str(hour(j-16))],'fontsize',12);
            Now_printing_figure_on=['2021-03-',num2str(i+22),'-',num2str(hour(j-16))]
            path = ['D:/files/Master/02学术/Case/Shaog03/fig_slice_hgt/O3_','2021-03-',num2str(i+22),'-',num2str(hour(j-16))]; % Note here to modify
            print(gcf,'-dtiff','-r600',path)
        end
    end
end

Program_Ends_at=datetime('now')
