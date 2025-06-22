function [A,matrix,I] = angles(matrix,varargin)

    n = size(matrix,1);

    maxk = n*(n-1)/2;
    
    A = zeros(1,maxk);
    I = zeros(1,maxk);
    
    if (size(varargin,2)>0)
        maxk = varargin{1};
    end
    
    k = 1;
    for i=1:n
        for j=(i+1):n
            if (k>maxk)
                return
            end
            s = matrix(j,i);
            c = matrix(i,i);
            I(k) = s*s + c*c;
            %aa = sqrt(I(k));
            aa = 1;
            A(k) = atan2(s,c);
            s = sin(A(k));
            c = cos(A(k));
            
            for h=1:n
                tmp = (c*matrix(i,h)+s*matrix(j,h))/aa;
                matrix(j,h)=(-s*matrix(i,h)+c*matrix(j,h))/aa;
                matrix(i,h)=tmp;
            end
            k=k+1;
        end
    end
end