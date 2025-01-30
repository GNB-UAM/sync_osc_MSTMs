function output_struct=multi_all_train_range_anal_bs_cluster_bal(stringa_dir_batch,par,stringa_name)

if nargin < 3
    stringa_name='';
end

PLOT.print=1;

nf=length(par.f);

N_trains=0;

for indf=1:nf

    f{indf}.n_par1=length(par.f{indf}.(par.f{indf}.ranged_par{1}));   % dynamic structure reference - much better than using eval
    f{indf}.n_par2=length(par.f{indf}.(par.f{indf}.ranged_par{2}));
    f{indf}.n_par3=length(par.f{indf}.(par.f{indf}.ranged_par{3}));

    f{indf}.ranged_par1_vect=par.f{indf}.(par.f{indf}.ranged_par{1});
    f{indf}.ranged_par2_vect=par.f{indf}.(par.f{indf}.ranged_par{2});
    f{indf}.ranged_par3_vect=par.f{indf}.(par.f{indf}.ranged_par{3});

    % in case we'd only want to consider a subset of indexes
    if isfield(par.f{indf},'ranged1_vect_plot')
        f{indf}.ranged1_vect_plot=par.f{indf}.ranged1_vect_plot;
        f{indf}.n_par1=length(f{indf}.ranged1_vect_plot);
    else
        f{indf}.ranged1_vect_plot=1:1:f{indf}.n_par1;
    end
    f{indf}.ranged_par1_vect=f{indf}.ranged_par1_vect(f{indf}.ranged1_vect_plot);

    if isfield(par.f{indf},'ranged2_vect_plot')
        f{indf}.ranged2_vect_plot=par.f{indf}.ranged2_vect_plot;
        f{indf}.n_par2=length(f{indf}.ranged2_vect_plot);
    else
        f{indf}.ranged2_vect_plot=1:1:f{indf}.n_par2;
    end
    f{indf}.ranged_par2_vect=f{indf}.ranged_par2_vect(f{indf}.ranged2_vect_plot);

    if isfield(par.f{indf},'ranged3_vect_plot')
        f{indf}.ranged3_vect_plot=par.f{indf}.ranged3_vect_plot;
        f{indf}.n_par3=length(f{indf}.ranged3_vect_plot);
    else
        f{indf}.ranged3_vect_plot=1:1:f{indf}.n_par3;
    end
    f{indf}.ranged_par3_vect=f{indf}.ranged_par3_vect(f{indf}.ranged3_vect_plot);


    length_ranged_par_this=length(par.f{indf}.ranged_par); % this supports up to 4 ranged par for each family
    if length_ranged_par_this>3
        f{indf}.n_par4=length(par.f{indf}.(par.f{indf}.ranged_par{4}));
        f{indf}.ranged_par4_vect=par.f{indf}.(par.f{indf}.ranged_par{4});

        if isfield(par.f{indf},'ranged4_vect_plot')
            f{indf}.ranged4_vect_plot=par.f{indf}.ranged4_vect_plot;
            f{indf}.n_par4=length(f{indf}.ranged4_vect_plot);
        else
            f{indf}.ranged4_vect_plot=1:1:f{indf}.n_par4;
        end
        f{indf}.ranged_par4_vect=f{indf}.ranged_par4_vect(f{indf}.ranged4_vect_plot);

        f{indf}.n_trains=f{indf}.n_par1*f{indf}.n_par2*f{indf}.n_par3*f{indf}.n_par4;
    else
        f{indf}.n_trains=f{indf}.n_par1*f{indf}.n_par2*f{indf}.n_par3;
    end

    N_trains=N_trains+f{indf}.n_trains;
end

get_field_names_bs;

fprintf('Total nuber of bs measures:%i\n',length(field_names_wc_ms));
fprintf('Uni:%i\n',n_uni);
fprintf('Bi:%i\n',n_bi);
fprintf('Multi:%i\n',n_multi);
fprintf('Bi+Multi:%i\n\n',n_bi+n_multi);

sync_all=zeros(length(field_names),2*N_trains);

i_train=0;

