function [LZdist]=LZ_distance(spiketimes,sim_time,inct)
% returns LZ distance
% Christen, Markus, Adam Kohn, Thomas Ott, and Ruedi Stoop. 2006. “Measuring Spike Pattern Reliability with the Lempel–Ziv-Distance.” Journal of Neuroscience Methods 156 (1): 342–50. https://doi.org/10.1016/j.jneumeth.2006.02.023.
codeBook = cellstr(['0';'1']);

t_vect=0:inct:sim_time;
n_neu=length(spiketimes);
spikes_binned=zeros(n_neu,length(t_vect)-1); % spike density
LZc=zeros(1,n_neu);
LZcondc=nan(n_neu,n_neu);
% binning and getting the codebook (set of phrases) for each neu
for neu=1:n_neu
    spikes_this=spiketimes(neu).t;
    
    if isempty(spikes_this)
        % spikes_binned(neu,:)=zeros(1,length(t_vect));
        spikes_binned(neu,:)=zeros(1,length(t_vect)-1); % this has the same length as histcounts(spikes_this,t_vect)
    else
        spikes_binned(neu,:)=histcounts(spikes_this,t_vect);
    end
    
    strInput = strrep((mat2str(spikes_binned(neu,:))),' ','');
    strInput = strrep(strInput,'[','');
    strInput =  strrep(strInput,']','');
    [output CodeBook{neu} NumRep NumRepBin]=lempelzivEnc(strInput,codeBook);
    c=length(CodeBook{neu});
    if c==0
        LZc(neu)=0.;
    else
        LZc(neu)=(c*log2(c))./(length(t_vect)-1);
    end
    %     max_y=max(spikes_binned(neu,:));
    %     figure
    %     plot(t_vect,spikes_binned(neu,:));
    %     hold on;
    %     plot(spiketimes(neu).t,1.05*max_y*ones(length(spiketimes(neu).t),1),'rx','MarkerSize',6);
    %     xlim([0 300]);
    %     keyboard;
end

for i_neu=1:n_neu
    for j_neu=(i_neu+1):n_neu % symmetric measure
        % if i_neu~=j_neu
        CodeBookDiff1=setdiff(CodeBook{i_neu},CodeBook{j_neu});
        c1=length(CodeBookDiff1);
        if c1==0
            LZcondc1=0;
        else
            LZcondc1=(c1*log2(c1))./(length(t_vect)-1);
        end
        
        CodeBookDiff2=setdiff(CodeBook{j_neu},CodeBook{i_neu});
        c2=length(CodeBookDiff2);
        if c2==0
            LZcondc2=0;
        else
            LZcondc2=(c2*log2(c2))./(length(t_vect)-1);
        end
        
        LZcondc(i_neu,j_neu)=1.-min([(LZc(i_neu)-LZcondc1)/LZc(i_neu) (LZc(j_neu)-LZcondc2)/LZc(j_neu)]);
        % end
    end
end

LZdist=nanmean(nanmean(LZcondc));

