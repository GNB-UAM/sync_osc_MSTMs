function output_struct=multi_train_anal_compute_id(dataDir,filenames,stringa,par)
% this code estimates ID for bio spike train datasets. Requires Python>= 3.7 with DADApy installed. Setting py.sys.path manually might be necessary.

PLOT.print=1;

figDir=['~/neuron/sync_osc/' stringa];

if ~exist(figDir,'dir')
    mkdir(figDir);
end

par_global=par; % probably unused

nfiles=length(filenames);

t_refr=4.;
n_neu=400;    % number of neurons
rate=12.; % avg rate [Hz]
r_osc_ampl=0.5;    % relative amplitude of the sinusoidal modulation (between 0 and 1)
transient=0.0;      % simulation time with STDP off
sim_time=10000;
seed=0;
inct=0.01;        % simulation time step
Rp_dt=10.*inct; % time step for population spike binning
n_neu_min=27; % we only consider recordings with n_neu_this>n_neu_min (that is, we disregard site5-rn1 - 16 neu - and site6-rn16 - 23 neu)

par_string={'t_refr','n_neu','rate','r_osc_ampl','transient','sim_time','seed','inct','Rp_dt','n_neu_min'};

for i=1:length(par_string)
    if(isfield(par,par_string(i)))
        eval([char(par_string(i)) '=par.' char(par_string(i)) ';']);
    end
end


for i=1:length(par_string)
    eval(['par.' char(par_string(i)) '=' char(par_string(i)) ';']);
end


if isempty(par.png_tail)
    get_field_names;
    FontSizeThis=4;
elseif strcmp(par.png_tail,'_bs')
    get_field_names_bs;
    FontSizeThis=10;
else
    keyboard;
end


win_duration=30000; % 30s
max_n_sample=100; % max number of samples of n_neu_min neurons extracted from the total number of available neurons
par_this=par;
par_this.n_neu=n_neu_min;    % number of neurons
nwin=floor(sim_time/win_duration);
par_this.sim_time=win_duration;
par_this.plot_win_zoom=win_duration/3;

nfiles2use=nfiles-2;

i_train=0;

color_vect_eachfile=distinguishable_colors(nfiles);
ifile2use=0;
% win_names=cell(1,nfiles2use*nwin);
% filenames2use=cell(1,nfiles2use);

for ifile=1:nfiles
    clear spiketimes n_spikes t_first t_last min_isi n_short_isi percent_short_isi;
    filethis=load(fullfile(dataDir,filenames{ifile}));
    if isfield(filethis,'spk')
        n_neu_this=length(filethis.spk);
    elseif isfield(filethis,'spiketimes')
        n_neu_this=length(filethis.spiketimes);
    elseif isfield(filethis,'spiketimes_clean')
        n_neu_this=length(filethis.spiketimes_clean);
    else
        fieldnamesthis=fieldnames(filethis);
        n_neu_this=length(filethis.(fieldnamesthis{1})); % if there is more than one variable, this might not work
        keyboard;
    end
    if isfield(filethis,'par')
        if isfield(filethis.par,'sim_time') % use recording-specific sim_time if available
            sim_time=filethis.par.sim_time;
            nwin=floor(sim_time/win_duration);
            if ifile==1
                clear sync_all; % cannot preallocate if recording-specific sim_time is used
            end
        end
    end
    if n_neu_this<n_neu_min
        continue;
    else
        ifile2use=ifile2use+1;
        filenames2use{ifile2use}=filenames{ifile};
        if n_neu_this==n_neu_min % minimum number of neurons: no sampling
            n_sample=1;
        elseif n_neu_this==(n_neu_min+1) % just one more neuron than the minimum number:exhaustive sampling is feasible
            n_sample=n_neu_this; % all possible combinations
        else
            n_sample=max_n_sample; % max_n_sample=100<nchoosek(29,2)=406 , hence we just select random samplings without repetitions
        end
        mat_ind=strfind(filenames{ifile},'.mat'); % some have mat, some not
        if isempty(mat_ind)
            for ind_out=1:length(measure_mat_files)
                filename_string{ind_out}=strcat(filenames{ifile},['_' measure_mat_files{ind_out} '.mat']);
            end
        else
            for ind_out=1:length(measure_mat_files)
                filename_string{ind_out}=strrep(filenames{ifile},'.mat',['_' measure_mat_files{ind_out} '.mat']);
            end
        end
        if exist(fullfile(dataDir,filename_string{1}),'file')
            for ind_out=1:length(measure_mat_files)
                output_this{ind_out}=load(fullfile(dataDir,filename_string{ind_out}));
            end
        else
            for ind_out=1:length(measure_mat_files)
                output_this{ind_out}=load(fullfile(dataDir,strrep(filename_string{ind_out},'.mat','_sofar.mat')));
            end
        end

        for i_sample=1:1 % we just consider i_sample=1 for the time being
            for iwin=1:nwin
                i_train=i_train+1;

                for kk=1:length(field_names)
                    try
                        sync_all(kk,i_train)=output_this{file_ind(kk)}.output_measures.([field_names{kk} '_all'])(i_sample,iwin); % dynamic field referencing
                        win_names{i_train}=num2str(iwin);
                        color_vect_all(i_train,:)=color_vect_eachfile(ifile2use,:);
                    catch
                        sync_all(kk,i_train)=NaN;
                        keyboard;
                    end
                end
            end
        end
    end