for indf=1:nf
    for i=1:f{indf}.n_par1
        for j=1:f{indf}.n_par2
            for k=1:f{indf}.n_par3
                if length(par.f{indf}.ranged_par)>3
                    for l=1:f{indf}.n_par4
                        i_train=i_train+1;
                        for ind_out=1:length(output_mat_files)
                            eval(['output_this{' num2str(ind_out) '}=load(''' stringa_dir_batch '_' num2str(f{indf}.ranged1_vect_plot(i)) '_' num2str(f{indf}.ranged2_vect_plot(j)) '_' num2str(f{indf}.ranged3_vect_plot(k)) '_' num2str(f{indf}.ranged4_vect_plot(l)) '_' par.f{indf}.suf1 '/' output_mat_files{ind_out} '.mat'');']);
                        end
                        for kk=1:length(field_names)
                            try
                                sync_all(kk,i_train)=output_this{file_ind(kk)}.(field_names{kk}); % dynamic field referencing
                            catch
                                sync_all(kk,i_train)=NaN;
                                keyboard;
                            end
                        end
                    end
                else
                    i_train=i_train+1;
                    for ind_out=1:length(output_mat_files)
                        eval(['output_this{' num2str(ind_out) '}=load(''' stringa_dir_batch '_' num2str(f{indf}.ranged1_vect_plot(i)) '_' num2str(f{indf}.ranged2_vect_plot(j)) '_' num2str(f{indf}.ranged3_vect_plot(k)) '_' par.f{indf}.suf1 '/' output_mat_files{ind_out} '.mat'');']);
                    end
                    for kk=1:length(field_names)
                        try
                            sync_all(kk,i_train)=output_this{file_ind(kk)}.(field_names{kk}); % dynamic field referencing
                        catch
                            sync_all(kk,i_train)=NaN;
                            keyboard;
                        end
                    end
                end
            end
        end
    end


    for i=1:f{indf}.n_par1
        for j=1:f{indf}.n_par2
            for k=1:f{indf}.n_par3
                if length(par.f{indf}.ranged_par)>3
                    for l=1:f{indf}.n_par4
                        i_train=i_train+1;
                        for ind_out=1:length(output_mat_files)
                            eval(['output_this{' num2str(ind_out) '}=load(''' stringa_dir_batch '_' num2str(f{indf}.ranged1_vect_plot(i)) '_' num2str(f{indf}.ranged2_vect_plot(j)) '_' num2str(f{indf}.ranged3_vect_plot(k)) '_' num2str(f{indf}.ranged4_vect_plot(l)) '_' par.f{indf}.suf2 '/' output_mat_files{ind_out} '.mat'');']);
                        end
                        for kk=1:length(field_names)
                            try
                                sync_all(kk,i_train)=output_this{file_ind(kk)}.(field_names{kk}); % dynamic field referencing
                            catch
                                sync_all(kk,i_train)=NaN;
                                keyboard;
                            end
                        end
                    end
                else
                    i_train=i_train+1;
                    for ind_out=1:length(output_mat_files)
                        eval(['output_this{' num2str(ind_out) '}=load(''' stringa_dir_batch '_' num2str(f{indf}.ranged1_vect_plot(i)) '_' num2str(f{indf}.ranged2_vect_plot(j)) '_' num2str(f{indf}.ranged3_vect_plot(k)) '_' par.f{indf}.suf2 '/' output_mat_files{ind_out} '.mat'');']);
                    end
                    for kk=1:length(field_names)
                        try
                            sync_all(kk,i_train)=output_this{file_ind(kk)}.(field_names{kk}); % dynamic field referencing
                        catch
                            sync_all(kk,i_train)=NaN;
                            keyboard;
                        end
                    end
                end
            end
        end
    end
end


eval(['mkdir ' stringa_dir_batch stringa_name '_All']);
eval(['cd ' stringa_dir_batch stringa_name '_All']);

stringa=['feat_analyze_' stringa_dir_batch];

mystyle = hgexport('factorystyle');
mystyle.Units='normalized';
mystyle.FontMode='none';

% cmap_parula=colormap; % Colormap 'default' option for heatmap displays the blue colormap instead of parula - Behavior changed in R2020b
cmap_parula=colormap(parula(64));
% ncolors=48;
ncolors=64;

