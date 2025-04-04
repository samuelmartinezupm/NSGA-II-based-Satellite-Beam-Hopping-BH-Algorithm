function Population = PopulationInitialization(N)
    global number_cells;
    global n_users;
    global frame;
    global b_slots;
    global P_T;
    global beams;
    global UpC;
    global Adj_c;
    global Adj_u;

    Population = [];
    for s = 1:N % Generamos un total de "PopulationSize" soluciones
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