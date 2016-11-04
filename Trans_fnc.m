function [Binned_Area,Total_DBP,SEM_DBP,weights,Intercept,Slope] = Trans_fnc(N,ECG_Removed,N1,N2)

mSNA=N.data(:,2);

Diastole=find(N.data(:,9)==1);
CardiacCycles=find(N.data(:,5)==1);
BP=N.data(:,6);
DBP=BP(Diastole);

%% Normalises mSNA trace

mSNA=mSNA-min(mSNA);

MaxBurst=max(mSNA);

mSNA=100*(mSNA-min(mSNA))/MaxBurst;

DBP(ECG_Removed)=mean(DBP);

%% Calculates the summed area of all mSNA bursts in a window of length (N1-N2) cardiac cycles

for i=N1+2:length(DBP)-4
    X=[];
    X=find(Diastole(i)<CardiacCycles,1,'first');
    Start=CardiacCycles(X-N1);
    End=CardiacCycles(X-N2);
    Area(i)=1e-3*sum(mSNA(Start:End));
end

Area(1:1+N1)=[];

%% Bins the mSNA area

Binned_Area=1:500;
[~,ind] = histc(Area,Binned_Area);
Indices=Binned_Area(ind);
Indices=Indices(1:end); % avoids there not being a cardiac cycle

%% For each binned sum of mSNA area (in a window of N1-N2 cardiac cycles), this works out the resultant DBP (mean +/- SEM)

for i=1:length(Binned_Area)
   X=find(ind==i);
   if length(X)==0
        weights(i)=0;
        Total_DBP(i)=0;
        SEM_DBP(i)=0;
   else
       Total_DBP(i)=mean(DBP(X));
       weights(i)=length(X);
       SEM_DBP(i)=std(DBP(X))/sqrt(length(X));
   end
end

%% writes to variables outputted by function, but only when weights>0 (ignores empty Area bins)

Total_DBP=Total_DBP(weights>0);
Binned_Area=Binned_Area(weights>0);
SEM_DBP=SEM_DBP(weights>0);
weights=weights(weights>0);

%% fits weighted linear slope

ft = fittype('poly1');
opts = fitoptions(ft);
opts.Weights = weights;
[f,gof]=fit(Binned_Area',Total_DBP',ft,opts);
gof
f
Slope=f.p1;
Intercept=f.p2;