n_nan_meas=sum(isnan(sum(sync_all,2)));
printf(['Out of %i measures, %i contain NaNs. That is the %f percent'],size(sync_all,1),n_nan_meas,100.*n_nan_meas/size(sync_all,1));
n_nan_trains=sum(isnan(sum(sync_all,1)));
printf(['Out of %i trains, %i contain NaNs. That is the %f percent'],size(sync_all,2),n_nan_trains,100.*n_nan_trains/size(sync_all,2));
fid = fopen([stringa_dir_batch stringa_name '_All' '_bs_nan_count.txt'],'w');
fprintf(fid,['\\noindent Out of %i measures, %i contain NaNs. That is the %f percent\\\\'],size(sync_all,1),n_nan_meas,100.*n_nan_meas/size(sync_all,1));
fprintf(fid,['\n']);
fprintf(fid,['Out of %i trains, %i contain NaNs. That is the %f percent\n'],size(sync_all,2),n_nan_trains,100.*n_nan_trains/size(sync_all,2));
fclose(fid);






% using abs(corr) and average distance

% sync_all_dist_abscorr = pdist(sync_all, @abscorr);
sync_all_dist_abscorr = pdist(sync_all, @abscorr_pairwise);
sync_all_link_abscorr_avg = linkage(sync_all_dist_abscorr, 'average');
sync_all_clust_corr = cluster(sync_all_link_abscorr_avg, 'cutoff', 1.2);


sync_all_dist_abscorr_mat=squareform(sync_all_dist_abscorr);
NSYNC=size(sync_all_dist_abscorr_mat);
icMDS=[];

try
    if isequal(icMDS,[])
        [xyMDS,stress] = mdscale(sync_all_dist_abscorr_mat,2,'criterion','metricstress');
        icMDS=xyMDS;
    else
        [xyMDS,stress] = mdscale(sync_all_dist_abscorr_mat,2,'criterion','metricstress','Start',icMDS);
        icMDS=xyMDS;
    end
catch
    [xyMDS,stress] = mdscale(sync_all_dist_abscorr_mat,2,'criterion','metricstress','Start','random');
end

ff=0.1;

figure;
set(gcf,'Color',[1 1 1]);
for iSYNC=1:NSYNC(1)
    plot(xyMDS(iSYNC,1),xyMDS(iSYNC,2),'wo'); % just so that the axis are set properly
    hold on;
    text(xyMDS(iSYNC,1),xyMDS(iSYNC,2),field_names{iSYNC},'HorizontalAlignment','center','VerticalAlignment','middle','Interpreter','none','FontSize',12);
end
axis equal;
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
    figure_name='sync_all_abscorr_mds_metric';
    export_fig(gcf,[figure_name stringa_name '_bs_bal_' names_string '.png']);
end


figure;
set(gcf,'Color',[1 1 1]);
for iSYNC=1:NSYNC(1)
    plot(xyMDS(iSYNC,1),xyMDS(iSYNC,2),'wo'); % just so that the axis are set properly
    hold on;
    text(xyMDS(iSYNC,1),xyMDS(iSYNC,2),field_names{iSYNC},'HorizontalAlignment','center','VerticalAlignment','middle','Interpreter','none','FontSize',12,'Color',field_colors{iSYNC});
end
axis equal;
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
    figure_name='sync_all_abscorr_mds_metric_color';
    export_fig(gcf,[figure_name stringa_name '_bs_bal_' names_string '.png']);
end

stress




figure;
set(gcf,'Color',[1 1 1]);
[H,T,outperm] = dendrogram(sync_all_link_abscorr_avg,0);
set(gcf,'Position',[1000         392        1476         942]);
% set(gca,'XTickLabels',field_names(outperm),'Interpreter','none');
set(gca,'XTickLabels',strrep(field_names(outperm),'_','\_'),'FontSize',14);
xtickangle(gca,45);
if PLOT.print
    figure_name='sync_all_abscorr_avg_dendro';
    export_fig(gcf,[figure_name stringa_name '_bs_bal_' names_string '.png']);
end

figure;
set(gcf,'Color',[1 1 1]);
[H,T,outperm] = dendrogram(sync_all_link_abscorr_avg,0);
set(gcf,'Position',[1000         392        1476         942]);
set(gca,'XTickLabels',strrep(field_names_wc_ms(outperm),'_','\_'),'FontSize',14);
xtickangle(gca,45);
if PLOT.print
    figure_name='sync_all_abscorr_avg_dendro_color';
    export_fig(gcf,[figure_name stringa_name '_bs_bal_' names_string '.png']);
end

