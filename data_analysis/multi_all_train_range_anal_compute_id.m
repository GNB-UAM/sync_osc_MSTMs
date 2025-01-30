function output_struct=multi_all_train_range_anal_compute_id(stringa_dir_batch,par,stringa_name)

if nargin < 3
    stringa_name='';
    stringa_title='all synth';
end

if strcmp(stringa_name,'_ss')
    stringa_title='single scale';
elseif strcmp(stringa_name,'_ds')
    stringa_title='dual scale';
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
figDir='.';
dataDir='.';

stringa=['feat_analyze_' stringa_dir_batch];

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
title([stringa_title, ' : ', num2str(size(sync_all_rm_win_zs, 1)), ' samples, ', num2str(size(sync_all_rm_win_zs, 2)), ' features'], 'FontSize', 15,'FontWeight','normal');
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
title([stringa_title, ' : ', num2str(size(sync_all_rm_win_zs, 1)), ' samples, ', num2str(size(sync_all_rm_win_zs, 2)), ' features'], 'FontSize', 15,'FontWeight','normal');
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
title([stringa_title, ' : ', num2str(size(sync_all_rm_meas_zs, 1)), ' samples, ', num2str(size(sync_all_rm_meas_zs, 2)), ' features'], 'FontSize', 15,'FontWeight','normal');
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
title([stringa_title, ' : ', num2str(size(sync_all_rm_meas_zs, 1)), ' samples, ', num2str(size(sync_all_rm_meas_zs, 2)), ' features'], 'FontSize', 15,'FontWeight','normal');
if PLOT.print
    figure_name=[figDir '/' 'id_vs_n_rm_meas' par.png_tail '_' names_string '.png'];
    hgexport(gcf,figure_name,mystyle,'Format','png');
end



% save(fullfile(dataDir,'sync_all_zs.mat'),"sync_all_zs");
save(fullfile(dataDir,['id_output' par.png_tail '_' names_string '.mat']), ...
    'ids_gride_rm_win','ids_err_gride_rm_win','rs_gride_rm_win', ...
    'ids_twoNN_rm_win','ids_err_twoNN_rm_win','rs_twoNN_rm_win', ...
    'xrange_rm_win','x_rm_win',...
    'ids_gride_rm_meas','ids_err_gride_rm_meas','rs_gride_rm_meas', ...
    'ids_twoNN_rm_meas','ids_err_twoNN_rm_meas','rs_twoNN_rm_meas', ...
    'xrange_rm_meas','x_rm_meas',...
    'N_min');

output_struct=[];
cd ..
return;
