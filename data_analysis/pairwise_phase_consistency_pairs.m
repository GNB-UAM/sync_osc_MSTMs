function ppc=pairwise_phase_consistency_pairs(A,B)
% pairwise phase consistency as in Vinck et al 2010 NeuroImage of spike train A with respect to spike train B
% all spikes in A included in (B(1),B(end)) will be assigned a phase
% phases are included in [0,1[

n_lim=10; % this version assigns NaN if there are less than n_lim phase values contributing to the estimate

if(length(B)<2)
    ppc=NaN;
    return;
end

i=1; j=1;

phases=[];

%keyboard;

ind_start=find(A>=B(1),1,'first');
ind_stop=find(A<B(end),1,'last');

A=A(ind_start:ind_stop);

% j is the index of the spike time in B just preceding spike i in A
% i is the index of the current spike in A

while i<=length(A)
    if A(i)>=B(j+1)
        j=j+1;
    else
        d=(A(i)-B(j))/(B(j+1)-B(j));
        phases=[phases d];
        i=i+1;
    end
end

% clear i;
i=sqrt(-1);

if length(phases)<n_lim
    ppc=NaN;
else
    ppc=sum(cos(2*pi*phases))/length(phases);
    %keyboard;
end