function D2 = abs_spearman_corr_pairwise(ZI,ZJ)

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
    D2(i)=1-abs(corr(ZI',ZJ(i,:)','Type','Spearman','rows','pairwise'));
end