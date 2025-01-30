function dists=spkdallq_final(qlist,sa,sb,clast,rmax)
% dists=spkdallq_final(qlist,sa,sb,clast,rmax) does the 
% final portion of parallel DP spike tima algorithm, extended to simultaneous
%  calculation for all values of q.
%
%    dists: a column vector of the distances
%    qlist: a column vector of values of q. qklist(:,1): q-values
%    sa, sb: spike times on the two spike trains
%    clast, rmax: calculated by spkdallq_recur
%
% See spkdallqk.doc.
%
%  Copyright (c) by Jonathan Victor.
%
%    See also SPKDALLQ_RECUR, SPKDALLQ_DIST, SPKD, SPKDALLQ.
%
%
na=length(sa);
nb=length(sb);
nq=length(qlist);
qlist=reshape(qlist,[nq 1]);
%
%make column vector of na+nb-2r, indicating costs of deletions and insertions
%
nanbrs=(na+nb)*ones(1+rmax,1)-2*[0:rmax]';
%
% find the best strategy (all r (matched links) and all s (mismatched links)
%
clast=reshape(clast,[1+rmax 1]);
for iq=1:nq
   posscosts=qlist(iq,1)*clast+nanbrs;
   dists(iq,1)=min(min(posscosts));
end
return
