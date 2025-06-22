longitud=3;
L=17*5;
nombre_corto='Knapsack';
nombre_inicial='NSK';
nombre='Dynamic 0/1 Knapsack Problem';
[f, basura]=fopen([nombre_corto,'.tex'],'a');
cabezera(f);
TMss_e=zeros(11,25);
TMss_s=zeros(11,25);
TMss_r=zeros(11,25);
TMge_e=zeros(11,25);
TMge_s=zeros(11,25);
TMge_r=zeros(11,25);
TMce_e=zeros(11,25);
TMce_s=zeros(11,25);
TMce_r=zeros(11,25);
borra=0;
%for iaux=[1:2:31 50 100 150 200]
for iaux=1:2:31
    iaux
	%borra=(iaux+1)/2;
	borra=borra+1;
    fprintf(f,'\\subsection{Cambio a las %i generaciones}\n',iaux);
	for i=1:25
		[iaux i]
		[M_ss{i}]=leerdatos(i,'ss',iaux);
	    [M_gen{i}]=leerdatos(i,'gen',iaux);
	    [M_cel{i}]=leerdatos(i,'cel',iaux);
		Media_ss=M_ss{i};
		auxiliar=mean(Media_ss);
		Mess_e{i}=auxiliar(1);
		Mess_s{i}=auxiliar(2);
		Mess_r{i}=auxiliar(3);
		TMss_e(borra,i)=auxiliar(1);
		TMss_s(borra,i)=auxiliar(2);
		TMss_r(borra,i)=auxiliar(3);
		Media_gen=M_gen{i};
	    auxiliar=mean(Media_gen);
    	Mege_e{i}=auxiliar(1);
	    Mege_s{i}=auxiliar(2);
    	Mege_r{i}=auxiliar(3);
		TMge_e(borra,i)=auxiliar(1);
		TMge_s(borra,i)=auxiliar(2);
		TMge_r(borra,i)=auxiliar(3);
		Media_cel=M_cel{i};
    	auxiliar=mean(Media_cel);
	    Mece_e{i}=auxiliar(1);
    	Mece_s{i}=auxiliar(2);
	    Mece_r{i}=auxiliar(3);
		TMce_e(borra,i)=auxiliar(1);
		TMce_s(borra,i)=auxiliar(2);
		TMce_r(borra,i)=auxiliar(3);
		E={Media_ss(:,1)', Media_gen(:,1)', Media_cel(:,1)'};
		[salida_e{i}, pt_e{i}, lp_e{i}, M_e{i}]=sacarest(E,longitud);
		E={Media_ss(:,2)', Media_gen(:,2)', Media_cel(:,2)'};
		[salida_s{i}, pt_s{i}, lp_s{i}, M_s{i}]=sacarest(E,longitud);
		E={Media_ss(:,3)', Media_gen(:,3)', Media_cel(:,3)'};
		[salida_r{i}, pt_r{i}, lp_r{i}, M_r{i}]=sacarest(E,longitud);
	end
	fprintf(f,'Los datos finales estan el las tablas siguientes (Figura \\ref{fig:a_p_%s_%i}):\n',nombre_inicial, borra);
	caption='Measures for different mutation rates in NS-Knapsack for frequency of change of one generations';
	label=['fig:a_p_NSK_' num2str(iaux)];
	dato1=[TMss_e(borra,:); TMge_e(borra,:); TMce_e(borra,:)];
	dato2=[TMss_s(borra,:); TMge_s(borra,:); TMce_s(borra,:)];
	dato3=[TMss_r(borra,:); TMge_r(borra,:); TMce_r(borra,:)];
	figura(f, caption, label ,{dato1', dato2', dato3'}, iaux);
	graficos(TMss_e, TMge_e, TMce_e, TMss_s, TMge_s, TMce_s, TMss_r, TMge_r, TMce_r, borra, iaux, nombre_corto);
	fprintf(f,'\n \\newpage \n');
	%for jaux=1:length(M_e)
	%	jaux
	%	M_e{jaux}
	%	disp('s')
	%	M_s{jaux}
	%	disp('r')
	%	M_r{jaux}
	%end
end
fprintf(f,'\\end{document}');
fclose(f);
%cambio=[1:2:31 50 100 150 200];
cambio=1:2:31
for (jaux=1:25)
    f1=figure;
    %p=plot(cambio,[TMss_e(:,jaux)'; TMge_e(:,jaux)'; TMce_e(:,jaux)']);
    p1=plot(cambio, TMss_e(:,jaux)');
    set(get(gca,'XLabel'),'String','frequency of change','FontSize',20);
    set(get(gca,'YLabel'),'String','Accuracy measure','FontSize',20);
    hold on;
    p2=plot(cambio, TMge_e(:,jaux)','--');
    p3=plot(cambio, TMce_e(:,jaux)','-.');
    set(p3,'LineWidth',2);
    set(gca,'FontSize',14);
    l=legend(gca,'ssGA','genGA','cGA',4);
    set(l,'FontSize',14);
    axis([0 205 0.6 1])
    print(f1, '-depsc',['/home/ixuser6/Cambio_dinamico/eps/' nombre_corto '_cambio_exactitud_' num2str(jaux)]);
    close(f1);
    f1=figure;
    p1=plot(cambio, TMss_s(:,jaux)');
    set(get(gca,'XLabel'),'String','frequency of change','FontSize',20);
    set(get(gca,'YLabel'),'String','Stability measure','FontSize',20);
    hold on;
    p2=plot(cambio, TMge_s(:,jaux)','--');
    p3=plot(cambio, TMce_s(:,jaux)','-.');
    set(p3,'LineWidth',2);
    set(gca,'FontSize',14);
    l=legend(gca,'ssGA','genGA','cGA',1);
    set(l,'FontSize',14);
    axis([0 205 0 0.07])
    print(f1, '-depsc',['/home/ixuser6/Cambio_dinamico/eps/' nombre_corto '_cambio_estabilidad_' num2str(jaux)]);
    close(f1);
    f1=figure;
    p1=plot(cambio, TMss_r(:,jaux)');
    set(get(gca,'XLabel'),'String','frecuency of change','FontSize',20);
    set(get(gca,'YLabel'),'String','Reactivity measure','FontSize',20);
    hold on;
    p2=plot(cambio, TMge_r(:,jaux),'--');
    p3=plot(cambio, TMce_r(:,jaux),'-.');
    set(p3,'LineWidth',2);
    set(gca,'FontSize',14);
    l=legend(gca,'ssGA','genGA','cGA',1);
    set(l,'FontSize',14);
    axis([0 205 1 2.6])
    print(f1, '-depsc',['/home/ixuser6/Cambio_dinamico/eps/' nombre_corto '_cambio_reaccion_' num2str(jaux)]);
    close(f1);
end
