# NSGA-II-based-Satellite-Beam-Hopping-BH-Algorithm

This code is © Samuel M. Zamacola and Francisco Luna Valero, 2025, and it is made available under the GPL license enclosed with the software.

Over and above the legal restrictions imposed by this license, if you use this software for an academic publication then you are obliged to provide proper attribution to the paper that describes it:
+ S. M. Zamacola, F. L. Valero and R. M. Rodríguez-Osorio, ‘Hybrid MOEA with problem-specific operators for beam-hopping based resource allocation in multi-beam LEO Satellites’, .....

Additionally as the software is based in PlaEMO, for research and educational purposes, the following reference must be acknowledged:
+ Ye Tian, Ran Cheng, Xingyi Zhang, and Yaochu Jin, PlatEMO: A MATLAB Platform for Evolutionary Multi-Objective Optimization [Educational Forum], IEEE Computational Intelligence Magazine, 2017, 12(4): 73-87

DEF.: "The NSGA-II based BH algorithm is an enhaced multi-objective genetic algorithm (GA) algorithm where illumination scheduling (BH) and resource allocation (bandwind+power) is performed in response to users' distribution and traffic demand, featuring specialized initialization, crossover, mutation, and hybrid local search operators. The overall flowchart is presented in Simulation_Flow.pdf. The diagram is divided in two parts: pre-computation modules to ease the assignment of resources and the calculation of the parameters of interest (PoI): UC/EC/TTS, and the BH algorithm to dynamically calculate illumination [Ill], power [P] and bandwidth [B] for each time slot. For more information, check the reference paper."

 
* INPUT: satellite altitude (h_sat), minimum elevation angle (el_min), number of rings within the satellite's FoV (rings), frequency (f), total ilumination slots (frame), slot duration (frame_dur), number of colours (colours), simultaneous beams (beams), ilumination weighting factor (TTL), number of users (n_users), distribution of users (traffic_model): random/linear/hotspot, cell scenario (cell_scenario_model): fixed/variable, total RF power (P_T), total bandwidth per colour (BW_T).

 
* OUTPUT (FoM): Unserved Capacity (UC), Extra Served Capacity (EC), Time To Serve (TTS).
 
Included Files:
 
+ User class (u.m): Each user is characterized by a given location, a type of station, a given traffic demand and
counts at UE level with some gain and noise characteristics. These are the static attributes of
the class, but there are other attributes that are going to be dynamically computed through
methods based on these prior attributes. Depending on the subsatellite point location and the
position of the satellite the following parameters are calculated: the slant range, the elevation
angle from the UE to the satellite, and the nadir angles, with respect to the satellite, and relative
to its cell center. Dynamic attributes, those that are going to be filled in each frame iteration and
therefore are time dependent, are used to store the intermediate and output variables of the
iteration. These are: assigned power and bandwidth resources for link budget computation, C/N
which is link budget’s output, and then served, pending and extra traffic counters.
 
+ Cell class (c.m): Cells are labelled by a given identifier or cell number, count with a given center and have a
radius that is going to be dependant of the total footprint area and the number of chosen rings.
Cell objects will include a position based computed attribute in which the user objects presented
above are stored. This is where the composition property comes into action, as cells count with
users located within their area, and the organisation of these is much simpler by incorporating
a list of user objects, if any, in each of the cells. Additionally, the nadir angle from the cell centre
and the list of interfering cells is computed based on the initial scheme. During each frame
iteration the aggregated traffic requirement is calculated based on the user list within the given
cell. Based on the cells that are selected for illumination, these are going to be classified in each
time instant as active or inactive. If that is the case, the aggregated power and bandwidth
resources assigned at cell level are computed. In case the cell is active, the assigned colour is
also stored as a dynamic attribute.
 
+ MultiObjectiveFunction.m: the executable file where BH algorithm is executed. 1) Instance Generation. 2) BH Population Initialization. 3)  NSGA-II BH Calculation. 4) DB BH Calculation. 5) Instance Result Saving.

  +1) loadSmall.m // loadLarge.m: 1) Instance Genenation. Input parameters are defined for each type of scenario and the respective parameter pre-computation is performed (traffic_model->Traffic_Distribution, cell_scenario_model->Cell_Scenario).
 
    + Traffic_Distribution.m: based on the selected user distribution type, the generation of users is performed in the file, by defining UE related specifications.
 
    + Cell_Scenario.m: based on the number of rings that are intended to be allocated within the satellite's FoV, cells are generated in the file.

  +2)  DB_PopulationInitialization.m: Demand-based BH algorithm is executed to include the solution as the first solution in NSGA-II population initialization. The rest of the population is generated in a controlled manner, by fixing first the cells that are chosen for illumination and then adjusting bandwidth and power matrices randomly, but in a controlled manner, complying with the defined constraints.
 
  +2) PopulationInitialization.m: Random population initialization. The entire population is randomly generated, by fixing first the cells that are chosen for illumination and then adjusting bandwidth and power matrices randomly, but in a controlled manner, complying with the defined constraints.
 
  +3) OperatorGA.m: It creates a new solution representation for the BH problem (type 6). The LEO function directly calls the crossover operator, as described in the paper, and then executes the mutation and local search (dB) operators with a given rate. if dbRate = 0, then a non-hybrid, canonical version of NSGA-II is considered.

  The mutation operator is implemented in MutationLEO.m, which receives a tentative solutions and perform the modifications in the B, P and Ill matrices. Analogously, DB_Local.m implements the db operator described in the paper.

    + MultiObjectiveFunction.m: Evaluation of a given illumination [Ill] and resource allocation ([B] and [P]) solution. 
 
      + FOM_calculation_optimization_based.m: For a gicen solution, calculation of FoM: EC, UC, TTS.
 
      + Single_Objective_Constraints.m: For a fiven solution, the constraint fulfillment is verified.

  +4) FOM_calculation_demand_based_band_slots.m: Execution of the Demand-based (DB) BH algorithm, for comparative purposes. For each time slot, cell illumination [Ill], resource allocation ([B] and [P]) and link budget calculations are performed, determining the FoM: EC, UC, TTS. 

  +5)  'NSGA_II_[', instance,'_', num2str(scenario), ']_result_','MAXFEs', num2str(maxFEs), '.P',num2str(popSize),'.i',init,'.cR', num2str(c_rate_LEO),'.mType', m_type_LEO,'.mRate', num2str(m_rate_LEO),'.lsType', ls_type, '.lsRate',num2str(ls_rate),'.users', num2str(n_users),'.r',num2str(run),'.mat': Instance result saving (NSGA-II + DB).
  
NOTE: Demand-based (DB) BH algorithm is available at: https://github.com/samuelmartinezupm/Demand-based-Satellite-Beam-Hopping-BH-Algorithm 

## Contact
For questions, issues, or contributions, please contact Samuel M. Zamacola at samuel.martinez@upm.es.
