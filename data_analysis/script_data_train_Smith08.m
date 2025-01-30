[~, name] = system('hostname');
name_db=deblank(name);
flag4cluster=0;
% the part below enables to set dir names for running the script either locally or in a computing cluster
% dataDir is the dir where the raw data is located. The other dirs are for storing (partially) preprocessed data
if (~flag4cluster && (strcmp(name_db,'laptop')))
    dataDir='/media/fabiano/Porsche/data/Smith08/data_and_scripts/spikes_spontaneous/';
    cleandataDir='/media/fabiano/Porsche/data/Smith08/data_and_scripts/spikes_spontaneous_clean/';
    recleandataDir='/media/fabiano/Porsche/data/Smith08/data_and_scripts/spikes_spontaneous_reclean/';
    recleannotsilentdataDir='/media/fabiano/Porsche/data/Smith08/data_and_scripts/spikes_spontaneous_reclean_notsilent/';
elseif (flag4cluster || strcmp(name_db,'mycluster'))
    dataDir='/home/fabiano/data/Smith08/spikes_spontaneous';
    cleandataDir='/home/fabiano/data/Smith08/spikes_spontaneous_clean';
    recleandataDir='/home/fabiano/data/Smith08/spikes_spontaneous_reclean';
    recleannotsilentdataDir='/home/fabiano/data/Smith08/spikes_spontaneous_reclean_notsilent';
end
if ~exist('dataDir') || (exist('dataDir') && exist(dataDir,'dir')~=7)
    disp('dataDir does not exist. Please make sure that dataDir is properly set to the dir where the data is located');
    return;
end
filenames={'spiketimesmonkey1spont.mat','spiketimesmonkey2spont.mat','spiketimesmonkey3spont.mat','spiketimesmonkey4spont.mat','spiketimesmonkey5spont.mat','spiketimesmonkey6spont.mat'};
stringa='Smith08';
clear par;
par=[];

par.names_string='050723'; % this identifies features extracted from output_all_ms.mat and output_all_fooof.mat and output_all_synfireind.mat
% par.sim_time=600000; % different for each recording and set based on par.sim_time=max(t_last)+1
par.n_neu_min=54; % corresponds to monkey2spont
par.tau_vect=[2.^[0:6]];
par.PLOT_print=1; % to (re)generate figures
% par.PLOT_print=0; % no need to regenerate figures

% removing neurons with more than 5% of ISI<1ms
stringa='Smith08Clean';
output_struct=clean_neu_osc_train_Smith08(dataDir,cleandataDir,filenames,stringa,par);

% removing spikes that result in ISI<1ms
stringa='Smith08ReClean';
output_struct=clean_spk_osc_train_Smith08(cleandataDir,recleandataDir,filenames,stringa,par);

% removing neurons with long periods of silence (ISI>20s)
stringa='Smith08ReCleanNotSilent';
output_struct=clean_silent_neu_osc_train_Smith08(recleandataDir,recleannotsilentdataDir,filenames,stringa,par);

stringa_mfile={'analyze_osc_train_ms_win_Smith08','analyze_osc_train_fooof_win_data','analyze_osc_train_synfireind_win_data'};
output_struct=distribute_analysis_qsub(recleannotsilentdataDir,filenames,stringa,stringa_mfile,par); % this distributes stringa_mfile jobs

% par.nperm=10; % for a quick check
par.nperm=1000; % for final results
png_tails={'','_bs'}; % extended set of measures (multiple time scales, or "ms"), core set of measures (best time scale, or "bs")
seed_vect=[3 4];
i_tail=0;
for png_tail=png_tails
% for png_tail=png_tails(2)    
    i_tail=i_tail+1;
    par.png_tail=png_tail{1};
    par.seed_silh=seed_vect(i_tail);
    output_struct=multi_train_anal_win_cluster(recleannotsilentdataDir,filenames,stringa,par); % better run with xvfb-run - needs a big screen
    output_struct=multi_train_anal_win_silhouette(recleannotsilentdataDir,filenames,stringa,par); % depending on par.nperm this can take a long time
    output_struct=multi_train_plot_win_silhouette(recleannotsilentdataDir,filenames,stringa,par);
    output_struct=multi_train_anal_compute_id(recleannotsilentdataDir,filenames,stringa,par);
end
