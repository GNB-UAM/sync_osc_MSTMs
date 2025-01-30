function output_struct=multi_all_train_range_data_anal_cluster_bal_compare(stringa_dir_batch,par)

PLOT.print=1;

nf=length(par.f);

nd=length(par.d);

nt=nf+3+nd;

for indf=1:nf
    eval(['output_this{indf}=load(''' stringa_dir_batch '_' par.f{indf}.suf1 '_' par.f{indf}.suf2 '_all/cluster_output' par.png_tail '_' par.names_string '.mat'');']);
    fam_names{indf}=[ par.f{indf}.suf1 ' & ' par.f{indf}.suf2];
    fam_names_short{indf}=[ par.f{indf}.suf1 ' & ' par.f{indf}.suf2];
    fam_names_vshort{indf}=[ par.f{indf}.suf1 ' & ' par.f{indf}.suf2];
end

output_this{indf+1}=load(fullfile([stringa_dir_batch '_ss_All'],['cluster_ss' par.png_tail '_bal_output_' par.names_string '.mat'])); % note it only makes sense to consider bal clustering when more than one synth family is lumped together
fam_names{indf+1}='all single-scale';
fam_names_short{indf+1}='single-scale';
fam_names_vshort{indf+1}='SS';

output_this{indf+2}=load(fullfile([stringa_dir_batch '_ds_All'],['cluster_ds' par.png_tail '_bal_output_' par.names_string '.mat']));
fam_names{indf+2}='all dual-scale';
fam_names_short{indf+2}='dual-scale';
fam_names_vshort{indf+2}='DS';

output_this{indf+3}=load(fullfile([stringa_dir_batch '_All'],['cluster' par.png_tail '_bal_output_' par.names_string '.mat']));
fam_names{indf+3}='all synth';
fam_names_short{indf+3}='all synth';
fam_names_vshort{indf+3}='AS';

for indd=1:nd
    output_this{nf+3+indd}=load(fullfile(par.d{indd}.dataDir,['cluster_output' par.png_tail '_' par.names_string '.mat']));
    fam_names{nf+3+indd}=[ par.d{indd}.stringa];
    fam_names_short{nf+3+indd}=[ par.d{indd}.stringa];
    fam_names_vshort{nf+3+indd}=[ par.d{indd}.vsstringa];
end


eval(['mkdir ' stringa_dir_batch  '_data_All']);
eval(['cd ' stringa_dir_batch  '_data_All']);


mystyle = hgexport('factorystyle');
mystyle.Units='normalized';
mystyle.FontMode='none';

% cmap_parula=colormap; % Colormap 'default' option for heatmap displays the blue colormap instead of parula - Behavior changed in R2020b
cmap_parula=colormap(parula(64));
% ncolors=48;
ncolors=64;


rho_mat_abscorr_all=nan(nt);
pval_mat_abscorr_all=nan(nt);

rho_mat_absspearmancorr_all=nan(nt);
pval_mat_absspearmancorr_all=nan(nt);

for indf=1:nt
    for jndf=(indf+1):nt
        [rho_mat_abscorr_all(indf,jndf) pval_mat_abscorr_all(indf,jndf)]=corr(output_this{indf}.sync_all_dist_abscorr',output_this{jndf}.sync_all_dist_abscorr');
        [rho_mat_absspearmancorr_all(indf,jndf) pval_mat_absspearmancorr_all(indf,jndf)]=corr(output_this{indf}.sync_all_dist_absspearmancorr',output_this{jndf}.sync_all_dist_absspearmancorr');
    end
end




figure;
set(gcf,'Color',[1 1 1]);
set(gcf,'Position',[1 1 1200 1000]);
imAlpha=ones(size(rho_mat_abscorr_all));
imAlpha(isnan(rho_mat_abscorr_all))=0;
imagesc(rho_mat_abscorr_all,'AlphaData',imAlpha);
set(gca,'color',0.95*[1 1 1]);
axis square
set(gca,'xaxisLocation','top')
set(gca,'XTick',1:1:nt);
set(gca,'XTickLabels',fam_names,'fontsize',16); % this sets the scale for all axis text properties... ok for now
xtickangle(gca,45);
set(gca,'YTick',1:1:nt);
set(gca,'YTickLabels',fam_names);
cbh=colorbar;
pos_vect=get(cbh,'Position');
th2=annotation('textbox',[pos_vect(1)+pos_vect(3)+0.01 pos_vect(2)+0.46*pos_vect(4) 0.012 0.046],'String','corr','FontSize',24,'LineStyle','none','VerticalAlignment','middle');
if PLOT.print
    figure_name='fam_dist_abscorr_mat';
    export_fig(gcf,[figure_name par.png_tail '_bal_' par.names_string '.png']);
end

