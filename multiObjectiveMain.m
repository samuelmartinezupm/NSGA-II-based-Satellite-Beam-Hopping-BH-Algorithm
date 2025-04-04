function [UC,EC,TTS,UC_db,EC_db,TTS_db]=multiObjectiveMain(instance, scenario, maxFEs, popSize, initFun, c_rate, m_type, m_rate, ls_type, ls_rate, run, users)
    addpath('./LEO')
    addpath('./LEO/Variable_Grid')

    global init;
    global B_T;
    global b_slots;
    global P_T;
    global UpC;
    global c_scenario;
    global n_users;
    global number_cells;
    global theta;
    global frame;
    global frame_dur;
    global freq;
    global colours;
    global Adj_u;
    global Adj_c;
    global beams;
    global current_scenario;
    global current_instance;
    global c_rate_LEO;
    global m_type_LEO;
    global m_rate_LEO;
    global EC_db;
    global TTS_db;
    global ls_type_LEO;
    global ls_rate_LEO;

    c_rate_LEO = c_rate;
    m_type_LEO = m_type;
    m_rate_LEO = m_rate;
    ls_type_LEO = ls_type;
    ls_rate_LEO = ls_rate;
    n_users=users;
    init = initFun;
    
    % Fix a random seed for comparison purposes
    seeds = [2086611235, 134546460, 372556643, 174984732, 1701384495, 1849275000, 319285460, 814873822, 1149458473, 1037906549, 1936202636, 752251260, 331834558, 1073404773, 473651765, 495752086, 1890790170, 30767557, 149610889, 549432576, 1899222341, 1305877330, 965789845, 136830328, 692993820, 173302510, 1936751275, 435756074, 1429130986, 1202487946, 1330904806, 1561538049, 1584558490, 1773010390, 475077922, 704819280, 1101917058, 916813798, 896500662, 1209693945, 1103696678, 1351622864, 1395343572, 978851367, 739895583, 295136723, 1425639839, 770762499, 119047332, 618439756];
    rng(seeds(scenario+1));
    current_scenario = scenario+1;
    current_instance = instance;

    % Instance generation
    if strcmp(instance, 'small')
        disp('Loading the small instance');
        loadSmall(instance, scenario, maxFEs, popSize, run);
    elseif strcmp(instance, 'large')
        disp('Loading the large instance');
        loadLarge(instance, scenario, maxFEs, popSize, run);
    elseif strcmp(instance, 'variable')
        disp('Loading the variable instance');
        loadVariable(instance, scenario, maxFEs, popSize, run);
    else
        disp('Unknown LEO instance');
        return
    end

    if strcmp(init, 'DB') && strcmp(instance,'large')
        initFunction = @DB_PopulationInitialization;
    else
        initFunction = @PopulationInitialization;
    end

    % OPTIMIZATION BASED APPROACH:

    % Reset the pseudorandom number generator
    s = randi([1 60]);
    %pause(s);
    rng('shuffle');

    % Number of variables and upper bounds
    Nvar = number_cells*frame + n_users*b_slots*frame + n_users*frame;     
    UB = [ones(number_cells*frame+n_users*b_slots*frame,1);ones(n_users*frame,1)*P_T];

    % New encoding value in PlatEMO for LEO problems
    encoding = ones(Nvar,1)*6;
    %'evalFcn',@SingleObjectiveFunction,...
    [vars,objectives,constraints]  = platemo( ...
        'evalFcn',@MultiObjectiveFunction,...
        'initFcn', initFunction,...
        'encoding',encoding',...
        'lower',0,...
        'upper',UB', ...
        'save',-1, ...
        'algorithm',@NSGAII,...
        'maxFE',maxFEs, ...
        'N', popSize ...
    );
   
    
    % DEMAND BASED APPROACH:
    TTL=5;
    %[RC,SC,UC,EC,TTS, Ill,B,P]
    [~,~,UC_db,EC_db,TTS_db, Ill_db,B_db,P_db]=FOM_calculation_demand_based_band_slots(B_T,b_slots, P_T, zeros(number_cells,frame), zeros(n_users,b_slots,frame), zeros(n_users,frame),c_scenario,n_users, beams, theta, colours, frame, frame_dur, TTL, freq);
    vars_db=zeros(1,Nvar);

    %Ill:
    limit1 = 1;
    limit2 = number_cells*frame;
    vars_db(limit1:limit2) = Ill_db(:)';

    %B:  
    limit1 = number_cells*frame+1;
    limit2 = number_cells*frame + n_users*b_slots*frame;
    vars_db(limit1:limit2) = B_db(:)';

    %P:
    limit1 = number_cells*frame + n_users*b_slots*frame+1;
    limit2 = number_cells*frame + n_users*b_slots*frame+n_users*frame;
    vars_db(limit1:limit2) = P_db(:)';


    % SAVE THE ENTIRE INSTANCE:

    save(strcat('NSGA_II_[', instance,'_', num2str(scenario), ...
                ']_result_','MAXFEs', num2str(maxFEs),...
                '.P',num2str(popSize),...
                '.i',init,...
                '.cR', num2str(c_rate_LEO), ...
                '.mType', m_type_LEO,...
                '.mRate', num2str(m_rate_LEO),...
                '.lsType', ls_type, ...
                '.lsRate',num2str(ls_rate),...
                '.users', num2str(n_users),...
                '.r',num2str(run),'.mat'),"vars","objectives", "constraints","vars_db","UC_db","EC_db","TTS_db","c_scenario","B_T","b_slots", "P_T", "Adj_c", "Adj_u", "UpC", "n_users", "beams", "theta", "colours", "frame", "frame_dur", "freq");

end