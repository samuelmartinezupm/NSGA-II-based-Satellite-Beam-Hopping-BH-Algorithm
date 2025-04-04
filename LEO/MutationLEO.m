function mutatedSolution = MutationLEO(solution, mType, mRate)

    global number_cells;
    global n_users;
    global frame;
    global b_slots;
    global P_T;
    global UpC;
    global Adj_u;
    global beams;

    if strcmp(mType,'randomOperator')
        r = randi([1 3]);
        if (r == 1)
            mutation = 'B';
        elseif (r == 2)
            mutation = 'Ill';
        else
            mutation = 'P';
        end
    else
    
        mutation = mType;
    end


    mutatedSolution = solution;

    if strcmp(mutation,'Ill') 

        if (rand < mRate)
            limit1 = 1;
            limit2 = number_cells*frame;
            Ill =  reshape(mutatedSolution(limit1:limit2),number_cells,frame);
            
            num_frame = randi(frame);
            for i=1:num_frame
                f = randi(frame);
                Ill(:,f) = zeros(number_cells,1);
                actives = randi(beams);
                pos = randperm(number_cells);
                for a = 1:actives
                    Ill(pos(a),f) = 1;
                end
            end
            mutatedSolution(limit1:limit2) = Ill(:)';
        
            % Illumination per user:
            Ill_u=(UpC'*Ill);
        
            %% Se muta consecuentemente B de forma aleatoria
            limit1 = number_cells*frame+1;
            limit2 = number_cells*frame + n_users*b_slots*frame;
            B = zeros(n_users,b_slots,frame);
            for f = 1:frame
                    % Asignamos banda en base a la nueva [Ill]
                    users = sum(Ill_u(:,f),1);
                    pos = find(Ill_u(:,f))';
                    % Se calculan los usuarios adyacentes que deben ser considerados en base a la iluminacion (si hay dos adyacentes que no se iluminan a la vez, da igual!)
                    adjacent_for_illumination=(Ill_u(:,f).*Adj_u);
                    adjacent_for_illumination_total=sum(Ill_u(:,f).*Adj_u,1); %==Ill_u(:,f)'*Adj_u
                    for u = 1:users
                        %Calculamos un porcentaje de banda para el primer usuario en función de la adyacencia de iluminación en cada instante (frame)! 
                        percentage=randi(b_slots);%floor(b_slots/adjacent_for_illumination_total(pos(u))); 
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
            mutatedSolution(limit1:limit2) = B(:)';
        
            %% Se muta consecuentemente P de forma aleatoria
            limit1 = number_cells*frame + n_users*b_slots*frame+1;
            limit2 = number_cells*frame + n_users*b_slots*frame+n_users*frame;
           
            P=zeros(n_users,frame);
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
             P = P*P_T*(0.8+rand()*0.2); % Escalamos de 1-> 18W randomizando, sin tener que llegar a 18W.
             mutatedSolution(limit1:limit2) = P(:)';
        end

    elseif strcmp(mutation,'P') 

        if (rand < mRate)
            limit1 = 1;
            limit2 = number_cells*frame;
            Ill =  reshape(mutatedSolution(limit1:limit2),number_cells,frame);
            
            % Illumination per user:
            Ill_u=(UpC'*Ill);
        
                 
            %% Se mantiene B en mutatedSolution
            % No change required as mutatedSolution = solution already.
           
            %% Se muta P de forma aleatoria
            limit1 = number_cells*frame + n_users*b_slots*frame+1;
            limit2 = number_cells*frame + n_users*b_slots*frame+n_users*frame;
           
            P=zeros(n_users,frame);
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
             P = P*P_T*(0.8+rand()*0.2); % Escalamos de 1-> 18W randomizando, sin tener que llegar a 18W.
             mutatedSolution(limit1:limit2) = P(:)';
         
        end

    elseif strcmp(mutation,'B') 
       
        if (rand < mRate)
            limit1 = 1;
            limit2 = number_cells*frame;
            Ill =  reshape(mutatedSolution(limit1:limit2),number_cells,frame);
            
            % Illumination per user:
            Ill_u=(UpC'*Ill);
        
                 
            %% Se mantiene P en mutatedSolution
            % No change required as mutatedSolution = solution already.
            
           
            %% Se muta B de forma aleatoria
            limit1 = number_cells*frame+1;
            limit2 = number_cells*frame + n_users*b_slots*frame;
            B = zeros(n_users,b_slots,frame);
            for f = 1:frame
                    % Asignamos banda en base a [Ill]
                    users = sum(Ill_u(:,f),1);
                    pos = find(Ill_u(:,f))';
                    % Se calculan los usuarios adyacentes que deben ser considerados en base a la iluminacion (si hay dos adyacentes que no se iluminan a la vez, da igual!)
                    adjacent_for_illumination=(Ill_u(:,f).*Adj_u);
                    adjacent_for_illumination_total=sum(Ill_u(:,f).*Adj_u,1); %==Ill_u(:,f)'*Adj_u
                    for u = 1:users
                        %Calculamos un porcentaje de banda para el primer usuario en función de la adyacencia de iluminación en cada instante (frame)! 
                        percentage=randi(b_slots);%floor(b_slots/adjacent_for_illumination_total(pos(u))); 
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
            mutatedSolution(limit1:limit2) = B(:)';
        
        end
   
    else 
        error(strcat(['Invalid mutation operator: ', mType]));   
    end
end