figure;
set(gcf,'Color',[1 1 1]);
set(gcf,'Position',[1 1 1200 1000]);
imAlpha=ones(size(rho_mat_absspearmancorr_all));
imAlpha(isnan(rho_mat_absspearmancorr_all))=0;
imagesc(rho_mat_absspearmancorr_all,'AlphaData',imAlpha);
set(gca,'color',0.95*[1 1 1]);
axis square
set(gca,'xaxisLocation','top')
set(gca,'XTick',1:1:nt);
set(gca,'XTickLabels',fam_names,'fontsize',16); % this sets the scale for all axis text properties... ok for now
xtickangle(gca,45);
set(gca,'YTick',1:1:nt);
set(gca,'YTickLabels',fam_names);
cbh=colorbar;
pos_vect=get(cbh,'Position');
th2=annotation('textbox',[pos_vect(1)+pos_vect(3)+0.01 pos_vect(2)+0.46*pos_vect(4) 0.012 0.046],'String','corr','FontSize',24,'LineStyle','none','VerticalAlignment','middle');
if PLOT.print
    figure_name='fam_dist_absspearmancorr_mat';
    export_fig(gcf,[figure_name par.png_tail '_bal_' par.names_string '.png']);
end


rho_mat_abscorr_sel=rho_mat_abscorr_all(5:end,5:end);
rho_mat_absspearmancorr_sel=rho_mat_absspearmancorr_all(5:end,5:end);

figure;
set(gcf,'Color',[1 1 1]);
set(gcf,'Position',[1 1 1200 1000]);
imAlpha=ones(size(rho_mat_abscorr_sel));
imAlpha(isnan(rho_mat_abscorr_sel))=0;
imagesc(rho_mat_abscorr_sel,'AlphaData',imAlpha);
set(gca,'color',0.95*[1 1 1]);
axis square
set(gca,'xaxisLocation','top')
set(gca,'XTick',1:1:(nt-4));
set(gca,'XTickLabels',fam_names_short(5:end),'fontsize',16); % this sets the scale for all axis text properties... ok for now
xtickangle(gca,45);
set(gca,'YTick',1:1:(nt-4));
set(gca,'YTickLabels',fam_names_short(5:end));
cbh=colorbar;
pos_vect=get(cbh,'Position');
th2=annotation('textbox',[pos_vect(1)+pos_vect(3)+0.01 pos_vect(2)+0.46*pos_vect(4) 0.012 0.046],'String','\rho','FontSize',24,'LineStyle','none','VerticalAlignment','middle');
if PLOT.print
    figure_name='fam_dist_abscorr_mat_v2';
    export_fig(gcf,[figure_name par.png_tail '_bal_' par.names_string '.png']);
end

figure;
set(gcf,'Color',[1 1 1]);
set(gcf,'Position',[1 1 1200 1000]);
imAlpha=ones(size(rho_mat_absspearmancorr_sel));
imAlpha(isnan(rho_mat_absspearmancorr_sel))=0;
imagesc(rho_mat_absspearmancorr_sel,'AlphaData',imAlpha);
set(gca,'color',0.95*[1 1 1]);
axis square
set(gca,'xaxisLocation','top')
set(gca,'XTick',1:1:(nt-4));
set(gca,'XTickLabels',fam_names_short(5:end),'fontsize',16); % this sets the scale for all axis text properties... ok for now
xtickangle(gca,45);
set(gca,'YTick',1:1:(nt-4));
set(gca,'YTickLabels',fam_names_short(5:end));
cbh=colorbar;
pos_vect=get(cbh,'Position');
th2=annotation('textbox',[pos_vect(1)+pos_vect(3)+0.01 pos_vect(2)+0.46*pos_vect(4) 0.012 0.046],'String','\rho','FontSize',24,'LineStyle','none','VerticalAlignment','middle');
if PLOT.print
    figure_name='fam_dist_absspearmancorr_mat_v2';
    export_fig(gcf,[figure_name par.png_tail '_bal_' par.names_string '.png']);
end


figure;
set(gcf,'Color',[1 1 1]);
set(gcf,'Position',[1 1 1200 1000]);
imAlpha=ones(size(rho_mat_absspearmancorr_sel));
imAlpha(isnan(rho_mat_absspearmancorr_sel))=0;
imagesc(rho_mat_absspearmancorr_sel,'AlphaData',imAlpha);
set(gca,'color',0.95*[1 1 1]);
axis square
set(gca,'xaxisLocation','top')
set(gca,'XTick',1:1:(nt-4));
set(gca,'XTickLabels',fam_names_short(5:end),'fontsize',30); % this sets the scale for all axis text properties... ok for now
xtickangle(gca,45);
set(gca,'YTick',1:1:(nt-4));
set(gca,'YTickLabels',fam_names_short(5:end));
cbh=colorbar;
pos_vect=get(gca,'Position');
cb_pos_vect=get(cbh,'Position');
    cb_pos_vect=[pos_vect(1)+pos_vect(3)+0.05*pos_vect(3) cb_pos_vect(2:end)];
