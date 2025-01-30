function output_struct=multi_all_train_range_anal_bs_pca_bal(stringa_dir_batch,par,stringa_name,stringa_title)

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

get_field_names_bs;

fprintf('Total nuber of ms measures:%i\n',length(field_names_wc_ms));
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

nanzscore = @(X,FLAG,DIM) bsxfun(@rdivide, bsxfun(@minus, X, nanmean(X,DIM)), nanstd(X,FLAG,DIM));
sync_all_zs=nanzscore(sync_all,0,2); % z-scoring across columns, for visualization only since corr distance already normalizes

[~, ~, ~, ~, explained] = pca(sync_all_zs','Rows','complete'); % better use this approach for consistency, since the other fails in some cases
cumsumvar=cumsum(explained);

cumsumvar_vect=[90 95 99];
color_mat=[1 0.5 0;1 0 0;1 0 1]; % orange, red, magenta
for i=1:length(cumsumvar_vect)
    x_cumsumvar_vect(i)=find(cumsumvar>cumsumvar_vect(i),1);
    y_cumsumvar_vect(i)=cumsumvar(x_cumsumvar_vect(i));
end

figure
set(gcf,'Color',[1 1 1]);
plot(1:numel(explained), cumsumvar, 'o-', 'MarkerFaceColor', 'r');
xlim_vect=get(gca,'XLim');
ylim_vect=get(gca,'YLim');
hold on
for i=1:length(cumsumvar_vect)
    plot([0 x_cumsumvar_vect(i)],y_cumsumvar_vect(i)*ones(1,2),'Color',color_mat(i,:));
    plot(x_cumsumvar_vect(i)*ones(1,2),[ylim_vect(1) y_cumsumvar_vect(i)],'Color',color_mat(i,:));
end
h = gca;
h.YAxis.TickLabel = strcat(h.YAxis.TickLabel, '%');
h.YAxis.Label.String='cum var explained';
title(stringa_title,'FontWeight','normal','Interpreter','none');
if PLOT.print
    figure_name='sync_all_pca_cumvar';
    export_fig(gcf,[figure_name '_bs_' names_string '.png']);
end

clear output_this sync_all*;
whos
save(['pca_bs_output' '_' names_string]);
% keyboard;
output_struct=[];
cd ..
return;
