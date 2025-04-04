function Offspring = OperatorGA(Problem,Parent,Parameter)
%OperatorGA - Crossover and mutation operators of genetic algorithm.
%
%   Off = OperatorGA(Pro,P) uses genetic operators to generate offsprings
%   for problem Pro based on parents P. If P is an array of SOLUTION
%   objects, then Off is also an array of SOLUTION objects. While if P is a
%   matrix of decision variables, then Off is also a matrix of decision
%   variables, i.e., the offsprings are not evaluated. P is split into two
%   subsets P1 and P2 with the same size, where each object or row of P1
%   and P2 is used to generate two offsprings. Different operators are used
%   for different encoding schemes.
%
%   Off = OperatorGA(Pro,P,{proC,disC,proM,disM}) specifies the parameters
%   of operators, where proC is the probability of crossover, disC is the
%   distribution index of simulated binary crossover, proM is the
%   expectation of the number of mutated variables, and disM is the
%   distribution index of polynomial mutation.
%
%   Example:
%       Offspring = OperatorGA(Problem,Parent)
%       Offspring = OperatorGA(Problem,Parent.decs,{1,20,1,20})
%
%   See also OperatorGAhalf

%------------------------------- Reference --------------------------------
% [1] K. Deb, K. Sindhya, and T. Okabe, Self-adaptive simulated binary
% crossover for real-parameter optimization, Proceedings of the Annual
% Conference on Genetic and Evolutionary Computation, 2007, 1187-1194.
% [2] K. Deb and M. Goyal, A combined genetic adaptive search (GeneAS) for
% engineering design, Computer Science and informatics, 1996, 26: 30-45.
% [3] L. Davis, Applying adaptive algorithms to epistatic domains,
% Proceedings of the International Joint Conference on Artificial
% Intelligence, 1985, 162-164.
% [4] D. B. Fogel, An evolutionary approach to the traveling salesman
% problem, Biological Cybernetics, 1988, 60(2): 139-144.
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
    Offspring = zeros(2*size(Parent1,1),size(Parent1,2));
    Type      = arrayfun(@(i)find(Problem.encoding==i),1:6,'UniformOutput',false);
    if ~isempty([Type{1:2}])    % Real and integer variables
        Offspring(:,[Type{1:2}]) = GAreal(Parent1(:,[Type{1:2}]),Parent2(:,[Type{1:2}]),Problem.lower([Type{1:2}]),Problem.upper([Type{1:2}]),proC,disC,proM*length([Type{1:2}])/size(Parent1,2),disM);
    end
    if ~isempty(Type{3})        % Label variables
        Offspring(:,Type{3}) = GAlabel(Parent1(:,Type{3}),Parent2(:,Type{3}),Problem.lower(Type{3}),Problem.upper(Type{3}),proC,proM*length(Type{3})/size(Parent1,2));
    end
    if ~isempty(Type{4})        % Binary variables
        Offspring(:,Type{4}) = GAbinary(Parent1(:,Type{4}),Parent2(:,Type{4}),proC,proM*length(Type{4})/size(Parent1,2));
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
    Offspring = [(Parent1+Parent2)/2+beta.*(Parent1-Parent2)/2
                 (Parent1+Parent2)/2-beta.*(Parent1-Parent2)/2];
             
    %% Polynomial mutation
    Lower = repmat(lower,2*N,1);
    Upper = repmat(upper,2*N,1);
    Site  = rand(2*N,D) < proM/D;
    mu    = rand(2*N,D);
    temp  = Site & mu<=0.5;
    Offspring       = min(max(Offspring,Lower),Upper);
    Offspring(temp) = Offspring(temp)+(Upper(temp)-Lower(temp)).*((2.*mu(temp)+(1-2.*mu(temp)).*...
                      (1-(Offspring(temp)-Lower(temp))./(Upper(temp)-Lower(temp))).^(disM+1)).^(1/(disM+1))-1);
    temp = Site & mu>0.5; 
    Offspring(temp) = Offspring(temp)+(Upper(temp)-Lower(temp)).*(1-(2.*(1-mu(temp))+2.*(mu(temp)-0.5).*...
                      (1-(Upper(temp)-Offspring(temp))./(Upper(temp)-Lower(temp))).^(disM+1)).^(1/(disM+1)));
end

function Offspring = GAlabel(Parent1,Parent2,lower,upper,proC,proM)
% Genetic operators for label variables

    %% Uniform crossover
    [N,D] = size(Parent1);
    k     = rand(N,D) < 0.5;
    k(repmat(rand(N,1)>proC,1,D)) = false;
    Offspring1    = Parent1;
    Offspring2    = Parent2;
    Offspring1(k) = Parent2(k);
    Offspring2(k) = Parent1(k);
    Offspring     = [Offspring1;Offspring2];
    
    %% Bitwise mutation
    Site = rand(2*N,D) < proM/D;
    Rand = round(unifrnd(repmat(lower,2*N,1),repmat(upper,2*N,1)));
    Offspring(Site) = Rand(Site);
end

function Offspring = GAbinary(Parent1,Parent2,proC,proM)
% Genetic operators for binary variables

    %% Uniform crossover
    [N,D] = size(Parent1);
    k     = rand(N,D) < 0.5;
    k(repmat(rand(N,1)>proC,1,D)) = false;
    Offspring1    = Parent1;
    Offspring2    = Parent2;
    Offspring1(k) = Parent2(k);
    Offspring2(k) = Parent1(k);
    Offspring     = [Offspring1;Offspring2];
    
    %% Bit-flip mutation
    Site = rand(2*N,D) < proM/D;
    Offspring(Site) = ~Offspring(Site);
end

function Offspring = GApermutation(Parent1,Parent2,proC)
% Genetic operators for permutation variables

    %% Order crossover
    [N,D]     = size(Parent1);
    Offspring = [Parent1;Parent2];
    k = randi(D,1,2*N);
    for i = 1 : N
        if rand < proC
            Offspring(i,k(i)+1:end)   = setdiff(Parent2(i,:),Parent1(i,1:k(i)),'stable');
            Offspring(i+N,k(i)+1:end) = setdiff(Parent1(i,:),Parent2(i,1:k(i)),'stable');
        end
    end
    
    %% Slight mutation
    k = randi(D,1,2*N);
    s = randi(D,1,2*N);
    for i = 1 : 2*N
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
    
            Offspring = [Offspring; child1; child2];
            % [x_1_p,f_1_p,g_1_p] = SingleObjectiveFunction(p1);
            % [x_1_c,f_1_c,g_1_c] = SingleObjectiveFunction(child1);
            % 
            % [x_2_p,f_2_p,g_2_p] = SingleObjectiveFunction(p2);
            % [x_2_c,f_2_c,g_2_c] = SingleObjectiveFunction(child2);
            % 
            % fprintf('parent1: %.4f; child1: %.4f \n',f_1_p,f_1_c);
            % fprintf('parent2: %.4f; child2: %.4f \n',f_2_p,f_2_c);
else
            Offspring = [Offspring; p1; p2];
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