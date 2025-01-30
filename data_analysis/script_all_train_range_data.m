stringa_dir='train_range';

clear par;
par=[];

par.names_string='050723'; % this identifies features extracted from output_all_ms.mat and output_all_fooof.mat and output_all_synfireind.mat

% names and parameter ranges for each synthetic spike train family
par.f{1}.suf1='osc';
par.f{1}.suf2='sinple';
par.f{2}.suf1='oscseq';
par.f{2}.suf2='sinpleseq';
par.f{3}.suf1='oscG';
par.f{3}.suf2='expG';
par.f{4}.suf1='oscGseq';
par.f{4}.suf2='expGseq';

par.f{1}.rate_vect=[1. 4. 8. 12. 36.];
par.f{1}.f_osc_vect=[4. 12. 36.]; % network frequency (delta, alpha, beta)
par.f{1}.r_osc_ampl_vect=[0.:0.25:1.]; % from weak to strong rate modulation

par.f{2}.rate_vect=[1. 4. 8. 12. 36.];
par.f{2}.f_osc_vect=[4. 12. 36.]; % network frequency (delta, alpha, beta)
par.f{2}.r_osc_ampl_vect=[0.:0.25:1.]; % from weak to strong rate modulation
par.f{2}.duty_cycle_vect=[0.4 0.2 0.1];

par.f{3}.f_osc_vect=[4. 12. 36.]; % network frequency (delta, alpha, beta)
par.f{3}.sigmaGpercent_vect=[0.5:-0.1:0.1]; % relative to network period
par.f{3}.p_fail_vect=[0.8:-0.2:0.];

par.f{4}.f_osc_vect=[4. 12. 36.]; % network frequency (delta, alpha, beta)
par.f{4}.sigmaGpercent_vect=[0.5:-0.1:0.1]; % relative to network period
par.f{4}.duty_cycle_vect=[0.4 0.2 0.1];
par.f{4}.p_fail_vect=[0.8:-0.2:0.];


par.f{1}.ranged_par={'rate_vect','f_osc_vect','r_osc_ampl_vect'}; % i,j,k
par.f{2}.ranged_par={'rate_vect','f_osc_vect','r_osc_ampl_vect','duty_cycle_vect'}; % i,j,k,l
par.f{3}.ranged_par={'f_osc_vect','sigmaGpercent_vect','p_fail_vect'}; % i,j,k
par.f{4}.ranged_par={'f_osc_vect','sigmaGpercent_vect','duty_cycle_vect','p_fail_vect'}; % i,j,k,l


% for each bio dataset, add (preprocessed) data dir and identifying labels
par.d{1}.dataDir='/media/fabiano/Porsche/data/See2021/ReCleanNotSilentData';
par.d{1}.stringa='rat A1'; % short version, uncleaned data won't be used here
par.d{1}.vsstringa='rat'; % very short version, uncleaned data won't be used here

par.d{2}.dataDir='/media/fabiano/Porsche/data/Formozov21/data_and_scripts/spikes_spontaneous_reclean_notsilent/';
par.d{2}.stringa='mouse CA1';
par.d{2}.vsstringa='mouse';

par.d{3}.dataDir='/media/fabiano/Porsche/data/Smith08/data_and_scripts/spikes_spontaneous_reclean_notsilent/';
par.d{3}.stringa='monkey V1';
par.d{3}.vsstringa='monkey';



png_tails={'','_bs'}; % extended set of measures (multiple time scales, or "ms"), core set of measures (best time scale, or "bs")
for png_tail=png_tails
% for png_tail=png_tails(2)
    par.png_tail=png_tail{1};
    output_struct=multi_all_train_range_data_anal_cluster_bal_compare(stringa_dir,par); % Generates Fig S11 panels.
    output_struct=multi_all_train_range_data_anal_pca_bal_compare(stringa_dir,par); % Generates Fig 12A panels.
    output_struct=multi_all_train_range_data_anal_plot_id(stringa_dir,par); % Generates Fig 12B panels.
end
