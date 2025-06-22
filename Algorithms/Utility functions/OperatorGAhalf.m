function Offspring = OperatorGAhalf(Problem,Parent,Parameter)
%OperatorGAhalf - Crossover and mutation operators of genetic algorithm.
%
%   This function is the same to OperatorGA, while only the first half of
%   the offsprings are evaluated and returned.
%
%   See also OperatorGA

%------------------------------- Copyright --------------------------------
% Copyright (c) 2023 BIMK Group. You are free to use the PlatEMO for
% research purposes. All publications which use this platform or any code
% in the platform should acknowledge the use of "PlatEMO" and reference "Ye
% Tian, Ran Cheng, Xingyi Zhang, and Yaochu Jin, PlatEMO: A MATLAB platform
% for evolutionary multi-objective optimization [educational forum], IEEE
% Computational Intelligence Magazine, 2017, 12(4): 73-87".
%--------------------------------------------------------------------------

    if nargin > 2
        [proC,disC,proM,disM] = deal(Parameter{:});
    else
        [proC,disC,proM,disM] = deal(1,20,1,20);
    end
    if isa(Parent(1),'SOLUTION')
        evaluated = true;
        Parent    = Parent.decs;
    else
        evaluated = false;
    end
    Parent1   = Parent(1:floor(end/2),:);
    Parent2   = Parent(floor(end/2)+1:floor(end/2)*2,:);
    Offspring = zeros(size(Parent1,1),size(Parent1,2));
    Type      = arrayfun(@(i)find(Problem.encoding==i),1:6,'UniformOutput',false);
    if ~isempty([Type{1:2}])    % Real and integer variables
        Offspring(:,[Type{1:2}]) = GAreal(Parent1(:,[Type{1:2}]),Parent2(:,[Type{1:2}]),Problem.lower([Type{1:2}]),Problem.upper([Type{1:2}]),proC,disC,proM,disM);
    end
    if ~isempty(Type{3})        % Label variables
        Offspring(:,Type{3}) = GAlabel(Parent1(:,Type{3}),Parent2(:,Type{3}),proC,proM);
    end
    if ~isempty(Type{4})        % Binary variables
        Offspring(:,Type{4}) = GAbinary(Parent1(:,Type{4}),Parent2(:,Type{4}),proC,proM);
    end
    if ~isempty(Type{5})        % Permutation variables
        Offspring(:,Type{5}) = GApermutation(Parent1(:,Type{5}),Parent2(:,Type{5}),proC);
    end
    if ~isempty(Type{6})        % LEO variables
        Offspring(:,Type{6}) = LEO(Parent1(:,[Type{6}]),Parent2(:,[Type{6}]),proC,disC,proM,disM);
    end
    if evaluated
        Offspring = Problem.Evaluation(Offspring);
    end
end

function Offspring = GAreal(Parent1,Parent2,lower,upper,proC,disC,proM,disM)
% Genetic operators for real and integer variables

    %% Simulated binary crossover
    [N,D] = size(Parent1);
    beta  = zeros(N,D);
    mu    = rand(N,D);
    beta(mu<=0.5) = (2*mu(mu<=0.5)).^(1/(disC+1));
    beta(mu>0.5)  = (2-2*mu(mu>0.5)).^(-1/(disC+1));
    beta = beta.*(-1).^randi([0,1],N,D);
    beta(rand(N,D)<0.5) = 1;
    beta(repmat(rand(N,1)>proC,1,D)) = 1;
    Offspring = (Parent1+Parent2)/2+beta.*(Parent1-Parent2)/2;
             
    %% Polynomial mutation
    Lower = repmat(lower,N,1);
    Upper = repmat(upper,N,1);
    Site  = rand(N,D) < proM/D;
    mu    = rand(N,D);
    temp  = Site & mu<=0.5;
    Offspring       = min(max(Offspring,Lower),Upper);
    Offspring(temp) = Offspring(temp)+(Upper(temp)-Lower(temp)).*((2.*mu(temp)+(1-2.*mu(temp)).*...
                      (1-(Offspring(temp)-Lower(temp))./(Upper(temp)-Lower(temp))).^(disM+1)).^(1/(disM+1))-1);
    temp = Site & mu>0.5; 
    Offspring(temp) = Offspring(temp)+(Upper(temp)-Lower(temp)).*(1-(2.*(1-mu(temp))+2.*(mu(temp)-0.5).*...
                      (1-(Upper(temp)-Offspring(temp))./(Upper(temp)-Lower(temp))).^(disM+1)).^(1/(disM+1)));
