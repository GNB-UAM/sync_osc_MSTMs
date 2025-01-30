stringa_dir='train_range';

clear par;
par=[];

par.names_string='050723'; % this identifies features extracted from output_all_ms.mat and output_all_fooof.mat and output_all_synfireind.mat

par.f{3}.suf1='oscG';
par.f{3}.suf2='expG';
par.f{4}.suf1='oscGseq';
par.f{4}.suf2='expGseq';

par.f{3}.f_osc_vect=[4. 12. 36.]; % network frequency (delta, alpha, beta)
par.f{3}.sigmaGpercent_vect=[0.5:-0.1:0.1]; % relative to network period
par.f{3}.p_fail_vect=[0.8:-0.2:0.];

par.f{4}.f_osc_vect=[4. 12. 36.]; % network frequency (delta, alpha, beta)
par.f{4}.sigmaGpercent_vect=[0.5:-0.1:0.1]; % relative to network period
par.f{4}.duty_cycle_vect=[0.4 0.2 0.1];
par.f{4}.p_fail_vect=[0.8:-0.2:0.];


% for multi_all_train_range_anal_corr_bal
% par.clim_corr=[0     1];
par.clim_corr=[0.1194    0.9800];
par.clim_corr_bs=[0.1198    0.9680];
par.pos_corr=[0.1300    0.1100    0.7750    0.5893];
par.pos_corr_bs=[0.1300    0.1100    0.7744    0.3298];


par.f{3}.ranged_par={'f_osc_vect','sigmaGpercent_vect','p_fail_vect'}; % i,j,k
par.f{4}.ranged_par={'f_osc_vect','sigmaGpercent_vect','duty_cycle_vect','p_fail_vect'}; % i,j,k,l

par.ranged_stringa_tex={'f_0','\Sigma','D_c','p_{fail}'}; % fine to have just one for all stf. only used in multi_all_train_range_anal_corr_bal.m

par.tau_vect=[2.^[0:6]];

par.f{4}.ranged3_vect_plot=[1 2]; % (duty_cycle=0.4 , 0.2)

par.f=par.f(~cellfun('isempty',par.f));

output_struct=multi_all_train_range_anal_ms_cluster_bal(stringa_dir,par,'_ds');

output_struct=multi_all_train_range_anal_ms_pca_bal(stringa_dir,par,'_ds','all dual-scale');


output_struct=multi_all_train_range_anal_bs_cluster_bal(stringa_dir,par,'_ds');

output_struct=multi_all_train_range_anal_bs_pca_bal(stringa_dir,par,'_ds','all dual-scale');

png_tails={'','_bs'}; % extended set of measures (multiple time scales, or "ms"), core set of measures (best time scale, or "bs")
for png_tail=png_tails
% for png_tail=png_tails(2)
    par.png_tail=png_tail{1};
    eval(['output_struct' par.png_tail '=multi_all_train_range_anal_corr_bal(stringa_dir,par,''_ds'',2);']);
    output_struct=multi_all_train_range_anal_compute_id(stringa_dir,par,'_ds');
end
