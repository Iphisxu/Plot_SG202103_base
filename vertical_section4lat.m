% Hour-Average Concentration of O3(unit:ppbV) from Simulation...
% on Vertical Section
% Date: 2022-04-25
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
for i=1:26
        lon_use(:,i)=squeeze(lon(:,62));
end
HT = squeeze(ncread(GridFile,'HT')); % terrain elevation(98,74)

% ==================================
% Read CMAQ Output
% ==================================

cmaqFile1=string(DataPath)+'COMBINE_ACONC_'+string(GridName)+'_202103_vertical.nc';
cmaqFile2=string(DataPath)+'COMBINE_ACONC_'+string(GridName)+'_202103_uv_vertical.nc';

O3 = ncread(cmaqFile1,'O3'); % O3(lon,lat,layer,tstep)
nDays = size(O3,4)/24; % get the length of tstep to calculate days number
O3 = squeeze(nanmean(O3(:,62:63,:,:),2));
% O3 = squeeze(O3(54,:,:,:));
O3 = reshape(O3(:,1:26,73:144),98,26,24,3); % O3(lat,layer,hour,day)
ZH = ncread(cmaqFile1,'ZH'); % (98,74,38,144)
ZH = reshape(ZH(:,:,1:26,73:144),98,74,26,24,3);
uwind=ncread(cmaqFile2,'UWind'); % (99,75,38,145)
uwind=reshape(uwind(1:98,1:74,1:26,73:144),98,74,26,24,3);
vwind=ncread(cmaqFile2,'VWind'); % (99,75,38,145)
vwind=reshape(vwind(1:98,1:74,1:26,73:144),98,74,26,24,3);
wwind=ncread(cmaqFile1,'WWind'); % (99,75,38,145)
wwind=reshape(wwind(:,:,1:26,73:144),98,74,26,24,3);

for i=1:26
        for j=1:24
                for k=1:3
                        height(:,:,i,j,k)=(ZH(:,:,i,j,k)+HT)/1000; % unit:km
                end
        end
end

%% Plot figure
% ==================================
% Plot
% ==================================

v = [0 0; 27 0; 27 27; 0 27];
f = [1 2 3 4];

for i=1:3
    for j=1:24
% i=2;j=8;
        figure
        set(gcf,'position',[100 100 800 600],'visible','off');
        patch('Faces',f,'Vertices',v,'FaceColor',[0,0,0],'EdgeColor',[0,0,0])
        hold on

        contourf(lon_use,squeeze(height(:,62,:,j,i)),O3(:,:,j,i),'edgecolor','none');
        caxis([0,120]);
        color=colormap(turbo);
        hc=colorbar('ytick',0:30:120,'fontsize',10);
        ylabel(hc,'ppbv','fontsize',10);
        % shading flat
        hold on

        quiver(lon_use(1:3:98,8:2:20),squeeze(height(1:3:98,62,8:2:20,j,i)),...
        squeeze(uwind(1:3:98,62,8:2:20,j,i))/25,squeeze(wwind(1:3:98,62,8:2:20,j,i))/3,...
        '-k','autoscale','off','linewidth',1);

        % set axis
        % axis([20 25 0 2]);
        xlim([112 115]);
        ylim([0 2]);
        set(gca,'Xtick',[112:1:115]);
        set(gca,'Ytick',[0:0.4:2],'Yticklabel',{'0','400','800','1200','1600','2000'});
        xlabel('Longitude(°E)','FontSize',12);
        ylabel('Height(m)','FontSize',12);
        grid off

        if (j>=1)&&(j<=16) 
            hour=[8:23];
            title(['2021-03-',num2str(i+25-1),'-',num2str(hour(j))],'fontsize',12,'FontWeight','bold');
            Now_printing_figure_on=['2021-03-',num2str(i+25-1),'-',num2str(hour(j))]
            path = ['D:/files/Master/02学术/Case/Shaog03/fig_vertical_xz/ver_','2021-03-',num2str(i+25-1),'-',num2str(hour(j))]; % Note here to modify
            print(gcf,'-dtiff','-r600',path)
        else
            hour=[0:7];
            title(['2021-03-',num2str(i+25),'-',num2str(hour(j-16))],'fontsize',12,'FontWeight','bold');
            Now_printing_figure_on=['2021-03-',num2str(i+25),'-',num2str(hour(j-16))]
            path = ['D:/files/Master/02学术/Case/Shaog03/fig_vertical_xz/ver_','2021-03-',num2str(i+25),'-',num2str(hour(j-16))]; % Note here to modify
            print(gcf,'-dtiff','-r600',path)
        end
    end
end

Program_Ends_at=datetime('now')
