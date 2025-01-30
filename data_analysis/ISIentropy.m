function ent=ISIentropy(log_isi_vect)
% calculates entropy
n_bins=20;
[n,edges] = histcounts(log_isi_vect,n_bins,'Normalization','probability');

 indices = n ~= 0; 
 ent = -sum(n(indices).*log2(n(indices))); 