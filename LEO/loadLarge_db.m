function loadLarge_db()

    global B_T;
    global b_slots;
    global P_T;
    global UpC;
    global c_scenario;
    global n_users;
    global rings;
    global number_cells;
    global theta;
    global frame;
    global frame_dur;
    global freq;
    global Adj_u;
    global Adj_c;
    global colours;
    global beams;

    %0) Input parameter definition.
    freq=20e9; % Ka Band (DL)
    h_sat=1100; % Starklink [550km] ; OneWeb [1100km] 
    el_min=25; % Minimum Elevation Angle [º] 
    Re=6378; % Earth Radius [km]
    frame=100; %100ms/frame = 10s % 1 frame (10ms in 5G NR) -> 10 subframe/slot (1ms)
    frame_dur=0.01; %s
    colours=1;
    %beams=8;
    beams=4;
    P_T=18; %W
    n_users=50; 
    traffic_model='uniform'; %'linear' %'hotspot'
    B_T=250/2; %MHz per colour
    %b_slots=B_T/1; % 1MHz slots
    b_slots=5;
    rings=10; %Fixed grid 271 cells
    number_cells=0;
    for i=1:rings
        number_cells=number_cells+6*(i-1);
    end
    number_cells=number_cells+1;
    
    % Tentative Outputs:
    Ill=zeros(number_cells,frame);
    B=zeros(n_users,b_slots,frame);
    P=zeros(n_users,frame);
    
    % Helping Matrixes:
    UpC=zeros(number_cells,n_users);
    Adj_c=zeros(number_cells,number_cells);
    Adj_u=zeros(n_users,n_users);
    
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
    
    % Cell Definition:
    [l,h,theta,D_footprint,number_cells,centers, interfering, Adj_c]=Cell_Scenario(h_sat,el_min,rings,Adj_c);
    
    % % PAINT:
    % % Satellite Footprint:
    % figure (2)
    % pgon = nsidedpoly(1000, 'Center',  [0,0], 'Radius', D_footprint/2);
    % plot(pgon, 'FaceColor', 'y');
    % axis equal
    % hold on
    
    % Cell Footprint 
    c_scenario=[];
    for i=1:number_cells
        c_scenario=[c_scenario c(i,centers(i,:),l,nonzeros(interfering(i,:)))]; %constructor
        c_scenario(i).compute_betta_to_sat(h_sat); % Compute betta to the cell center so that the gain loss due to beam scanning (moving ftom boresight) can be then accounted: non-ideal isotropic behavior of the embedded element gain.
       % % PAINT:
       % c_scenario(i).draw(1);
       % hold on
    end
    % % PAINT:
    % title(strcat('Cell Scenario:  ',num2str(rings),' rings'))
    
    % 2) User and traffic generation:
    %User Generation
    [x_y,demand,type,g_rx,T_noise_rx]=Traffic_Distribution(traffic_model,n_users,D_footprint, freq);
    
    % 3) User Grouping into cells:
    for i=1:n_users
        %Euclidean distance to cell centers to determine the cell:
        [dist_min,cell_num]=min(sqrt((x_y(i,1)-centers(:,1)).^2+(x_y(i,2)-centers(:,2)).^2)); 
        %Assign user to corresponding cell:
        c_scenario(cell_num).adduser(u(i,[x_y(i,1),x_y(i,2)],type,demand(i),g_rx,T_noise_rx));  %constructor
        c_scenario(cell_num).users(length(c_scenario(cell_num).users)).compute_distance_elevation_betta_to_sat(h_sat); % Compute distance, elevation and betta angle to the satellite of the the last added user
        c_scenario(cell_num).users(length(c_scenario(cell_num).users)).compute_betta_to_cell_center(h_sat,c_scenario(cell_num)); % Compute the betta angle with respect to the cell center so that the gain loss can be accounted by the fact of not being at the cell center
        UpC(cell_num,i)=1;
    end
    Adj_u=UpC'*Adj_c*UpC;

    
end