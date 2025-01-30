function output_struct=multi_train_anal_win_cluster(dataDir,filenames,stringa,par)
% this code performs clustering of time windows

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
                    catch
                        sync_all(kk,i_train)=NaN;
                        keyboard;
                    end
                end
            end
        end
    end
end

output_this=load(fullfile(dataDir,['cluster_output' par.png_tail '_' names_string '.mat'])); % loading the results of clustering across measures, for ordering measures for visualization purposes


stringa=['feat_analyze_' stringa];

mystyle = hgexport('factorystyle');
mystyle.Units='normalized';
mystyle.FontMode='none';

mystyle_highres=mystyle;
mystyle_highres.Resolution=300; % best option for final figures

if strfind(filenames2use{1},'-') % stripping -rn1 or -rn16 for See18
    for ifile=1:length(filenames2use)
        ind_dash=strfind(filenames2use{ifile},'-');
        filenames2use{ifile}=filenames2use{ifile}(1:ind_dash-1); % 'site1', etc.
    end
end
if startsWith(filenames2use{1},'spiketimes') % stripping file names for Smith08
    for ifile=1:length(filenames2use)
        filenames2use{ifile}=filenames2use{ifile}(11:17); % 'monkey1', etc.
    end
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
sync_all_zs_sorted=sync_all_zs(output_this.outperm_absspearmancorr_avg,:); % ordering wrt hierarchical clustering results with absspearmancorr measure and average linkage

figure;
set(gcf,'Color',[1 1 1]);
set(gcf,'Position',[4           7        1917         769]);
imagesc(sync_all_zs_sorted);
set(gca,'Position',[0.1351    0.1022    0.8260    0.7828]);
cbh=colorbar;
xlabel('win');
set(gca,'YTickLabel',{'','','','','','','','',''});
for imeas=1:length(field_names)
    text(-2,imeas,field_names{output_this.outperm_absspearmancorr_avg(imeas)},'Interpreter','none','HorizontalAlignment','right','VerticalAlignment','middle','Rotation',0,'FontSize',FontSizeThis); % we might add color later, to indicate monovariate, bivariate, multivariate
end
xlim(0.5+[0 i_train]);
pos_vect=get(cbh,'Position');
set(gca,'Position',[0.1351    0.1022    0.8260    0.7828]);

sa=axes('Position',[0.1351    0.8850    0.8260    0.05]);
for ifile=1:ifile2use
    plot((nwin_cum_vect(ifile)+.5)*ones(1,2),[0 1],'Color',color_vect_eachfile(ifile,:));
    hold on;
    text(nwin_cum_vect(ifile+1)-.5*nwin_vect(ifile),0.5,strrep(filenames2use{ifile},'.mat',''),'Color',color_vect_eachfile(ifile,:),'Interpreter','none','HorizontalAlignment','center','VerticalAlignment','middle','Rotation',0,'FontSize',14);
end
xlim(0.5+[0 i_train]);
ylim([0 1]);
axis off;
if PLOT.print
    figure_name=fullfile(figDir,'sync_all_zs'); % we only have the measabscorrsorted version of this, should not be used as the name is not informative enough
    export_fig(gcf,[figure_name par.png_tail '_' names_string '.png']);
end

figure;
set(gcf,'Color',[1 1 1]);
set(gcf,'Position',[4           7        1917         769]);
imagesc(sync_all_zs_sorted);
set(gca,'Position',[0.1351    0.1022    0.8260    0.7828]);
cbh=colorbar;
xlabel('win');
set(gca,'YTickLabel',{'','','','','','','','',''});
for imeas=1:length(field_names)
    text(-2,imeas,field_names{output_this.outperm_absspearmancorr_avg(imeas)},'Interpreter','none','HorizontalAlignment','right','VerticalAlignment','middle','Rotation',0,'FontSize',FontSizeThis,'Color',field_colors{output_this.outperm_absspearmancorr_avg(imeas)}); % we might add color later, to indicate monovariate, bivariate, multivariate
end
xlim(0.5+[0 i_train]);
pos_vect=get(cbh,'Position');
set(gca,'Position',[0.1351    0.1022    0.8260    0.7828]);

sa=axes('Position',[0.1351    0.8850    0.8260    0.05]);
for ifile=1:ifile2use
    plot((nwin_cum_vect(ifile)+.5)*ones(1,2),[0 1],'Color',color_vect_eachfile(ifile,:));
    hold on;
    text(nwin_cum_vect(ifile+1)-.5*nwin_vect(ifile),0.5,strrep(filenames2use{ifile},'.mat',''),'Color',color_vect_eachfile(ifile,:),'Interpreter','none','HorizontalAlignment','center','VerticalAlignment','middle','Rotation',0,'FontSize',14);
end
xlim(0.5+[0 i_train]);
ylim([0 1]);
axis off;
if PLOT.print
    figure_name=fullfile(figDir,'sync_all_zs_measabscorrsorted_color');
    export_fig(gcf,[figure_name par.png_tail '_' names_string '.png']);
end

figure;
set(gcf,'Color',[1 1 1]);
set(gcf,'Position',[4           7        1917         769]);
imagesc(sync_all_zs_sorted);
set(gca,'Position',[0.1351    0.1022    0.8260    0.7828]);
cbh=colorbar;
xlabel('win');
set(gca,'YTickLabel',{'','','','','','','','',''});
for imeas=1:length(field_names)
    text(-2,imeas,field_names{output_this.outperm_absspearmancorr_avg(imeas)},'Interpreter','none','HorizontalAlignment','right','VerticalAlignment','middle','Rotation',0,'FontSize',FontSizeThis,'Color',field_colors{output_this.outperm_absspearmancorr_avg(imeas)}); % we might add color later, to indicate monovariate, bivariate, multivariate
end
xlim(0.5+[0 i_train]);
pos_vect=get(cbh,'Position');
set(gca,'Position',[0.1351    0.1022    0.8260    0.7828]);

sa=axes('Position',[0.1351    0.8850    0.8260    0.05]);
for ifile=1:ifile2use
    plot((nwin_cum_vect(ifile)+.5)*ones(1,2),[0 1],'Color',color_vect_eachfile(ifile,:));
    hold on;
    text(nwin_cum_vect(ifile+1)-.5*nwin_vect(ifile),0.5,strrep(filenames2use{ifile},'.mat',''),'Color',color_vect_eachfile(ifile,:),'Interpreter','none','HorizontalAlignment','center','VerticalAlignment','middle','Rotation',0,'FontSize',14);
end
xlim(0.5+[0 i_train]);
ylim([0 1]);
axis off;
if PLOT.print
    figure_name=fullfile(figDir,'sync_all_zs_measabsspearmancorrsorted_color');
    export_fig(gcf,[figure_name par.png_tail '_' names_string '.png']);
end



imAlpha=ones(size(sync_all_zs_sorted));
imAlpha(isnan(sync_all_zs_sorted))=0;

figure;
set(gcf,'Color',[1 1 1]);
set(gcf,'Position',[4           7        1917         769]);
imagesc(sync_all_zs_sorted,'AlphaData',imAlpha);
set(gca,'color',0.8*[1 1 1]);
set(gca,'Position',[0.1061    0.1022    0.8550    0.8328]);
cbh=colorbar;
xlabel('time windows');
set(gca,'YTick',1:1:length(field_names));
set(gca,'YTickLabel',{'','','','','','','','',''});
for imeas=1:length(field_names)
    text(-2,imeas,field_names_long_ms{output_this.outperm_absspearmancorr_avg(imeas)},'Interpreter','none','HorizontalAlignment','right','VerticalAlignment','middle','Rotation',0,'FontSize',FontSizeThis,'Color',field_colors{output_this.outperm_absspearmancorr_avg(imeas)}); % we might add color later, to indicate monovariate, bivariate, multivariate
