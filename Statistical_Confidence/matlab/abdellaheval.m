function [Y,P] = abdellaheval (pesos, funcion, cv)

    min1=min(funcion(:,1));
    max1=max(funcion(:,1));
    min2=min(funcion(:,2));
    max2=max(funcion(:,2));
    
    n = size(funcion,1);
    fold = floor (n/cv);
    
    net = newff([min1 max1; min2 max2],[9 1],{'logsig','purelin'});
    
    net.iw{1,1} = [pesos(1,11:19); pesos(1,20:28)]';
    net.lw{2,1} = pesos(1,29:37);
    net.b{1} = pesos(1,1:9)';
    net.b{2} = pesos(1,10);
    
    perf = zeros(cv,1);
    
    for i=0:(cv-1)
        patrones = funcion(fold*i+(1:fold),:)';
        [sal,x,y,E,perf(i+1)] = sim(net,patrones(1:2,:),[],[],patrones(3,:));
    end;
    
    P = sqrt(perf);
    Y = mean (P);
    
end