function [c, eq] = Single_Objective_Constraints(x,RC,UC,EC,TTS,EC_db,TTS_db,B_T,b_slots, P_T, UpC, c_scenario, n_users, number_cells, theta, frame, frame_dur, freq, Adj_u, beams, init)
    limit1 = 1;
    limit2 = number_cells*frame;
    Ill = reshape(x(limit1:limit2),number_cells,frame);
    
    limit1 = limit2+1;
    limit2 = number_cells*frame + n_users*b_slots*frame;
    B = reshape(x(limit1:limit2),n_users,b_slots,frame);

    limit1 = limit2+1;
    limit2 = number_cells*frame + n_users*b_slots*frame+n_users*frame;
    P = reshape(x(limit1:limit2),n_users,frame);


   db_margin=0.05; % DB margin 5%

   if strcmp(init, 'DB') % DB Constraints;
        EC_constraint=EC_db*(1+db_margin);
       TTS_constraint=TTS_db*(1+db_margin);
   else % Generic Constraints EC<20% && TTS<1.5s
       EC_constraint=RC*0.2;
       TTS_constraint=n_users*0.03;
   end

    c = zeros(7,1);
    eq = [];
    
    for t=1:size(P,2)
        c(1) = c(1) + max(0,(round(sum(P(:,t))*100)/100 - P_T));
        c(2) = c(2) + max(0, (sum(((B(:,:,t)'*Adj_u)*B(:,:,t)>size(B,2)),"all")));
        c(3) = c(3) + max(0, (ones(size(Ill,1),1)-Ill(:,t))'*(UpC*P(:,t)));
        c(4) = c(4) + max(0, ((ones(size(Ill,1),1)-Ill(:,t))'*(UpC*sum(B(:,:,t),2))));
        c(5) = c(5) + max(0, (sum(Ill(:,t)) - beams));
        
    end
    c(6) = c(6) + max(0, (EC - EC_constraint));
    c(7) = c(7) + max(0, (TTS - TTS_constraint));
    %c
    %c = sum(c);
    %fprintf('%f \n',c);
    
end
