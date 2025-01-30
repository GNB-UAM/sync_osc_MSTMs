function output_struct=multi_all_train_range_anal_corr_bal(stringa_dir_batch,par,stringa_name,ind_sort)

if nargin < 3
    stringa_name='';
    stringa_title='all synth';
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

if isempty(par.png_tail)
    get_field_names;
    FontSizeThis=7;
elseif strcmp(par.png_tail,'_bs')
    get_field_names_bs;
    FontSizeThis=14;
else
    keyboard;
end

fprintf('Total nuber of ms measures:%i\n',length(field_names_wc_ms));
fprintf('Uni:%i\n',n_uni);
fprintf('Bi:%i\n',n_bi);
fprintf('Multi:%i\n',n_multi);
fprintf('Bi+Multi:%i\n\n',n_bi+n_multi);

sync_all=zeros(length(field_names),2*N_trains);
par_mat=zeros(5,2*N_trains);
i_train=0;

for indf=1:nf
    for i=1:f{indf}.n_par1
        for j=1:f{indf}.n_par2
            for k=1:f{indf}.n_par3
                if length(par.f{indf}.ranged_par)>3
                    for l=1:f{indf}.n_par4
                        i_train=i_train+1;
                        par_mat(1,i_train)=f{indf}.ranged_par1_vect(i);
                        par_mat(2,i_train)=f{indf}.ranged_par2_vect(j);
                        par_mat(3,i_train)=f{indf}.ranged_par3_vect(k);
                        par_mat(4,i_train)=f{indf}.ranged_par4_vect(l);
                        par_mat(5,i_train)=1;
                        clear output_this;
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
                    par_mat(1,i_train)=f{indf}.ranged_par1_vect(i);
                    par_mat(2,i_train)=f{indf}.ranged_par2_vect(j);
                    par_mat(3,i_train)=f{indf}.ranged_par3_vect(k);
                    par_mat(4,i_train)=0; % non-seq trains can be considered as seq trains with duty_cycle=0
                    par_mat(5,i_train)=1;
                    clear output_this;
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
                        par_mat(1,i_train)=f{indf}.ranged_par1_vect(i);
                        par_mat(2,i_train)=f{indf}.ranged_par2_vect(j);
                        par_mat(3,i_train)=f{indf}.ranged_par3_vect(k);
                        par_mat(4,i_train)=f{indf}.ranged_par4_vect(l);
                        par_mat(5,i_train)=0;
                        clear output_this;
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
                    par_mat(1,i_train)=f{indf}.ranged_par1_vect(i);
                    par_mat(2,i_train)=f{indf}.ranged_par2_vect(j);
                    par_mat(3,i_train)=f{indf}.ranged_par3_vect(k);
                    par_mat(4,i_train)=0; % non-seq trains can be considered as seq trains with duty_cycle=0
                    par_mat(5,i_train)=0;
                    clear output_this;
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

nmeas=length(field_names);

% using  abs(spearman_corr)

rho_spearman_mat_all=nan(5,nmeas);
pval_spearman_mat_all=nan(5,nmeas);

for ipar=1:5
    for imeas=1:nmeas
        [rho_spearman_mat_all(ipar,imeas) pval_spearman_mat_all(ipar,imeas)]=corr(par_mat(ipar,:)',sync_all(imeas,:)','Type','Spearman','rows','pairwise');
    end
end

absrho_spearman_mat_all=abs(rho_spearman_mat_all);

[absrho_spearman_sorted absrho_spearman_sorted_ind]=sort(absrho_spearman_mat_all(ind_sort,:),'descend'); % sorting according to correlation with r_osc_ampl

ranged_stringa_tex=par.ranged_stringa_tex;
ranged_stringa_tex{5}='osc';
par_sorted_ind=[ind_sort setdiff([1:5],ind_sort)];
if contains(stringa_name,'ds')
    par_sorted_ind=[2 4 1 3 5];
end

absrho_spearman_mat_all_2plot=absrho_spearman_mat_all(par_sorted_ind,absrho_spearman_sorted_ind);


pval_min=-log10(0.05);
pval_max=6;

pval_spearman_mat_all_2plot=pval_spearman_mat_all(par_sorted_ind,absrho_spearman_sorted_ind);
pval_spearman_mat_all_2plot=min(pval_max,-log10(pval_spearman_mat_all_2plot)); % clipping at pval_max=6


pval_spearman_thr_mat_all_2plot=pval_spearman_mat_all_2plot;
absrho_spearman_thr_mat_all_2plot=absrho_spearman_mat_all_2plot;
for irow=1:size(pval_spearman_thr_mat_all_2plot,1)
    pval_spearman_thr_mat_all_2plot(irow,pval_spearman_mat_all_2plot(irow,:)<pval_min)=nan(size(find(pval_spearman_mat_all_2plot(irow,:)<pval_min)));
    absrho_spearman_thr_mat_all_2plot(irow,pval_spearman_mat_all_2plot(irow,:)<pval_min)=nan(size(find(pval_spearman_mat_all_2plot(irow,:)<pval_min)));
