stringa_dir='train_nneu_range'; % for naming output dir
stringa_mfile_osc={'generate_osc_train','analyze_sinosc_train_ms','analyze_sinosc_train_fooof','analyze_sinosc_train_synfireind'};
stringa_mfile_ple={'generate_sinple_train','analyze_sinosc_train_ms','analyze_sinosc_train_fooof','analyze_sinosc_train_synfireind'};

clear par;
par=[];

par.names_string='050723'; % this identifies features extracted from output_all_ms.mat and output_all_fooof.mat and output_all_synfireind.mat

par.suf1='osc';
par.suf2='sinple';

par.r_osc_ampl_vect=[0.:0.25:1.]; % from weak to strong rate modulation

par.n_neu_vect=[4 12 34 100]; % close to logspace(0.6021,2,4) = [4.0004   11.6968   34.2006  100.0000]
par.seed_ind_vect=[1:50];

% par.n_neu=100;
par.sim_time=100000; % in ms
par.t_refr=4.;
par.rate=12.; % avg rate [Hz]
par.f_osc=12.; % network frequency (alpha frequency by default)
par.tau_OUnoise=10;
par.r_osc_ampl=0.5;    % relative amplitude of the rate modulation (between 0 and 1)
par.transient=100;
% par.seed=1001;
par.inct=0.01;        % simulation time step
par.Rp_dt=10.*par.inct; % time step for population spike binning

par.tau_vect=[2.^[0:6]];
par.PLOT_print=0; % flag for (re)generating figures

ranged_par={'par.r_osc_ampl_vect','par.n_neu_vect','par.seed_ind_vect'}; % i,j,k
ranged_stringa={'r_osc_ampl','n_neu','seed_ind'}; % i,j,k

% it should be enough with
% #SBATCH --time=03:00:00
% #SBATCH --mem-per-cpu=4G
output_struct=multi_train_range_qsub(stringa_dir,stringa_mfile_osc,stringa_mfile_ple,par,ranged_par); % use this to distribute jobs in a Slurm queue - this requires licensing for several toolboxes

output_struct=plot_train_all_win(stringa_dir,par,ranged_par,ranged_stringa,'# neurons'); % this generates Fig 5 panels
output_struct=plot_train_all_win_si(stringa_dir,par,ranged_par,ranged_stringa,'# neurons'); % this generates Fig S3 panels
