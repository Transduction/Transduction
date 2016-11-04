%% Make sure you change the below command so that it points to the location of the matlab function Trans_fnc.m

path(path,'.\Functions')

%% Make sure you change the below command so that it points to the location of the data file Data_example.txt

cd('.\Data\')

%% Imports example data file

N=importdata('Data_example.txt',',',1);

%% Runs transduction script

[Binned_Area,Total_DBP,SEM_DBP,weights,Intercept,Slope] = Trans_fnc(N,[],10,6);

%% Plotting output of transduction script

Area=[10:0.1:110];
hold on;
plot(Area,Intercept+Slope*Area,'-r');
errorbar(Binned_Area,Total_DBP,SEM_DBP,'-sb','MarkerFaceColor','b');
xlabel('Binned mSNA Area')
ylabel('DBP')
title('Example transduction analysis')
axis([40 110 66 84])
legend('Weighted linear regression (R^2=0.6)','Data');