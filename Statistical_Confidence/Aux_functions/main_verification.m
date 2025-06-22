clear all
clc
close all

%  Optimization-based
 load("[demand_based_band_segregation]data_8beams_1colours.mat","Ill","B","P") % Let's start with demand based results!
 load("c_scenario_test") 
 [RC,SC,UC,EC,TTS]=FOM_calculation_optimization_based(B_T,b_slots, P_T,  Ill, B, P, Adj_c, Adj_u, UpC, c_scenario, n_users, beams, theta, colours, frame, frame_dur, TTL, freq);
 save(strcat('[optimization_based]data_',string(beams),'beams_',string(colours),'colours'),"SC","UC","EC","RC","TTS","Ill", "B", "P")
