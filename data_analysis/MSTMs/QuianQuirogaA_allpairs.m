function [QQ,qq]=QuianQuirogaA_allpairs(spiketimes,n_exc)
% function [QQ,QQE,QQI,QQ_mat]=QuianQuiroga_allpairs(spiketimes,n_exc,tau)

n_neu=length(spiketimes);

QQ_mat=nan(n_neu);
qq_mat=nan(n_neu);

for i=1:n_neu
    for j=(i+1):n_neu
        [QQ_mat(i,j),qq_mat(i,j)]=QuianQuirogaA(spiketimes(i).t,spiketimes(j).t);
        QQ_mat(j,i)=QQ_mat(i,j); % symmetric
        qq_mat(j,i)=-qq_mat(i,j); % antisymmetric
    end
end

QQ=nanmean(nanmean(QQ_mat));
qq=nanmean(nanmean(abs(qq_mat))); % we take the abs here, otherwise it is zero (qq is antisymmetric)
% QQE=nanmean(nanmean(QQ_mat(1:n_exc,1:n_exc)));
% QQI=nanmean(nanmean(QQ_mat(n_exc+1:end,n_exc+1:end)));