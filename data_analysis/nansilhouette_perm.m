function [silh_perm_vect]=nansilhouette_perm(data,sess_id,dist_fun,nperm)
silh_perm_vect=nan(1,nperm);
n_sample=length(sess_id);

for iperm=1:nperm
    [silh_vect_this]=nansilhouette(data,sess_id(randperm(n_sample)),dist_fun);
    silh_perm_vect(iperm)=mean(silh_vect_this);
end