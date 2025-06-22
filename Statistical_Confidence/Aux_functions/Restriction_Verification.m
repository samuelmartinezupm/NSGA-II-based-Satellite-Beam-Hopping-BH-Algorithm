clc
clear all
close all

P_T=18;
beams=4;

%function [c_error]=Restriction_Verification()

load("[demand_based_band_segregation]data_4beams_1colours.mat","Ill","B","P")
load("[demand_based_NO_band_segregation]data_4beams_1colours.mat","Adj_c","Adj_u","UpC")

% Restrictions: C1, C2, C3, C4, C5
C=ones(1,5);

for t=1:size(P,2)
    if round(sum(P(:,t))*100)/100>P_T
        C(1)=0;
    end
    if (B(:,:,t)'*Adj_u)*B(:,:,t)>ones(size(B,2),size(B,2))*size(B,2)
        C(2)=0;
    end
    if Ill(:,t)>UpC*P(:,t)
        C(3)=0;
    end
    if Ill(:,t)>UpC*P(:,t)
        C(3)=0;
    end
    if Ill(:,t)>UpC*sum(B(:,:,t),2)
        C(4)=0;
    end
    if sum(Ill(:,t))>beams
        C(5)=0;
    end
end

%end