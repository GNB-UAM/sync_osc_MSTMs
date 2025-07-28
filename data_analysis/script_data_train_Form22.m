[~, name] = system('hostname');
name_db=deblank(name);
flag4cluster=0;
% the part below enables to set dir names for running the script either locally or in a computing cluster
% dataDir is the dir where the raw data is located. The other dirs are for storing (partially) preprocessed data
if (~flag4cluster && (strcmp(name_db,'delf')))
    dataDir='/media/fabiano/Porsche/data/Formozov21/anesthesia_ca1/Sleep/SUA/';
    concatdataDir='/media/fabiano/Porsche/data/Formozov21/data_and_scripts/spikes_spontaneous_concat/';
    cleandataDir='/media/fabiano/Porsche/data/Formozov21/data_and_scripts/spikes_spontaneous_clean/';
    recleandataDir='/media/fabiano/Porsche/data/Formozov21/data_and_scripts/spikes_spontaneous_reclean/';
    recleannotsilentdataDir='/media/fabiano/Porsche/data/Formozov21/data_and_scripts/spikes_spontaneous_reclean_notsilent/';

    sleepDir='/media/fabiano/Porsche/data/Formozov21/anesthesia_ca1/Sleep/sleep_scoring/'; % raw ss data; processed ss data is stored in /home/fabiano/neuron/sync_osc/Form22ReCleanNotSilent/
elseif (flag4cluster || strcmp(name_db,'mycluster'))
    dataDir='/home/fabiano/data/Formozov21/spikes_spontaneous';
    concatdataDir='/home/fabiano/data/Formozov21/spikes_spontaneous_concat';
    cleandataDir='/home/fabiano/data/Formozov21/spikes_spontaneous_clean';
    recleandataDir='/home/fabiano/data/Formozov21/spikes_spontaneous_reclean';
    recleannotsilentdataDir='/home/fabiano/data/Formozov21/spikes_spontaneous_reclean_notsilent';

    sleepDir='/home/fabiano/data/Formozov21/sleep_scoring/';
end
if ~exist('dataDir') || (exist('dataDir') && exist(dataDir,'dir')~=7)
    disp('dataDir does not exist. Please make sure that dataDir is properly set to the dir where the data is located');
    return;
end
filenames={'M1R1','M1R2','M2R2','M4R1'};
stringa='Form22';
clear par;
par=[];

par.names_string='050723'; % this identifies features extracted from output_all_ms.mat and output_all_fooof.mat and output_all_synfireind.mat
% par.sim_time=600000; % different for each recording and set based on par.sim_time=max(t_last)+1
par.n_neu_min=28; % corresponds to M2R2
par.tau_vect=[2.^[0:6]];
par.PLOT_print=1; % to (re)generate figures
% par.PLOT_print=0; % no need to regenerate figures

% note that these parameters are also set independently in some of the functions below
par.win_duration=30000; % 30s
par.max_n_sample=100; % max number of samples of n_neu_min neurons extracted from the total number of available neurons

output_struct=concatenate_data_osc_train_Form22(dataDir,concatdataDir,filenames,stringa,par); % this concatenates SUA data and stores it in a single structure for each recording

% removing neurons with more than 5% of ISI<1ms
stringa='Form22Clean';
output_struct=clean_neu_osc_train_Form22(concatdataDir,cleandataDir,filenames,stringa,par);

% removing spikes that result in ISI<1ms
stringa='Form22ReClean';
output_struct=clean_spk_osc_train_Form22(cleandataDir,recleandataDir,filenames,stringa,par);

% removing neurons with long periods of silence (ISI>20s)
stringa='Form22ReCleanNotSilent';
output_struct=clean_silent_neu_osc_train_Form22(recleandataDir,recleannotsilentdataDir,filenames,stringa,par);

stringa_mfile={'analyze_osc_train_ms_win_data','analyze_osc_train_fooof_win_data','analyze_osc_train_synfireind_win_data'};
output_struct=distribute_analysis_qsub(recleannotsilentdataDir,filenames,stringa,stringa_mfile,par); % this distributes stringa_mfile jobs



% par.nperm=10; % for a quick check
par.nperm=1000; % for final results
png_tails={'','_bs'}; % extended set of measures (multiple time scales, or "ms"), core set of measures (best time scale, or "bs")
seed_vect=[5 6];
i_tail=0;
par.field_names_ind=[10 5 43]; % bursty LvR_ISI fooof_1p_r_squared
for png_tail=png_tails
% for png_tail=png_tails(2)
    i_tail=i_tail+1;
    par.png_tail=png_tail{1};
    par.seed_silh=seed_vect(i_tail);
    output_struct=multi_train_anal_win_cluster_cb(recleannotsilentdataDir,filenames,stringa,par); % better run with xvfb-run - needs a big screen
    output_struct=multi_train_anal_win_silhouette(recleannotsilentdataDir,filenames,stringa,par); % depending on par.nperm this can take a long time
    output_struct=multi_train_plot_win_silhouette(recleannotsilentdataDir,filenames,stringa,par);
    output_struct=multi_train_anal_compute_id(recleannotsilentdataDir,filenames,stringa,par);
    output_struct=multi_train_anal_win_violin(recleannotsilentdataDir,filenames,stringa,par);
