function output_struct=analyze_osc_train_ms_win_Smith08(dataDir,filenames,stringa,par)
% analyzes spike trains

figDir=['~/neuron/sync_osc/' stringa];

if ~exist(figDir,'dir')
    mkdir(figDir);
end

par_global=par; % probably unused

nfiles=length(filenames);
n_neu_vect=nan(1,nfiles);
n_neu_wo_silence_vect=nan(1,nfiles);
min_n_spikes=nan(1,nfiles);
mean_n_spikes=nan(1,nfiles);
median_n_spikes=nan(1,nfiles);
max_n_spikes=nan(1,nfiles);
max_all_isi=nan(1,nfiles);


t_refr=4.;
n_neu=400;    % number of neurons
rate=12.; % avg rate [Hz]
r_osc_ampl=0.5;    % relative amplitude of the sinusoidal modulation (between 0 and 1)
transient=0.0;      % simulation time with STDP off
sim_time=10000;
seed=0;
inct=0.01;        % simulation time step
Rp_dt=10.*inct; % time step for population spike binning
tau_vect=[2.^[0:6]];

par_string={'t_refr','n_neu','rate','r_osc_ampl','transient','sim_time','seed','inct','Rp_dt','PLOT_print','tau_vect'};


for i=1:length(par_string)
    if(isfield(par,par_string(i)))
        eval([char(par_string(i)) '=par.' char(par_string(i)) ';']);
    end
end


for i=1:length(par_string)
    eval(['par.' char(par_string(i)) '=' char(par_string(i)) ';']);
end


field_names={'f_rate','cv_ISI','cv2_ISI','Lv_ISI','LvR_ISI','LCV_ISI','IR_ISI','ent_ISI','SM_ISI','bursty','MPC','PPC','vR','vRn','VP','VPN','psd_max','psd_max_f','ampl_gauss','mean_gauss','sigma_gauss','spec_beta','spec_rmse','golomb_sync','sttc','corr_ind','Sc','LZdist','SPIKY_ISI','SPIKY_SPIKE','SPIKY_SPIKE_synchro','SPIKY_SPIKE_order','schreiber_c','kruskal_c','HM','QQ','qq','QQA','qqa','emd','emdn','modulus_m','modulus_mn'}; % 150222 updated with additional measures

ms_names={'VP','VPN','corr_ind','golomb_sync','sttc','vR','vRn','schreiber_c','kruskal_c','HM','QQ','qq'};

ifnms=0;
for ifn=1:length(field_names)
    if ismember(field_names{ifn},ms_names)
        for tau_ind=1:length(par.tau_vect)
            tau=par.tau_vect(tau_ind);
            ifnms=ifnms+1;
            field_names_ms{ifnms}=[field_names{ifn} num2str(tau)];
        end
    else
        ifnms=ifnms+1;
        field_names_ms{ifnms}=field_names{ifn};
    end
end

field_names=field_names_ms;

rand('state',seed);       % initialize random number generator

mystyle = hgexport('factorystyle');
mystyle.Units='normalized';
mystyle.FontMode='none';

par.PLOT=1;
par.figDir=figDir;

n_neu_min=54; % corresponds to monkey2spont
win_duration=30000; % 30s
max_n_sample=100; % max number of samples of n_neu_min neurons extracted from the total number of available neurons
par_this=par;
par_this.n_neu=n_neu_min;    % number of neurons
par_this.sim_time=win_duration;
par_this.plot_win_zoom=win_duration/3;

