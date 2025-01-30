stringa_dir='train_nneu_range';

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

par.f{1}.stringa_dir='train_nneu_range';
par.f{2}.stringa_dir='train_nneu_range';
par.f{3}.stringa_dir='train_nneu_range';
par.f{4}.stringa_dir='train_nneu_range';


par.f{1}.r_osc_ampl_vect=[0.:0.25:1.]; % from weak to strong rate modulation
par.f{1}.n_neu_vect=[4 12 34 100]; % close to logspace(0.6021,2,4) = [4.0004   11.6968   34.2006  100.0000]
par.f{1}.seed_ind_vect=[1:50];

par.f{2}.r_osc_ampl_vect=[0.:0.25:1.]; % from weak to strong rate modulation
par.f{2}.n_neu_vect=[4 12 34 100]; % close to logspace(0.6021,2,4) = [4.0004   11.6968   34.2006  100.0000]
par.f{2}.seed_ind_vect=[1:50];

par.f{3}.sigmaGpercent_vect=[0.2 0.1 0.05]; % relative to network period
par.f{3}.n_neu_vect=[4 12 34 100]; % close to logspace(0.6021,2,4) = [4.0004   11.6968   34.2006  100.0000]
par.f{3}.seed_ind_vect=[1:50];

par.f{4}.sigmaGpercent_vect=[0.2 0.1 0.05]; % relative to network period
par.f{4}.n_neu_vect=[4 12 34 100]; % close to logspace(0.6021,2,4) = [4.0004   11.6968   34.2006  100.0000]
par.f{4}.seed_ind_vect=[1:50];

par.f{1}.ranged_par={'r_osc_ampl_vect','n_neu_vect','seed_ind_vect'}; % i,j,k
par.f{2}.ranged_par={'r_osc_ampl_vect','n_neu_vect','seed_ind_vect'};
par.f{3}.ranged_par={'sigmaGpercent_vect','n_neu_vect','seed_ind_vect'};
par.f{4}.ranged_par={'sigmaGpercent_vect','n_neu_vect','seed_ind_vect'};

par.tau_vect=[2.^[0:6]];

% if desired, only a subset of indexes can be selected, as in the example below
% par.f{1}.ranged1_vect_plot=[2 3 5]; % "corresponding" values
% par.f{2}.ranged1_vect_plot=[2 3 5]; % "corresponding" values
% par.f{3}.ranged1_vect_plot=[1:3]; % all values
% par.f{4}.ranged1_vect_plot=[1:3]; % all values


par.bias_abscv_pos=[0.1486    0.2904    0.7564    0.6346];
par.bias_abscv_xl_norm=[0.5000 -0.3001 0];

par.stringa_title=' neurons';
png_tails={'','_bs'}; % extended set of measures (multiple time scales, or "ms"), core set of measures (best time scale, or "bs")
% for png_tail=png_tails
for png_tail=png_tails(2)
    par.png_tail=png_tail{1};
    output_struct=analyze_train_ms_all_win_mean(stringa_dir,par)
end
return;
