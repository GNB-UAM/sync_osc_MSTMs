stringa_dir='train_range'; % for naming output dir
stringa_mfile_osc={'generate_oscG_train','analyze_sinosc_train_ms','analyze_sinosc_train_fooof','analyze_sinosc_train_synfireind','plot_sinosc_train'};
stringa_mfile_ple={'generate_expG_train','analyze_sinosc_train_ms','analyze_sinosc_train_fooof','analyze_sinosc_train_synfireind','plot_sinosc_train'};

clear par;
par=[];

par.names_string='050723'; % this identifies features extracted from output_all_ms.mat and output_all_fooof.mat and output_all_synfireind.mat

par.suf1='oscG';
par.suf2='expG';

% swept parameters
par.f_osc_vect=[4. 12. 36.]; % network frequency (delta, alpha, beta)
par.sigmaGpercent_vect=[0.5:-0.1:0.1]; % relative to network period
par.p_fail_vect=[0.8:-0.2:0.];

% % single combination for quick check
% par.f_osc_vect=[12.];
% par.sigmaGpercent_vect=[0.3];
% par.p_fail_vect=[0.4];

% canonical values
par.n_neu=100;
par.sim_time=10000; % in ms
par.t_refr=4.;
par.f_osc=12.; % network frequency (alpha frequency by default)
par.tau_OUnoise=10;
par.transient=100;
par.seed=1001;
par.inct=0.01;        % simulation time step
par.Rp_dt=10.*par.inct; % time step for population spike binning

par.tau_vect=[2.^[0:6]];
par.PLOT_print=1; % flag for (re)generating figures

par.clim_corr_ms=[0.1194    0.9800]; % for multi_train_range_anal_ms_corr
par.clim_corr_bs=[0.1231    0.9800]; % for multi_train_range_anal_bs_corr
par.pos_corr_ms=[0.1213    0.0100    0.8089    0.7547]; % for multi_train_range_anal_ms_corr
par.pos_corr_bs=[0.1191    0.0100    0.7800    0.5313]; % for multi_train_range_anal_bs_corr

par.win_vect=logspace(2.699,4,4);

ranged_par={'par.f_osc_vect','par.sigmaGpercent_vect','par.p_fail_vect'}; % i,j,k
ranged_stringa={'f_osc','sigmaGpercent','p_fail'}; % i,j,k
ranged_stringa_tex={'f_0','\Sigma','p_{fail}'}; % i,j,k

% it should be enough with
% #SBATCH --time=00:30:00
% #SBATCH --mem-per-cpu=16G
output_struct=multi_train_range_qsub(stringa_dir,stringa_mfile_osc,stringa_mfile_ple,par,ranged_par); % use this to distribute jobs in a Slurm queue - this requires licensing for several toolboxes

output_struct=multi_train_range_anal_all_cb(stringa_dir,par,ranged_par,ranged_stringa,ranged_stringa_tex); % this generates Fig 2 panels
output_struct=multi_train_range_anal_all_cb_title(stringa_dir,par,ranged_par,ranged_stringa,ranged_stringa_tex); % this generates Fig S1 panels