end
xlim(0.5+[0 i_train]);
xtick_vect=get(gca,'XTick');
if xtick_vect(end)==800 % this fixes the problem with the legend going beyond the limits for Form22
    set(gca,'XTick',xtick_vect(1:end-1));
end
pos_vect=get(cbh,'Position');
set(gca,'Position',[0.1061    0.1022    0.8550    0.8328]);
clim_this=get(gca,'CLim');

sa=axes('Position',[0.1061    0.9350    0.8550    0.05]);
for ifile=1:ifile2use
    plot((nwin_cum_vect(ifile)+.5)*ones(1,2),[0 1],'Color',color_vect_eachfile(ifile,:));
    hold on;
    text(nwin_cum_vect(ifile+1)-.5*nwin_vect(ifile),0.5,strrep(filenames2use{ifile},'.mat',''),'Color',color_vect_eachfile(ifile,:),'Interpreter','none','HorizontalAlignment','center','VerticalAlignment','middle','Rotation',0,'FontSize',13);
end
xlim(0.5+[0 i_train]);
ylim([0 1]);
axis off;
pos_this=[0.1061    0.1022    0.8550    0.8328];
if PLOT.print
    figure_name=fullfile(figDir,'sync_all_zs_measabsspearmancorrsorted_color_longn');
    export_fig(gcf,[figure_name par.png_tail '_' names_string '.png'],'-nocrop');
end



figure;
set(gcf,'Color',[1 1 1]);
set(gcf,'Position',[4           7        1917         769]);
imagesc(sync_all_zs_sorted,'AlphaData',imAlpha);
set(gca,'color',0.8*[1 1 1]);
set(gca,'Position',[0.1061    0.1022    0.8550    0.8328]);
cbh=colorbar;
xlabel('time windows (ordered chronologically per recording)');
set(gca,'YTick',1:1:length(field_names));
set(gca,'YTickLabel',{'','','','','','','','',''});
for imeas=1:length(field_names)
    text(-2,imeas,field_names_long_ms{output_this.outperm_absspearmancorr_avg(imeas)},'Interpreter','none','HorizontalAlignment','right','VerticalAlignment','middle','Rotation',0,'FontSize',FontSizeThis,'Color',field_colors{output_this.outperm_absspearmancorr_avg(imeas)}); % we might add color later, to indicate monovariate, bivariate, multivariate
end
xlim(0.5+[0 i_train]);
xtick_vect=get(gca,'XTick');
if xtick_vect(end)==800 % this fixes the problem with the legend going beyond the limits for Form22
    set(gca,'XTick',xtick_vect(1:end-1));
end
pos_vect=get(cbh,'Position');
set(gca,'Position',[0.1061    0.1022    0.8550    0.8328]);
clim_this=get(gca,'CLim');
ylim_vect=get(gca,'YLim');
hold on;
for ifile=2:ifile2use
    plot((nwin_cum_vect(ifile)+.5)*ones(1,2),ylim_vect,'Color',0.2*ones(1,3),'LineWidth',.5);
    hold on;
end

sa=axes('Position',[0.1061    0.9350    0.8550    0.05]);
for ifile=1:ifile2use
    plot((nwin_cum_vect(ifile)+.5)*ones(1,2),[0 1],'Color',color_vect_eachfile(ifile,:));
    hold on;
    text(nwin_cum_vect(ifile+1)-.5*nwin_vect(ifile),0.5,strrep(filenames2use{ifile},'.mat',''),'Color',color_vect_eachfile(ifile,:),'Interpreter','none','HorizontalAlignment','center','VerticalAlignment','middle','Rotation',0,'FontSize',13);
end
xlim(0.5+[0 i_train]);
ylim([0 1]);
axis off;
pos_this=[0.1061    0.1022    0.8550    0.8328];
if PLOT.print
    figure_name=fullfile(figDir,'sync_all_zs_measabsspearmancorrsorted_color_longn_vlines');
    export_fig(gcf,[figure_name par.png_tail '_' names_string '.png'],'-nocrop');
end




figure;
set(gcf,'Color',[1 1 1]);
set(gcf,'Position',[4           7        1917         1000]); % 769*1.3
imagesc(sync_all_zs_sorted,'AlphaData',imAlpha);
set(gca,'color',0.8*[1 1 1]);
set(gca,'Position',[0.1361    0.1022    0.8250    0.8328]);
cbh=colorbar;
xlabel('time windows');
set(gca,'YTick',1:1:length(field_names));
set(gca,'YTickLabel',{'','','','','','','','',''});
for imeas=1:length(field_names)
    text(-2,imeas,field_names_long_ms{output_this.outperm_absspearmancorr_avg(imeas)},'Interpreter','none','HorizontalAlignment','right','VerticalAlignment','middle','Rotation',0,'FontSize',FontSizeThis*1.3,'Color',field_colors{output_this.outperm_absspearmancorr_avg(imeas)}); % we might add color later, to indicate monovariate, bivariate, multivariate
end
xlim(0.5+[0 i_train]);
xtick_vect=get(gca,'XTick');
if xtick_vect(end)==800 % this fixes the problem with the legend going beyond the limits for Form22
    set(gca,'XTick',xtick_vect(1:end-1));
end
pos_vect=get(cbh,'Position');
set(gca,'Position',[0.1361    0.1022    0.8250    0.8328]);
clim_this=get(gca,'CLim');

sa=axes('Position',[0.1361    0.9350    0.8250    0.05]);
for ifile=1:ifile2use
    plot((nwin_cum_vect(ifile)+.5)*ones(1,2),[0 1],'Color',color_vect_eachfile(ifile,:));
    hold on;
    text(nwin_cum_vect(ifile+1)-.5*nwin_vect(ifile),0.5,strrep(filenames2use{ifile},'.mat',''),'Color',color_vect_eachfile(ifile,:),'Interpreter','none','HorizontalAlignment','center','VerticalAlignment','middle','Rotation',0,'FontSize',13);
end
xlim(0.5+[0 i_train]);
ylim([0 1]);
axis off;
pos_this=[0.1061    0.1022    0.8550    0.8328];
if PLOT.print
    figure_name=fullfile(figDir,'sync_all_zs_measabsspearmancorrsorted_color_longn_h');
    export_fig(gcf,[figure_name par.png_tail '_' names_string '.png'],'-nocrop');
end



figure;
set(gcf,'Color',[1 1 1]);
set(gcf,'Position',[4           7        1917         1000]); % 769*1.3
imagesc(sync_all_zs_sorted,'AlphaData',imAlpha);
set(gca,'color',0.8*[1 1 1]);
set(gca,'Position',[0.1361    0.1022    0.8250    0.8328]);
cbh=colorbar;
xlabel('time windows (ordered chronologically per recording)');
set(gca,'YTick',1:1:length(field_names));
set(gca,'YTickLabel',{'','','','','','','','',''});
for imeas=1:length(field_names)
    text(-2,imeas,field_names_long_ms{output_this.outperm_absspearmancorr_avg(imeas)},'Interpreter','none','HorizontalAlignment','right','VerticalAlignment','middle','Rotation',0,'FontSize',FontSizeThis*1.3,'Color',field_colors{output_this.outperm_absspearmancorr_avg(imeas)}); % we might add color later, to indicate monovariate, bivariate, multivariate
