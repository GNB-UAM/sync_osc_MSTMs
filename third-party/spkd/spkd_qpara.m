function d=spkd_qpara(tli,tlj,costs)
%
% d=spkd(tli,tlj,costs) calculates the "spike time" distance
% (Victor & Purpura 1996) for a single costs
%
% tli: vector of spike times for first spike train
% tlj: vector of spike times for second spike train
% costs: costs per unit time to move a spike
%
% Copyright (c) 1999 by Daniel Reich and Jonathan Victor.
% Translated to Matlab by Daniel Reich from FORTRAN code by Jonathan Victor.

nspi=length(tli);
nspj=length(tlj);
if costs==0
    d=abs(nspi-nspj);
    return
elseif costs==Inf
    d=nspi+nspj;
    return
end
scr=zeros(nspi+1,nspj+1);
scr(:,1)=(0:nspi)';
scr(1,:)=(0:nspj);
scr=repmat(shiftdim(scr,-1),[length(costs),1,1]);
if nspi && nspj
    for i=2:nspi+1
        for j=2:nspj+1           
            scr(:,i,j)=min(cat(3,scr(:,i-1,j)+1,scr(:,i,j-1)+1,scr(:,i-1,j-1)+costs'*abs(tli(i-1)-tlj(j-1))),[],3);
        end
    end
end
d=scr(:,nspi+1,nspj+1);

