function Population = DB_PopulationInitialization(N)
    global number_cells;
    global n_users;
    global frame;
    global b_slots;
    global P_T;
    global beams;
    global UpC;
    global Adj_c;
    global Adj_u;
    global current_scenario;
    global B_T;
    global c_scenario;
    global theta;
    global colours;
    global frame_dur;
    global freq;
    global current_instance;
    global EC_db;
    global TTS_db;
    global UC_db;

    % DB generation:
    % Old way:

    % if (strcmp(current_instance, 'large'))
    %     load('demand_based_variables_per_c_scenariolarge.mat');
    % elseif (strcmp(current_instance, 'small'))
    %     load('demand_based_variables_per_c_scenariosmall.mat');
    % else
    %     error('No se dispone de DB solucions para esta instancia');
    % end
    % db_solution2 = Variables(current_scenario,:);
    % 

    % New way (integrated):
    TTL=5;
    % [RC,SC,UC,EC,TTS, Ill,B,P]
    %[~,~,~,~,~, Ill,B,P]
    [~,~,UC_db,EC_db,TTS_db, Ill,B,P]=FOM_calculation_demand_based_band_slots(B_T,b_slots, P_T, zeros(number_cells,frame), zeros(n_users,b_slots,frame), zeros(n_users,frame),c_scenario,n_users, beams, theta, colours, frame, frame_dur, TTL, freq);
    db_solution = [Ill(:)', B(:)',P(:)'];
    %db_solution = generate_db_solution();

    Population = [];

    %% Insert demand_based initial solutions
    Population = [Population; db_solution];
    % for s = 2:(N/2)
    %     mutation = randi([1 2]);
    %     if mutation == 1
    %         mType = 'P';
    %     else
    %         mType = 'B';
    %     end
    %     newSolution = MutationLEO(db_solution,mType,1.0);
    %     Population = [Population; newSolution];
    % end

    %% Generate the remaining randomly
    for s = 1:(N-1) % Generamos el resto de soluciones
    %for s = 1:(N/2) % Generamos el resto de soluciones
        %Inicializamos las matrices
        Ill = zeros(number_cells,frame);
        B   = zeros(n_users,b_slots,frame);
        P   = zeros(n_users,frame);
    
        % Se construye [Ill] de forma aleatoria: 
        % se activan entre 1 y 'beams' beams
        for f = 1:frame
            actives = randi(beams);
            pos = randperm(number_cells);
            for a = 1:actives
                Ill(pos(a),f) = 1;
            end
        end

        % Illumination per user:
        Ill_u=(UpC'*Ill);


        %% Se construye [B] de forma aleatoria
         for f = 1:frame
            % Asignamos banda en base a [Ill]
            users = sum(Ill_u(:,f),1);
            pos = find(Ill_u(:,f))';
            % Se calculan los usuarios adyacentes que deben ser considerados en base a la iluminacion (si hay dos adyacentes que no se iluminan a la vez, da igual!)
            adjacent_for_illumination=(Ill_u(:,f).*Adj_u);
            adjacent_for_illumination_total=sum(Ill_u(:,f).*Adj_u,1); %==Ill_u(:,f)'*Adj_u
            for u = 1:users
                %Calculamos un porcentaje de banda para el primer usuario en función de la adyacencia de iluminación en cada instante (frame)! 
                percentage=floor(b_slots/adjacent_for_illumination_total(pos(u))); 
                restricted=[];
                adjacents=find(adjacent_for_illumination(:,pos(u))); %Ver cuales son los adyacentes que le afectan a ese usuario para verificación de la banda
                for i=1:length(adjacents) % Ver adyacentes
                    restricted=[restricted find(B(adjacents(i),:,f))]; % Buscar si banda ya asignada y guardar porciones para no re-asignar.
                end
                available=setdiff(1:b_slots,restricted);
                if length(available)<percentage
                    percentage=length(available);
                end
                if length(available)>0
                    b_pos=available(randperm(percentage));
                    B(pos(u),b_pos,f)=1;
                end
            end
         end


        %% Se construye [P] de forma aleatoria
         for f = 1:frame
            % Asignamos potencia en base a [Ill]
            users = sum(Ill_u(:,f),1);
            pos = find(Ill_u(:,f))';

            % Usamos una estrategia similar a una ruleta aleatoria
            initial = 0.0;
            final = 1.0;
            for u = 1:(users-1)
                %Calculamos un porcentaje de potencia para el primer usuario
                p = rand()*(final - initial);
                P(pos(u),f) = p;
                initial = p+initial;
            end
            if users~=0
            P(pos(users),f) = final - initial; % lo que sobra
            end
         end
         P = P*P_T; % Escalamos de 1-> 18W


        %%  Reshaping a vector unidimensional de nuevo
        solution = [Ill(:)', B(:)',P(:)'];

        Population = [Population; solution];
    end
end