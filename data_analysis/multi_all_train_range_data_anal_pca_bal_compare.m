function output_struct=multi_all_train_range_data_anal_pca_bal_compare(stringa_dir_batch,par)

PLOT.print=1;

nf=length(par.f);

nd=length(par.d);

nt=nf+3+nd;

for indf=1:nf
    eval(['output_this{indf}=load(''' stringa_dir_batch '_' par.f{indf}.suf1 '_' par.f{indf}.suf2 '_all/pca_output' par.png_tail '_' par.names_string '.mat'');']);
    fam_names{indf}=[ par.f{indf}.suf1 ' & ' par.f{indf}.suf2];
    fam_names_short{indf}=[ par.f{indf}.suf1 ' & ' par.f{indf}.suf2];
end

output_this{indf+1}=load(fullfile([stringa_dir_batch '_ss_All'],['pca_output' par.png_tail '_' par.names_string '.mat'])); % note it only makes sense to consider bal pcaing when more than one synth family is lumped together
% fam_names{indf+1}='all single-scale';
fam_names{indf+1}=output_this{indf+1}.stringa_title;
fam_names_short{indf+1}='single-scale';

output_this{indf+2}=load(fullfile([stringa_dir_batch '_ds_All'],['pca_output' par.png_tail '_' par.names_string '.mat']));
% fam_names{indf+2}='all dual-scale';
fam_names{indf+2}=output_this{indf+2}.stringa_title;
fam_names_short{indf+2}='dual-scale';

output_this{indf+3}=load(fullfile([stringa_dir_batch '_All'],['pca_output' par.png_tail '_' par.names_string '.mat']));
% fam_names{indf+3}='all synth';
fam_names{indf+3}=output_this{indf+3}.stringa_title;
fam_names_short{indf+3}='all synth';

for indd=1:nd
    output_this{nf+3+indd}=load(fullfile(par.d{indd}.dataDir,['pca_output' par.png_tail '_' par.names_string '.mat']));
    fam_names{nf+3+indd}=[ par.d{indd}.stringa];
    fam_names_short{nf+3+indd}=[ par.d{indd}.stringa];
end

nc_pca=zeros(nt,length(output_this{1}.cumsumvar_vect));
for ind=1:nt
    nc_pca(ind,:)=output_this{ind}.x_cumsumvar_vect;
end


eval(['mkdir ' stringa_dir_batch  '_data_All']);
eval(['cd ' stringa_dir_batch  '_data_All']);


mystyle = hgexport('factorystyle');
mystyle.Units='normalized';
mystyle.FontMode='none';

mystyle_highres=mystyle;
mystyle_highres.Resolution=300;

% cmap_parula=colormap; % Colormap 'default' option for heatmap displays the blue colormap instead of parula - Behavior changed in R2020b
cmap_parula=colormap(parula(64));
% ncolors=48;
ncolors=64;

figure
set(gcf,'Color',[1 1 1]);
set(gcf,'Position',[381          85        1300         865]);
for i=1:length(output_this{1}.cumsumvar_vect)
    subtightplot(length(output_this{1}.cumsumvar_vect),1,i,0.08,[0.18 0.05],[0.04 0.02]);
    ca=gca;
    bar(nc_pca(:,i));
    if i==3
        % set(gca,'XTickLabels',fam_names,'fontsize',16); % this sets the scale for all axis text properties... ok for now
        set(gca,'XTickLabels',fam_names);
        ca.XAxis.FontSize=16; % ok, this works for setting FontSize independently for x and y axes
        ca.YAxis.FontSize=18.5;
    else
        set(gca,'XTickLabel',{'','','','','','','','',''});
        ca.XAxis.FontSize=16;
        ca.YAxis.FontSize=18.5;
    end
    title(['n components for explaining ' num2str(output_this{1}.cumsumvar_vect(i)) '% of var'],'FontWeight','normal','Interpreter','none');
end
if PLOT.print
    figure_name='nc_pca';
    % export_fig(gcf,[figure_name par.png_tail '_' par.names_string '.png']);
    hgexport(gcf,[figure_name par.png_tail '_' par.names_string '.png'],mystyle,'Format','png');
end

figure
set(gcf,'Color',[1 1 1]);
% set(gcf,'Position',[386         236        1290         726]);
% set(gcf,'Position',[381          85        1300         865]);
set(gcf,'Position',[381          85        570   713]); % standard w h: 570   413
for i=2:length(output_this{1}.cumsumvar_vect) % we only show 95 and 99%
    subtightplot(length(output_this{1}.cumsumvar_vect)-1,1,i-1,0.08,[0.17 0.05],[0.09 0.03]);
    ca=gca;
    bar(nc_pca(5:end,i)); % we don't show "osc & sinple", etc. only aggregates
    if i==3
        % set(gca,'XTickLabels',fam_names,'fontsize',16); % this sets the scale for all axis text properties... ok for now
        set(gca,'XTickLabels',fam_names_short(5:end));
        %         ca.XAxis.FontSize=16; % ok, this works for setting FontSize independently for x and y axes
        %         ca.YAxis.FontSize=18.5;
    else
        set(gca,'XTickLabel',{'','','','','','','','',''});
        ca.XAxis.FontSize=16;
        ca.YAxis.FontSize=18.5;
    end
    ylabel('N','Rotation',0);
    % title(['n components for explaining ' num2str(output_this{1}.cumsumvar_vect(i)) '% of var'],'FontWeight','normal','Interpreter','none','fontsize',16);
    th=title(['# components explaining ' num2str(output_this{1}.cumsumvar_vect(i)) '% of variance'],'FontWeight','normal','Interpreter','none');
    set(th,'Position',th.Position+[-0.2 0 0]); % shift a bit to the left
    set(gca,'FontSize',18); % better to have this uniform for all text items in the figure
end
if PLOT.print
    figure_name='nc_pca_v2';
    hgexport(gcf,[figure_name par.png_tail '_' par.names_string '.png'],mystyle,'Format','png');
end


figure
set(gcf,'Color',[1 1 1]);
set(gcf,'Position',[381          85        570   799]); % standard w h: 570   413
for i=2:length(output_this{1}.cumsumvar_vect) % we only show 95 and 99%
    subtightplot(length(output_this{1}.cumsumvar_vect)-1,1,i-1,0.18,[0.13 0.04],[0.1 0.03]);
    ca=gca;
    bar(nc_pca(5:end,i)); % we don't show "osc & sinple", etc. only aggregates
    set(gca,'XLim',[0.2 6.8]); % 0.4 on each side, double space than between bars, looks pretty good
    if i==3
        set(gca,'XTickLabels',fam_names_short(5:end));
    else
        set(gca,'XTickLabel',{'','','','','','','','',''});
        ca.XAxis.FontSize=16;
        ca.YAxis.FontSize=18.5;
    end
    if strcmp(par.png_tail,'_bs')
    ylh=ylabel('N','Rotation',0);
    if i==2
ylh.Position(1)=-0.3233;
ylh.Position(2)=11;
    end
    end
    set(gca,'FontSize',18); % better to have this uniform for all text items in the figure
end
if PLOT.print
    figure_name='nc_pca_v3';
    hgexport(gcf,[figure_name par.png_tail '_' par.names_string '.png'],mystyle_highres,'Format','png');
end

nc_pca(5:end,2:end)' % corresponding to what's plotted in nc_pca_v2

output_struct=[];
cd ..
return;