function output_struct=multi_all_train_range_data_anal_plot_id(stringa_dir_batch,par)

PLOT.print=1;

% nf=length(par.f);
nf=0; % we don't consider individual stf here

nd=length(par.d);

nt=nf+3+nd;

for indf=1:nf
    eval(['output_this{indf}=load(''' stringa_dir_batch '_' par.f{indf}.suf1 '_' par.f{indf}.suf2 '_all/id_output' par.png_tail '_' par.names_string '.mat'');']);
    fam_names{indf}=[ par.f{indf}.suf1 ' & ' par.f{indf}.suf2];
end
indf=0; % we don't consider individual stf here

output_this{indf+1}=load(fullfile([stringa_dir_batch '_ss_All'],['id_output' par.png_tail '_' par.names_string '.mat'])); % note it only makes sense to consider bal pcaing when more than one synth family is lumped together
fam_names{indf+1}='single-scale';
% fam_names{indf+1}='all single-scale';
% fam_names{indf+1}=output_this{indf+1}.stringa_title;

output_this{indf+2}=load(fullfile([stringa_dir_batch '_ds_All'],['id_output' par.png_tail '_' par.names_string '.mat']));
fam_names{indf+2}='dual-scale';
% fam_names{indf+2}='all dual-scale';
% fam_names{indf+2}=output_this{indf+2}.stringa_title;

output_this{indf+3}=load(fullfile([stringa_dir_batch '_All'],['id_output' par.png_tail '_' par.names_string '.mat']));
fam_names{indf+3}='all synth';
% fam_names{indf+3}='all synth';
% fam_names{indf+3}=output_this{indf+3}.stringa_title;

for indd=1:nd
    output_this{nf+3+indd}=load(fullfile(par.d{indd}.dataDir,['id_output' par.png_tail '_' par.names_string '.mat']));
    fam_names{nf+3+indd}=[ par.d{indd}.stringa];
end


eval(['mkdir ' stringa_dir_batch  '_data_All']);
eval(['cd ' stringa_dir_batch  '_data_All']);
figDir='.';

mystyle = hgexport('factorystyle');
mystyle.Units='normalized';
mystyle.FontMode='none';

mystyle_highres=mystyle;
mystyle_highres.Resolution=300;

% cmap_parula=colormap; % Colormap 'default' option for heatmap displays the blue colormap instead of parula - Behavior changed in R2020b
cmap_parula=colormap(parula(64));
% ncolors=48;
ncolors=64;


% synth

figure
set(gcf,'Color',[1 1 1]);
for i=1:3
    lh(i)=plot(output_this{nf+i}.rs_gride_rm_win, output_this{nf+i}.ids_gride_rm_win, 'o-', 'DisplayName', fam_names{nf+i});
    hold on;
    jbfill(output_this{nf+i}.rs_gride_rm_win, output_this{nf+i}.ids_gride_rm_win-output_this{nf+i}.ids_err_gride_rm_win,output_this{nf+i}.ids_gride_rm_win+output_this{nf+i}.ids_err_gride_rm_win,lh(i).Color,lh(i).Color);
    hold on;
end
set(gca, 'XScale', 'log');
ylabel('intrinsic dimension');
xlabel('distance range');
legend(lh);
if PLOT.print
    figure_name=[figDir '/' 'id_vs_dist_rm_win_synth' par.png_tail '_' par.names_string '.png'];
    % export_fig(gcf,[figure_name '_' par.names_string '.png']);
    hgexport(gcf,figure_name,mystyle,'Format','png');
end


figure
set(gcf,'Color',[1 1 1]);
for i=1:3
    lh(i)=plot(output_this{nf+i}.x_rm_win, output_this{nf+i}.ids_gride_rm_win(1:output_this{nf+i}.xrange_rm_win), 'o-', 'DisplayName', fam_names{nf+i});
    hold on;
    jbfill(output_this{nf+i}.x_rm_win, output_this{nf+i}.ids_gride_rm_win(1:output_this{nf+i}.xrange_rm_win)-output_this{nf+i}.ids_err_gride_rm_win(1:output_this{nf+i}.xrange_rm_win),output_this{nf+i}.ids_gride_rm_win(1:output_this{nf+i}.xrange_rm_win)+output_this{nf+i}.ids_err_gride_rm_win(1:output_this{nf+i}.xrange_rm_win),lh(i).Color,lh(i).Color);
    hold on;
