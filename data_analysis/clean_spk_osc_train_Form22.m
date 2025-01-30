function output_struct=clean_spk_osc_train_Form22(dataDir,cleandataDir,filenames,stringa,par)
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

total_n_spikes=0;
total_n_spikes_clean=0;

for ifile=1:nfiles
    clear spiketimes spiketimes_clean n_spikes n_spikes_clean min_isi n_short_isi percent_short_isi n_consecutive_short_isi clean_neu_vect;
    filethis=load(fullfile(dataDir,filenames{ifile}));
    if isfield(filethis,'spiketimes')
        n_neu_this=length(filethis.spiketimes);
    elseif isfield(filethis,'spiketimes_clean')
        n_neu_this=length(filethis.spiketimes_clean);
    else
        fieldnamesthis=fieldnames(filethis);
        n_neu_this=length(filethis.(fieldnamesthis{1})); % if there is more than one variable, this might not work
        keyboard;
    end
    for i_neu=1:n_neu_this
        if isfield(filethis,'spiketimes')
            spiketimes(i_neu).t=filethis.spiketimes(i_neu).t;
        elseif isfield(filethis,'spiketimes_clean')
            spiketimes(i_neu).t=filethis.spiketimes_clean(i_neu).t;
        else
            spiketimes(i_neu).t=filethis.(fieldnamesthis{1})(i_neu).t; % if there is more than one variable, this might not work
            keyboard;
        end
        n_spikes(i_neu)=length(spiketimes(i_neu).t);
        isi_this=spiketimes(i_neu).t(2:end)-spiketimes(i_neu).t(1:end-1);
        n_isi=length(isi_this);

        spiketimes_clean(i_neu).t(1)=spiketimes(i_neu).t(1);

        i_spk_clean=1;
        n_spk_2skip=0;
        for i_spk=2:n_spikes(i_neu)
            if n_spk_2skip>0
                n_spk_2skip=n_spk_2skip-1;
                continue;
            end
            if isi_this(i_spk-1)<1 % preceding ISI is too short, we need to remove at least one spike
                n_adj_consecutive_short_isi=0;
                flag_still_searching=1;
                while flag_still_searching
                    n_adj_consecutive_short_isi=n_adj_consecutive_short_isi+1;
                    if i_spk-1+n_adj_consecutive_short_isi<=n_isi && isi_this(i_spk-1+n_adj_consecutive_short_isi)<1

                    else
                        flag_still_searching=0;
                        n_adj_consecutive_short_isi=n_adj_consecutive_short_isi-1;
                    end
                end
                switch n_adj_consecutive_short_isi
                    case 0 % skip 1 spike

                    case 1 % 2 consecutive very short ISI: just keep the spike in the middle
                        spiketimes_clean(i_neu).t(i_spk_clean)=spiketimes(i_neu).t(i_spk);
                        n_spk_2skip=1;

                    case 2 % 3 consecutive very short ISI (extremely rare): just keep the 2nd spike of the quadruplet
                        spiketimes_clean(i_neu).t(i_spk_clean)=spiketimes(i_neu).t(i_spk);
                        n_spk_2skip=2;

                    otherwise
                        keyboard;
                end
            else
                i_spk_clean=i_spk_clean+1;
                spiketimes_clean(i_neu).t(i_spk_clean)=spiketimes(i_neu).t(i_spk);
            end
        end
        if ~iscolumn(spiketimes_clean(i_neu).t) % we want spiketimes_clean(i_neu).t to be a column vector
            spiketimes_clean(i_neu).t=spiketimes_clean(i_neu).t';
        end
        n_spikes_clean(i_neu)=length(spiketimes_clean(i_neu).t);

    end

    % UNCOMMENT BELOW TO REGENERATE CLEAN SPIKETIMES
    save(fullfile(cleandataDir,filenames{ifile}),'spiketimes_clean');

    n_spikes_removed=n_spikes-n_spikes_clean;
    percent_removed_spk=n_spikes_removed./n_spikes;

    total_n_spikes=total_n_spikes+sum(n_spikes);
    total_n_spikes_clean=total_n_spikes_clean+sum(n_spikes_clean);


    n_spikes_all{ifile}=n_spikes;
    n_spikes_clean_all{ifile}=n_spikes_clean;
    n_spikes_removed_all{ifile}=n_spikes_removed;
    percent_removed_spk_all{ifile}=percent_removed_spk;

end

printf(['Initial data includes ' num2str(total_n_spikes) ' spikes\n']);
printf(['Cleaned data includes ' num2str(total_n_spikes_clean) ' spikes\n']);
printf(['We removed ' num2str(total_n_spikes-total_n_spikes_clean) ' spikes\n']);
save(fullfile(cleandataDir,'clean_spk.out'),'n_spikes_all','n_spikes_clean_all','n_spikes_removed_all','percent_removed_spk_all','total_n_spikes','total_n_spikes_clean');

output_struct=[];

return;
