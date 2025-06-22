function [pt,mc]=estadistico(X, num_X)
%[salida, pt, lp]=
%[X, num_X]=leerdatos();
%[i,j]=size(X);
%if i==num_X
%	X=X';
%elseif j~=num_X
%	disp('ERROR en estadistico');
%else
	Datos=[];
	salida=0;
	for i=1:num_X
		Datos=[Datos; X{i}', i*ones(length(X{i}),1)];
		if std(X{i}) == 0.0
			X{i}(1) = X{i}(1)+ 0.01;
		end
		[h(i),p(i),sstats(i),cv(i)]=kstest((X{i}-mean(X{i}))/std(X{i}));
		%[sstats(i),p(i),h(i)]=shapirowilks(X{i}',0,0.05);

		salida=salida+h(i);
	end
        lp=Levenetest(Datos);
	if salida>0
		if salida<num_X
			%salida
			%disp('Algunos datos no son normales y otros si');
			[pt, anovatab, stats]=kruskalwallis(Datos(:,1), Datos(:,2),'off');
		else
			%disp('No es normal');
			[pt, anovatab, stats]=kruskalwallis(Datos(:,1), Datos(:,2),'off');
		end
	else
        if (lp >= 0.05)
		%disp('Es normal');
		[pt, anovatab, stats]=anova1(Datos(:,1), Datos(:,2),'off');
               
	else
		
		[pt, anovatab, stats]=kruskalwallis(Datos(:,1), Datos(:,2),'off');
	end
        end
	%pt
	%if (pt>=0.05)
		%disp('Las medias son iguales');
	%else
		%disp('Las medias son distintas');
	%end
	%lp
	if (lp>=0.05)
		%disp('Hay igualdad de varianzas');
		mc=multcompare(stats,0.05,'off', 'bonferroni');
	else
		%disp('No hay igualdad de varianzas');
		%disp('No se puede usar bonferroni');
		mc=multcompare(stats,0.05,'off');
	end

%end
close all