sync_all_corr=1-sync_all_dist_abscorr;
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
set(gca,'xaxisLocation','top')
set(gca,'XTick',1:1:length(field_names));
set(gca,'XTickLabels',strrep(field_names(outperm),'_','\_'),'fontsize',14); % this sets the scale for all axis text properties... ok for now
xtickangle(gca,45);
set(gca,'YTick',1:1:length(field_names));
set(gca,'YTickLabels',strrep(field_names(outperm),'_','\_'));
cbh=colorbar;
pos_vect=get(cbh,'Position');
th2=annotation('textbox',[pos_vect(1)+pos_vect(3)+0.01 pos_vect(2)+0.46*pos_vect(4) 0.012 0.046],'String','corr','FontSize',24,'LineStyle','none','VerticalAlignment','middle');
if PLOT.print
    figure_name='sync_all_abscorr_avg_mat';
    export_fig(gcf,[figure_name stringa_name '_bs_bal_' names_string '.png']);
end

figure;
set(gcf,'Color',[1 1 1]);
set(gcf,'Position',[1 1 1200 1000]);
imAlpha=ones(size(sync_all_corr_mat_2plot));
imAlpha(isnan(sync_all_corr_mat_2plot))=0;
imagesc(sync_all_corr_mat_2plot,'AlphaData',imAlpha);
set(gca,'color',0.95*[1 1 1]);
axis square
set(gca,'xaxisLocation','top')
set(gca,'XTick',1:1:length(field_names_wc_ms));
set(gca,'XTickLabels',strrep(field_names_wc_ms(outperm),'_','\_'),'fontsize',14); % this sets the scale for all axis text properties... ok for now
xtickangle(gca,45);
set(gca,'YTick',1:1:length(field_names_wc_ms));
set(gca,'YTickLabels',strrep(field_names_wc_ms(outperm),'_','\_'));
cbh=colorbar;
pos_vect=get(cbh,'Position');
th2=annotation('textbox',[pos_vect(1)+pos_vect(3)+0.01 pos_vect(2)+0.46*pos_vect(4) 0.012 0.046],'String','corr','FontSize',24,'LineStyle','none','VerticalAlignment','middle');
if PLOT.print
    figure_name='sync_all_abscorr_avg_mat_color';
    export_fig(gcf,[figure_name stringa_name '_bs_bal_' names_string '.png']);
end






% using  abs(spearman_corr) and average distance

% sync_all_dist_abscorr = pdist(sync_all, @abscorr);
% sync_all_dist_abscorr = pdist(sync_all, @abscorr_pairwise);
sync_all_dist_absspearmancorr = pdist(sync_all, @abs_spearman_corr_pairwise);
sync_all_link_absspearmancorr_avg = linkage(sync_all_dist_absspearmancorr, 'average');
sync_all_clust_corr = cluster(sync_all_link_absspearmancorr_avg, 'cutoff', 1.2);


sync_all_dist_absspearmancorr_mat=squareform(sync_all_dist_absspearmancorr);
NSYNC=size(sync_all_dist_absspearmancorr_mat);
icMDS=[];

try
    if isequal(icMDS,[])
        [xyMDS,stress] = mdscale(sync_all_dist_absspearmancorr_mat,2,'criterion','metricstress');
        icMDS=xyMDS;
    else
        [xyMDS,stress] = mdscale(sync_all_dist_absspearmancorr_mat,2,'criterion','metricstress','Start',icMDS);
        icMDS=xyMDS;
    end
catch
    [xyMDS,stress] = mdscale(sync_all_dist_absspearmancorr_mat,2,'criterion','metricstress','Start','random');
end

ff=0.1;

figure;
set(gcf,'Color',[1 1 1]);
for iSYNC=1:NSYNC(1)
    plot(xyMDS(iSYNC,1),xyMDS(iSYNC,2),'wo'); % just so that the axis are set properly
    hold on;
    text(xyMDS(iSYNC,1),xyMDS(iSYNC,2),field_names{iSYNC},'HorizontalAlignment','center','VerticalAlignment','middle','Interpreter','none','FontSize',12);
