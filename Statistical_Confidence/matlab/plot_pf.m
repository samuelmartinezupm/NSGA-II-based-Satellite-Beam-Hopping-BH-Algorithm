function f = plot_pf(x1, x2, x3, x4, x5, x6, x7, x8)
    hold on

    data1 = dlmread(x1, ' ');
    data2 = dlmread(x2, ' ');
    data3 = dlmread(x3, ' ');
    data4 = dlmread(x4, ' ');
    data5 = dlmread(x5, ' ');
    data6 = dlmread(x6, ' ');
    data7 = dlmread(x7, ' ');
    data8 = dlmread(x8, ' ');
    
    plot(-data1(:,2),data1(:,1), '*', 'markersize',5);
    plot(-data2(:,2),data2(:,1), '*', 'markersize',5);
    plot(-data3(:,2),data3(:,1), '*', 'markersize',5);
    plot(-data4(:,2),data4(:,1), '*', 'markersize',5);
    plot(-data5(:,2),data5(:,1), '*', 'markersize',5);
    plot(-data6(:,2),data6(:,1), '*', 'markersize',5);
    plot(-data7(:,2),data7(:,1), '*', 'markersize',5);
    plot(-data8(:,2),data8(:,1), '*', 'markersize',5);

    ylabel('Power comsumption')
    xlabel('Capacity')

    %legend('NSGA-II any','NSGA-II full','NSGA-II noUsers','NSGA-II maintenancePower')
    legend('0, 0','0.01, 0.01','0.001, 0','0.01, 0','0.1, 0','0, 0.001','0, 0.01','0, 0.1')
    %legend('SparseEA any','SparseEA full','SparseEA noUsers','SparseEA maintenancePower')
    
    hold off
end