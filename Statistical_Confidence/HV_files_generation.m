clear all
clc
close all

warning('off','all')


% Select MOEA:
MOEA='NSGA_II';%'SMSEMOA';%'MOEAD'; %'

PWD=pwd;
addpath (PWD)

Results_Path = [PWD, filesep, 'HV_random_files_', MOEA];

Data_Path = fullfile(PWD, 'Results');
Function_Path = fullfile(PWD, 'Aux_functions');
Statistic_Functions = fullfile(PWD, 'matlab');

javaPath = 'C:\Program Files\Java\jre1.8.0_431\bin\java.exe';
jarFilePath = fullfile(Function_Path, 'hv.jar');

% Saved RPF:
PWD_acumulado=fullfile(PWD, 'GA_HV_Determination_Java')


addpath (Data_Path)
addpath (Function_Path)

% CONFIG:
population=100;
users=50;

num_objectives=3;

inits={'DB'};
MAXFEs=[100000];
DBRates=[0 0.01, 0.1, 0.2, 0.3];
mRates=[0.1, 0.5];
cRs=[0.8, 1.0];
    
for scenario=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30]
    for MAXFE=MAXFEs
        cd (strcat(Data_Path,'\large.s',num2str(scenario),'.MaxFEs',num2str(MAXFE),'.p',num2str(population)))
        for init=inits
            for DBRate=DBRates
                for cR=cRs
                    for mRate=mRates
                        for run=0:1:29
                            if isfile(char(strcat(MOEA,'_[large_',num2str(scenario),']_result_MaxFEs',num2str(MAXFE),'.P',num2str(population),'.i',init,'.cR',num2str(cR),'.mTyperandomOperator.mRate',num2str(mRate),'.lsTyperandomOperator.lsRate',num2str(DBRate),'.users',num2str(users),'.r',num2str(run),'.mat')))
                                try
                                    fileID_HV = fopen(strcat(Results_Path,'\[large_',num2str(scenario),']_HV_MAXFE',num2str(MAXFE),'.P',num2str(population),'.iDB.cR',num2str(cR),'.mTyperandomOperator.mRate',num2str(mRate),'.lsTyperandomOperator.lsRate',num2str(DBRate),'.users',num2str(users),'.txt'), 'a'); % "w" write y no "a" append para que no se sobrescriba.
                                    load (char(strcat(MOEA,'_[large_',num2str(scenario),']_result_MaxFEs',num2str(MAXFE),'.P',num2str(population),'.i',init,'.cR',num2str(cR),'.mTyperandomOperator.mRate',num2str(mRate),'.lsTyperandomOperator.lsRate',num2str(DBRate),'.users',num2str(users),'.r',num2str(run),'.mat')))
                                    Population.best.objs=objectives;
                                    
                                    % Generate current PF:
                                    fileID = fopen(strcat(PWD,'\frente_actual.txt'), 'w'); 
                                    % Loop over each row of the objectives matrix:
                                    for i = 1:size(objectives, 1)
                                        % Convert the row to a string with spaces separating the values
                                        fprintf(fileID, '%f %f %f\n',  objectives(i,1), objectives(i,2), objectives(i,3));
                                    end
                                    % Close the file
                                    fclose(fileID);
    
                                    % Compute HV:
                                    inputPresentFrontPath = strcat(PWD,'\frente_actual.txt');
                                    inputReferenceFrontPath = strcat(PWD_acumulado,'\acumulado_',num2str(scenario),'.txt.pf');
                                    % Construct the java -jar command:
                                    command = sprintf('"%s" -jar "%s" "%s" "%s" %d', javaPath, jarFilePath,inputPresentFrontPath, inputReferenceFrontPath, num_objectives);
                                    % Execute the command
                                    [status, cmdout] = system(command); 
                                    % Save HV value:
                                    fprintf(fileID_HV, '%f\n', str2double(cmdout));
                                    % Close the file
                                    fclose(fileID_HV);

                                catch

                                end
                            end
                        end
                     end
                end
            end
        end
    end
end