end
axis equal;
axis off;
xlim_vect=xlim;
ylim_vect=ylim;
xwidth=xlim_vect(2)-xlim_vect(1);
ywidth=ylim_vect(2)-ylim_vect(1);
% xlim_vect=[xlim_vect(1)-ff*xwidth,xlim_vect(2)+ff*xwidth];
xlim_vect=[xlim_vect(1)-1.38*ff*xwidth,xlim_vect(2)+1.38*ff*xwidth];
ylim_vect=[ylim_vect(1)-ff*ywidth,ylim_vect(2)+ff*ywidth];
plot(xlim_vect,ylim_vect(1).*ones(1,2),'k','LineWidth',2);
plot(xlim_vect,ylim_vect(2).*ones(1,2),'k','LineWidth',2);
plot(xlim_vect(1).*ones(1,2),ylim_vect,'k','LineWidth',2);
plot(xlim_vect(2).*ones(1,2),ylim_vect,'k','LineWidth',2);
if PLOT.print
    figure_name='sync_all_absspearmancorr_mds_metric';
    export_fig(gcf,[figure_name stringa_name '_bs_bal_' names_string '.png']);
end


figure;
set(gcf,'Color',[1 1 1]);
for iSYNC=1:NSYNC(1)
    plot(xyMDS(iSYNC,1),xyMDS(iSYNC,2),'wo'); % just so that the axis are set properly
    hold on;
    text(xyMDS(iSYNC,1),xyMDS(iSYNC,2),field_names{iSYNC},'HorizontalAlignment','center','VerticalAlignment','middle','Interpreter','none','FontSize',12,'Color',field_colors{iSYNC});
end
axis equal;
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
    figure_name='sync_all_absspearmancorr_mds_metric_color';
    export_fig(gcf,[figure_name stringa_name '_bs_bal_' names_string '.png']);
end

figure;
set(gcf,'Color',[1 1 1]);
for iSYNC=1:NSYNC(1)
    scatter(xyMDS(iSYNC,1),xyMDS(iSYNC,2),'wo','MarkerEdgeAlpha',0,'MarkerFaceAlpha',0); % just so that the axis are set properly
    hold on;
    text(xyMDS(iSYNC,1),xyMDS(iSYNC,2),field_names_latex_ms{iSYNC},'HorizontalAlignment','center','VerticalAlignment','middle','Interpreter','latex','FontSize',12,'Color',field_colors{iSYNC});
end
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
    figure_name='sync_all_absspearmancorr_mds_metric_color_latex';
    export_fig(gcf,[figure_name stringa_name '_bs_bal_' names_string '.png'],'-m3');
end

stress

% not_shown={'modulus_mn','emdn','schreiber_c1','vRn1','VPN1','HM1','vR1','VP1','Lv_ISI','IR_ISI','SM_ISI','QQA','kruskal_c1','sttc1','fooof_1p_offset'};
not_shown={'modulus_m','modulus_mn','emd','emdn','bursty','PPC','schreiber_c1','vRn1','VPN1','HM1','vR1','VP1','cv_ISI','Lv_ISI','LCV_ISI','IR_ISI','SM_ISI','QQA','kruskal_c1','sttc1','fooof_1p_offset','psd_max'};

figure;
set(gcf,'Color',[1 1 1]);
for iSYNC=1:NSYNC(1)
    % plot(xyMDS(iSYNC,1),xyMDS(iSYNC,2),'wo'); % just so that the axis are set properly - this can't be made tranparent
    scatter(xyMDS(iSYNC,1),xyMDS(iSYNC,2),'wo','MarkerEdgeAlpha',0,'MarkerFaceAlpha',0); % just so that the axis are set properly
    hold on;
    if any(strcmp(field_names{iSYNC},not_shown))
        continue
    end

    text(xyMDS(iSYNC,1),xyMDS(iSYNC,2),field_names_latex_ms{iSYNC},'HorizontalAlignment','center','VerticalAlignment','middle','Interpreter','latex','FontSize',12,'Color',field_colors{iSYNC});
end
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
    figure_name='sync_all_absspearmancorr_mds_metric_color_latex_sel';
    export_fig(gcf,[figure_name stringa_name '_bs_bal_' names_string '.png'],'-m3'); % triple-size
    % hgexport(gcf,[figure_name stringa_name '_bs_bal_' names_string '_hge.png'],mystyle,'Format','png'); % same problem, some symbols are not shown correctly
end




figure;
set(gcf,'Color',[1 1 1]);
[H,T,outperm_spearman] = dendrogram(sync_all_link_absspearmancorr_avg,0);
set(gcf,'Position',[1000         392        1476         942]);
% set(gca,'XTickLabels',field_names(outperm_spearman),'Interpreter','none');
set(gca,'XTickLabels',strrep(field_names(outperm_spearman),'_','\_'),'FontSize',14);
xtickangle(gca,45);
if PLOT.print
    figure_name='sync_all_absspearmancorr_avg_dendro';
    export_fig(gcf,[figure_name stringa_name '_bs_bal_' names_string '.png']);
