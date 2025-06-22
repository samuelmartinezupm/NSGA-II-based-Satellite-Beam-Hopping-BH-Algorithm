function chessmat(mat, file, lado, shape, show)

fid = fopen(file,'w');

if (nargin <= 4)
    show=0;
end

if (nargin <= 3)
    shape = 0;
end

if (nargin <= 2)
    lado =10;
end

% Para 4 algoritmos solo canonicos -> 120
% Para los 16, sin combinaciones -> 130

fprintf(fid,'%%%%!PS-Adobe-3.0 EPSF-3.0\n');
fprintf(fid,'%%%%BoundingBox: -130 -1 %d %d\n', [lado*size(mat,2)+1, lado*size(mat,1)+130]);
fprintf(fid,'%%%%Title: %s\n',file);
fprintf(fid,'%%%%Creator: Francisco Chicano\n');
fprintf(fid,'%%%%Pages: 1\n');
fprintf(fid,'%%%%EndComments\n');
fprintf(fid,'%%%%Page: 1 1\n');
fprintf(fid,'%%%%BeginDocument: %s\n',file);
fprintf(fid,'/lado %d def\n',lado);
fprintf(fid,'/rell 0.70 def\n');
fprintf(fid,'/nrell 1 rell sub 2 div def\n');
fprintf(fid,'/filas %d def\n',[size(mat,1)]);
fprintf(fid,'/cols %d def\n',[size(mat,2)]);
if (shape == 1)
	fprintf(fid,'/trgup {newpath 3 1 roll moveto dup 0 rlineto dup 2 div neg exch rlineto closepath fill} def\n');
	fprintf(fid,'/trgdown {newpath 3 1 roll moveto dup 0 exch rmoveto dup 0 rlineto neg dup 2 div exch rlineto closepath stroke} def\n');
	fprintf(fid,'/celdaup {lado mul exch lado mul exch lado nrell mul add exch lado nrell mul add exch lado rell mul trgup} def\n');
	fprintf(fid,'/celdadown {lado mul exch lado mul exch lado nrell mul add exch lado nrell mul add exch lado rell mul trgdown} def\n');
else
	fprintf(fid,'/box {newpath 3 1 roll moveto dup 0 rlineto dup 0 exch rlineto neg 0 rlineto closepath fill} def\n');
	fprintf(fid,'/celdaup {lado mul exch lado mul exch lado nrell mul add exch lado nrell mul add exch lado rell mul box} def\n');
	fprintf(fid,'/celdadown {celdaup} def\n');
end

if (show == 1)
	fprintf(fid,'/escalon {exch dup 0 rlineto exch dup 0 exch rlineto} def\n');
	fprintf(fid,'/stair {1 1 3 2 roll {pop escalon} for pop pop} def\n');
	fprintf(fid,'/rightshow {dup stringwidth pop 4 -1 roll exch sub 3 -1 roll moveto show} def\n');
	fprintf(fid,'%% Escalera\n');
	fprintf(fid,'newpath\n');
	fprintf(fid,'0 lado moveto\n');
	fprintf(fid,'lado lado filas 1 sub stair\n');
	fprintf(fid,'0 filas lado mul lineto\n');
	fprintf(fid,'closepath\n');
	fprintf(fid,'stroke\n');

end

for i=1:size(mat,1)
	for j=1:size(mat,2)
		if (show == 0 || (show < 0 && j >= i) || (show > 0 && j <= i))
			if (mat(i,j)>0)
				fprintf(fid,'%d %d celdadown\n',[j-1, i-1]);
			elseif (mat(i,j)<0)
				fprintf(fid,'%d %d celdaup\n',[j-1, i-1]);
			end
		end
	end
end

fprintf(fid,'%d %d celdaup\n',[size(mat,1)+1,size(mat,2)+1]);

if (show == 1)

	fprintf(fid,'%% Texto\n');
	fprintf(fid,'/Helvetica findfont lado scalefont setfont\n');
	for i=1:(size(mat,1)-1)
		fprintf(fid,'-1 %d lado mul (L%d) rightshow\n',[i, i+1]);
	end
	fprintf(fid,'0 lado filas mul translate\n');
	fprintf(fid,'90 rotate\n');

	for j=1:(size(mat,2)-1)
		fprintf(fid,'1 %d lado mul moveto (L%d) show\n', [-j, j]);
	end

end


fprintf(fid,'%%%%EndDocument\n');
fprintf(fid,'%%%%Trailer\n');
fclose(fid);
