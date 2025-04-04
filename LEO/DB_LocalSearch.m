function db_refined_solution = DB_LocalSearch(solution, lsType, lsRate)
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
    global beams;
    global colours;

    if strcmp(lsType,'randomOperator')
        r = randi([1 2]);
        if (r == 1)
            ls = 'DB';
        else
            ls = 'DB_instants';
        end
    else
    
        ls = lsType;
    end


    TTL = 5;
    db_refined_solution = solution;

    if (rand < lsRate)
        if strcmp(ls,'DB') 
            t_mutation = randi([1 frame]);
            db_refined_solution = DB_Mutation( ...
                t_mutation, ...
                solution, ...
                B_T,b_slots, P_T, UpC, c_scenario,n_users,number_cells, beams, theta, colours, frame, frame_dur, TTL, freq);
        else
            numberModifiedFrames = randi([1 frame]);
            exchangedFrames = randperm(frame);
            t_mutation_array = exchangedFrames([1 numberModifiedFrames]);
            db_refined_solution = DB_Mutation_Instants( ...
                t_mutation_array, ...
                solution, ...
                B_T,b_slots, P_T, UpC, c_scenario,n_users,number_cells, beams, theta, colours, frame, frame_dur, TTL, freq);
        end
    end


end