set(cbh,'Position',cb_pos_vect);
set(gca,'Position',pos_vect); % we need to reset this after setting cb pos
if strcmp(par.png_tail,'_bs')
th2=annotation('textbox',[cb_pos_vect(1)+cb_pos_vect(3)+0.035 cb_pos_vect(2)+0.44*cb_pos_vect(4) 0.012 0.046],'String','\rho','FontSize',34,'LineStyle','none','VerticalAlignment','middle');
elseif strcmp(par.png_tail,'')
th2=annotation('textbox',[cb_pos_vect(1)+cb_pos_vect(3)+0.035 cb_pos_vect(2)+0.46*cb_pos_vect(4) 0.012 0.046],'String','\rho','FontSize',34,'LineStyle','none','VerticalAlignment','middle');
end
if PLOT.print
    figure_name='fam_dist_absspearmancorr_mat_v3';
    export_fig(gcf,[figure_name par.png_tail '_bal_' par.names_string '.png']);
end


rho_mat_absspearmancorr_sel

rho_mat_absspearmancorr_sel_full=zeros(size(rho_mat_absspearmancorr_sel)); % filling in all values
for i=1:size(rho_mat_absspearmancorr_sel_full,1)
    rho_mat_absspearmancorr_sel_full(i,i)=1;
    for j=(i+1):size(rho_mat_absspearmancorr_sel_full,2)
        rho_mat_absspearmancorr_sel_full(i,j)=rho_mat_absspearmancorr_sel(i,j);
        rho_mat_absspearmancorr_sel_full(j,i)=rho_mat_absspearmancorr_sel(i,j);
    end
end

rho_dist_absspearmancorr_sel=1-rho_mat_absspearmancorr_sel_full;
try
    if isequal(icMDS,[])
        [xyMDS,stress] = mdscale(rho_dist_absspearmancorr_sel,2,'criterion','metricstress');
        icMDS=xyMDS;
    else
        [xyMDS,stress] = mdscale(rho_dist_absspearmancorr_sel,2,'criterion','metricstress','Start',icMDS);
        icMDS=xyMDS;
    end
catch
    maximumNumberOfTries = 100;
    counter  = 0;
    xyMDS=[];
    while isempty(xyMDS) && counter < maximumNumberOfTries % maximum ~100 tries
        try
            [xyMDS,stress] = mdscale(rho_dist_absspearmancorr_sel,2,'criterion','metricstress','Start','random');
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

figure;
set(gcf,'Color',[1 1 1]);
for iSYNC=1:size(rho_mat_absspearmancorr_sel_full,1)
    plot(xyMDS(iSYNC,1),xyMDS(iSYNC,2),'wo'); % just so that the axis are set properly
    hold on;
    text(xyMDS(iSYNC,1),xyMDS(iSYNC,2),fam_names_vshort{4+iSYNC},'HorizontalAlignment','center','VerticalAlignment','middle','Interpreter','none','FontSize',12);
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
    figure_name='fam_dist_absspearmancorr_mds_metric';
    export_fig(gcf,[figure_name par.png_tail '_bal_' par.names_string '.png']);
end




for indf=1:nt
    coph_abscorr_avg(indf) = cophenet(output_this{indf}.sync_all_link_abscorr_avg,output_this{indf}.sync_all_dist_abscorr);
    coph_absspearmancorr_avg(indf) = cophenet(output_this{indf}.sync_all_link_absspearmancorr_avg,output_this{indf}.sync_all_dist_absspearmancorr);
end





figure;
set(gcf,'Color',[1 1 1]);
set(gcf,'Position',[1 1 1200 1000]);
bar(coph_abscorr_avg);
set(gca,'XTick',1:1:nt);
set(gca,'XTickLabels',fam_names,'fontsize',16); % this sets the scale for all axis text properties... ok for now
xtickangle(gca,45);
ylabel('cophenet corr');
if PLOT.print
    figure_name='fam_coph_abscorr_avg_mat';
    export_fig(gcf,[figure_name par.png_tail '_bal_' par.names_string '.png']);
end

figure;
set(gcf,'Color',[1 1 1]);
set(gcf,'Position',[1 1 1200 1000]);
bar(coph_absspearmancorr_avg);
set(gca,'XTick',1:1:nt);
set(gca,'XTickLabels',fam_names,'fontsize',16); % this sets the scale for all axis text properties... ok for now
xtickangle(gca,45);
ylabel('cophenet corr');
if PLOT.print
    figure_name='fam_coph_absspearmancorr_avg_mat';
    export_fig(gcf,[figure_name par.png_tail '_bal_' par.names_string '.png']);
end


output_struct=[];
cd ..
return;