end

figure;
set(gcf,'Color',[1 1 1]);
[H,T,outperm_spearman] = dendrogram(sync_all_link_absspearmancorr_avg,0);
set(gcf,'Position',[1000         392        1476         942]);
% set(gca,'XTickLabels',field_names(outperm_spearman),'Interpreter','none');
set(gca,'XTickLabels',strrep(field_names_wc_ms(outperm_spearman),'_','\_'),'FontSize',14);
xtickangle(gca,45);
if PLOT.print
    figure_name='sync_all_absspearmancorr_avg_dendro_color';
    export_fig(gcf,[figure_name stringa_name '_bs_bal_' names_string '.png']);
end

figure;
set(gcf,'Color',[1 1 1]);
[H,T,outperm_spearman] = dendrogram(sync_all_link_absspearmancorr_avg,0);
ylabel('cluster distance');
set(gcf,'Position',[1000         392        1476         942]);
% set(gca,'XTickLabels',field_names(outperm_spearman),'Interpreter','none');
set(gca,'XTickLabels',strrep(field_names_long_wc_ms(outperm_spearman),'_','\_'),'FontSize',14);
xtickangle(gca,45);
if PLOT.print
    figure_name='sync_all_absspearmancorr_avg_dendro_color_longn';
    export_fig(gcf,[figure_name stringa_name '_bs_bal_' names_string '.png']);
end

sync_all_corr=1-sync_all_dist_absspearmancorr;
sync_all_corr_mat=squareform(sync_all_corr);
sync_all_corr_mat_sorted=sync_all_corr_mat(outperm_spearman,outperm_spearman);
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
set(gca,'xaxisLocation','top')
set(gca,'XTick',1:1:length(field_names));
set(gca,'XTickLabels',strrep(field_names(outperm_spearman),'_','\_'),'fontsize',14); % this sets the scale for all axis text properties... ok for now
xtickangle(gca,45);
set(gca,'YTick',1:1:length(field_names));
set(gca,'YTickLabels',strrep(field_names(outperm_spearman),'_','\_'));
cbh=colorbar;
pos_vect=get(cbh,'Position');
th2=annotation('textbox',[pos_vect(1)+pos_vect(3)+0.01 pos_vect(2)+0.46*pos_vect(4) 0.012 0.046],'String','corr','FontSize',24,'LineStyle','none','VerticalAlignment','middle');
if PLOT.print
    figure_name='sync_all_absspearmancorr_avg_mat';
    export_fig(gcf,[figure_name stringa_name '_bs_bal_' names_string '.png']);
end

figure;
set(gcf,'Color',[1 1 1]);
set(gcf,'Position',[1 1 1200 1000]);
imAlpha=ones(size(sync_all_corr_mat_2plot));
imAlpha(isnan(sync_all_corr_mat_2plot))=0;
imagesc(sync_all_corr_mat_2plot,'AlphaData',imAlpha);
set(gca,'color',0.95*[1 1 1]);
axis square
set(gca,'xaxisLocation','top')
set(gca,'XTick',1:1:length(field_names_wc_ms));
set(gca,'XTickLabels',strrep(field_names_wc_ms(outperm_spearman),'_','\_'),'fontsize',14); % this sets the scale for all axis text properties... ok for now
xtickangle(gca,45);
set(gca,'YTick',1:1:length(field_names_wc_ms));
set(gca,'YTickLabels',strrep(field_names_wc_ms(outperm_spearman),'_','\_'));
cbh=colorbar;
pos_vect=get(cbh,'Position');
th2=annotation('textbox',[pos_vect(1)+pos_vect(3)+0.01 pos_vect(2)+0.51*pos_vect(4) 0.012 0.046],'String','|\rho|','FontSize',24,'LineStyle','none','VerticalAlignment','middle');
if PLOT.print
    figure_name='sync_all_absspearmancorr_avg_mat_color';
    export_fig(gcf,[figure_name stringa_name '_bs_bal_' names_string '.png']);
end