end

mystyle = hgexport('factorystyle');
mystyle.Units='normalized';
mystyle.FontMode='none';

% cmap_parula=colormap; % Colormap 'default' option for heatmap displays the blue colormap instead of parula - Behavior changed in R2020b
cmap_parula=colormap(parula(64));
% ncolors=48;
ncolors=64;

fprintf('%i samples and %i features before removing NaNs\n',size(sync_all,2),size(sync_all,1));

wins_w_nans=any(isnan(sync_all));

sync_all_rm_win=sync_all(:,~wins_w_nans);

sync_all_rm_win_zs=zscore(sync_all_rm_win,0,2); % z-scoring across columns, for visualization only since corr distance already normalizes

sync_all_rm_win_zs=sync_all_rm_win_zs'; % better to have samples running across rows, features across columns

fprintf('%i samples and %i features after removing NaN wins\n',size(sync_all_rm_win_zs,1),size(sync_all_rm_win_zs,2));

% RUN ONE OF THESE JUST ONCE
% pyenv(ExecutionMode="OutOfProcess"); % this might help avoiding crashes - does not seem necessary if pyenv is called at the start
% pyenv(Version="/home/fabiano/anaconda3/bin/python",ExecutionMode="OutOfProcess"); % 3.8
% pyenv(Version="/usr/bin/python3.9",ExecutionMode="OutOfProcess")
% pyenv(Version="/home/fabiano/venv/bin/python3.9",ExecutionMode="OutOfProcess") % loading the python executable from the virtual environment might result in the corresponding packages being imported? No, the folder needs to be included in the path as done below

% uncomment below as needed and corresponding to the python version selected above (3.8 or 3.9)
P = py.sys.path;
if count(P,'/home/fabiano/.local/lib/python3.8/site-packages') == 0 % maybe I have to do this for every package? no, it does not seem necessary
    insert(P,int32(0),'/home/fabiano/.local/lib/python3.8/site-packages'); % this modifies both P and the output of py.sys.path
end
% if count(P,'/home/fabiano/venv/lib/python3.9/site-packages') == 0 % maybe I have to do this for every package? no, it does not seem necessary
%     insert(P,int32(0),'/home/fabiano/venv/lib/python3.9/site-packages'); % this modifies both P and the output of py.sys.path
% end
% if count(P,'/home/fabiano/venv/lib/python3.9/site-packages/dadapy') == 0 % not needed
%     insert(P,int32(0),'/home/fabiano/venv/lib/python3.9/site-packages/dadapy');
% end

% range_max=2048;
range_max_rm_win=size(sync_all_rm_win_zs,1)-1; % n_samples-1
[ids_gride_rm_win, ids_err_gride_rm_win, rs_gride_rm_win] = id_scaling_gride(sync_all_rm_win_zs,range_max_rm_win);

N_min = 20;
[ids_twoNN_rm_win, ids_err_twoNN_rm_win, rs_twoNN_rm_win] = id_scaling_2NN(sync_all_rm_win_zs,N_min);

