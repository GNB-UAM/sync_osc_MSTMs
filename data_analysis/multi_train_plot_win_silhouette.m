function output_struct=multi_train_plot_win_silhouette(dataDir,filenames,stringa,par)
% this code loads and plots the results of the Silhouette score analysis

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

fprintf(['Total nuber of ' strrep(par.png_tail,'_','') ' measures:%i\n'],length(field_names_wc_ms));
fprintf('Uni:%i\n',n_uni);
fprintf('Bi:%i\n',n_bi);
fprintf('Multi:%i\n',n_multi);
fprintf('Bi+Multi:%i\n\n',n_bi+n_multi);


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
% win_names=cell(1,nfiles2use*nwin); % nwin might be different for each recording, we can't easily know it in advance
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
    if n_neu_this<n_neu_min
        continue;
    else
        ifile2use=ifile2use+1;
        filenames2use{ifile2use}=filenames{ifile};

        if isfield(filethis,'par') % use recording-specific sim_time if available
            if isfield(filethis.par,'sim_time') % use recording-specific sim_time if available
                sim_time=filethis.par.sim_time;
                nwin=floor(sim_time/win_duration);
                nwin_vect(ifile2use)=nwin;
                if ifile2use==1
                    clear sync_all; % cannot preallocate if recording-specific sim_time is used
                end
            else
                nwin_vect(ifile2use)=nwin;
            end
        else
            nwin_vect(ifile2use)=nwin;
        end
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
                        win_rank(i_train)=iwin/nwin; % relative to each recording nwin
                        color_vect_all(i_train,:)=color_vect_eachfile(ifile2use,:);
                        sess_id(i_train)=ifile2use;
                    catch
                        sync_all(kk,i_train)=NaN;
                        keyboard;
                    end
                end
            end
        end
    end
end



stringa=['feat_analyze_' stringa];

mystyle = hgexport('factorystyle');
mystyle.Units='normalized';
mystyle.FontMode='none';

if startsWith(filenames2use{1},'spiketimes') % stripping file names for Smith08
    for ifile=1:length(filenames2use)
        filenames2use{ifile}=filenames2use{ifile}(11:17); % 'monkey1', etc.
    end
end
% we need short file names
if startsWith(filenames2use{1},'site') % stripping file names for See18
    for ifile=1:length(filenames2use)
        ind_stop=strfind(filenames2use{ifile},'-');
        filenames2use_short{ifile}=[filenames2use{ifile}(1) filenames2use{ifile}(5:(ind_stop-1))]; % 's1', etc.
    end
elseif startsWith(filenames2use{1},'monkey') % stripping file names for Smith08
    for ifile=1:length(filenames2use)
        filenames2use_short{ifile}=[filenames2use{ifile}(1) filenames2use{ifile}(7)]; % 'm1', etc.
    end
else
    filenames2use_short=filenames2use;
end

for ifile=1:length(filenames2use)
    filenames2use_wc{ifile}=['\color[rgb]{' sprintf('%f,%f,%f',color_vect_eachfile(ifile,1),color_vect_eachfile(ifile,2),color_vect_eachfile(ifile,3)) '}' strrep(filenames2use{ifile},'.mat','')];
    filenames2use_short_wc{ifile}=['\color[rgb]{' sprintf('%f,%f,%f',color_vect_eachfile(ifile,1),color_vect_eachfile(ifile,2),color_vect_eachfile(ifile,3)) '}' strrep(filenames2use_short{ifile},'.mat','')];
end


% cmap_parula=colormap; % Colormap 'default' option for heatmap displays the blue colormap instead of parula - Behavior changed in R2020b
cmap_parula=colormap(parula(64));
% ncolors=48;
ncolors=64;

nwin_cum_vect=[0 cumsum(nwin_vect)];

printf('Number of windows per recording file:');
nwin_vect

nanzscore = @(X,FLAG,DIM) bsxfun(@rdivide, bsxfun(@minus, X, nanmean(X,DIM)), nanstd(X,FLAG,DIM));
sync_all_zs=nanzscore(sync_all,0,2); % z-scoring across columns, for visualization only since corr distance already normalizes

load(fullfile(dataDir,['silhouette_output' par.png_tail '_' names_string '.mat'])); % this loads silh_eucl_perm_vect

figure;
set(gcf,'Color',[1 1 1]);
[silh_eucl_vect,silh_eucl_h]=nansilhouette_colorlab(sync_all_zs',sess_id,color_vect_all,filenames2use_short_wc,@euclidean_pairwise);
hold on
silh_eucl_mean=mean(silh_eucl_vect);
plot(silh_eucl_mean*ones(1,2),ylim,'r');
silh_eucl_thr=prctile(silh_eucl_perm_vect,sign_level_vect);
% plot(silh_eucl_thr(1)*ones(1,2),ylim,'Color',0.8*ones(1,3),'LineStyle','--'); % p=0.01
% plot(silh_eucl_thr(2)*ones(1,2),ylim,'Color',0.8*ones(1,3),'LineStyle',':'); % p=0.001
plot(silh_eucl_thr(2)*ones(1,2),ylim,'Color',0.8*ones(1,3),'LineStyle','--'); % p=0.001
xlabel('silhouette score');
ylabel('time windows');
set(gcf,'Position',[680    39   550   923]);
if PLOT.print
    figure_name=fullfile(figDir,'sync_all_win_silhouette_eucl_highres');
    export_fig(gcf,[figure_name par.png_tail '_' names_string '.png'],'-m2');
end


output_struct=[];

return
