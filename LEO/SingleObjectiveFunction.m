function [x,f,g] = SingleObjectiveFunction(x)
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
    global Adj_u;
    global beams;
    global EC_db;
    global TTS_db;


    limit1 = 1;
    limit2 = number_cells*frame;
    Ill = reshape(x(limit1:limit2),number_cells,frame);
    
    limit1 = limit2+1;
    limit2 = number_cells*frame + n_users*b_slots*frame;
    B = reshape(x(limit1:limit2),n_users,b_slots,frame);

    limit1 = limit2+1;
    limit2 = number_cells*frame + n_users*b_slots*frame+n_users*frame;
    P = reshape(x(limit1:limit2),n_users,frame);

  

    [RC,SC,UC,EC,TTS] = FOM_calculation_optimization_based(B_T,b_slots, P_T,  Ill, B, P, UpC, c_scenario, n_users, theta, frame, frame_dur, freq);


    f(1) = UC;
    %f(2) = EC;
    %f(3) = TTS;

    [c, eq] = Single_Objective_Constraints(x,RC,UC,EC,TTS,EC_db,TTS_db,B_T,b_slots, P_T, UpC, c_scenario, n_users, number_cells, theta, frame, frame_dur, freq, Adj_u, beams, init);

    g = c;

end