figure;
set(gcf,'Color',[1 1 1]);
set(gcf,'Position',[1 1 1200 1000]);
imAlpha=ones(size(sync_all_corr_mat_2plot));
imAlpha(isnan(sync_all_corr_mat_2plot))=0;
imagesc(sync_all_corr_mat_2plot,'AlphaData',imAlpha);
set(gca,'color',0.95*[1 1 1]);
axis square
set(gca,'xaxisLocation','top')
set(gca,'XTick',1:1:length(field_names));
set(gca,'XTickLabels',strrep(field_names_long_wc_ms(outperm_spearman),'_','\_'),'fontsize',10); % this sets the scale for all axis text properties... ok for now
xtickangle(gca,45);
set(gca,'YTick',1:1:length(field_names));
set(gca,'YTickLabels',strrep(field_names_long_wc_ms(outperm_spearman),'_','\_'),'fontsize',10); % this sets the scale for all axis text properties... ok for now
cbh=colorbar;
pos_vect=get(cbh,'Position');
th2=annotation('textbox',[pos_vect(1)+pos_vect(3)+0.01 pos_vect(2)+0.51*pos_vect(4) 0.012 0.046],'String','|\rho|','FontSize',24,'LineStyle','none','VerticalAlignment','middle');
if PLOT.print
    figure_name='sync_all_absspearmancorr_avg_mat_color_longn';
    export_fig(gcf,[figure_name stringa_name '_bs_bal_' names_string '.png']);
end




figure;
set(gcf,'Color',[1 1 1]);
set(gcf,'Position',[1 1 1200 1420]); % adding 420 (standard height is 413)
imAlpha=ones(size(sync_all_corr_mat_2plot));
imAlpha(isnan(sync_all_corr_mat_2plot))=0;
imagesc(sync_all_corr_mat_2plot,'AlphaData',imAlpha);
set(gca,'color',0.95*[1 1 1]);
axis square
set(gca,'XTick',1:1:length(field_names));
set(gca,'XTickLabel',{'','','','',''})
set(gca,'YTick',1:1:length(field_names));
set(gca,'YTickLabels',strrep(field_names_long_wc_ms(outperm_spearman),'_','\_'),'fontsize',10); % this sets the scale for all axis text properties... ok for now
set(gca,'Position',[0.1300    0.01    0.7265    0.5039]);
cbh=colorbar;
pos_vect=get(cbh,'Position');
set(cbh,'FontSize',10);
th2=annotation('textbox',[pos_vect(1)+pos_vect(3)+0.02 pos_vect(2)+0.51*pos_vect(4) 0.012 0.046],'String','|\rho|','FontSize',24,'LineStyle','none','VerticalAlignment','middle');
set(gca,'Position',[0.1300    0.01    0.7265    0.5039]); % the same as automatically set, just in case (width is automatically shrinked for some reason)

pos_vect=get(gca,'Position');
pos_tight=tightPosition(gca);
sa=axes('Position',[pos_tight(1)    pos_tight(2)+pos_vect(4)+0.005    pos_tight(3)    0.1252]);
for iSYNC=1:NSYNC(1)
    iSYNC_perm=outperm_spearman(iSYNC);
    text(iSYNC,0.5,strrep(field_names_long_wc_ms(iSYNC_perm),'_','\_'),'HorizontalAlignment','center','VerticalAlignment','middle','Rotation',90,'FontSize',10);
    hold on;
end
set(sa,'XLim',0.5+[0 size(sync_all,1)]);
axis off;

pos_vect=get(gca,'Position');
pos_tight=tightPosition(gca);
xsa=axes('Position',[pos_tight(1)    pos_tight(2)+pos_vect(4)+0.005    pos_tight(3)    0.3539]); % not as high

[H,T,outperm_spearman] = dendrogram(sync_all_link_absspearmancorr_avg,0); % trying to display the whole tree
set(H,'LineWidth',1)
hold on;
set(xsa,'XLim',0.5+[0 size(sync_all,1)]);
set(xsa,'XTickLabel',{'','','','',''})
ylabel('cluster distance');
if PLOT.print
    figure_name='sync_all_absspearmancorr_avg_mat_color_dendro_longn';
    export_fig(gcf,[figure_name stringa_name '_bs_bal_' names_string '.png']);
end

clear output_this;
whos
save(['cluster' stringa_name '_bs_bal_output' '_' names_string]);
% keyboard;
output_struct=[];
cd ..

return