xrange_rm_win = min(length(ids_gride_rm_win), length(ids_twoNN_rm_win));
x_rm_win = size(sync_all_rm_win_zs,1) ./ (2.^(0:(xrange_rm_win-1))); % n° data points entering the calculation % has to be inverted
% x=flip(x); % no, that was a bug in the dadapy tutorial

figure;
set(gcf,'Color',[1 1 1]);
lh(1)=plot(rs_gride_rm_win, ids_gride_rm_win, 'o-', 'DisplayName', 'Gride');
hold on;
jbfill(rs_gride_rm_win, ids_gride_rm_win-ids_err_gride_rm_win,ids_gride_rm_win+ids_err_gride_rm_win,lh(1).Color,lh(1).Color);
hold on;
lh(2)=plot(rs_twoNN_rm_win, ids_twoNN_rm_win, 'o-', 'DisplayName', 'twoNN');
jbfill(rs_twoNN_rm_win, ids_twoNN_rm_win-ids_err_twoNN_rm_win,ids_twoNN_rm_win+ids_err_twoNN_rm_win,lh(2).Color,lh(2).Color);
set(gca, 'XScale', 'log');
ylabel('ID', 'FontSize', 14);
xlabel('distance range', 'FontSize', 14);
legend(lh,'FontSize', 10);
title([stringa, ' : ', num2str(size(sync_all_rm_win_zs, 1)), ' samples, ', num2str(size(sync_all_rm_win_zs, 2)), ' features'], 'FontSize', 15,'FontWeight','normal');
if PLOT.print
    figure_name=[figDir '/' 'id_vs_dist_rm_win' par.png_tail '_' names_string '.png'];
    hgexport(gcf,figure_name,mystyle,'Format','png');
end

figure;
set(gcf,'Color',[1 1 1]);
lh(1)=plot(x_rm_win, ids_gride_rm_win(1:xrange_rm_win), 'o-', 'DisplayName', 'Gride');
hold on;
jbfill(x_rm_win, ids_gride_rm_win(1:xrange_rm_win)-ids_err_gride_rm_win(1:xrange_rm_win),ids_gride_rm_win(1:xrange_rm_win)+ids_err_gride_rm_win(1:xrange_rm_win),lh(1).Color,lh(1).Color);
hold on;
lh(2)=plot(x_rm_win, ids_twoNN_rm_win(1:xrange_rm_win), 'o-', 'DisplayName', 'twoNN');
jbfill(x_rm_win, ids_twoNN_rm_win(1:xrange_rm_win)-ids_err_twoNN_rm_win(1:xrange_rm_win),ids_twoNN_rm_win(1:xrange_rm_win)+ids_err_twoNN_rm_win(1:xrange_rm_win),lh(2).Color,lh(2).Color);
set(gca, 'XScale', 'log');
legend(lh,'FontSize', 10);
ylabel('ID', 'FontSize', 14);
xlabel('n° data', 'FontSize', 14);
title([stringa, ' : ', num2str(size(sync_all_rm_win_zs, 1)), ' samples, ', num2str(size(sync_all_rm_win_zs, 2)), ' features'], 'FontSize', 15,'FontWeight','normal');
if PLOT.print
    figure_name=[figDir '/' 'id_vs_n_rm_win' par.png_tail '_' names_string '.png'];
    hgexport(gcf,figure_name,mystyle,'Format','png');
end













meas_w_nans=any(isnan(sync_all),2);

sync_all_rm_meas=sync_all(~meas_w_nans,:);

sync_all_rm_meas_zs=zscore(sync_all_rm_meas,0,2); % z-scoring across columns, for visualization only since corr distance already normalizes

sync_all_rm_meas_zs=sync_all_rm_meas_zs'; % better to have samples running across rows, features across columns

fprintf('%i samples and %i features after removing NaN measures\n',size(sync_all_rm_meas_zs,1),size(sync_all_rm_meas_zs,2));

range_max_rm_meas=size(sync_all_rm_meas_zs,1)-1; % n_samples-1
[ids_gride_rm_meas, ids_err_gride_rm_meas, rs_gride_rm_meas] = id_scaling_gride(sync_all_rm_meas_zs,range_max_rm_meas);

N_min = 20;
[ids_twoNN_rm_meas, ids_err_twoNN_rm_meas, rs_twoNN_rm_meas] = id_scaling_2NN(sync_all_rm_meas_zs,N_min);

