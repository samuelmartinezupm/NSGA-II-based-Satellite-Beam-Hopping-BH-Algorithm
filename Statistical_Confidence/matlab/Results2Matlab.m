function Results2Matlab(run)    
    %fileIDVAR= fopen(strcat('VAR.',string(run)));
    %fileIDOBJ= fopen(strcat('FUN.',string(run)));
    fileIDVAR= fopen(strcat('nsga2.VAR.0'));
    fileIDOBJ= fopen(strcat('nsga2.FUN.0'));
    %read variables
    Varline = fgetl(fileIDVAR);
    C=strsplit(Varline);
    var_line_value = str2double(C(1:end-1));
    VARS=var_line_value;
    while ischar(Varline)
        Varline=fgetl(fileIDVAR);
        C=strsplit(Varline);
        var_line_value = str2double(C(1:end-1));
        VARS=cat(1,VARS,var_line_value);
        Varline = fgetl(fileIDVAR);
    end
    %read objectives
    Objline = fgetl(fileIDOBJ);
    COBJ=strsplit(Objline);
    obj_line_value = str2double(COBJ(1:end));
    OBJS=obj_line_value;
    
    while ischar(Objline)
        Objline=fgetl(fileIDOBJ);
        COBJ=strsplit(Objline);
        obj_line_value = str2double(COBJ(1:end));
        OBJS=cat(1,OBJS,obj_line_value);
        Objline = fgetl(fileIDOBJ);
    end
    %save files
    filename=strcat('SimResults.',int2str(run),'.mat');
    save(filename,'VARS','OBJS');
end


%end

