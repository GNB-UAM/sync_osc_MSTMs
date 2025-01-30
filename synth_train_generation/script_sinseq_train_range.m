stringa_dir='train_range'; % for naming output dir
stringa_mfile_osc={'generate_oscseq_train','analyze_sinosc_train_ms','analyze_sinosc_train_fooof','analyze_sinosc_train_synfireind','plot_sinosc_train'};
stringa_mfile_ple={'generate_sinpleseq_train','analyze_sinosc_train_ms','analyze_sinosc_train_fooof','analyze_sinosc_train_synfireind','plot_sinosc_train'};

clear par;
par=[];

par.names_string='050723'; % this identifies features extracted from output_all_ms.mat and output_all_fooof.mat and output_all_synfireind.mat

par.suf1='oscseq';
par.suf2='sinpleseq';

% swept parameters
par.rate_vect=[1. 4. 8. 12. 36.];
par.f_osc_vect=[4. 12. 36.]; % network frequency (delta, alpha, beta)
par.r_osc_ampl_vect=[0.:0.25:1.]; % from weak to strong rate modulation
par.duty_cycle_vect=[0.4 0.2 0.1];

% % single combination for quick check
% par.rate_vect=[8.];
% par.f_osc_vect=[12.];
% par.r_osc_ampl_vect=[0.5];
% par.duty_cycle_vect=[0.2];

% canonical values
par.n_neu=100;
par.sim_time=10000; % in ms
par.t_refr=4.;
par.rate=12.; % avg rate [Hz]
par.f_osc=12.; % network frequency (alpha frequency by default)
par.tau_OUnoise=10;
par.r_osc_ampl=0.5;    % relative amplitude of the rate modulation (between 0 and 1)
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

ranged_par={'par.rate_vect','par.f_osc_vect','par.r_osc_ampl_vect','par.duty_cycle_vect'}; % i,j,k,l
ranged_stringa={'rate','f_osc','r_osc_ampl','duty_cycle_vect'}; % i,j,k,l

% it should be enough with
% % #SBATCH --time=00:30:00 % might not be enough
% #SBATCH --time=02:00:00
% #SBATCH --mem-per-cpu=16G
output_struct=multi_train_4Drange_qsub(stringa_dir,stringa_mfile_osc,stringa_mfile_ple,par,ranged_par); % use this to distribute jobs in a Slurm queue - this requires licensing for several toolboxes