end

function Offspring = GAlabel(Parent1,Parent2,proC,proM)
% Genetic operators for label variables

    %% Uniform crossover
    [N,D] = size(Parent1);
    k     = rand(N,D) < 0.5;
    k(repmat(rand(N,1)>proC,1,D)) = false;
    Offspring    = Parent1;
    Offspring(k) = Parent2(k);
    
    %% Bitwise mutation
    Site = rand(N,D) < proM/D;
    Rand = randi(D,N,D);
    Offspring(Site) = Rand(Site);
    
    %% Repair
    for i = 1 : N
        Off = zeros(1,D);
        while ~all(Off)
            x = find(~Off,1);
            Off(Offspring(i,:)==Offspring(i,x)) = max(Off) + 1;
        end
        Offspring(i,:) = Off;
    end
end

function Offspring = GAbinary(Parent1,Parent2,proC,proM)
% Genetic operators for binary variables

    %% Uniform crossover
    [N,D] = size(Parent1);
    k     = rand(N,D) < 0.5;
    k(repmat(rand(N,1)>proC,1,D)) = false;
    Offspring    = Parent1;
    Offspring(k) = Parent2(k);
    
    %% Bit-flip mutation
    Site = rand(N,D) < proM/D;
    Offspring(Site) = ~Offspring(Site);
end

function Offspring = GApermutation(Parent1,Parent2,proC)
% Genetic operators for permutation variables

    %% Order crossover
    [N,D]     = size(Parent1);
    Offspring = Parent1;
    k         = randi(D,1,N);
    for i = 1 : N
        if rand < proC
            Offspring(i,k(i)+1:end) = setdiff(Parent2(i,:),Parent1(i,1:k(i)),'stable');
        end
    end
    
    %% Slight mutation
    k = randi(D,1,N);
    s = randi(D,1,N);
    for i = 1 : N
        if s(i) < k(i)
            Offspring(i,:) = Offspring(i,[1:s(i)-1,k(i),s(i):k(i)-1,k(i)+1:end]);
        elseif s(i) > k(i)
            Offspring(i,:) = Offspring(i,[1:k(i)-1,k(i)+1:s(i)-1,k(i),s(i):end]);
        end
    end
end

