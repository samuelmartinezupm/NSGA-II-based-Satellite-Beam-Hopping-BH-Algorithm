function matrix = anglesinv(A,varargin)

    k = size(A,2);
    n = (sqrt(8*k+1)+1)/2;
    
    matrix = eye(n);
    
    mink = 1;
    
    if (size(varargin,2)>0)
        mink = k-varargin{1}+1;
    end
    
    for i=n-1:-1:1
        for j=n:-1:(i+1)
            if (k<mink)
                return
            end
            for h=1:n
                tmp = cos(A(k))*matrix(i,h)-sin(A(k))*matrix(j,h);
                matrix(j,h)=sin(A(k))*matrix(i,h)+cos(A(k))*matrix(j,h);
                matrix(i,h)=tmp;
            end
            k=k-1;
        end
    end

end