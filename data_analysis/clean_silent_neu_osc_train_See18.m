function output_struct=clean_silent_neu_osc_train_See18(dataDir,cleandataDir,filenames,stringa,par)
% analyzes spike trains

figDir=['~/neuron/sync_osc/' stringa];

if ~exist(figDir,'dir')
    mkdir(figDir);
end
if ~exist(cleandataDir,'dir')
    mkdir(cleandataDir);
end

par_global=par; % probably unused

nfiles=length(filenames);
n_neu_vect=nan(1,nfiles);




t_refr=4.;
n_neu=400;    % number of neurons
rate=12.; % avg rate [Hz]
r_osc_ampl=0.5;    % relative amplitude of the sinusoidal modulation (between 0 and 1)
transient=0.0;      % simulation time with STDP off
sim_time=10000;
seed=0;
inct=0.01;        % simulation time step
Rp_dt=10.*inct; % time step for population spike binning

par_string={'t_refr','n_neu','rate','r_osc_ampl','transient','sim_time','seed','inct','Rp_dt'};


for i=1:length(par_string)
    if(isfield(par,par_string(i)))
        eval([char(par_string(i)) '=par.' char(par_string(i)) ';']);
    end
end


for i=1:length(par_string)
    eval(['par.' char(par_string(i)) '=' char(par_string(i)) ';']);
end




mystyle = hgexport('factorystyle');
mystyle.Units='normalized';
mystyle.FontMode='none';

par.PLOT=1;
par.figDir=figDir;

percent_short_isi_thr=0.05; % neurons with more than 5% of very short ISIs are removed
max_ISI_thr=20000; % neurons with period of silence greater than 20 s will be removed

for ifile=1:nfiles
    clear spiketimes spiketimes_clean n_spikes t_first t_last min_isi max_isi n_short_isi percent_short_isi n_consecutive_short_isi clean_neu_vect;
    filethis=load(fullfile(dataDir,filenames{ifile}));
    if isfield(filethis,'spk')
        n_neu_this=length(filethis.spk);
    else
        fieldnamesthis=fieldnames(filethis);
        n_neu_this=length(filethis.(fieldnamesthis{1})); % if there is more than one variable, this might not work
    end
    all_isi=[];
    all_short_isi_prev=[];
    all_short_isi_next=[];
    i_neu_clean=0;
    clean_neu_vect=[];
    for i_neu=1:n_neu_this
        if isfield(filethis,'spk')
            spiketimes(i_neu).t=filethis.spk(i_neu).spiketimes'; % this should be a column vector
        else
            spiketimes(i_neu).t=filethis.(fieldnamesthis{1})(i_neu).t; % if there is more than one variable, this might not work
        end
        n_spikes(i_neu)=length(spiketimes(i_neu).t);
        t_first(i_neu)=spiketimes(i_neu).t(1);
        t_last(i_neu)=spiketimes(i_neu).t(end);
        isi_this=spiketimes(i_neu).t(2:end)-spiketimes(i_neu).t(1:end-1);
        n_isi=length(isi_this);
        min_isi(i_neu)=min(isi_this);
        max_isi(i_neu)=max(isi_this);
        all_isi=[all_isi; isi_this];
        ind_short_isi=find(isi_this<1);
        n_short_isi(i_neu)=length(ind_short_isi);
        percent_short_isi(i_neu)=n_short_isi(i_neu)./length(isi_this);

        if max_isi(i_neu) < max_ISI_thr
            i_neu_clean=i_neu_clean+1;
            clean_neu_vect(i_neu_clean)=i_neu;
            spiketimes_clean(i_neu_clean).t=spiketimes(i_neu).t;
        end
    end

    % UNCOMMENT BELOW TO REGENERATE CLEAN SPIKETIMES
    save(fullfile(cleandataDir,filenames{ifile}),'spiketimes_clean');

    n_neu_vect(ifile)=n_neu_this;
    n_neu_clean_vect(ifile)=i_neu_clean;
    n_neu_removed(ifile)=n_neu_this-i_neu_clean;
    percent_removed_neu(ifile)=(n_neu_removed(ifile))./n_neu_this;
    n_spikes_all{ifile}=n_spikes;
    t_first_all{ifile}=t_first;
    t_last_all{ifile}=t_last;
    min_isi_all{ifile}=min_isi;
    max_isi_all{ifile}=max_isi;
    percent_short_isi_all{ifile}=percent_short_isi;

    par.n_neu=n_neu_this;    % number of neurons
    par.sim_time=max(t_last)+1; % good enough, any reasonable choice should not make any appreciable difference
    par.stringa=strrep(filenames{ifile},'.mat','');

end

figure
[n_counts edges]=histcounts(n_neu_removed);
% histogram(n_counts,edges); % this calculates the histogram
histogram('BinEdges',edges,'BinCounts',n_counts); % this just plots
hold on;
y_pos=1.05*max(n_counts);
plot(n_neu_removed,y_pos*ones(1,length(n_neu_removed)),'rx');
xlabel('# neu removed');
ylabel('count');
title(['rm neu w ISI>' num2str(max_ISI_thr/1000) 's'],'FontWeight','normal','Interpreter','none');
figure_name=strcat(figDir,filesep,'n_neu_removed_hist','.png');
hgexport(gcf,figure_name,mystyle,'Format','png');

figure
[n_counts edges]=histcounts(percent_removed_neu);
% histogram(n_counts,edges); % this calculates the histogram
histogram('BinEdges',edges,'BinCounts',n_counts); % this just plots
hold on;
y_pos=1.05*max(n_counts);
plot(percent_removed_neu,y_pos*ones(1,length(percent_removed_neu)),'rx');
xlabel('fraction neu removed');
ylabel('count');
title(['rm neu w ISI>' num2str(max_ISI_thr/1000) 's'],'FontWeight','normal','Interpreter','none');
figure_name=strcat(figDir,filesep,'percent_removed_neu_hist','.png');
hgexport(gcf,figure_name,mystyle,'Format','png');

save(fullfile(cleandataDir,'clean_neu.out'),'n_neu_vect','n_neu_clean_vect','n_neu_removed','percent_removed_neu');

output_struct=[];

return;