end
set(gca, 'XScale', 'log');
ylabel('intrinsic dimension');
xlabel('n° data');
legend(lh);
if PLOT.print
    figure_name=[figDir '/' 'id_vs_n_rm_win_synth' par.png_tail '_' par.names_string '.png'];
    % export_fig(gcf,[figure_name '_' par.names_string '.png']);
    hgexport(gcf,figure_name,mystyle,'Format','png');
end







figure
set(gcf,'Color',[1 1 1]);
for i=1:3
    lh(i)=plot(output_this{nf+i}.rs_gride_rm_meas, output_this{nf+i}.ids_gride_rm_meas, 'o-', 'DisplayName', fam_names{nf+i});
    hold on;
    jbfill(output_this{nf+i}.rs_gride_rm_meas, output_this{nf+i}.ids_gride_rm_meas-output_this{nf+i}.ids_err_gride_rm_meas,output_this{nf+i}.ids_gride_rm_meas+output_this{nf+i}.ids_err_gride_rm_meas,lh(i).Color,lh(i).Color);
    hold on;
end
set(gca, 'XScale', 'log');
% xlabel('distance range');
if strcmp(par.png_tail,'')
legend(lh);
else
ylabel('intrinsic dimension');
end
set(gca,'Position',[0.1300    0.1859    0.7750    0.7391]);
if PLOT.print
    figure_name=[figDir '/' 'id_vs_dist_rm_meas_synth' par.png_tail '_' par.names_string '.png'];
    % export_fig(gcf,[figure_name '_' par.names_string '.png']);
    hgexport(gcf,figure_name,mystyle_highres,'Format','png');
end


figure
set(gcf,'Color',[1 1 1]);
for i=1:3
    lh(i)=plot(output_this{nf+i}.x_rm_meas, output_this{nf+i}.ids_gride_rm_meas(1:output_this{nf+i}.xrange_rm_meas), 'o-', 'DisplayName', fam_names{nf+i});
    hold on;
    jbfill(output_this{nf+i}.x_rm_meas, output_this{nf+i}.ids_gride_rm_meas(1:output_this{nf+i}.xrange_rm_meas)-output_this{nf+i}.ids_err_gride_rm_meas(1:output_this{nf+i}.xrange_rm_meas),output_this{nf+i}.ids_gride_rm_meas(1:output_this{nf+i}.xrange_rm_meas)+output_this{nf+i}.ids_err_gride_rm_meas(1:output_this{nf+i}.xrange_rm_meas),lh(i).Color,lh(i).Color);
    hold on;
end
set(gca, 'XScale', 'log');
ylabel('intrinsic dimension');
xlabel('n° data');
legend(lh);
if PLOT.print
    figure_name=[figDir '/' 'id_vs_n_rm_meas_synth' par.png_tail '_' par.names_string '.png'];
    % export_fig(gcf,[figure_name '_' par.names_string '.png']);
    hgexport(gcf,figure_name,mystyle,'Format','png');
end





% data

figure
set(gcf,'Color',[1 1 1]);
for i=1:nd
    lh(i)=plot(output_this{nf+3+i}.rs_gride_rm_win, output_this{nf+3+i}.ids_gride_rm_win, 'o-', 'DisplayName', fam_names{nf+3+i});
    hold on;
    jbfill(output_this{nf+3+i}.rs_gride_rm_win, output_this{nf+3+i}.ids_gride_rm_win-output_this{nf+3+i}.ids_err_gride_rm_win,output_this{nf+3+i}.ids_gride_rm_win+output_this{nf+3+i}.ids_err_gride_rm_win,lh(i).Color,lh(i).Color);
    hold on;
end
set(gca, 'XScale', 'log');
ylabel('intrinsic dimension');
xlabel('distance range');
legend(lh);
if PLOT.print
    figure_name=[figDir '/' 'id_vs_dist_rm_win_data' par.png_tail '_' par.names_string '.png'];
    % export_fig(gcf,[figure_name '_' par.names_string '.png']);
    hgexport(gcf,figure_name,mystyle,'Format','png');
