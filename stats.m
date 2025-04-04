clear all;
matDir ='./s2/';
files = dir(strcat(matDir,'*.mat'));

ucs=zeros(size(files,1),1);
i = 1;
for f=files'
    %s.\n', file.name)
    %fprintf(1,'%s.\n', f.name);
    uc = load(strcat(matDir,f.name),'objectives');
    ucs(i) = min(uc.objectives);
    i = i +1;
end

disp(matDir);
disp(mean(ucs));