end

% return % this will not terminate execution here if script is submitted from the terminal: matlab < script.m
% exit % this will

output_struct=analyze_sleep_scoring_Form22(sleepDir,filenames,stringa,par);

% DECODING
par.Job.Lambda=10^6;
par.Job.nFoldValidation=1000; % v@c, c@v, v_sub (nFoldValidation=1000)
par.Job.nPerm=1000; % single
% par.Job.nPerm=100; % pair
% par.Job.nFoldValidation=10; % dummy values for quick check
% par.Job.nPerm=20; % dummy values for quick check
par.Job.NullString='220123n'; % 1000 perm 1000 fold
par.Job.LambdaString='220123'; % 1000 fold

par.Job.vDecodeTypeMulti = [1]; % 1 'wake_vs_nrem'
par.Job.vDecodeMode = [1 2]; % 1  single, 2 pair

par.Job.iDecodeMode = par.Job.vDecodeMode(1);
par.Job.iDecodeTypeMulti = par.Job.vDecodeTypeMulti(1);

nfiles=length(filenames);

% within-recording decoding
for ifile=1:nfiles
    for iDecodeMode = par.Job.vDecodeMode
        par.Job.iDecodeMode = iDecodeMode;
        for iDecodeTypeMulti = par.Job.vDecodeTypeMulti
            par.Job.iDecodeTypeMulti=iDecodeTypeMulti;
            decodeEachFile(recleannotsilentdataDir,filenames{ifile},stringa,par);
            % decodeEachFile_perm(recleannotsilentdataDir,filenames{ifile},stringa,par); % this can take a long time ... consider using distribute_analysis_qsub below
        end
    end
end

% LORO decoding
for iDecodeMode = par.Job.vDecodeMode
    par.Job.iDecodeMode = iDecodeMode;
    for iDecodeTypeMulti = par.Job.vDecodeTypeMulti
        par.Job.iDecodeTypeMulti=iDecodeTypeMulti;
        decodeAll(recleannotsilentdataDir,filenames,stringa,par);
        % decodeAll_perm(recleannotsilentdataDir,filenames,stringa,par); % this can take a long time ... consider using distribute_analysis_qsub or distribute_analysis_field_qsub below
    end
end

% stringa_mfile={'decodeEachFile_perm'}; % for single and pair within-recording (distributing over recordings)
% stringa_mfile={'decodeAll_perm'}; % for single LORO (distributing over recordings)
stringa_mfile={'decodeEachFile_perm','decodeAll_perm'}; % (distributing over recordings)
% stringa_mfile={'decode_perm'}; % for pair LORO (distributing over outer measures)
for iDecodeMode = par.Job.vDecodeMode
    par.Job.iDecodeMode = iDecodeMode;
    for iDecodeTypeMulti = par.Job.vDecodeTypeMulti
        par.Job.iDecodeTypeMulti=iDecodeTypeMulti;
        output_struct=distribute_analysis_qsub(recleannotsilentdataDir,filenames,stringa,stringa_mfile,par); % this distributes stringa_mfile jobs across recordings
        % output_struct=distribute_analysis_field_qsub(recleannotsilentdataDir,filenames,stringa,stringa_mfile,par); % this distributes stringa_mfile jobs across measures
    end
end


% PLOTTING DECODING RESULTS

png_tails={'','_bs'}; % extended set of measures (multiple time scales, or "ms"), core set of measures (best time scale, or "bs")
% png_tails={'_bs'}; % core set only
% png_tails={''}; % extended set only

for ifile=1:nfiles
    for iDecodeMode = par.Job.vDecodeMode
        par.Job.iDecodeMode = iDecodeMode;
        for iDecodeTypeMulti = par.Job.vDecodeTypeMulti
            par.Job.iDecodeTypeMulti=iDecodeTypeMulti;
            for png_tail=png_tails
                par.png_tail=png_tail{1};
                plot_decodeEachFile_cb(recleannotsilentdataDir,filenames{ifile},stringa,par); % fig_decoding_pair_M1R1
            end
        end
    end
end

for iDecodeMode = par.Job.vDecodeMode
    par.Job.iDecodeMode = iDecodeMode;
    for iDecodeTypeMulti = par.Job.vDecodeTypeMulti
        par.Job.iDecodeTypeMulti=iDecodeTypeMulti;
        for png_tail=png_tails
        % for png_tail=png_tails(2)
            par.png_tail=png_tail{1};
            plot_decode_all_cb(recleannotsilentdataDir,filenames,stringa,par); % fig_decoding_pair_median
        end
    end
end


for iDecodeMode = par.Job.vDecodeMode
    par.Job.iDecodeMode = iDecodeMode;
    for iDecodeTypeMulti = par.Job.vDecodeTypeMulti
        par.Job.iDecodeTypeMulti=iDecodeTypeMulti;
        for png_tail=png_tails
        % for png_tail=png_tails(2)
            par.png_tail=png_tail{1};
            plot_decode_LORO_cb(recleannotsilentdataDir,filenames,stringa,par);
        end
    end
end