end


figure
set(gcf,'Color',[1 1 1]);
for i=1:nd
    lh(i)=plot(output_this{nf+3+i}.x_rm_win, output_this{nf+3+i}.ids_gride_rm_win(1:output_this{nf+3+i}.xrange_rm_win), 'o-', 'DisplayName', fam_names{nf+3+i});
    hold on;
    jbfill(output_this{nf+3+i}.x_rm_win, output_this{nf+3+i}.ids_gride_rm_win(1:output_this{nf+3+i}.xrange_rm_win)-output_this{nf+3+i}.ids_err_gride_rm_win(1:output_this{nf+3+i}.xrange_rm_win),output_this{nf+3+i}.ids_gride_rm_win(1:output_this{nf+3+i}.xrange_rm_win)+output_this{nf+3+i}.ids_err_gride_rm_win(1:output_this{nf+3+i}.xrange_rm_win),lh(i).Color,lh(i).Color);
    hold on;
end
set(gca, 'XScale', 'log');
ylabel('intrinsic dimension');
xlabel('n° data');
legend(lh);
if PLOT.print
    figure_name=[figDir '/' 'id_vs_n_rm_win_data' par.png_tail '_' par.names_string '.png'];
    % export_fig(gcf,[figure_name '_' par.names_string '.png']);
    hgexport(gcf,figure_name,mystyle,'Format','png');
end







figure
set(gcf,'Color',[1 1 1]);
for i=1:nd
    lh(i)=plot(output_this{nf+3+i}.rs_gride_rm_meas, output_this{nf+3+i}.ids_gride_rm_meas, 'o-', 'DisplayName', fam_names{nf+3+i});
    hold on;
    jbfill(output_this{nf+3+i}.rs_gride_rm_meas, output_this{nf+3+i}.ids_gride_rm_meas-output_this{nf+3+i}.ids_err_gride_rm_meas,output_this{nf+3+i}.ids_gride_rm_meas+output_this{nf+3+i}.ids_err_gride_rm_meas,lh(i).Color,lh(i).Color);
    hold on;
end
set(gca, 'XScale', 'log');
xlabel('distance range');
if strcmp(par.png_tail,'')
legend(lh);
else
ylabel('intrinsic dimension');
end
set(gca,'Position',[0.1300    0.1859    0.7750    0.7391]);
if PLOT.print
    figure_name=[figDir '/' 'id_vs_dist_rm_meas_data' par.png_tail '_' par.names_string '.png'];
    % export_fig(gcf,[figure_name '_' par.names_string '.png']);
    hgexport(gcf,figure_name,mystyle_highres,'Format','png');
end


figure
set(gcf,'Color',[1 1 1]);
for i=1:nd
    lh(i)=plot(output_this{nf+3+i}.x_rm_meas, output_this{nf+3+i}.ids_gride_rm_meas(1:output_this{nf+3+i}.xrange_rm_meas), 'o-', 'DisplayName', fam_names{nf+3+i});
    hold on;
    jbfill(output_this{nf+3+i}.x_rm_meas, output_this{nf+3+i}.ids_gride_rm_meas(1:output_this{nf+3+i}.xrange_rm_meas)-output_this{nf+3+i}.ids_err_gride_rm_meas(1:output_this{nf+3+i}.xrange_rm_meas),output_this{nf+3+i}.ids_gride_rm_meas(1:output_this{nf+3+i}.xrange_rm_meas)+output_this{nf+3+i}.ids_err_gride_rm_meas(1:output_this{nf+3+i}.xrange_rm_meas),lh(i).Color,lh(i).Color);
    hold on;
end
set(gca, 'XScale', 'log');
ylabel('intrinsic dimension');
xlabel('n° data');
legend(lh);
if PLOT.print
    figure_name=[figDir '/' 'id_vs_n_rm_meas_data' par.png_tail '_' par.names_string '.png'];
    % export_fig(gcf,[figure_name '_' par.names_string '.png']);
    hgexport(gcf,figure_name,mystyle,'Format','png');
end






output_struct=[];
cd ..
return;