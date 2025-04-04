function loadVariable(instance, scenario, maxFEs, popSize, run)
    addpath('./LEO')

    global B_T;
    global b_slots;
    global P_T;
    global UpC;
    global c_scenario;
    global n_users;
    global number_cells;
    global theta;
    global colours;
    global frame;
    global frame_dur;
    global freq;
    global Adj_u;
    global beams;
    global c_rate_LEO;
    global m_type_LEO;
    global m_rate_LEO;

    %0) Input parameter definition.
    freq=20e9; % Ka Band (DL)
    h_sat=1100; % Starklink [550km] ; OneWeb [1100km] 
    el_min=25; % Minimum Elevation Angle [º] 
    Re=6378; % Earth Radius [km]
    frame=100; %100ms/frame = 10s % 1 frame (10ms in 5G NR) -> 10 subframe/slot (1ms)
    frame_dur=0.1; %s
    colours=1;
    beams=4;
    P_T=18; %W
    n_users=50; 
    traffic_model='uniform'; %'linear' %'hotspot'
    B_T=250/2; %MHz per colour
    %b_slots=B_T/1; % 1MHz slots
    %b_slots=B_T/5; % 5MHz slots
    b_slots=5;
    rings=10; %Fixed grid 271 cells
    number_cells=0;
    
    %FOM Parameter Inicialization:
    n_realizations=1;
    RC=zeros(1,n_realizations); % Requested Capacity
    SC=zeros(1,n_realizations);% Served Capaciaty (from requested)
    UC=zeros(1,n_realizations); % Unserved Capacity
    EC=zeros(1,n_realizations); % Extra Served Capacity
    TTS=zeros(1,n_realizations); % Time Till Being Served
    
    % _________________________________________________________________ %
    
    % 1) Ring-based cell generation
    % Satellite's Footrprint Trigonometric relationships:
    betta_max=(asin((Re/(Re+h_sat))*cos(el_min*pi/180)))*180/pi;
    gamma_max=90-betta_max-el_min;
    h_prime_max=Re*(1-cos(gamma_max*pi/180));
    A_footprint=2*pi*Re*h_prime_max;
    D_footprint=((2*gamma_max)/360)*(2*pi*Re);
    

    % 1) User and traffic generation:
    %User Generation
    [x_y,demand,type,g_rx,T_noise_rx]=Traffic_Distribution(traffic_model,n_users,D_footprint, freq);
    
    users=[];
    for i=1:n_users
    users=[users u(i,[x_y(i,1),x_y(i,2)],type,demand(i),g_rx,T_noise_rx)];
    users(i).compute_distance_elevation_betta_to_sat(h_sat);
    end

    % Calculate FoV and l values based on rings:
    [l,h,theta]=Cell_Scenario(h_sat,el_min,rings);
    FoV=theta; 


    adj_matrix=zeros(n_users,n_users); % Adjacent matrix: 1 if users can be allocated into the same beam (alpha(i,j)<FoV), if not 0

    % Separation between users:
    dist=zeros(n_users,n_users);

    for i=1:n_users
        for j=1:n_users
            dist=sqrt((users(i).location(1)-users(j).location(1))^2+(users(i).location(2)-users(j).location(2))^2);
            if dist<=2*l
                adj_matrix(i,j)=1;
            end
        end
    end 

    % 2) Non Fixed Beam - User Aggrupation Algorithm:
    algorithm_repetition=1;
    S=Non_Fixed_Beam_Aggrupation(n_users, adj_matrix, algorithm_repetition);

    % 3) Cell definition by calculating the centroid of each user aggrupation:
    number_cells=length(S);

    % Tentative Outputs:
    Ill=zeros(number_cells,frame);
    B=zeros(n_users,b_slots,frame);
    P=zeros(n_users,frame);
    
    % Helping Matrixes:
    UpC=zeros(number_cells,n_users);
    Adj_c=zeros(number_cells,number_cells);
    Adj_u=zeros(n_users,n_users);

    % Cell Footprint 
    c_scenario=[];
    centers=zeros(number_cells,2);
    for i=1:number_cells
        % Centroid calculation;
        for user_idx=1:length(S{i})
            centers(i,1)=centers(i,1)+users(S{i}(user_idx)).location(1);
            centers(i,2)=centers(i,2)+users(S{i}(user_idx)).location(2);
        end
        centers(i,1)=centers(i,1)/length(S{i});
        centers(i,2)=centers(i,2)/length(S{i});
       
        c_scenario=[c_scenario c(i,centers(i,:),l,[])]; %constructor: for this case assume interfering []
        c_scenario(i).compute_betta_to_sat(h_sat); % Compute betta to the cell center so that the gain loss due to beam scanning (moving ftom boresight) can be then accounted: non-ideal isotropic behavior of the embedded element gain.
        
        % Assign user to corresponding cell:
        for user_idx=1:length(S{i})
            c_scenario(i).adduser(users(S{i}(user_idx)));  %constructor
            c_scenario(i).users(user_idx).compute_distance_elevation_betta_to_sat(h_sat); % Compute distance, elevation and betta angle to the satellite of the the last added user
            c_scenario(i).users(user_idx).compute_betta_to_cell_center(h_sat,c_scenario(i)); % Compute the betta angle with respect to the cell center so that the gain loss can be accounted by the fact of not being at the cell center
            %UpC(i,user_idx)=1;
            UpC(i,users(S{i}(user_idx)).id)=1;
        end

    end


    % 4) Interfering Cells Computation
    d_interfering=4*h;
    interfering=zeros(number_cells,1);
    for i=1:number_cells
        cont=0;
        for j=1:number_cells
            if i==j
                Adj_c(i,j)=1;
                Adj_c(j,i)=1;
            else
                if sqrt((c_scenario(i).center(1)-c_scenario(j).center(1))^2+(c_scenario(i).center(2)-c_scenario(j).center(2))^2)<d_interfering
                    cont=cont+1;
                    interfering(i,cont)=j;
                    Adj_c(i,j)=1;
                    Adj_c(j,i)=1;
                end
            end
        end
    end

    for i=1:number_cells
        c_scenario(i).interfering=nonzeros(interfering(i,:));
    end
   
    Adj_u=UpC'*Adj_c*UpC;

    % % Save the instance
    % save(strcat('[',instance,'_', num2str(scenario),...
    %     ']_c_scenario_optimization_based_MAXFEs',num2str(maxFEs),...
    %     '.P',num2str(popSize),...
    %     '.cR', num2str(c_rate_LEO), ...
    %     '.mType', m_type_LEO,...
    %     '.mRate', num2str(m_rate_LEO),...
    %     '.r',num2str(run),'.mat'), "c_scenario","B_T","b_slots", "P_T", "Adj_c", "Adj_u", "UpC", "n_users", "beams", "theta", "colours", "frame", "frame_dur", "freq");
    % 
   
  
end