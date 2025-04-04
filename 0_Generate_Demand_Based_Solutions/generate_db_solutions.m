clear all
clc
close all

global B_T;
global b_slots;
global P_T;
global UpC;
global c_scenario;
global n_users;
global number_cells;
global rings;
global theta;
global frame;
global frame_dur;
global freq;
global Adj_u;
global Adj_c;
global colours;
global beams;

instance='small'
TTL=5;

seeds = [2086611235, 134546460, 372556643, 174984732, 1701384495, 1849275000, 319285460, 814873822, 1149458473, 1037906549, 1936202636, 752251260, 331834558, 1073404773, 473651765, 495752086, 1890790170, 30767557, 149610889, 549432576, 1899222341, 1305877330, 965789845, 136830328, 692993820, 173302510, 1936751275, 435756074, 1429130986, 1202487946, 1330904806, 1561538049, 1584558490, 1773010390, 475077922, 704819280, 1101917058, 916813798, 896500662, 1209693945, 1103696678, 1351622864, 1395343572, 978851367, 739895583, 295136723, 1425639839, 770762499, 119047332, 618439756];

FOM=zeros(length(seeds),3);
if strcmp(instance, 'small')
    Variables=zeros(length(seeds),19*10+15*10*5+15*10);
elseif strcmp(instance, 'large')
    Variables=zeros(length(seeds),271*100+25*100*50+50*100);      
else
    disp('Unknown LEO instance');
    return
end

for i=1:length(seeds)
     rng(seeds(i));
     if strcmp(instance, 'small')
            disp(strcat('Loading the small instance:',' ',num2str(i)));
            loadSmall_db();
        elseif strcmp(instance, 'large')
            disp(strcat('Loading the large instance:',' ',num2str(i)));
            loadLarge_db();
        else
            disp('Unknown LEO instance');
            return
     end

%Initialization:
    %Tentative Outputs:
    Ill=zeros(number_cells,frame);
    B=zeros(n_users,b_slots,frame);
    P=zeros(n_users,frame);
    
    % Helping Matrixes:
    % UpC=zeros(number_cells,n_users);
    % Adj_c=zeros(number_cells,number_cells);
    % Adj_u=zeros(n_users,n_users);
    
    %FOM Parameter Inicialization:
    n_realizations=1;
    RC=zeros(1,n_realizations); % Requested Capacity
    SC=zeros(1,n_realizations);% Served Capaciaty (from requested)
    UC=zeros(1,n_realizations); % Unserved Capacity
    EC=zeros(1,n_realizations); % Extra Served Capacity
    TTS=zeros(1,n_realizations); % Time Till Being Served

% Demand-based calculation:
[RC,SC,UC,EC,TTS, Ill,B,P]=FOM_calculation_demand_based_band_slots(B_T,b_slots, P_T, Ill, B, P,c_scenario,n_users, beams, theta, colours, frame, frame_dur, TTL, freq);
% % Testing RESTRICCIONES Demand-based:
%     bool_INI=1;
%     c = zeros(5,1);
%         for t=1:size(P,2)
%                 if round(sum(P(:,t))*100)/100>P_T
%                     c(1) = c(1) + (round(sum(P(:,t))*100)/100 - P_T);
%                 end
%                 if sum(((B(:,:,t)'*Adj_u)*B(:,:,t)>size(B,2)),"all")>0
%                     c(2) = c(2) + sum(((B(:,:,t)'*Adj_u)*B(:,:,t)>size(B,2)),"all");
%                 end
%                 if (ones(size(Ill,1),1)-Ill(:,t))'*(UpC*P(:,t))>0
%                     c(3) = c(3) + (ones(size(Ill,1),1)-Ill(:,t))'*(UpC*P(:,t));
%                 end
% 
%                 if (ones(size(Ill,1),1)-Ill(:,t))'*(UpC*sum(B(:,:,t),2))>0
%                     c(4) = c(4) + (ones(size(Ill,1),1)-Ill(:,t))'*(UpC*sum(B(:,:,t),2));
%                 end
%                 if sum(Ill(:,t))>beams
%                     c(5) = c(5) + sum(Ill(:,t)) - beams;
%                 end
%         end
%         if sum(c)~=0
%             bool_INI=0;
%         end
%     bool_INI

FOM(i,:)=[UC EC TTS];
Variables(i,:) = [Ill(:)', B(:)',P(:)'];
end

save(strcat('demand_based_variables_per_c_scenario',instance), 'FOM','Variables')



