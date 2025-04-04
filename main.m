clear all
clc
close all

global B_T;
global b_slots;
global P_T;
global UpC;
global c_scenario;
global n_users;
global number_cells;
global theta;
global colours;
global frame;
global frame_dur;
global freq;
global Adj_u;
global beams;
global c_rate_LEO;
global m_type_LEO;
global m_rate_LEO;

init='DB'; %probar también init='DB';
instance='large';
maxFEs=100000;
popSize=1000;

% Tasas seleccionadas:
c_rate=0.9;
m_type='B';
m_rate=0.1;

n_scenarios=50; % Monte Carlo.
n_runs=30; % Confianza Estadística. ¿Suficiente?
user_steps=[10, 20, 30, 40, 50, 60, 70, 80, 90, 100];

UC=zeros(length(user_steps),n_runs,n_scenarios);
EC=zeros(length(user_steps),n_runs,n_scenarios);
TTS=zeros(length(user_steps),n_runs,n_scenarios);
UC_db=zeros(length(user_steps),n_runs,n_scenarios);
EC_db=zeros(length(user_steps),n_runs,n_scenarios);
TTS_db=zeros(length(user_steps),n_runs,n_scenarios);

for scenario=1:n_scenarios
    for run=1:n_scenarios
        for users=user_steps
            users=50;
            [UC(users,run,scenario),EC(users,run,scenario),TTS(users,run,scenario),UC_db(users,run,scenario),EC_db(users,run,scenario),TTS_db(users,run,scenario)]=singleObjectiveMain(instance, scenario, maxFEs, popSize, init, c_rate, m_type, m_rate, run, users)
        end
    end
end
