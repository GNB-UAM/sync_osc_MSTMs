stringa_dir='train_win_range';

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

par.f{1}.stringa_dir='train_win_range';
par.f{2}.stringa_dir='train_win_range';
par.f{3}.stringa_dir='train_win_range';
par.f{4}.stringa_dir='train_win_range';


par.f{1}.r_osc_ampl_vect=[0.:0.25:1.]; % from weak to strong rate modulation
par.f{1}.sim_time_vect=[500 3000 20000 100000]; % in ms
par.f{1}.seed_ind_vect=[1:50];

par.f{2}.r_osc_ampl_vect=[0.:0.25:1.]; % from weak to strong rate modulation
par.f{2}.sim_time_vect=[500 3000 20000 100000]; % in ms
par.f{2}.seed_ind_vect=[1:50];

par.f{3}.sigmaGpercent_vect=[0.2 0.1 0.05]; % relative to network period
par.f{3}.sim_time_vect=[500 3000 20000 100000]; % in ms
par.f{3}.seed_ind_vect=[1:50];

par.f{4}.sigmaGpercent_vect=[0.2 0.1 0.05]; % relative to network period
par.f{4}.sim_time_vect=[500 3000 20000 100000]; % in ms
par.f{4}.seed_ind_vect=[1:50];

par.f{1}.ranged_par={'r_osc_ampl_vect','sim_time_vect','seed_ind_vect'}; % i,j,k
par.f{2}.ranged_par={'r_osc_ampl_vect','sim_time_vect','seed_ind_vect'};
par.f{3}.ranged_par={'sigmaGpercent_vect','sim_time_vect','seed_ind_vect'};
par.f{4}.ranged_par={'sigmaGpercent_vect','sim_time_vect','seed_ind_vect'};

par.tau_vect=[2.^[0:6]];

% if desired, only a subset of indexes can be selected, as in the example below
% par.f{1}.ranged1_vect_plot=[2 3 5]; % "corresponding" values
% par.f{2}.ranged1_vect_plot=[2 3 5]; % "corresponding" values
% par.f{3}.ranged1_vect_plot=[1:3]; % all values
% par.f{4}.ranged1_vect_plot=[1:3]; % all values


par.bias_abscv_pos=[0.1486    0.2904    0.7564    0.6346];

par.stringa_title='ms window';
png_tails={'','_bs'}; % extended set of measures (multiple time scales, or "ms"), core set of measures (best time scale, or "bs")
% for png_tail=png_tails
for png_tail=png_tails(2)
    par.png_tail=png_tail{1};
    output_struct=analyze_train_ms_all_win_mean(stringa_dir,par)
end
return;
