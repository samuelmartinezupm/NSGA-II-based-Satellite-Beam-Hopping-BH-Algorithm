function vars = generate_db_solution()

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
    
    
    %instance='small'
    TTL=5;
   
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
    %save(strcat('demand_based_variables_per_c_scenario',instance), 'FOM','Variables')
    vars =[Ill(:)', B(:)',P(:)']; 
end



