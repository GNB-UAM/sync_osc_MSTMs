function [d,scr]=spkd_int_FAST_post(tli,tlj,cost,tsamp)
%
% d=spkd(tli,tlj,cost) calculates the "spike time" distance
% (Victor & Purpura 1996) for a single cost
%
% tli: vector of spike times for first spike train
% tlj: vector of spike times for second spike train
% cost: cost per unit time to move a spike
%
%  Copyright (c) 1999 by Daniel Reich and Jonathan Victor.
%  Translated to Matlab by Christina Behrend from FORTRAN code by Jonathan Victor.
%  Matlab code optimized for faster processing by Jim Hokanson

% calculates distance between two spike trains in the spike interval metric
% by a continuum modification of the sellers algorithm

% end conditions: the first and last ISI are expanded as needed to minimize
% the total cost

% input variables
% tli: vector spike times for first spike train
% tlj: vector spike times for second spike train
% cost: cost per unit time to move a spike
% tsamp: the length of the entire interval

nspi=length(tli);       % number of spike times in train 1
nspj=length(tlj);       % number of spike times in train 2


ni = nspi+1;            % number of intervals in train 1
nj = nspj+1;            % number of intervals in train 2
scr=zeros(ni+1,nj+1);

% define calculation for a cost of zero
if cost==0
    d=abs(ni-nj);
    return
end


% INITIALIZE MARGINS WITH COST OF ADDING A SPIKE
scr(:,1)=(0:ni)';
scr(1,:)=(0:nj);

tli_diff = diff(tli);
tlj_diff = diff(tlj);

for i = 1:ni
    if (i > 1) && (i < ni)
        %di = tli(i)-tli(i-1);
        di = tli_diff(i-1);
    elseif (i == 1) && (i == ni)
        di = tsamp;
    elseif (i == 1) && (i < ni)
        di = tli(i);
    else %(i > 1) && (i == ni)
        di = tsamp-tli(i-1);
    end

    iend = ((i == 1) || (i == ni));

    % unrolled loop for j = 1    
    % ------------------------
    if (nj == 1)
        dj = tsamp;
    else %(j < nj)
        dj = tlj(1);
    end
        
    if iend 
        dist = 0;
    else %jend
        dist = max(0,dj-di);
    end
    
    scr(i+1,2)=min([scr(i,2)+1 scr(i+1,1)+1 scr(i,1)+cost*dist]);
    
    % main code
    % ---------
    for j = 2:nj-1
        dj = tlj_diff(j-1);
                
        if iend
            dist = max(0,di-dj);
        else
            dist = abs(di-dj);
        end
        tmp = min(scr(i,j+1)+1,scr(i+1,j)+1);
        scr(i+1,j+1)=min(tmp,scr(i,j)+cost*dist);
    end
    
    % unrolled loop for j = nj
    % ------------------------
    if (nj == 1)
        dj = tsamp;
    else %(j > 1) && (j == nj)
        dj = tsamp-tlj(nj-1);
    end
    
    if iend 
        dist = 0;
    else %jend
        dist = max(0,dj-di);
    end
    
    scr(i+1,nj+1)=min([scr(i,nj+1)+1 scr(i+1,nj)+1 scr(i,nj)+cost*dist]);
    
end
d = scr(ni+1,nj+1);

