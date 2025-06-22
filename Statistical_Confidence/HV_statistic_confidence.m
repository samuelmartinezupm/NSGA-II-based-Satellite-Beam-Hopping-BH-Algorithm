clear all
clc
close all

PWD=pwd;
addpath (PWD)

% Select MOEA:
MOEA='NSGA_II';%'SMSEMOA';%'MOEAD'; %'

Results_Path = [PWD, filesep, 'HV_random_files_', MOEA];
addpath (Results_Path)

Statistic_Functions = fullfile(PWD, 'matlab');
addpath (Statistic_Functions_Path)

% CONFIG:

population=100;
users=50;

inits={'DB'};
MAXFEs=[100000];
DBRates=[0 0.01, 0.1, 0.2, 0.3]; 
mRates=[0.1, 0.5];
cRs=[0.8, 1.0];

for scenario=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30]
    file_name = strcat('preliminary_ST_',MOEA,'_S',num2str(scenario),'.eps');
    arg_names={};
    n_args=1;
    
    for MAXFE=MAXFEs
        for init=inits
            for DBRate=DBRates
                for cR=cRs
                    for mRate=mRates
                        args{n_args}=strcat('[large_',num2str(scenario),']_HV_MAXFE',num2str(MAXFE),'.P',num2str(population),'.iDB.cR',num2str(cR),'.mTyperandomOperator.mRate',num2str(mRate),'.lsTyperandomOperator.lsRate',num2str(DBRate),'.users',num2str(users),'.txt');
                        arg_names{n_args}=strcat('cR',num2str(cR),'-mR',num2str(mRate),'-dbR',num2str(DBRate));
                        n_args=n_args+1;
                    end
                end
            end
        end
    end
    
    % Execute Statistic Functions:
    cd(Main_Path)
    [pt,mc]=statistics(args{:}); 
    chessmat(signifmat(mc),file_name,10,1,1)


    % Change L{X} Names:
    % Define the file path of the EPS file
    inputFile = file_name;
    outputFile = strcat('ST_',MOEA,'_S',num2str(scenario),'.eps');

    % Read the .eps file content
    fileID = fopen(inputFile, 'r');
    epsContent = fread(fileID, '*char')'; % Read as a string
    fclose(fileID);
    
    % Replace L{X} labels:
    for i=length(args):-1:1
        epsContent = strrep(epsContent, strcat('L',num2str(i)), arg_names{i});%['(' newL1 ')']
    end
    
    % Save the updated content to a new file
    fileID = fopen(outputFile, 'w');
    fwrite(fileID, char(epsContent), 'char');
    fclose(fileID);
    
    disp(['Updated EPS file saved as: ', outputFile]);

    delete(file_name)
end      