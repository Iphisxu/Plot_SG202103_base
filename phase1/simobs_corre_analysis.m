% Hour-Average Concentration of O3(unit:ppbV) from Simulation...
% on 1000hPa/Ground
% Compared with Observation Datasets
% Date: 2022-04-10
% Edited by Evan
% ==================================
% clc
clear
close all

Program_Starts_at=datetime('now')

% ==================================
% Read Gridfile
% ==================================
DataPath='F:/Data/';
Grid='CN9';
GridName='CN9GD_98X74'; % Note here to modify
GridFile = string(DataPath)+'GRIDCRO2D_2021076.nc'; % Note here to modify
close

lat = ncread(GridFile,'LAT');
lon = ncread(GridFile,'LON');  

% ==================================
% Read CMAQ Output
% ==================================

ncFile=string(DataPath)+'COMBINE_ACONC_'+string(GridName)+'_202103_simple.nc'; % Note here to modify
% ncFile=string(DataPath)+'COMBINE_ACONC_'+string(GridName)+'_202103_O33d.nc';

O3 = squeeze(ncread(ncFile,'O3')); % O3(lon,lat,tstep)
NO2 = squeeze(ncread(ncFile,'NO2')); % O3(lon,lat,tstep)
PM = squeeze(ncread(ncFile,'PM25_TOT')); % O3(lon,lat,tstep)
nDays = size(O3,3)/24; % get the length of tstep to calculate days number

% set start_end grid in lon & lat
slon=53;
elon=55;
slat=62;
elat=63;

O3 = squeeze(nanmean(O3(slon:elon,:,:),1));
O3 = squeeze(nanmean(O3(slat:elat,:),1));

NO2 = squeeze(nanmean(NO2(slon:elon,:,:),1));
NO2 = squeeze(nanmean(NO2(slat:elat,:),1));

PM = squeeze(nanmean(PM(slon:elon,:,:),1));
PM = squeeze(nanmean(PM(slat:elat,:),1));


% ==================================
% Read Observation Data
% ==================================

load(string(DataPath)+'chemdata_2021.mat');
nsite=594:598;
O3_o(5,24,365)=0;
NO2_o(5,24,365)=0;
PM_o(5,24,365)=0;

for i=1:5
    O3_o(i,:,:)=chemdata(:,:,nsite(i),10);
    NO2_o(i,:,:)=chemdata(:,:,nsite(i),8);
    PM_o(i,:,:)=chemdata(:,:,nsite(i),2);
end
for i=1:5
    for j=1:24
        for k=1:nDays
            O3_ob(i,j,k)=O3_o(i,j,k+80); % O3_obs(site,hour,day)
            NO2_ob(i,j,k)=NO2_o(i,j,k+80); % O3_obs(site,hour,day)
            PM_ob(i,j,k)=PM_o(i,j,k+80); % O3_obs(site,hour,day)
        end
    end
end

O3_obs=reshape(O3_ob,5,144);
O3_obs=squeeze(nanmean(O3_obs,1));

NO2_obs=reshape(NO2_ob,5,144);
NO2_obs=squeeze(nanmean(NO2_obs,1));

PM_obs=reshape(PM_ob,5,144);
PM_obs=squeeze(nanmean(PM_obs,1));

% ==================================
% Correlation Analysis
% ==================================

% Pearson
OS_O3 = [O3(1:136)' O3_obs(9:144)'];
OS_NO2 = [NO2(1:136)' NO2_obs(9:144)'];
OS_PM = [PM(1:136)' PM_obs(9:144)'];
[R1,P1]=corrcoef(OS_O3)
[R2,P2]=corrcoef(OS_NO2)
[R3,P3]=corrcoef(OS_PM)

% Spearman
% Rs1=corr(O3(1:136)',O3_obs(9:144)','type','Spearman')
% Rs2=corr(NO2(1:136)',NO2_obs(9:144)','type','Spearman')
% Rs3=corr(PM(1:136)',PM_obs(9:144)','type','Spearman')

Program_Ends_at=datetime('now')