end
xlim(0.5+[0 i_train]);
xtick_vect=get(gca,'XTick');
if xtick_vect(end)==800 % this fixes the problem with the legend going beyond the limits for Form22
    set(gca,'XTick',xtick_vect(1:end-1));
end
pos_vect=get(cbh,'Position');
set(gca,'Position',[0.1361    0.1022    0.8250    0.8328]);
clim_this=get(gca,'CLim');
ylim_vect=get(gca,'YLim');
hold on;
for ifile=2:ifile2use
    plot((nwin_cum_vect(ifile)+.5)*ones(1,2),ylim_vect,'Color',0.2*ones(1,3),'LineWidth',.5);
    hold on;
end

sa=axes('Position',[0.1361    0.9350    0.8250    0.05]);
for ifile=1:ifile2use
    plot((nwin_cum_vect(ifile)+.5)*ones(1,2),[0 1],'Color',color_vect_eachfile(ifile,:));
    hold on;
    text(nwin_cum_vect(ifile+1)-.5*nwin_vect(ifile),0.5,strrep(filenames2use{ifile},'.mat',''),'Color',color_vect_eachfile(ifile,:),'Interpreter','none','HorizontalAlignment','center','VerticalAlignment','middle','Rotation',0,'FontSize',13);
end
xlim(0.5+[0 i_train]);
ylim([0 1]);
axis off;
pos_this=[0.1061    0.1022    0.8550    0.8328];
if PLOT.print
    figure_name=fullfile(figDir,'sync_all_zs_measabsspearmancorrsorted_color_longn_h_vlines');
    export_fig(gcf,[figure_name par.png_tail '_' names_string '.png'],'-nocrop');
end



clip_v=-min(min(sync_all_zs_sorted));

figure;
set(gcf,'Color',[1 1 1]);
set(gcf,'Position',[4           7        1917         1000]); % 769*1.3
imagesc(min(sync_all_zs_sorted,clip_v),'AlphaData',imAlpha);
set(gca,'color',0.8*[1 1 1]);
set(gca,'Position',[0.1361    0.1022    0.8250    0.8328]);
cbh=colorbar;
xlabel('time windows (ordered chronologically per recording)');
set(gca,'YTick',1:1:length(field_names));
set(gca,'YTickLabel',{'','','','','','','','',''});
for imeas=1:length(field_names)
    text(-2,imeas,field_names_long_ms{output_this.outperm_absspearmancorr_avg(imeas)},'Interpreter','none','HorizontalAlignment','right','VerticalAlignment','middle','Rotation',0,'FontSize',FontSizeThis*1.3,'Color',field_colors{output_this.outperm_absspearmancorr_avg(imeas)}); % we might add color later, to indicate monovariate, bivariate, multivariate
end
xlim(0.5+[0 i_train]);
xtick_vect=get(gca,'XTick');
if xtick_vect(end)==800 % this fixes the problem with the legend going beyond the limits for Form22
    set(gca,'XTick',xtick_vect(1:end-1));
end
pos_vect=get(cbh,'Position');
set(gca,'Position',[0.1361    0.1022    0.8250    0.8328]);
clim_this=get(gca,'CLim');
ylim_vect=get(gca,'YLim');
hold on;
for ifile=2:ifile2use
    plot((nwin_cum_vect(ifile)+.5)*ones(1,2),ylim_vect,'Color',0.2*ones(1,3),'LineWidth',.5);
    hold on;
end

sa=axes('Position',[0.1361    0.9350    0.8250    0.05]);
for ifile=1:ifile2use
    plot((nwin_cum_vect(ifile)+.5)*ones(1,2),[0 1],'Color',color_vect_eachfile(ifile,:));
    hold on;
    text(nwin_cum_vect(ifile+1)-.5*nwin_vect(ifile),0.5,strrep(filenames2use{ifile},'.mat',''),'Color',color_vect_eachfile(ifile,:),'Interpreter','none','HorizontalAlignment','center','VerticalAlignment','middle','Rotation',0,'FontSize',13);
end
xlim(0.5+[0 i_train]);
ylim([0 1]);
axis off;
pos_this=[0.1061    0.1022    0.8550    0.8328];
if PLOT.print
    figure_name=fullfile(figDir,'sync_all_zs_measabsspearmancorrsorted_color_longn_h_vlines_clipped');
    export_fig(gcf,[figure_name par.png_tail '_' names_string '.png'],'-nocrop');
end




