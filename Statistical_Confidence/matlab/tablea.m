function tablea (nombre, mat, varargin)

if (nargin > 2)
	fmt = varargin{1};
else
	fmt ='%0.4e';
end

if (nargin > 3)
	n = varargin{2};
else
	n = mat*0;
end

if (nargin > 4)
	f = varargin{3};
	noclose = 1;
else
	[f,basura] = fopen (nombre,'w');
	noclose = 0;
end

if (nargin > 5)
	cap = varargin{4};
else
	cap = '';
end

fprintf(f,'\\begin{table}[!ht]\n');
fprintf(f,['\\caption{' cap '}\n']);
line = '\\begin{tabular}{|';

for col=1:size(mat,2)
	line = [line, 'l|'];
end
line = [line, '}\n'];

fprintf(f, line);
fprintf(f,'\\hline\n');
for row=1:size(mat,1)
	line = [];
	for col=1:size(mat,2)
		if (n(row,col)==1)
			line = [line, '\\textbf{' num2str(mat(row,col),fmt) '}'];
		else
			line = [line, num2str(mat(row,col),fmt)];
		end
		if (col < size(mat,2))
			line = [line, ' & '];
		end
	end
	line = [line, ' \\\\\n'];
	fprintf(f,line);
end
fprintf(f,'\\hline\n');
fprintf(f,'\\end{tabular}\n');
fprintf(f,'\\end{table}\n');

if (noclose == 0)
	fclose(f);
end
