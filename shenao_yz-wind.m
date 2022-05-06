clear
clc

%模式
gridfile1='D:\项目\韶关\data\GRIDCRO2D_2020175';
gridfile2='D:\项目\韶关\data\GRIDDOT2D_2020175';
ncfile1='D:\项目\韶关\data\202007\COMBINE_MET3D_202007_wind.nc';
ncfile2='D:\项目\韶关\data\202007\COMBINE_MET3D_202007.nc';
ncfile3='D:\项目\韶关\data\202007\COMBINE_ACONC_v521_intel_CN9GD_98X74_202007.nc';
lat=ncread(gridfile1,'LAT');
lon=ncread(gridfile1,'LON');
o3=squeeze(ncread(ncfile3,'O3'));
o3=reshape(o3(:,:,:,16:87),98,74,26,24,3)*48/22.4;
ht=ncread(gridfile1,'HT');
zh=ncread(ncfile2,'ZH');
zh=reshape(zh(:,:,1:26,16:87),98,74,26,24,3);
uwind=ncread(ncfile1,'UWIND');
uwind=reshape(uwind(1:98,1:74,1:26,16:87),98,74,26,24,3);
vwind=ncread(ncfile1,'VWIND');
vwind=reshape(vwind(1:98,1:74,1:26,16:87),98,74,26,24,3);
wwind=ncread(ncfile2,'WWIND');
wwind=reshape(wwind(:,:,1:26,16:87),98,74,26,24,3);
for i=1:26
    for j=1:24
        for k=1:3
            height(:,:,i,j,k)=(zh(:,:,i,j,k)+ht)/1000;
        end
    end
end
for i=1:26
    xx(:,i)=squeeze(lat(54,:));
end
v = [0 0; 27 0; 27 27; 0 27];
f = [1 2 3 4];

for j=1:3
for i=1:24
clf
set(gcf,'position',[100,100,550,360]);
patch('Faces',f,'Vertices',v,'FaceColor',[0.7,0.7,0.7],'EdgeColor',[0.7,0.7,0.7])
hold on
[~,h]=contourf(xx,squeeze(height(54,:,:,i,j)),squeeze(o3(54,:,:,i,j)),0:25:300);
set(h,'edgecolor','none');
caxis([0,300])
color=WhiteBlueGreenYellowRed(12);
colormap(color(:,:));
hc=colorbar('ytick',0:50:300,'fontsize',17);
ylabel(hc,'O_3 [μg/m^3]','fontname','Times New Roman','fontsize',17);
hold on
quiver(xx(1:3:74,8:2:20),squeeze(height(54,1:3:74,8:2:20,i,j)),squeeze(vwind(54,1:3:74,8:2:20,i,j))/25,squeeze(wwind(54,1:3:74,8:2:20,i,j))/3,'-k','autoscale','off','linewidth',1)
axis([19.65 25.68 0 2])
set(gca,'xtick',(20:1:26),'ytick',(0:0.4:2),'fontname','Times New Roman','fontsize',17);
set(gca,'yticklabel',{'0','400','800','1200','1600','2000'});
xlabel(['\fontsize{17}\fontname{宋体}纬度 \fontsize{17}\fontname{Times New Roman}(°)']);
ylabel(['\fontsize{17}\fontname{宋体}高度 \fontsize{17}\fontname{Times New Roman}(m)']);
title([datestr(datenum(2020,6,29)+(i-1)/24+(j-1),'yyyy-mm-dd HH:MM')],'fontsize',17);
set(gca,'position',[0.17 0.20 0.6 0.7]);
print(gcf,'-dtiff','-r300',['D:\项目\韶关\pic\wind_z\o3_',datestr(datenum(2020,6,29)+(i-1)/24+(j-1),'yyyy-mm-dd-HH')]);
set(gcf,'PaperPositionMode','manual');
set(gcf,'PaperUnits', 'points');
set(gcf,'PaperSize',[440 280]);
%set(gcf,'PaperPosition', [-0.75 0.2 26.5 26]);
set(gcf,'PaperPosition',[0,0,440,280]);
print(gcf,'-dpdf','-painters',['D:\项目\韶关\pic\wind_z\o3_',datestr(datenum(2020,6,29)+(i-1)/24+(j-1),'yyyy-mm-dd-HH')]);
end
end