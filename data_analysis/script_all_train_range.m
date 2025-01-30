stringa_dir='train_range';

clear par;
par=[];

par.names_string='050723'; % this identifies features extracted from output_all_ms.mat and output_all_fooof.mat and output_all_synfireind.mat

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

par.tau_vect=[2.^[0:6]];

par.f{2}.ranged4_vect_plot=[1 2]; % (duty_cycle=0.4 , 0.2)
par.f{4}.ranged3_vect_plot=[1 2]; % (duty_cycle=0.4 , 0.2)


output_struct=multi_all_train_range_anal_ms_cluster_bal(stringa_dir,par); % better run with xvfb-run - needs a big screen

output_struct=multi_all_train_range_anal_ms_pca_bal(stringa_dir,par);


output_struct=multi_all_train_range_anal_bs_cluster_bal(stringa_dir,par); % better run with xvfb-run - needs a big screen

output_struct=multi_all_train_range_anal_bs_pca_bal(stringa_dir,par);



png_tails={'','_bs'}; % extended set of measures (multiple time scales, or "ms"), core set of measures (best time scale, or "bs")
for png_tail=png_tails
    par.png_tail=png_tail{1};
    output_struct=multi_all_train_range_anal_compute_id(stringa_dir,par);
end
