function D2 = euclidean_pairwise(ZI,ZJ)
% NaNs are ignored, but a weighted version is also implemented but commented out

dimi=size(ZI);
dimj=size(ZJ);

if dimi(1)~=1
   error('ZI must contain a single observation'); 
end

if dimi(2)~=dimj(2)
   error('ZI and ZJ must have the same number of columns');     
end

for i=1:dimj(1)
    % D2_this=1-abs(corrcoef(ZI,ZJ(i,:)));
    % D2(i)=D2_this(1,2);    
    % D2(i)=1-(corr(ZI',ZJ(i,:)','Type','Spearman','rows','pairwise'));
    % D2(i); % otherwise conditional breakpoint (isnan(D2(i))) cannot be set

    sqdx = (ZI'-ZJ(i,:)').^2;
    D2(i)=sqrt(sum(sqdx,'omitnan'));
    % D2(i)=sqrt((dimj(2)/sum(~isnan(sqdx)))*sum(sqdx,'omitnan')); % applying a weight = Total # of coordinates / # of present coordinates % https://scikit-learn.org/stable/modules/generated/sklearn.metrics.pairwise.nan_euclidean_distances.html % https://www.mathworks.com/help/stats/pdist.html
end