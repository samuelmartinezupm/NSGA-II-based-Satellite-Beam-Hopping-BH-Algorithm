function functionMain(instance, scenario, maxFEs, popSize, init, c_rate, m_type, m_rate, run)
    addpath('./LEO')
    addpath('./LEO/Variable_Grid')

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
    global Adj_u;
    global Adj_c;
    global beams;
    global current_scenario;
    global current_instance;
    global c_rate_LEO;
    global m_type_LEO;
    global m_rate_LEO;

    c_rate_LEO = c_rate;
    m_type_LEO = m_type;
    m_rate_LEO = m_rate;
    
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

    
    % Reset the pseudorandom number generator
    s = randi([1 60]);
    %pause(s);
    rng('shuffle');

    % Number of variables and upper bounds
    Nvar = number_cells*frame + n_users*b_slots*frame + n_users*frame;     
    UB = [ones(number_cells*frame+n_users*b_slots*frame,1);ones(n_users*frame,1)*P_T];

    % New encoding value in PlatEMO for LEO problems
    encoding = ones(Nvar,1)*6;

    [vars,objectives,constraints]  = platemo( ...
        'evalFcn',@ObjectiveFunction,...
        'initFcn', initFunction,...
        'encoding',encoding',...
        'lower',0,...
        'upper',UB', ...
        'save',5, ...
        'algorithm',@NSGAII,...
        'maxFE',maxFEs, ...
        'N', popSize ...
    );

    save(strcat('[', instance,'_', num2str(scenario), ...
                ']_result_','MAXFEs', num2str(maxFEs),...
                '.P',num2str(popSize),...
                '.cR', num2str(c_rate_LEO), ...
                '.mType', m_type_LEO,...
                '.mRate', num2str(m_rate_LEO),...
                '.r',num2str(run),'.mat'),"vars","objectives", "constraints");

end