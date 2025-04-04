function [users,demand,type,g,T_noise]=Traffic_Distribution(traffic_model, n_users, D_footprint, frequency)
   
    % UNIFORM DISTRIBUTION
    if strcmp(traffic_model,'uniform')
        %n_users=100;
        users=[];
        demand=[];
        antenna_diameter=0.49;  %Starlink
        g=10*log10(0.65*((pi*antenna_diameter/((3*10^8)/frequency)))^2); %dB
        lnb=2; %dB
        T_noise=((10^(lnb/10)-1)*290); %K
        while (size(users,1)<n_users) 
            % Location: gerate values from the uniform distribution on the interval (a, b): r = a + (b-a).*rand(100,1)
            x=-1500 + (3000-0).*rand(1,1);
            y=-1500 + (3000-0).*rand(1,1);
            % Type of station:
            type=1;
            % Ensure generated users are within the satellite's footprint:
            if (sqrt((x-0)^2+(y-0)^2)<=D_footprint/2) 
                users=[users; [x,y]];
                % Demand
                demand=[demand; 0 + (30-0).*rand(1,1)];
            end
        end
        % % Draw
        % figure (2)
        % pgon = nsidedpoly(1000, 'Center',  [0,0], 'Radius', D_footprint/2); % Satellite Footprint
        % plot(pgon, 'FaceColor', 'y');
        % axis equal
        % hold on 
        % for i=1:n_users
        %     u_obj=u(i, users(i,:),type,demand(i),0,0); 
        %     u_obj.draw
        %         hold on
        % end
        % hold off
        % title('Uniform Traffic Distribution')
       
    % HOTSPOT DISTRIBUTION
    elseif strcmp(traffic_model,'hotspot')
        %n_users=8;
        users=[];
        demand=[];
        antenna_diameter=2.5;  %Starlink
        g=10*log10(0.65*((pi*antenna_diameter/((3*10^8)/frequency)))^2); %dB
        lnb=1.5; %dB
        T_noise=((10^(lnb/10)-1)*290); %K
        while (length(users)<n_users)
            % Location
            x=-1500 + (3000-0).*rand(1,1);
            y=-1500 + (3000-0).*rand(1,1);
            % Type of station:
            type=2;
            % Ensure generated users are within the satellite's footprint:
            if (sqrt((x-0)^2+(y-0)^2)<=D_footprint/2) 
                users=[users; [x,y]];
                % Demand
                demand= [demand; 250 + (1000-250).*rand(1,1)];
            end
        end
        % % Draw
        % figure (2)
        % pgon = nsidedpoly(1000, 'Center',  [0,0], 'Radius', D_footprint/2); % Satellite Footprint
        % plot(pgon, 'FaceColor', 'y');
        % axis equal
        % hold on 
        % for i=1:n_users
        %     u_obj=u(i, users(i,:),type,demand(i),0,0); 
        %     u_obj.draw
        %         hold on
        % end
        % hold off
        % title('Hotspot Traffic Distribution')
    
    % LINEAR DISTRIBUTION
    elseif strcmp(traffic_model,'linear')
        %n_users=30;
        users=[];
        demand=[];
        antenna_aperture=1.98*1.19;  %Astronics E-series (600)
        g=10*log10(0.65*(4*pi*antenna_aperture/((3*10^8)/frequency)^2)); %dB        
        lnb=2; %dB
        T_noise=((10^(lnb/10)-1)*290); %K
        %y=mx+n
        m=0.1;
        n1=500;
        n2=-500;
        while (length(users)<n_users)
            % Location
            x=-1500 + (3000-0).*rand(1,1);
            if (mod(length(users),2))
                y=m*x+n1; % Corridor 1.
            else
                y=m*x+n2; % Corridor 2.
            end
            % Type of station:
            type=3;
            % Ensure generated users are within the satellite's footprint:
            if (sqrt((x-0)^2+(y-0)^2)<=D_footprint/2) 
                users=[users; [x,y]];
                % Demand
                demand= [demand; 100 + (200-100).*rand(1,1)];
            end
        end
        % % Draw
        % figure (2)
        % pgon = nsidedpoly(1000, 'Center',  [0,0], 'Radius', D_footprint/2); % Satellite Footprint
        % plot(pgon, 'FaceColor', 'y');
        % axis equal
        % hold on 
        % for i=1:n_users
        %     u_obj=u(i, users(i,:),type,demand(i),0,0); 
        %     u_obj.draw
        %         hold on
        % end
        % hold off
        % title('Linear Traffic Distribution')
    
    % NON OF THE SELECTED ONES
    else
                users=0;
                demand=0;
                type=0;
                g=0;
                lnb=0;
                T_noise=0;
                fprintf('No model loaded!\n')
           
    end

end


