function [mrmse,rmse] = abdellahall (todospesos, funcion)

    redes = size(todospesos,1);
    
    cv = 5;
    
    mrmse = zeros(1,redes);
    rmse = zeros(cv,redes);
    
    for i=1:redes
        [mrmse(1,i),rmse(:,i)] = abdellaheval(todospesos(i,:),funcion, cv);
    end;
end