% D = pdist(X) returns a vector D containing the Euclidean distances between each pair of observations in the M-by-N data matrix X.
% Rows of X correspond to observations (measures), columns correspond to variables (spike trains)
% using average distance
% sync_all_dist = pdist(sync_all, 'euclid'); % euclidian not appropriate
% sync_all_dist_corr = pdist(sync_all', 'correlation'); % this results in nearly every entry ~ 1
% sync_all_dist_corr = pdist(sync_all_zs', 'correlation');
sync_all_dist_corr = pdist(sync_all_zs', @corr_pairwise);
% sync_all_link_corr = linkage(sync_all_dist_corr, 'single');
sync_all_link_corr_avg = linkage(sync_all_dist_corr, 'average');
sync_all_clust_corr = cluster(sync_all_link_corr_avg, 'cutoff', 1.2);

% sync_all_dist_spearman = pdist(sync_all, 'spearman');
% sync_all_link = linkage(sync_all_dist_spearman, 'single');
% sync_all_clust = cluster(sync_all_link, 'cutoff', 1.2);



sync_all_dist_corr_mat=squareform(sync_all_dist_corr);
NSYNC=size(sync_all_dist_corr_mat);
icMDS=[];

try
    if isequal(icMDS,[])
        [xyMDS,stress] = mdscale(sync_all_dist_corr_mat,2,'criterion','metricstress');
        icMDS=xyMDS;
    else
        [xyMDS,stress] = mdscale(sync_all_dist_corr_mat,2,'criterion','metricstress','Start',icMDS);
        icMDS=xyMDS;
    end
catch
    maximumNumberOfTries = 100;
    counter  = 0;
    xyMDS=[];
    while isempty(xyMDS) && counter < maximumNumberOfTries % maximum ~100 tries
        try
            [xyMDS,stress] = mdscale(sync_all_dist_corr_mat,2,'criterion','metricstress','Start','random');
        catch ME
            fprintf([ME.identifier '\n']);
            fprintf([ME.message '\n'])
        end
        counter = counter + 1;
    end
    if isempty(xyMDS)
        fprintf('robust_mdscale: well, seems that some of these points are Really co-located...\n');
    end
end

ff=0.1;

if ~isempty(xyMDS)
    figure;
    set(gcf,'Color',[1 1 1]);
    for iSYNC=1:NSYNC(1)
        plot(xyMDS(iSYNC,1),xyMDS(iSYNC,2),'wo'); % just so that the axis are set properly
        hold on;
        text(xyMDS(iSYNC,1),xyMDS(iSYNC,2),win_names{iSYNC},'Color',color_vect_all(iSYNC,:),'HorizontalAlignment','center','VerticalAlignment','middle','Interpreter','none','FontSize',12);
    end
    axis tight;
    axis equal;
    axis square;
    axis off;
    xlim_vect=xlim;
    ylim_vect=ylim;
    xwidth=xlim_vect(2)-xlim_vect(1);
    ywidth=ylim_vect(2)-ylim_vect(1);
    xlim_vect=[xlim_vect(1)-1.38*ff*xwidth,xlim_vect(2)+1.38*ff*xwidth];
    ylim_vect=[ylim_vect(1)-ff*ywidth,ylim_vect(2)+ff*ywidth];
    plot(xlim_vect,ylim_vect(1).*ones(1,2),'k','LineWidth',2);
    plot(xlim_vect,ylim_vect(2).*ones(1,2),'k','LineWidth',2);
    plot(xlim_vect(1).*ones(1,2),ylim_vect,'k','LineWidth',2);
    plot(xlim_vect(2).*ones(1,2),ylim_vect,'k','LineWidth',2);
    if PLOT.print
        figure_name=fullfile(figDir,'sync_all_win_corr_avg_mds_metric');
        export_fig(gcf,[figure_name par.png_tail '_' names_string '.png']);
    end

    stress
end



figure;
set(gcf,'Color',[1 1 1]);
[H,T,outperm] = dendrogram(sync_all_link_corr_avg,0); % trying to display the whole tree
set(gcf,'Position',[1000         392        1476         942]);
set(gca,'XTickLabels',{'','',''});
if PLOT.print
    figure_name=fullfile(figDir,'sync_all_win_corr_avg_dendro');
    export_fig(gcf,[figure_name par.png_tail '_' names_string '.png']);
end

figure;
set(gcf,'Color',[1 1 1]);
[H,T,outperm] = mypolardendrogram(sync_all_link_corr_avg,0); % trying to display the whole tree
zoom(0.8);
view(2);
xrange=size(sync_all,2);
minx=0;
for iSYNC=1:NSYNC(1)
    iSYNC_perm=outperm(iSYNC);
    [x,y]=pol2cart((((iSYNC-minx)/xrange)*(pi*11/6))+(pi*1/12),1.05);
    text(x,y,win_names{iSYNC_perm},'Color',color_vect_all(iSYNC_perm,:),'FontSize',18,'HorizontalAlignment','center','VerticalAlignment','middle');
    hold on;
end
set(gcf,'Position',[1000         392        942*6         942*6]);
if PLOT.print
    figure_name=fullfile(figDir,'sync_all_win_corr_avg_polardendro_sym');
    export_fig(gcf,[figure_name par.png_tail '_' names_string '.png']);
end




figure;
set(gcf,'Color',[1 1 1]);
[H,T,outperm] = dendrogram(sync_all_link_corr_avg,0); % trying to display the whole tree
hold on;
set(gca,'XLim',[0 size(sync_all,2)+1]);
set(gca,'XTickLabel',{'','','','',''})
set(gca,'Position',[0.1300    0.1100    0.7750    0.8150]); % the same as automatically set, just in case
sa=axes('Position',[0.1300    0.0600    0.7750    0.05]);
axis off;
for iSYNC=1:NSYNC(1)
    iSYNC_perm=outperm(iSYNC);
    text(iSYNC,-0.1,win_names{iSYNC_perm},'Color',color_vect_all(iSYNC_perm,:),'FontSize',FontSizeThis,'HorizontalAlignment','center');
    hold on;
end
set(sa,'XLim',[0 size(sync_all,2)+1]);
set(gcf,'Position',[1000         392        14760         942]); % trying to make it much wider
axis off;
if PLOT.print
    figure_name=fullfile(figDir,'sync_all_win_corr_avg_dendro_sym');
    export_fig(gcf,[figure_name par.png_tail '_' names_string '.png']);
end


figure;
set(gcf,'Color',[1 1 1]);
[H,T,outperm] = dendrogram(sync_all_link_corr_avg,0); % trying to display the whole tree
hold on;
set(gca,'XLim',[0 size(sync_all,2)+1]);
set(gca,'XTickLabel',{'','','','',''})
set(gca,'Position',[0.1300    0.1100    0.7750    0.8150]); % the same as automatically set, just in case
sa=axes('Position',[0.1300    0.0600    0.7750    0.05]);
axis off;
for iSYNC=1:NSYNC(1)
    iSYNC_perm=outperm(iSYNC);
    plot(iSYNC*ones(1,2),[0 win_rank(iSYNC_perm)],'Color',color_vect_all(iSYNC_perm,:));
    hold on;
end
set(sa,'XLim',[0 size(sync_all,2)+1]);
set(gcf,'Position',[1000         392        1476         942]);
axis off;
if PLOT.print
    figure_name=fullfile(figDir,'sync_all_win_corr_avg_dendro_lines');
    export_fig(gcf,[figure_name par.png_tail '_' names_string '.png']);
end


sync_all_zs_sorted2=sync_all_zs_sorted(:,outperm); % also ordering wrt hierarchical clustering results across windows

figure;
set(gcf,'Color',[1 1 1]);
set(gcf,'Position',[4           7        1917         769]);
imagesc(sync_all_zs_sorted2);
set(gca,'Position',[0.1351    0.1022    0.8260    0.7828]);
cbh=colorbar;
xlabel('win');
set(gca,'YTickLabel',{'','','','','','','','',''});
for imeas=1:length(field_names)
    text(-2,imeas,field_names{output_this.outperm_absspearmancorr_avg(imeas)},'Interpreter','none','HorizontalAlignment','right','VerticalAlignment','middle','Rotation',0,'FontSize',FontSizeThis); % we might add color later, to indicate monovariate, bivariate, multivariate
end
xlim(0.5+[0 i_train]);
pos_vect=get(cbh,'Position');
set(gca,'Position',[0.1351    0.1022    0.8260    0.7828]);
xlim(0.5+[0 i_train]);
ylim_vect=get(gca,'YLim');
for iwin=1:length(win_names)
    text(iwin,ylim_vect(1)-(ylim_vect(2)-ylim_vect(1))*0.02,win_names{outperm(iwin)},'Color',color_vect_all(outperm(iwin),:),'HorizontalAlignment','center','FontSize',5); % FontSize needs to be very small or otherwise adyacent labels will overlap
    hold on;
end
xlim(0.5+[0 i_train]);
if PLOT.print
    figure_name=fullfile(figDir,'sync_all_zs_abscorr_sorted');
    export_fig(gcf,[figure_name par.png_tail '_' names_string '.png']);
end

figure;
set(gcf,'Color',[1 1 1]);
set(gcf,'Position',[4           7        1917         769]);
imagesc(sync_all_zs_sorted2);
set(gca,'Position',[0.1351    0.1022    0.8260    0.7828]);
cbh=colorbar;
xlabel('win');
set(gca,'YTickLabel',{'','','','','','','','',''});
for imeas=1:length(field_names)
    text(-2,imeas,field_names{output_this.outperm_absspearmancorr_avg(imeas)},'Interpreter','none','HorizontalAlignment','right','VerticalAlignment','middle','Rotation',0,'FontSize',FontSizeThis,'Color',field_colors{output_this.outperm_absspearmancorr_avg(imeas)}); % we might add color later, to indicate monovariate, bivariate, multivariate
end
xlim(0.5+[0 i_train]);
pos_vect=get(cbh,'Position');
set(gca,'Position',[0.1351    0.1022    0.8260    0.7828]);
xlim(0.5+[0 i_train]);
ylim_vect=get(gca,'YLim');
for iwin=1:length(win_names)
    text(iwin,ylim_vect(1)-(ylim_vect(2)-ylim_vect(1))*0.02,win_names{outperm(iwin)},'Color',color_vect_all(outperm(iwin),:),'HorizontalAlignment','center','FontSize',5); % FontSize needs to be very small or otherwise adyacent labels will overlap
    hold on;
end
xlim(0.5+[0 i_train]);
if PLOT.print
    figure_name=fullfile(figDir,'sync_all_zs_abscorr_sorted_color');
    export_fig(gcf,[figure_name par.png_tail '_' names_string '.png']);
end



sync_all_corr=1-sync_all_dist_corr;
sync_all_corr_mat=squareform(sync_all_corr);
sync_all_corr_mat_sorted=sync_all_corr_mat(outperm,outperm);
sync_all_corr_mat_2plot=nan(size(sync_all_corr_mat));
ut=triu(true(size(sync_all_corr_mat)),1); % we only consider the upper triangular part without the diagonal
sync_all_corr_mat_2plot(ut)=sync_all_corr_mat_sorted(ut);



figure;
set(gcf,'Color',[1 1 1]);
set(gcf,'Position',[1 1 1200 1000]);
imAlpha=ones(size(sync_all_corr_mat_2plot));
imAlpha(isnan(sync_all_corr_mat_2plot))=0;
imagesc(sync_all_corr_mat_2plot,'AlphaData',imAlpha);
set(gca,'color',0.95*[1 1 1]);
axis square
set(gca,'XTickLabels',{'','',''}); % not possible to display them at a readable size
set(gca,'YTickLabels',{'','',''});
cbh=colorbar;
pos_vect=get(cbh,'Position');
th2=annotation('textbox',[pos_vect(1)+pos_vect(3)+0.01 pos_vect(2)+0.46*pos_vect(4) 0.012 0.046],'String','corr','FontSize',24,'LineStyle','none','VerticalAlignment','middle');
if PLOT.print
    figure_name=fullfile(figDir,'sync_all_win_corr_avg_mat');
    export_fig(gcf,[figure_name par.png_tail '_' names_string '.png']);
end



figure;
set(gcf,'Color',[1 1 1]);
set(gcf,'Position',[1 1 1200 1000]);
imAlpha=ones(size(sync_all_corr_mat_2plot));
imAlpha(isnan(sync_all_corr_mat_2plot))=0;
imagesc(sync_all_corr_mat_2plot,'AlphaData',imAlpha);
set(gca,'color',0.95*[1 1 1]);
axis square
set(gca,'XTickLabels',{'','',''}); % not possible to display them at a readable size
set(gca,'YTickLabels',{'','',''});
set(gca,'Position',[0.1300    0.1100    0.7750    0.8150]); % the same as automatically set, just in case
cacorr=gca;
cbh=colorbar;
pos_vect=get(cbh,'Position');
th2=annotation('textbox',[pos_vect(1)+pos_vect(3)+0.01 pos_vect(2)+0.46*pos_vect(4) 0.012 0.046],'String','corr','FontSize',24,'LineStyle','none','VerticalAlignment','middle');

set(gca,'Position',[0.1300    0.1100    0.7265    0.8150]); % the same as automatically set, just in case
pos_vect=get(gca,'Position');
pos_tight=tightPosition(gca);
sa=axes('Position',[pos_tight(1)    pos_tight(2)+pos_vect(4)+0.005    pos_tight(3)    0.05]);
for iSYNC=1:NSYNC(1)
    iSYNC_perm=outperm(iSYNC);
    plot(iSYNC*ones(1,2),[0 win_rank(iSYNC_perm)],'Color',color_vect_all(iSYNC_perm,:));
    hold on;
end
set(sa,'XLim',[0 size(sync_all,2)+1]);
axis off;
if PLOT.print
    figure_name=fullfile(figDir,'sync_all_win_corr_avg_mat_lines');
    export_fig(gcf,[figure_name par.png_tail '_' names_string '.png']);
end









% using  spearman corr and average distance

sync_all_dist_spearmancorr = pdist(sync_all_zs', @spearman_corr_pairwise);
sync_all_link_spearmancorr_avg = linkage(sync_all_dist_spearmancorr, 'average');
sync_all_clust_corr = cluster(sync_all_link_spearmancorr_avg, 'cutoff', 1.2);

% sync_all_dist_spearman = pdist(sync_all, 'spearman');
% sync_all_link = linkage(sync_all_dist_spearman, 'single');
% sync_all_clust = cluster(sync_all_link, 'cutoff', 1.2);



sync_all_dist_spearmancorr_mat=squareform(sync_all_dist_spearmancorr);
NSYNC=size(sync_all_dist_spearmancorr_mat);
icMDS=[];

try
    if isequal(icMDS,[])
        [xyMDS,stress] = mdscale(sync_all_dist_spearmancorr_mat,2,'criterion','metricstress');
        icMDS=xyMDS;
    else
        [xyMDS,stress] = mdscale(sync_all_dist_spearmancorr_mat,2,'criterion','metricstress','Start',icMDS);
        icMDS=xyMDS;
    end
catch
    maximumNumberOfTries = 100;
    counter  = 0;
    xyMDS=[];
    while isempty(xyMDS) && counter < maximumNumberOfTries % maximum ~100 tries
        try
            [xyMDS,stress] = mdscale(sync_all_dist_spearmancorr_mat,2,'criterion','metricstress','Start','random');
        catch ME
            fprintf([ME.identifier '\n']);
            fprintf([ME.message '\n'])
        end
        counter = counter + 1;
    end
    if isempty(xyMDS)
        fprintf('robust_mdscale: well, seems that some of these points are Really co-located...\n');
    end
end

ff=0.1;

if ~isempty(xyMDS)
    figure;
    set(gcf,'Color',[1 1 1]);
    for iSYNC=1:NSYNC(1)
        plot(xyMDS(iSYNC,1),xyMDS(iSYNC,2),'wo'); % just so that the axis are set properly
        hold on;
        text(xyMDS(iSYNC,1),xyMDS(iSYNC,2),win_names{iSYNC},'Color',color_vect_all(iSYNC,:),'HorizontalAlignment','center','VerticalAlignment','middle','Interpreter','none','FontSize',12);
    end
    axis tight;
    axis equal;
    axis square;
    axis off;
    xlim_vect=xlim;
    ylim_vect=ylim;
    xwidth=xlim_vect(2)-xlim_vect(1);
    ywidth=ylim_vect(2)-ylim_vect(1);
    xlim_vect=[xlim_vect(1)-1.38*ff*xwidth,xlim_vect(2)+1.38*ff*xwidth];
    ylim_vect=[ylim_vect(1)-ff*ywidth,ylim_vect(2)+ff*ywidth];
    plot(xlim_vect,ylim_vect(1).*ones(1,2),'k','LineWidth',2);
    plot(xlim_vect,ylim_vect(2).*ones(1,2),'k','LineWidth',2);
    plot(xlim_vect(1).*ones(1,2),ylim_vect,'k','LineWidth',2);
    plot(xlim_vect(2).*ones(1,2),ylim_vect,'k','LineWidth',2);
    if PLOT.print
        figure_name=fullfile(figDir,'sync_all_win_spearmancorr_avg_mds_metric');
        export_fig(gcf,[figure_name par.png_tail '_' names_string '.png']);
    end

    figure;
    set(gcf,'Color',[1 1 1]);
    for iSYNC=1:NSYNC(1)
        plot(xyMDS(iSYNC,1),xyMDS(iSYNC,2),'o','Color',color_vect_all(iSYNC,:),'MarkerFaceColor',color_vect_all(iSYNC,:),'MarkerSize',3);
        hold on;
    end
    axis tight;
    axis equal;
    axis square;
    set(gca,'XTickLabel',{'','',''});
    set(gca,'YTickLabel',{'','',''});
    set(gca,'TickLength',zeros(1,2));
    xlabel('MDS-1');
    ylabel('MDS-2');
    if PLOT.print
        figure_name=fullfile(figDir,'sync_all_win_spearmancorr_avg_mds_metric_v2');
        export_fig(gcf,[figure_name par.png_tail '_' names_string '.png'],'-m2'); % this doesn't come out nice with xvfb
    end

    stress
end



figure;
set(gcf,'Color',[1 1 1]);
[H,T,outperm] = dendrogram(sync_all_link_spearmancorr_avg,0); % trying to display the whole tree
set(gcf,'Position',[1000         392        1476         942]);
set(gca,'XTickLabels',{'','',''});
if PLOT.print
    figure_name=fullfile(figDir,'sync_all_win_spearmancorr_avg_dendro');
    export_fig(gcf,[figure_name par.png_tail '_' names_string '.png']);
end

figure;
set(gcf,'Color',[1 1 1]);
[H,T,outperm] = mypolardendrogram(sync_all_link_spearmancorr_avg,0); % trying to display the whole tree
zoom(0.8);
view(2);
xrange=size(sync_all,2);
minx=0;
for iSYNC=1:NSYNC(1)
    iSYNC_perm=outperm(iSYNC);
    [x,y]=pol2cart((((iSYNC-minx)/xrange)*(pi*11/6))+(pi*1/12),1.05);
    text(x,y,win_names{iSYNC_perm},'Color',color_vect_all(iSYNC_perm,:),'FontSize',18,'HorizontalAlignment','center','VerticalAlignment','middle');
    hold on;
end
set(gcf,'Position',[1000         392        942*6         942*6]);
if PLOT.print
    figure_name=fullfile(figDir,'sync_all_win_spearmancorr_avg_polardendro_sym');
    export_fig(gcf,[figure_name par.png_tail '_' names_string '.png']);
end




figure;
set(gcf,'Color',[1 1 1]);
[H,T,outperm] = dendrogram(sync_all_link_spearmancorr_avg,0); % trying to display the whole tree
hold on;
set(gca,'XLim',[0 size(sync_all,2)+1]);
set(gca,'XTickLabel',{'','','','',''})
set(gca,'Position',[0.1300    0.1100    0.7750    0.8150]); % the same as automatically set, just in case
sa=axes('Position',[0.1300    0.0600    0.7750    0.05]);
axis off;
for iSYNC=1:NSYNC(1)
    iSYNC_perm=outperm(iSYNC);
    text(iSYNC,-0.1,win_names{iSYNC_perm},'Color',color_vect_all(iSYNC_perm,:),'FontSize',FontSizeThis,'HorizontalAlignment','center');
    hold on;
end
set(sa,'XLim',[0 size(sync_all,2)+1]);
set(gcf,'Position',[1000         392        14760         942]); % trying to make it much wider
axis off;
if PLOT.print
    figure_name=fullfile(figDir,'sync_all_win_spearmancorr_avg_dendro_sym');
    export_fig(gcf,[figure_name par.png_tail '_' names_string '.png']);
end


figure;
set(gcf,'Color',[1 1 1]);
[H,T,outperm] = dendrogram(sync_all_link_spearmancorr_avg,0); % trying to display the whole tree
hold on;
set(gca,'XLim',[0 size(sync_all,2)+1]);
set(gca,'XTickLabel',{'','','','',''})
set(gca,'Position',[0.1300    0.1100    0.7750    0.8150]); % the same as automatically set, just in case
sa=axes('Position',[0.1300    0.0600    0.7750    0.05]);
axis off;
for iSYNC=1:NSYNC(1)
    iSYNC_perm=outperm(iSYNC);
    plot(iSYNC*ones(1,2),[0 win_rank(iSYNC_perm)],'Color',color_vect_all(iSYNC_perm,:));
    hold on;
end
set(sa,'XLim',[0 size(sync_all,2)+1]);
set(gcf,'Position',[1000         392        1476         942]);
axis off;
if PLOT.print
    figure_name=fullfile(figDir,'sync_all_win_spearmancorr_avg_dendro_lines');
    export_fig(gcf,[figure_name par.png_tail '_' names_string '.png']);
end


sync_all_zs_sorted2=sync_all_zs_sorted(:,outperm); % also ordering wrt hierarchical clustering results across windows

figure;
set(gcf,'Color',[1 1 1]);
set(gcf,'Position',[4           7        1917         769]);
imagesc(sync_all_zs_sorted2);
set(gca,'Position',[0.1351    0.1022    0.8260    0.7828]);
cbh=colorbar;
xlabel('win');
set(gca,'YTickLabel',{'','','','','','','','',''});
for imeas=1:length(field_names)
    text(-2,imeas,field_names{output_this.outperm_absspearmancorr_avg(imeas)},'Interpreter','none','HorizontalAlignment','right','VerticalAlignment','middle','Rotation',0,'FontSize',FontSizeThis); % we might add color later, to indicate monovariate, bivariate, multivariate
end
xlim(0.5+[0 i_train]);
pos_vect=get(cbh,'Position');
set(gca,'Position',[0.1351    0.1022    0.8260    0.7828]);
xlim(0.5+[0 i_train]);
ylim_vect=get(gca,'YLim');
for iwin=1:length(win_names)
    text(iwin,ylim_vect(1)-(ylim_vect(2)-ylim_vect(1))*0.02,win_names{outperm(iwin)},'Color',color_vect_all(outperm(iwin),:),'HorizontalAlignment','center','FontSize',5); % FontSize needs to be very small or otherwise adyacent labels will overlap
    hold on;
end
xlim(0.5+[0 i_train]);
if PLOT.print
    figure_name=fullfile(figDir,'sync_all_zs_absspearmancorr_sorted');
    export_fig(gcf,[figure_name par.png_tail '_' names_string '.png']);
end

figure;
set(gcf,'Color',[1 1 1]);
set(gcf,'Position',[4           7        1917         769]);
imagesc(sync_all_zs_sorted2);
set(gca,'Position',[0.1351    0.1022    0.8260    0.7828]);
cbh=colorbar;
xlabel('win');
set(gca,'YTickLabel',{'','','','','','','','',''});
for imeas=1:length(field_names)
    text(-2,imeas,field_names{output_this.outperm_absspearmancorr_avg(imeas)},'Interpreter','none','HorizontalAlignment','right','VerticalAlignment','middle','Rotation',0,'FontSize',FontSizeThis,'Color',field_colors{output_this.outperm_absspearmancorr_avg(imeas)}); % we might add color later, to indicate monovariate, bivariate, multivariate
end
xlim(0.5+[0 i_train]);
pos_vect=get(cbh,'Position');
set(gca,'Position',[0.1351    0.1022    0.8260    0.7828]);
xlim(0.5+[0 i_train]);
ylim_vect=get(gca,'YLim');
for iwin=1:length(win_names)
    text(iwin,ylim_vect(1)-(ylim_vect(2)-ylim_vect(1))*0.02,win_names{outperm(iwin)},'Color',color_vect_all(outperm(iwin),:),'HorizontalAlignment','center','FontSize',5); % FontSize needs to be very small or otherwise adyacent labels will overlap
    hold on;
end
xlim(0.5+[0 i_train]);
if PLOT.print
    figure_name=fullfile(figDir,'sync_all_zs_absspearmancorr_sorted_color');
    export_fig(gcf,[figure_name par.png_tail '_' names_string '.png']);
end



figure;
set(gcf,'Color',[1 1 1]);
set(gcf,'Position',[4           7        1917         769]);
imagesc(sync_all_zs_sorted2);
set(gca,'Position',[0.1351    0.1022    0.8260    0.7828]);
cbh=colorbar;
xlabel('time windows');
set(gca,'YTickLabel',{'','','','','','','','',''});
for imeas=1:length(field_names)
    text(-2,imeas,field_names_long_ms{output_this.outperm_absspearmancorr_avg(imeas)},'Interpreter','none','HorizontalAlignment','right','VerticalAlignment','middle','Rotation',0,'FontSize',FontSizeThis,'Color',field_colors{output_this.outperm_absspearmancorr_avg(imeas)}); % we might add color later, to indicate monovariate, bivariate, multivariate
end
xlim(0.5+[0 i_train]);
pos_vect=get(cbh,'Position');
set(gca,'Position',[0.1351    0.1022    0.8260    0.7828]);
xlim(0.5+[0 i_train]);
ylim_vect=get(gca,'YLim');
for iwin=1:length(win_names)
    text(iwin,ylim_vect(1)-(ylim_vect(2)-ylim_vect(1))*0.02,win_names{outperm(iwin)},'Color',color_vect_all(outperm(iwin),:),'HorizontalAlignment','center','FontSize',5); % FontSize needs to be very small or otherwise adyacent labels will overlap
    hold on;
end
xlim(0.5+[0 i_train]);
if PLOT.print
    figure_name=fullfile(figDir,'sync_all_zs_absspearmancorr_sorted_color_longn');
    export_fig(gcf,[figure_name par.png_tail '_' names_string '.png']);
end


imAlpha=ones(size(sync_all_zs_sorted2));
imAlpha(isnan(sync_all_zs_sorted2))=0;

figure;
set(gcf,'Color',[1 1 1]);
set(gcf,'Position',[4           7        1917         769]);
imagesc(sync_all_zs_sorted2,'AlphaData',imAlpha);
set(gca,'color',0.8*[1 1 1]);
set(gca,'Position',[0.1051    0.1022    0.8560    0.8328]);
xlabel('time windows (ordered according to clustering results)');
set(gca,'YTick',1:1:length(field_names));
set(gca,'YTickLabel',{'','','','','','','','',''});
for imeas=1:length(field_names)
    text(-2,imeas,field_names_long_ms{output_this.outperm_absspearmancorr_avg(imeas)},'Interpreter','none','HorizontalAlignment','right','VerticalAlignment','middle','Rotation',0,'FontSize',FontSizeThis,'Color',field_colors{output_this.outperm_absspearmancorr_avg(imeas)}); % we might add color later, to indicate monovariate, bivariate, multivariate
end
xlim(0.5+[0 i_train]);
set(gca,'Position',[0.1061    0.1022    0.8550    0.8328]);
set(gca,'CLim',clim_this); % it's exactly the same data, just with reordered columns, but just in case

pos_vect=get(gca,'Position');
pos_tight=tightPosition(gca);
sa=axes('Position',[pos_tight(1)    pos_tight(2)+pos_vect(4)+0.005    pos_tight(3)    0.05]);
for iSYNC=1:NSYNC(1)
    iSYNC_perm=outperm(iSYNC);
    plot(iSYNC*ones(1,2),[0 win_rank(iSYNC_perm)],'Color',color_vect_all(iSYNC_perm,:));
    hold on;
end
set(sa,'XLim',0.5+[0 i_train]);
axis off;
if PLOT.print
    figure_name=fullfile(figDir,'sync_all_zs_absspearmancorr_sorted_color_longn_lines');
    export_fig(gcf,[figure_name par.png_tail '_' names_string '.png'],'-nocrop');
end


figure;
set(gcf,'Color',[1 1 1]);
set(gcf,'Position',[4           7        1917         1000]);
imagesc(sync_all_zs_sorted2,'AlphaData',imAlpha);
set(gca,'color',0.8*[1 1 1]);
set(gca,'Position',[0.1351    0.1022    0.8260    0.8328]);
xlabel('time windows (ordered according to clustering results)');
set(gca,'YTick',1:1:length(field_names));
set(gca,'YTickLabel',{'','','','','','','','',''});
for imeas=1:length(field_names)
    text(-2,imeas,field_names_long_ms{output_this.outperm_absspearmancorr_avg(imeas)},'Interpreter','none','HorizontalAlignment','right','VerticalAlignment','middle','Rotation',0,'FontSize',FontSizeThis*1.3,'Color',field_colors{output_this.outperm_absspearmancorr_avg(imeas)}); % we might add color later, to indicate monovariate, bivariate, multivariate
end
xlim(0.5+[0 i_train]);
set(gca,'Position',[0.1361    0.1022    0.8250    0.8328]);
set(gca,'CLim',clim_this); % it's exactly the same data, just with reordered columns, but just in case
pos_vect=get(gca,'Position');
pos_tight=tightPosition(gca);
sa=axes('Position',[pos_tight(1)    pos_tight(2)+pos_vect(4)+0.005    pos_tight(3)    0.05]);
for iSYNC=1:NSYNC(1)
    iSYNC_perm=outperm(iSYNC);
    plot(iSYNC*ones(1,2),[0 win_rank(iSYNC_perm)],'Color',color_vect_all(iSYNC_perm,:));
    hold on;
end
set(sa,'XLim',0.5+[0 i_train]);
axis off;
if PLOT.print
    figure_name=fullfile(figDir,'sync_all_zs_absspearmancorr_sorted_color_longn_lines_h');
    export_fig(gcf,[figure_name par.png_tail '_' names_string '.png'],'-nocrop');
end


figure;
set(gcf,'Color',[1 1 1]);
set(gcf,'Position',[4           7        1917         1000]);
imagesc(min(sync_all_zs_sorted2,clip_v),'AlphaData',imAlpha);
set(gca,'color',0.8*[1 1 1]);
set(gca,'Position',[0.1351    0.1022    0.8260    0.8328]);
xlabel('time windows (ordered according to clustering results)');
set(gca,'YTick',1:1:length(field_names));
set(gca,'YTickLabel',{'','','','','','','','',''});
for imeas=1:length(field_names)
    text(-2,imeas,field_names_long_ms{output_this.outperm_absspearmancorr_avg(imeas)},'Interpreter','none','HorizontalAlignment','right','VerticalAlignment','middle','Rotation',0,'FontSize',FontSizeThis*1.3,'Color',field_colors{output_this.outperm_absspearmancorr_avg(imeas)}); % we might add color later, to indicate monovariate, bivariate, multivariate
end
xlim(0.5+[0 i_train]);
set(gca,'Position',[0.1361    0.1022    0.8250    0.8328]);
set(gca,'CLim',clim_this); % it's exactly the same data, just with reordered columns, but just in case
pos_vect=get(gca,'Position');
pos_tight=tightPosition(gca);
sa=axes('Position',[pos_tight(1)    pos_tight(2)+pos_vect(4)+0.005    pos_tight(3)    0.05]);
for iSYNC=1:NSYNC(1)
    iSYNC_perm=outperm(iSYNC);
    plot(iSYNC*ones(1,2),[0 win_rank(iSYNC_perm)],'Color',color_vect_all(iSYNC_perm,:));
    hold on;
end
set(sa,'XLim',0.5+[0 i_train]);
axis off;
if PLOT.print
    figure_name=fullfile(figDir,'sync_all_zs_absspearmancorr_sorted_color_longn_lines_h_clipped');
    export_fig(gcf,[figure_name par.png_tail '_' names_string '.png'],'-nocrop');
end




sync_all_spearmancorr=1-sync_all_dist_spearmancorr;
sync_all_spearmancorr_mat=squareform(sync_all_spearmancorr);
sync_all_spearmancorr_mat_sorted=sync_all_spearmancorr_mat(outperm,outperm);
sync_all_spearmancorr_mat_2plot=nan(size(sync_all_spearmancorr_mat));
ut=triu(true(size(sync_all_spearmancorr_mat)),1); % we only consider the upper triangular part without the diagonal
sync_all_spearmancorr_mat_2plot(ut)=sync_all_spearmancorr_mat_sorted(ut);



figure;
set(gcf,'Color',[1 1 1]);
set(gcf,'Position',[1 1 1200 1000]);
imAlpha=ones(size(sync_all_spearmancorr_mat_2plot));
imAlpha(isnan(sync_all_spearmancorr_mat_2plot))=0;
imagesc(sync_all_spearmancorr_mat_2plot,'AlphaData',imAlpha);
set(gca,'color',0.95*[1 1 1]);
axis square
set(gca,'XTickLabels',{'','',''}); % not possible to display them at a readable size
set(gca,'YTickLabels',{'','',''});
cbh=colorbar;
pos_vect=get(cbh,'Position');
th2=annotation('textbox',[pos_vect(1)+pos_vect(3)+0.01 pos_vect(2)+0.51*pos_vect(4) 0.012 0.046],'String','\rho','FontSize',24,'LineStyle','none','VerticalAlignment','middle');
if PLOT.print
    figure_name=fullfile(figDir,'sync_all_win_spearmancorr_avg_mat');
    export_fig(gcf,[figure_name par.png_tail '_' names_string '.png']);
end



figure;
set(gcf,'Color',[1 1 1]);
set(gcf,'Position',[1 1 1200 1000]);
imAlpha=ones(size(sync_all_spearmancorr_mat_2plot));
imAlpha(isnan(sync_all_spearmancorr_mat_2plot))=0;
imagesc(sync_all_spearmancorr_mat_2plot,'AlphaData',imAlpha);
set(gca,'color',0.95*[1 1 1]);
axis square
set(gca,'XTickLabels',{'','',''}); % not possible to display them at a readable size
set(gca,'YTickLabels',{'','',''});
set(gca,'Position',[0.1300    0.1100    0.7750    0.8150]); % the same as automatically set, just in case
cacorr=gca;
cbh=colorbar;
pos_vect=get(cbh,'Position');
th2=annotation('textbox',[pos_vect(1)+pos_vect(3)+0.01 pos_vect(2)+0.51*pos_vect(4) 0.012 0.046],'String','\rho','FontSize',24,'LineStyle','none','VerticalAlignment','middle');

set(gca,'Position',[0.1300    0.1100    0.7265    0.8150]); % the same as automatically set, just in case
pos_vect=get(gca,'Position');
pos_tight=tightPosition(gca);
sa=axes('Position',[pos_tight(1)    pos_tight(2)+pos_vect(4)+0.005    pos_tight(3)    0.05]);
for iSYNC=1:NSYNC(1)
    iSYNC_perm=outperm(iSYNC);
    plot(iSYNC*ones(1,2),[0 win_rank(iSYNC_perm)],'Color',color_vect_all(iSYNC_perm,:));
    hold on;
end
set(sa,'XLim',[0 size(sync_all,2)+1]);
axis off;
if PLOT.print
    figure_name=fullfile(figDir,'sync_all_win_spearmancorr_avg_mat_lines');
    export_fig(gcf,[figure_name par.png_tail '_' names_string '.png']);
end



% corr mat lines and dendro together

figure;
set(gcf,'Color',[1 1 1]);
set(gcf,'Position',[1 1 1200 1420]); % adding 420 (standard height is 413)
imAlpha=ones(size(sync_all_spearmancorr_mat_2plot));
imAlpha(isnan(sync_all_spearmancorr_mat_2plot))=0;
imagesc(sync_all_spearmancorr_mat_2plot,'AlphaData',imAlpha);
set(gca,'color',0.95*[1 1 1]);
axis square
xlabel('time windows');
ylabel('time windows');
set(gca,'XTickLabels',{'','',''}); % not possible to display them at a readable size
set(gca,'YTickLabels',{'','',''});
set(gca,'Position',[0.1300    0.0775    0.7750    0.5039]); % not as high
cacorr=gca;
cbh=colorbar;
pos_vect=get(cbh,'Position');
th2=annotation('textbox',[pos_vect(1)+pos_vect(3)+0.01 pos_vect(2)+0.51*pos_vect(4) 0.012 0.0324],'String','\rho','FontSize',24,'LineStyle','none','VerticalAlignment','middle'); % scaling: 0.046/1420*1000

set(gca,'Position',[0.1300    0.0775    0.7265    0.5039]); % the same as automatically set, just in case (width is automatically shrinked for some reason)
pos_vect=get(gca,'Position');
pos_tight=tightPosition(gca);
sa=axes('Position',[pos_tight(1)    pos_tight(2)+pos_vect(4)+0.005    pos_tight(3)    0.0352]); % scaling: 0.05/1420*1000
for iSYNC=1:NSYNC(1)
    iSYNC_perm=outperm(iSYNC);
    plot(iSYNC*ones(1,2),[0 win_rank(iSYNC_perm)],'Color',color_vect_all(iSYNC_perm,:));
    hold on;
end
set(sa,'XLim',0.5+[0 size(sync_all,2)]);
axis off;

pos_vect=get(gca,'Position');
pos_tight=tightPosition(gca);
xsa=axes('Position',[pos_tight(1)    pos_tight(2)+pos_vect(4)+0.005    pos_tight(3)    0.3739]); % not as high

[H,T,outperm] = dendrogram(sync_all_link_spearmancorr_avg,0); % trying to display the whole tree
set(H,'LineWidth',1)
hold on;
set(xsa,'XLim',0.5+[0 size(sync_all,2)]);
set(xsa,'XTickLabel',{'','','','',''})
ylabel('cluster distance');
if PLOT.print
    figure_name=fullfile(figDir,'sync_all_win_spearmancorr_avg_mat_lines_dendro');
    export_fig(gcf,[figure_name par.png_tail '_' names_string '.png'],'-m2'); % double-size
end

output_struct=[];

return