function Offspring = LEO(Parent1,Parent2,cType, cRate, mType, mRate)
    % Genetic operators for LEO problem
    global b_slots;
    global n_users;
    global number_cells;
    global frame;
    global c_rate_LEO;
    global m_type_LEO;
    global m_rate_LEO;
    global ls_type_LEO;
    global ls_rate_LEO;


    %% LEO customized crossover
    [N,D] = size(Parent1);

    Offspring = [];

    for i = 1:N
        p1 = Parent1(i,:);
        p2 = Parent2(i,:);
        if rand < c_rate_LEO

            % Exchange up to 10% frames randomly
            numberExchangedFrames = randi([1 frame]);
            %numberExchangedFrames = 1;
            exchangedFrames = randperm(frame);
    
            %% Ilumination
            limit1 = 1;
            limit2 = number_cells*frame;
            Ill_p1 = reshape(p1(limit1:limit2),number_cells,frame);
            Ill_p2 = reshape(p2(limit1:limit2),number_cells,frame);
    
            % Copy Ills 
            Ill_c1 = Ill_p1;
            Ill_c2 = Ill_p2;
    
            % Exchange the random frames
            for f = 1:numberExchangedFrames
                chosenFrame = exchangedFrames(f);
                aux = Ill_c1(:,chosenFrame);
                Ill_c1(:,chosenFrame) = Ill_c2(:,chosenFrame);
                Ill_c2(:,chosenFrame) = aux;
            end
            
            %% Bandwidth
    
            limit1 = limit2+1;
            limit2 = number_cells*frame + n_users*b_slots*frame;
            B_p1 = reshape(p1(limit1:limit2),n_users,b_slots,frame);
            B_p2 = reshape(p2(limit1:limit2),n_users,b_slots,frame);
    
            B_c1 = B_p1;
            B_c2 = B_p2;
    
            for f = 1:numberExchangedFrames
                chosenFrame = exchangedFrames(f);
                aux = B_c1(:,:,chosenFrame);
                B_c1(:,:,chosenFrame) = B_c2(:,:,chosenFrame);
                B_c2(:,:,chosenFrame) = aux;
    
            end
    
        
            %% Power
            limit1 = limit2+1;
            limit2 = number_cells*frame + n_users*b_slots*frame+n_users*frame;
            P_p1 = reshape(p1(limit1:limit2),n_users,frame);
            P_p2 = reshape(p2(limit1:limit2),n_users,frame);
    
            % Copy Ills 
            P_c1 = P_p1;
            P_c2 = P_p2;
    
            % Exchange the random frames
            for f = 1:numberExchangedFrames
                chosenFrame = exchangedFrames(f);
                aux = P_c1(:,chosenFrame);
                P_c1(:,chosenFrame) = P_c2(:,chosenFrame);
                P_c2(:,chosenFrame) = aux;
            end
            
            % Append children to the optput value after mutation
            child1 = [Ill_c1(:)', B_c1(:)',P_c1(:)'];
            child2 = [Ill_c2(:)', B_c2(:)',P_c2(:)'];
    
            if rand < 0.5
                Offspring = [Offspring; child1];
            else
                Offspring = [Offspring; child2];
            end

            % [x_1_p,f_1_p,g_1_p] = SingleObjectiveFunction(p1);
            % [x_1_c,f_1_c,g_1_c] = SingleObjectiveFunction(child1);
            % 
            % [x_2_p,f_2_p,g_2_p] = SingleObjectiveFunction(p2);
            % [x_2_c,f_2_c,g_2_c] = SingleObjectiveFunction(child2);
            % 
            % fprintf('parent1: %.4f; child1: %.4f \n',f_1_p,f_1_c);
            % fprintf('parent2: %.4f; child2: %.4f \n',f_2_p,f_2_c);
        else
            %Offspring = [Offspring; p1; p2];
            
            if rand < 0.5
                Offspring = [Offspring; p1];
            else
                Offspring = [Offspring; p2];
            end
        end
        
    end

    for i = 1:size(Offspring,1)
        %[x_1,f_1,g_1] = SingleObjectiveFunction(Offspring(i,:));
        Offspring(i,:) = MutationLEO(Offspring(i,:),m_type_LEO, m_rate_LEO);
        %[x_2,f_2,g_2] = SingleObjectiveFunction(Offspring(i,:));
        %fprintf('Before mutation: %.4f; After mutation: %.4f \n',f_1,f_2);
    end

    for i = 1:size(Offspring,1)
        %[x_1,f_1,g_1] = SingleObjectiveFunction(Offspring(i,:));
        Offspring(i,:) = DB_LocalSearch(Offspring(i,:),ls_type_LEO, ls_rate_LEO);
        %[x_2,f_2,g_2] = SingleObjectiveFunction(Offspring(i,:));
        %fprintf('Before mutation: %.4f; After mutation: %.4f \n',f_1,f_2);
    end
    
end