function [dists,clast,rmax]=spkdallq_dist(qlist,sa,sb)
% function [dists,clast,rmax]=spkdallq_dist(qlist,sa,sb) does the 
% recursion and final portion of the parallel DP single unit algorithm, extended to simultaneous
%  calculation for all values of q.
%
%    qlist: a column vector of values of q. qklist(:,1): q-values.
%    sa, sb: spike times on the two spike trains
%    clast, rmax: calculated by spkdallq_recur.
%
% See spkdallqk.doc.
%
%  Copyright (c) by Jonathan Victor.
%
%    See also SPKDALLQ_RECUR, SPKDALLQ_DIST.
%
%do the recursion
[clast,rmax,c]=spkdallq_recur(sa,sb);
%do the final stage
dists=spkdallq_final(qlist,sa,sb,clast,rmax);
return