xrange_rm_meas = min(length(ids_gride_rm_meas), length(ids_twoNN_rm_meas));
x_rm_meas = size(sync_all_rm_meas_zs,1) ./ (2.^(0:(xrange_rm_meas-1))); % n° data points entering the calculation % has to be inverted
% x=flip(x); % no, that was a bug in the dadapy tutorial

figure;
set(gcf,'Color',[1 1 1]);
lh(1)=plot(rs_gride_rm_meas, ids_gride_rm_meas, 'o-', 'DisplayName', 'Gride');
hold on;
jbfill(rs_gride_rm_meas, ids_gride_rm_meas-ids_err_gride_rm_meas,ids_gride_rm_meas+ids_err_gride_rm_meas,lh(1).Color,lh(1).Color);
hold on;
lh(2)=plot(rs_twoNN_rm_meas, ids_twoNN_rm_meas, 'o-', 'DisplayName', 'twoNN');
jbfill(rs_twoNN_rm_meas, ids_twoNN_rm_meas-ids_err_twoNN_rm_meas,ids_twoNN_rm_meas+ids_err_twoNN_rm_meas,lh(2).Color,lh(2).Color);
set(gca, 'XScale', 'log');
ylabel('ID', 'FontSize', 14);
xlabel('distance range', 'FontSize', 14);
legend(lh,'FontSize', 10);
title([stringa, ' : ', num2str(size(sync_all_rm_meas_zs, 1)), ' samples, ', num2str(size(sync_all_rm_meas_zs, 2)), ' features'], 'FontSize', 15,'FontWeight','normal');
if PLOT.print
    figure_name=[figDir '/' 'id_vs_dist_rm_meas' par.png_tail '_' names_string '.png'];
    hgexport(gcf,figure_name,mystyle,'Format','png');
end

figure;
set(gcf,'Color',[1 1 1]);
lh(1)=plot(x_rm_meas, ids_gride_rm_meas(1:xrange_rm_meas), 'o-', 'DisplayName', 'Gride');
hold on;
jbfill(x_rm_meas, ids_gride_rm_meas(1:xrange_rm_meas)-ids_err_gride_rm_meas(1:xrange_rm_meas),ids_gride_rm_meas(1:xrange_rm_meas)+ids_err_gride_rm_meas(1:xrange_rm_meas),lh(1).Color,lh(1).Color);
hold on;
lh(2)=plot(x_rm_meas, ids_twoNN_rm_meas(1:xrange_rm_meas), 'o-', 'DisplayName', 'twoNN');
jbfill(x_rm_meas, ids_twoNN_rm_meas(1:xrange_rm_meas)-ids_err_twoNN_rm_meas(1:xrange_rm_meas),ids_twoNN_rm_meas(1:xrange_rm_meas)+ids_err_twoNN_rm_meas(1:xrange_rm_meas),lh(2).Color,lh(2).Color);
set(gca, 'XScale', 'log');
legend(lh,'FontSize', 10);
ylabel('ID', 'FontSize', 14);
xlabel('n° data', 'FontSize', 14);
title([stringa, ' : ', num2str(size(sync_all_rm_meas_zs, 1)), ' samples, ', num2str(size(sync_all_rm_meas_zs, 2)), ' features'], 'FontSize', 15,'FontWeight','normal');
if PLOT.print
    figure_name=[figDir '/' 'id_vs_n_rm_meas' par.png_tail '_' names_string '.png'];
    hgexport(gcf,figure_name,mystyle,'Format','png');
end



save(fullfile(dataDir,['id_output' par.png_tail '_' names_string '.mat']), ...
    'ids_gride_rm_win','ids_err_gride_rm_win','rs_gride_rm_win', ...
    'ids_twoNN_rm_win','ids_err_twoNN_rm_win','rs_twoNN_rm_win', ...
    'xrange_rm_win','x_rm_win',...
    'ids_gride_rm_meas','ids_err_gride_rm_meas','rs_gride_rm_meas', ...
    'ids_twoNN_rm_meas','ids_err_twoNN_rm_meas','rs_twoNN_rm_meas', ...
    'xrange_rm_meas','x_rm_meas',...
    'N_min');

output_struct=[];
return;
