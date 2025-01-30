%
%implementation of regularized least square classifier (RLSC), single class
%with binary labels.
%
%A variable with constant =1 is added automatically (intercept).
%Uses a linear kernel without interactions. Other kernels can be added by changing the A*A' part.
%
%
%Implemented according to:
%Rifkin, PhD Thesis MIT, 2002
%Poggio&Smale 2003, Notices Am Math Soc
%
%inputs:
% x is an lxp matrix, l is nr samples, p number variables.
% y lx1 matrix of binary labels
% varsTouse: which columns of x to use (others are ignored). default is all.
% nu is the regularization parameter
%
%outputs:
%weight vector, 1xp
%
%urut/aug06
function w = trainRLSC(x,y,varsToUse,lambda)
if nargin<=2
    varsToUse=[];
end

if nargin<=3
    lambda=1;
end
%==training
n=size(x,1);

%
%
if 1
    A=[ ones(n,1) ];

    if 1 % ~isempty(varsToUse)
        varsToUse = 1:size(x,2);
        for i=1:length(varsToUse)
            A(:,i+1) = x(:,varsToUse(i) );
        end
    else
        keyboard
        A(:,2:end) = x; 
    end
        
        
    G=(A*A' + lambda*eye(n));
    Ginv=inv(G);
    c = inv(G)*y;

    %==calc w
    w=c'*A;
else

    keyboard
    DesignX = cat(2,ones(size(y)),y-mean(y));
    DesignX = diag(1./sqrt(sum(DesignX.^2,2)))*DesignX;   %normalize each column

    Betas = DesignX'*x;
    Res = spm_atranspa(x - DesignX*Betas)/(size(y,1)-1);    %[Trialnum voxelnum]      == (x - DesignX'*Betas)*(x - DesignX'*Betas)'
    Regularizer = lambda*eye(size(Res,1)) + (1-lambda)*ones(size(Res));

    Weight = (Res.*Regularizer)\Betas(2,:)';   % == pinv(Res)*Betas
    % Weight = [-Betas(1,:)' Weight]; %no bias
    Weight = [0; Weight]; %no bias

    w = Weight';

end