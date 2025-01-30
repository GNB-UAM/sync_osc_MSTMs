[~, name] = system('hostname');
name_db=deblank(name);
flag4cluster=0;
% the part below enables to set dir names for running the script either locally or in a computing cluster
% dataDir is the dir where the raw data is located. The other dirs are for storing (partially) preprocessed data
if (~flag4cluster && (strcmp(name_db,'laptop')))
    dataDir='/media/fabiano/Porsche/data/See2021/Data';
    cleandataDir='/media/fabiano/Porsche/data/See2021/CleanData';
    recleandataDir='/media/fabiano/Porsche/data/See2021/ReCleanData';
    recleannotsilentdataDir='/media/fabiano/Porsche/data/See2021/ReCleanNotSilentData';
elseif (flag4cluster || strcmp(name_db,'mycluster'))
    dataDir='/home/fabiano/data/See2021/Data';
    cleandataDir='/home/fabiano/data/See2021/CleanData';
    recleandataDir='/home/fabiano/data/See2021/ReCleanData';
    recleannotsilentdataDir='/home/fabiano/data/See2021/ReCleanNotSilentData';
end
if ~exist('dataDir') || (exist('dataDir') && exist(dataDir,'dir')~=7)
    disp('dataDir does not exist. Please make sure that dataDir is properly set to the dir where the data is located');
    return;
end
filenames={'site1-rn1.mat','site2-rn16.mat','site3-rn1.mat','site4-rn16.mat','site5-rn1.mat','site6-rn16.mat','site7-rn1.mat','site8-rn16.mat','site9-rn1.mat','site10-rn16.mat','site11-rn1.mat','site12-rn16.mat','site13-rn1.mat','site14-rn16.mat','site15-rn1.mat','site16-rn16.mat'};
stringa='See18';
clear par;
par=[];

par.names_string='050723'; % this identifies features extracted from output_all_ms.mat and output_all_fooof.mat and output_all_synfireind.mat
par.sim_time=600000; % 600 s (10 min)
par.n_neu_min=27; % we only consider recordings with n_neu_this>n_neu_min (that is, we disregard site5-rn1 - 16 neu - and site6-rn16 - 23 neu)
par.tau_vect=[2.^[0:6]];
par.PLOT_print=1; % to (re)generate figures
% par.PLOT_print=0; % no need to regenerate figures

% removing neurons with more than 5% of ISI<1ms
stringa='See18Clean';
output_struct=clean_neu_osc_train_See18(dataDir,cleandataDir,filenames,stringa,par);

% removing spikes that result in ISI<1ms
stringa='See18ReClean';
output_struct=clean_spk_osc_train_See18(cleandataDir,recleandataDir,filenames,stringa,par);

% removing neurons with long periods of silence (ISI>20s)
stringa='See18ReCleanNotSilent';
output_struct=clean_silent_neu_osc_train_See18(recleandataDir,recleannotsilentdataDir,filenames,stringa,par);

stringa_mfile={'analyze_osc_train_ms_win_See18','analyze_osc_train_fooof_win_data','analyze_osc_train_synfireind_win_data'};
output_struct=distribute_analysis_qsub(recleannotsilentdataDir,filenames,stringa,stringa_mfile,par); % this distributes stringa_mfile jobs

% par.nperm=10; % for a quick check
par.nperm=1000; % for final results
png_tails={'','_bs'}; % extended set of measures (multiple time scales, or "ms"), core set of measures (best time scale, or "bs")
seed_vect=[1 2];
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