end
imAlpha=ones(size(pval_spearman_thr_mat_all_2plot));
imAlpha(isnan(pval_spearman_thr_mat_all_2plot))=0;


figure;
set(gcf,'Color',[1 1 1]);
text(0,0,['{\color[rgb]{' num2str(color_mat(2,:)) '}bivariate} and {\color[rgb]{' num2str(color_mat(3,:)) '}multivariate} measures']);
axis off;
if PLOT.print
    figure_name='sync_all_color_legend';
    export_fig(gcf,[figure_name par.png_tail '_' names_string '.png'],'-m2');
end


figure;
set(gcf,'Color',[1 1 1]);
set(gcf,'Position',[115         428        1716         411]);
imagesc(absrho_spearman_thr_mat_all_2plot,'AlphaData',imAlpha);
set(gca,'color',0.8*[1 1 1]);
set(gca,'xaxisLocation','top')
set(gca,'XTick',1:1:length(field_names));
set(gca,'XTickLabels',strrep(field_names_long_wc_ms(absrho_spearman_sorted_ind),'_','\_'),'fontsize',FontSizeThis); % this sets the scale for all axis text properties... ok for now
xtickangle(gca,45);
set(gca,'YTick',1:1:length(ranged_stringa_tex));
set(gca,'YTickLabels',ranged_stringa_tex(par_sorted_ind));
eval(['xlabel(''{\color[rgb]{' num2str(color_mat(1,:)) '}univariate} {\color[rgb]{' num2str(color_mat(2,:)) '}bivariate} and {\color[rgb]{' num2str(color_mat(3,:)) '}multivariate} measures'');']);
ylabel({'generative','parameters'});
% set(gca,'CLim',[0 1]);
% set(gca,'Position',[0.0851    0.1822    0.8860    0.7428]);
if isfield(par,['clim_corr' par.png_tail])
    set(gca,'CLim',par.(['clim_corr' par.png_tail]));
end
% cbh=colorbar; % we only do this if pos_corr is set
if isfield(par,['pos_corr' par.png_tail])
    set(gca,'Position',par.(['pos_corr' par.png_tail]));
end
if isfield(par,['pos_corr' par.png_tail])
    cbh=colorbar;
    pos_vect=get(cbh,'Position');
    set(cbh,'Position',[par.(['pos_corr' par.png_tail])(1)+par.(['pos_corr' par.png_tail])(3)+0.02 pos_vect(2) pos_vect(3) pos_vect(4)]);
    pos_vect=get(cbh,'Position');
    th2=annotation('textbox',[pos_vect(1)+pos_vect(3)+0.015 pos_vect(2)+0.46*pos_vect(4) 0.012 0.046],'String','|\rho|','FontSize',24,'LineStyle','none','VerticalAlignment','middle');
end
if PLOT.print
    figure_name='sync_all_absspearmancorr_thr_scaled_mat_par_color_longn';
    export_fig(gcf,[figure_name par.png_tail '_' names_string '.png'],'-nocrop');
end
output_struct.CLim=get(gca,'CLim');
output_struct.pos=get(gca,'Position');



figure;
set(gcf,'Color',[1 1 1]);
set(gcf,'Position',[115         428        1716         411]);
imagesc(absrho_spearman_thr_mat_all_2plot,'AlphaData',imAlpha);
set(gca,'color',0.8*[1 1 1]);
set(gca,'xaxisLocation','top')
set(gca,'XTick',1:1:length(field_names));
set(gca,'XTickLabels',strrep(field_names_long_wc_ms(absrho_spearman_sorted_ind),'_','\_'),'fontsize',FontSizeThis); % this sets the scale for all axis text properties... ok for now
xtickangle(gca,45);
set(gca,'YTick',1:1:length(ranged_stringa_tex));
set(gca,'YTickLabels',ranged_stringa_tex(par_sorted_ind));
if isfield(par,['clim_corr' par.png_tail])
    set(gca,'CLim',par.(['clim_corr' par.png_tail]));
end
if isfield(par,['pos_corr' par.png_tail])
    set(gca,'Position',par.(['pos_corr' par.png_tail]));
end
if PLOT.print
    figure_name='sync_all_absspearmancorr_thr_scaled_mat_par_color_longn_nocb';
    export_fig(gcf,[figure_name par.png_tail '_' names_string '.png'],'-nocrop');
end


clear output_this sync_all*;
whos
save(['corr_output' par.png_tail '_' names_string]);
cd ..
return;
