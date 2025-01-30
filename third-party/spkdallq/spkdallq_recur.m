function [clast,rmax,c]=spkdallq_recur(sa,sb)
% function [clast,rmax,c]=spkdallqk_recur(sa,sb) does the recursion for the DP
% algorithm for spike time distance.  It uses the method of spkdallq, but
% reformats and produces arguments to be parallel to spkdallqk_recur.
%
% sa: vector of spike times for first spike train
% sb: vector of spike times for second spike train
% c: array of critical lengthts of linkages. size(c)=[1+length(sa) 1+length(sb) 1+rmax]
% rmax: maximum number of linkages (=min(length(sa),length(sb))
% clast: vector of critical lengths for full spike trains, necessary for calculating all
%    distances, which is done in spkdallq_dist, via spkdallq_final.
%
%  Copyright (c) by Jonathan Victor.
%
%    See also SPKD, SPKDALLQ, SPKDALLQK_RECUR.
%
tli=sa; %reformat the input arguments
tlj=sb;
nspi=length(tli);
nspj=length(tlj);
nij=min(nspi,nspj);
lc=repmat(NaN,[nspi+1 nspj+1 nij]); % assume no length of movement
if (nij>0)
%
%     best linkage length is a recursion based on linkages for shorter trains
%
	for i=2:nspi+1
   	for j=2:nspj+1
         td=abs(tli(i-1)-tlj(j-1));
         li=squeeze(lc(i-1,j,:));
         lj=squeeze(lc(i,j-1,:));
         lij=td+[0;squeeze(lc(i-1,j-1,1:nij-1))];
         lc(i,j,:)=min([li,lj,lij],[],2);
   	end
	end
end
rmax=nij;
c=cat(3,zeros(nspi+1,nspj+1),lc);
clast=squeeze(c(end,end,:));
return