for ifile=1:nfiles
    clear spiketimes n_spikes t_first t_last min_isi n_short_isi percent_short_isi;
    filethis=load(fullfile(dataDir,filenames{ifile}));
    if isfield(filethis,'par')
        if isfield(filethis.par,'sim_time')
            sim_time=filethis.par.sim_time;
            nwin=floor(sim_time/win_duration);
        end
    else
        keyboard;
    end
    if isfield(filethis,'data')
        if isfield(filethis.data,'EVENTS')
            n_neu_this=length(filethis.data.EVENTS);
        end
    elseif isfield(filethis,'spiketimes_clean')
        n_neu_this=length(filethis.spiketimes_clean);
    else
        fieldnamesthis=fieldnames(filethis);
        n_neu_this=length(filethis.(fieldnamesthis{1})); % if there is more than one variable, this might not work
    end
    if n_neu_this<n_neu_min
        continue;
    else
        for i_neu=1:n_neu_this
            if isfield(filethis,'data')
                if isfield(filethis.data,'EVENTS')
                    spiketimes(i_neu).t=1000.*filethis.data.EVENTS{i_neu}; % this should be a column vector - spike times in s
                end
            elseif isfield(filethis,'spiketimes_clean')
                spiketimes(i_neu).t=filethis.spiketimes_clean(i_neu).t;
            else
                spiketimes(i_neu).t=filethis.(fieldnamesthis{1})(i_neu).t; % if there is more than one variable, this might not work
            end
        end

        if n_neu_this==n_neu_min % minimum number of neurons: no sampling
            n_sample=1;
            neu_ind_mat=1:n_neu_this;
        elseif n_neu_this==(n_neu_min+1) % just one more neuron than the minimum number:exhaustive sampling is feasible
            n_sample=n_neu_this; % all possible combinations
            neu_ind_mat=nan(n_sample,n_neu_min);
            for i_sample=1:n_sample
                neu_ind_mat(i_sample,:)=setdiff([1:n_neu_this],i_sample);
            end
        else
            n_sample=max_n_sample; % max_n_sample=100<nchoosek(29,2)=406 , hence we just select random samplings without repetitions
            neu_ind_mat=nan(n_sample,n_neu_min);

            rand_perm_this=randperm(n_neu_this);
            rand_perm_this=rand_perm_this(1:n_neu_min);
            rand_perm_this_ord=sort(rand_perm_this);

            neu_ind_mat(1,:)=rand_perm_this_ord;

            for i_sample=2:n_sample

                rand_perm_this=randperm(n_neu_this);
                rand_perm_this=rand_perm_this(1:n_neu_min);
                rand_perm_this_ord=sort(rand_perm_this);

                is_already_included=0;
                for j_sample=1:(i_sample-1)
                    if isequal(rand_perm_this_ord,neu_ind_mat(j_sample,:))
                        is_already_included=1;
                        break;
                    end
                end
                while is_already_included==1
                    rand_perm_this=randperm(n_neu_this);
                    rand_perm_this=rand_perm_this(1:n_neu_min);
                    rand_perm_this_ord=sort(rand_perm_this);

                    is_already_included=0;
                    for j_sample=1:(i_sample-1)
                        if isequal(rand_perm_this_ord,neu_ind_mat(j_sample,:))
                            is_already_included=1;
                            break;
                        end
                    end
                end
                neu_ind_mat(i_sample,:)=rand_perm_this_ord;
            end
        end

        clear output_measures;
        for kk=1:length(field_names)
            eval(['clear ' field_names{kk} '_all;']);
        end

        for i_sample=1:n_sample
            spiketimes_sampled=spiketimes(neu_ind_mat(i_sample,:));

            for iwin=1:nwin
                par_this.stringa=[strrep(filenames{ifile},'.mat','') '_sample' num2str(i_sample) '_win' num2str(iwin)]; % only used in analyze_osc_train_fun_plot
                tstart=win_duration*(iwin-1);
                tend=win_duration*iwin;
                spiketimes_win=extract_spiketimes(spiketimes_sampled,tstart,tend);
                if (i_sample==1 && (iwin==1 || iwin==floor(nwin/2) || iwin==nwin)) % we only generate figures (or not, depending on PLOT_print) for 3 windows from the first sample
                    % par_this.PLOT=1;
                    par_this.PLOT=PLOT_print;
                else
                    par_this.PLOT=0;
                end
                % output_this=analyze_osc_train_fun(spiketimes_win,par_this,field_names); % does not generate figures
                output_this=analyze_osc_train_ms_fun_plot(spiketimes_win,par_this,field_names); % in case we wanted to generate figures - not recommended for every win and every recording, but we can control plotting with par.PLOT
                for kk=1:length(field_names)
                    try
                        output_measures.([field_names{kk} '_all'])(i_sample,iwin)=output_this.(field_names{kk}); % dynamic structure reference - much better than using eval
                    catch
                        output_measures.([field_names{kk} '_all'])(i_sample,iwin)=NaN;
                        keyboard;
                    end
                end
            end
        end
    end
    % keyboard;
    save(fullfile(dataDir,strrep(filenames{ifile},'.mat','_measures_ms.mat')),'output_measures','neu_ind_mat','par','par_this');
end

output_struct=[];

return;
