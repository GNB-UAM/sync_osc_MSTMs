stringa_dir='train_range';

clear par;
par=[];

par.names_string='050723'; % this identifies features extracted from output_all_ms.mat and output_all_fooof.mat and output_all_synfireind.mat

par.f{1}.suf1='osc';
par.f{1}.suf2='sinple';
par.f{2}.suf1='oscseq';
par.f{2}.suf2='sinpleseq';

par.f{1}.rate_vect=[1. 4. 8. 12. 36.];
par.f{1}.f_osc_vect=[4. 12. 36.]; % network frequency (delta, alpha, beta)
par.f{1}.r_osc_ampl_vect=[0.:0.25:1.]; % from weak to strong rate modulation

par.f{2}.rate_vect=[1. 4. 8. 12. 36.];
par.f{2}.f_osc_vect=[4. 12. 36.]; % network frequency (delta, alpha, beta)
par.f{2}.r_osc_ampl_vect=[0.:0.25:1.]; % from weak to strong rate modulation
par.f{2}.duty_cycle_vect=[0.4 0.2 0.1];

% for multi_all_train_range_anal_corr_bal
% par.clim_corr=[0     1];
par.clim_corr=[0.1194    0.9800];
par.clim_corr_bs=[0.1198    0.9680];
par.pos_corr=[0.1300    0.1100    0.7750    0.5893];
par.pos_corr_bs=[0.1300    0.1100    0.7744    0.3298];


par.f{1}.ranged_par={'rate_vect','f_osc_vect','r_osc_ampl_vect'}; % i,j,k
par.f{2}.ranged_par={'rate_vect','f_osc_vect','r_osc_ampl_vect','duty_cycle_vect'}; % i,j,k,l

par.ranged_stringa_tex={'r_0','f_0','m','D_c'}; % fine to have just one for all stf. only used in multi_all_train_range_anal_corr_bal.m

par.tau_vect=[2.^[0:6]];

par.f{2}.ranged4_vect_plot=[1 2]; % (duty_cycle=0.4 , 0.2)

output_struct=multi_all_train_range_anal_ms_cluster_bal(stringa_dir,par,'_ss');

output_struct=multi_all_train_range_anal_ms_pca_bal(stringa_dir,par,'_ss','all single-scale');


output_struct=multi_all_train_range_anal_bs_cluster_bal(stringa_dir,par,'_ss');

output_struct=multi_all_train_range_anal_bs_pca_bal(stringa_dir,par,'_ss','all single-scale');



png_tails={'','_bs'}; % extended set of measures (multiple time scales, or "ms"), core set of measures (best time scale, or "bs")
for png_tail=png_tails
% for png_tail=png_tails(2)
    par.png_tail=png_tail{1};
    eval(['output_struct' par.png_tail '=multi_all_train_range_anal_corr_bal(stringa_dir,par,''_ss'',3);']);
    output_struct=multi_all_train_range_anal_compute_id(stringa_dir,par,'_ss');
end
