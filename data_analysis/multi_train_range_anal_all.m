function output_struct=multi_train_range_anal_all(stringa_dir_batch,par,ranged_par,ranged_stringa,ranged_stringa_tex)
% organises simulations (ranging gmax_inh and I_bias) and m files to be submitted to a PBS queue

eval(['n_k_ratio=length(' char(ranged_par(1)) ');']);
eval(['n_g_exc=length(' char(ranged_par(2)) ');']);
eval(['n_g_inh=length(' char(ranged_par(3)) ');']);

eval(['ranged_par1_vect=' char(ranged_par(1)) ';']);
eval(['ranged_par2_vect=' char(ranged_par(2)) ';']);
eval(['ranged_par3_vect=' char(ranged_par(3)) ';']);

if isfield(par,'syn')
    if isfield(par.syn,'ranged3_vect_plot')
        ranged3_vect_plot=par.syn.ranged3_vect_plot;
        n_g_inh=length(ranged3_vect_plot);
    else
        ranged3_vect_plot=1:1:n_g_inh;
    end
else
    ranged3_vect_plot=1:1:n_g_inh;
end

eval(['ranged_par3_vect=' char(ranged_par(3)) '(ranged3_vect_plot);']);

% eval(['output_this=load(''' stringa_dir_batch '_' num2str(1) '_' num2str(1) '_' num2str(1) '_osc/output_all.mat'');']);

get_field_names_bs; % enough with bs measures for now

pos_this=[0.1907    0.1859    0.7143    0.7391]; % better option for fitting both

for i=1:n_k_ratio
    for j=1:n_g_exc
        for k=1:n_g_inh
            for ind_out=1:length(output_mat_files)
                eval(['output_this{' num2str(ind_out) '}=load(''' stringa_dir_batch '_' num2str(i) '_' num2str(j) '_' num2str(ranged3_vect_plot(k)) '_' par.suf1 '/' output_mat_files{ind_out} '.mat'');']);
            end
            for kk=1:length(field_names)
                try
                    eval([field_names{kk} '_osc_all(i,j,k)=output_this{file_ind(kk)}.' field_names{kk} ';']);
                catch
                    eval([field_names{kk} '_osc_all(i,j,k)=NaN;']);
                    keyboard;
                end
            end

        end
    end
end


for i=1:n_k_ratio
    for j=1:n_g_exc
        for k=1:n_g_inh
            for ind_out=1:length(output_mat_files)
                eval(['output_this{' num2str(ind_out) '}=load(''' stringa_dir_batch '_' num2str(i) '_' num2str(j) '_' num2str(ranged3_vect_plot(k)) '_' par.suf2 '/' output_mat_files{ind_out} '.mat'');']);
            end
            for kk=1:length(field_names)
                try
                    eval([field_names{kk} '_ple_all(i,j,k)=output_this{file_ind(kk)}.' field_names{kk} ';']);
                catch
                    eval([field_names{kk} '_ple_all(i,j,k)=NaN;']);
                    keyboard;
                end
            end

        end
    end
end

try
    sim_time=par.sim.sim_time;
catch
    sim_time=par.sim_time;
end

if isfield(par,'ylabel_ind')
    ylabel_ind=par.ylabel_ind;
else
    ylabel_ind=1;
end

eval(['mkdir ' stringa_dir_batch '_' par.suf1 '_' par.suf2 '_all']);
eval(['cd ' stringa_dir_batch '_' par.suf1 '_' par.suf2 '_all']);

stringa=['feat_analyze_' stringa_dir_batch];

mystyle = hgexport('factorystyle');
mystyle.Units='normalized';
mystyle.FontMode='none';

% cmap_parula=colormap; % Colormap 'default' option for heatmap displays the blue colormap instead of parula - Behavior changed in R2020b
cmap_parula=colormap(parula(64));
% ncolors=48;
ncolors=64;

% we first do burstiness with legend and title, then all the others without legend and title
% with legend only actually, and just for script_sin_train_prova_range.m , no title needed
% legend only for i==1
if 1 % already done for the ss family... actually needs to be done for both ss and ds
    for kk=10
        for i=1:n_k_ratio
            clear conditions;
            fh=figure();
            set(gcf,'Color',[1 1 1]);
            for j=1:n_g_exc
                try
                    actual_color_ind=floor((ncolors/(1+n_g_exc))*j);
                catch
                    actual_color_ind=1;
                end
                eval(['clh(j)=plot(ranged_par3_vect,squeeze(' field_names{kk} '_osc_all(i,j,:)),''o'',''Color'',cmap_parula(actual_color_ind,:),''LineStyle'',''-'');'])
                hold on;
            end
            for j=1:n_g_exc
                try
                    actual_color_ind=floor((ncolors/(1+n_g_exc))*j);
                catch
                    actual_color_ind=1;
                end
                eval(['dlh(j)=plot(ranged_par3_vect,squeeze(' field_names{kk} '_ple_all(i,j,:)),''s'',''Color'',cmap_parula(actual_color_ind,:),''LineStyle'',''--'');'])
                hold on;
            end
            xlim(sort([ranged_par3_vect(1) ranged_par3_vect(end)]));
            stringa_legend='';
            for j=1:n_g_exc
                if strcmp(char(ranged_stringa_tex(2)),'\Sigma') || strcmp(char(ranged_stringa_tex(2)),'m')
                    eval(['stringa_legend=[stringa_legend ''''''' char(ranged_stringa_tex(2)) '=' num2str(ranged_par2_vect(j),'%.2f') ''''''' '',''];']); % this works
                elseif strcmp(char(ranged_stringa_tex(2)),'p_{fail}')
                    eval(['stringa_legend=[stringa_legend ''''''' char(ranged_stringa_tex(2)) '=' num2str(ranged_par2_vect(j),'%.1f') ''''''' '',''];']); % this works
                elseif strcmp(char(ranged_stringa_tex(2)),'f_0') || strcmp(char(ranged_stringa_tex(2)),'r_0')
                    eval(['stringa_legend=[stringa_legend ''''''' char(ranged_stringa_tex(2)) '=' num2str(ranged_par2_vect(j),'%.0f') 'Hz' ''''''' '',''];']); % this works
                end
            end
            xlabel(char(ranged_stringa_tex(3)));
            set(gca,'Position',pos_this);
            if ismember(i,ylabel_ind)
                ylabel(field_names_long_wc_ms{kk});
                set(gca,'Position',pos_this);
                if strcmp(par.suf1,'osc') % we only put legend for osc trains
                    %                     eval(['legh=legend(' stringa_legend(1:end-1) ',''Location'',''best'');']);
                    %                     ah1 = axes('position',get(gca,'position'),'visible','off');
                    %                     legh2=legend(ah1,[clh(1) dlh(1)],{'pseudo-rhythmic','non-rhythmic'},'Location','best');

                    legh=legend([clh(1) dlh(1)],{'pseudo-rhythmic','non-rhythmic'},'Position',[0.2027 0.7298 0.4474 0.1780]);
                    ah1 = axes('position',get(gca,'position'),'visible','off');
                    % we need to plot the lines again, and then set the new axis as not visible, otherwise is not possible to have 2 independent legends
                    for j=1:n_g_exc
                        try
                            actual_color_ind=floor((ncolors/(1+n_g_exc))*j);
                        catch
                            actual_color_ind=1;
                        end
                        eval(['clh(j)=plot(ranged_par3_vect,squeeze(' field_names{kk} '_osc_all(i,j,:)),''o'',''Color'',cmap_parula(actual_color_ind,:),''LineStyle'',''-'');'])
                        hold on;
                    end
                    eval(['legh2=legend(ah1,clh,' stringa_legend(1:end-1) ',''Position'',[0.2027 0.4194 0.2719 0.3027],''AutoUpdate'',''off'');']);
                    ah1.Visible='off';
                end
            end
            figure_name=[stringa '_' strrep(field_names{kk},'.','_') '_vs_' char(ranged_stringa(3)) '_m' char(ranged_stringa(2)) '_at_' char(ranged_stringa(1)) '' num2str(i) '_longn.png']; % long measure name
            hgexport(fh,figure_name,mystyle,'Format','png');

            clear conditions;
            fh=figure();
            set(gcf,'Color',[1 1 1]);
            for j=1:n_g_inh
                try
                    actual_color_ind=floor((ncolors/(1+n_g_inh))*j);
                catch
                    actual_color_ind=1;
                end
                eval(['plot(ranged_par2_vect,squeeze(' field_names{kk} '_osc_all(i,:,j)),''o'',''Color'',cmap_parula(actual_color_ind,:),''LineStyle'',''-'');'])
                hold on;
            end
            for j=1:n_g_inh
                try
                    actual_color_ind=floor((ncolors/(1+n_g_inh))*j);
                catch
                    actual_color_ind=1;
                end
                eval(['plot(ranged_par2_vect,squeeze(' field_names{kk} '_ple_all(i,:,j)),''s'',''Color'',cmap_parula(actual_color_ind,:),''LineStyle'',''--'');'])
                hold on;
            end
            xlim(sort([ranged_par2_vect(1) ranged_par2_vect(end)]));
            stringa_legend='';
            for j=1:n_g_inh
                if strcmp(char(ranged_stringa_tex(3)),'\Sigma') || strcmp(char(ranged_stringa_tex(3)),'m')
                    eval(['stringa_legend=[stringa_legend ''''''' char(ranged_stringa_tex(3)) '=' num2str(ranged_par3_vect(j),'%.2f') ''''''' '',''];']); % this works
                elseif strcmp(char(ranged_stringa_tex(3)),'p_{fail}')
                    eval(['stringa_legend=[stringa_legend ''''''' char(ranged_stringa_tex(3)) '=' num2str(ranged_par3_vect(j),'%.1f') ''''''' '',''];']); % this works
                elseif strcmp(char(ranged_stringa_tex(3)),'f_0') || strcmp(char(ranged_stringa_tex(3)),'r_0')
                    eval(['stringa_legend=[stringa_legend ''''''' char(ranged_stringa_tex(3)) '=' num2str(ranged_par3_vect(j),'%.0f') 'Hz' ''''''' '',''];']); % this works
                end
            end
            if ismember(i,ylabel_ind)
                if strcmp(par.suf1,'osc') % we only put legend for osc trains
                    eval(['legh=legend(' stringa_legend(1:end-1) ',''Location'',''best'');']);
                end
                ylabel(field_names_long_wc_ms{kk});
            end
            xlabel(char(ranged_stringa_tex(2)));
            if strcmp(par.suf1,'oscG') % we need to specify this explicitly for dual trains
                set(gca,'XTick',ranged_par2_vect([5 3 1]));
            end
            set(gca,'Position',pos_this);
            figure_name=[stringa '_' strrep(field_names{kk},'.','_') '_vs_' char(ranged_stringa(2)) '_m' char(ranged_stringa(3)) '_at_' char(ranged_stringa(1)) '' num2str(i) '_longn.png'];
            hgexport(fh,figure_name,mystyle,'Format','png');
        end


        for i=1:n_g_exc
            clear conditions;
            fh=figure();
            set(gcf,'Color',[1 1 1]);
            for j=1:n_k_ratio
                try
                    actual_color_ind=floor((ncolors/(1+n_k_ratio))*j);
                catch
                    actual_color_ind=1;
                end
                eval(['plot(ranged_par3_vect,squeeze(' field_names{kk} '_osc_all(j,i,:)),''o'',''Color'',cmap_parula(actual_color_ind,:),''LineStyle'',''-'');'])
                hold on;
            end
            for j=1:n_k_ratio
                try
                    actual_color_ind=floor((ncolors/(1+n_k_ratio))*j);
                catch
                    actual_color_ind=1;
                end
                eval(['plot(ranged_par3_vect,squeeze(' field_names{kk} '_ple_all(j,i,:)),''s'',''Color'',cmap_parula(actual_color_ind,:),''LineStyle'',''--'');'])
                hold on;
            end
            xlim(sort([ranged_par3_vect(1) ranged_par3_vect(end)]));
            stringa_legend='';
            for j=1:n_k_ratio
                % stringa_legend=[stringa_legend '''k_ratio=' num2str(ranged_par1_vect(j),'%.2f') ''',']; % only this works, options above do not work
                % eval(['stringa_legend=[stringa_legend ''''''' char(ranged_stringa(1)) '=' num2str(ranged_par1_vect(j),'%.2f') ''''''' '',''];']); % this works
                % eval(['stringa_legend=[stringa_legend ''''''' char(ranged_stringa(1)) '=' num2str(ranged_par1_vect(j),'%.0f') 'Hz' ''''''' '',''];']); % this works
                if strcmp(char(ranged_stringa_tex(1)),'\Sigma') || strcmp(char(ranged_stringa_tex(1)),'m')
                    eval(['stringa_legend=[stringa_legend ''''''' char(ranged_stringa_tex(1)) '=' num2str(ranged_par1_vect(j),'%.2f') ''''''' '',''];']); % this works
                elseif strcmp(char(ranged_stringa_tex(1)),'p_{fail}')
                    eval(['stringa_legend=[stringa_legend ''''''' char(ranged_stringa_tex(1)) '=' num2str(ranged_par1_vect(j),'%.1f') ''''''' '',''];']); % this works
                elseif strcmp(char(ranged_stringa_tex(1)),'f_0') || strcmp(char(ranged_stringa_tex(1)),'r_0')
                    eval(['stringa_legend=[stringa_legend ''''''' char(ranged_stringa_tex(1)) '=' num2str(ranged_par1_vect(j),'%.0f') 'Hz' ''''''' '',''];']); % this works
                end
            end
            if ismember(i,ylabel_ind)
                if strcmp(par.suf1,'osc') % we only put legend for osc trains
                    eval(['legh=legend(' stringa_legend(1:end-1) ',''Location'',''best'');']);
                end
                ylabel(field_names_long_wc_ms{kk});
            end
            % set(legh,'Interpreter','none');
            % xlabel(char(ranged_stringa(3)),'Interpreter','none');
            xlabel(char(ranged_stringa_tex(3)));
            % ylabel(field_names{kk},'Interpreter','none');
            % title([char(ranged_stringa(2)) '=' num2str(ranged_par2_vect(i),'%.2f')],'FontWeight','normal','Interpreter','none');
            % title([char(ranged_stringa(2)) '=' num2str(ranged_par2_vect(i),'%.0f') 'Hz'],'FontWeight','normal','Interpreter','none');
            set(gca,'Position',pos_this);
            figure_name=[stringa '_' strrep(field_names{kk},'.','_') '_vs_' char(ranged_stringa(3)) '_m' char(ranged_stringa(1)) '_at_' char(ranged_stringa(2)) '' num2str(i) '_longn.png'];
            hgexport(fh,figure_name,mystyle,'Format','png');

            clear conditions;
            fh=figure();
            set(gcf,'Color',[1 1 1]);
            for j=1:n_g_inh
                try
                    actual_color_ind=floor((ncolors/(1+n_g_inh))*j);
                catch
                    actual_color_ind=1;
                end
                eval(['plot(ranged_par1_vect,squeeze(' field_names{kk} '_osc_all(:,i,j)),''o'',''Color'',cmap_parula(actual_color_ind,:),''LineStyle'',''-'');'])
                hold on;
            end
            for j=1:n_g_inh
                try
                    actual_color_ind=floor((ncolors/(1+n_g_inh))*j);
                catch
                    actual_color_ind=1;
                end
                eval(['plot(ranged_par1_vect,squeeze(' field_names{kk} '_ple_all(:,i,j)),''s'',''Color'',cmap_parula(actual_color_ind,:),''LineStyle'',''--'');'])
                hold on;
            end
            xlim([ranged_par1_vect(1) ranged_par1_vect(end)]);
            stringa_legend='';
            for j=1:n_g_inh
                % stringa_legend=[stringa_legend '''g_inh=' num2str(ranged_par3_vect(j),'%.2f') ''','];
                % eval(['stringa_legend=[stringa_legend ''''''' char(ranged_stringa(3)) '=' num2str(ranged_par3_vect(j),'%.2f') ''''''' '',''];']); % this works
                % eval(['stringa_legend=[stringa_legend ''''''' char(ranged_stringa(3)) '=' num2str(ranged_par3_vect(j),'%.0f') 'Hz' ''''''' '',''];']); % this works
                if strcmp(char(ranged_stringa_tex(3)),'\Sigma') || strcmp(char(ranged_stringa_tex(3)),'m')
                    eval(['stringa_legend=[stringa_legend ''''''' char(ranged_stringa_tex(3)) '=' num2str(ranged_par3_vect(j),'%.2f') ''''''' '',''];']); % this works
                elseif strcmp(char(ranged_stringa_tex(3)),'p_{fail}')
                    eval(['stringa_legend=[stringa_legend ''''''' char(ranged_stringa_tex(3)) '=' num2str(ranged_par3_vect(j),'%.1f') ''''''' '',''];']); % this works
                elseif strcmp(char(ranged_stringa_tex(3)),'f_0') || strcmp(char(ranged_stringa_tex(3)),'r_0')
                    eval(['stringa_legend=[stringa_legend ''''''' char(ranged_stringa_tex(3)) '=' num2str(ranged_par3_vect(j),'%.0f') 'Hz' ''''''' '',''];']); % this works
                end
            end
            if ismember(i,ylabel_ind)
                if strcmp(par.suf1,'osc') % we only put legend for osc trains
                    eval(['legh=legend(' stringa_legend(1:end-1) ',''Location'',''best'');']);
                end
                ylabel(field_names_long_wc_ms{kk});
            end
            % set(legh,'Interpreter','none');
            % xlabel(char(ranged_stringa(1)),'Interpreter','none');
            xlabel(char(ranged_stringa_tex(1)));
            % ylabel(field_names{kk},'Interpreter','none');
            % title([char(ranged_stringa(2)) '=' num2str(ranged_par2_vect(i),'%.2f')],'FontWeight','normal','Interpreter','none');
            % title([char(ranged_stringa(2)) '=' num2str(ranged_par2_vect(i),'%.0f') 'Hz'],'FontWeight','normal','Interpreter','none');
            set(gca,'Position',pos_this);
            figure_name=[stringa '_' strrep(field_names{kk},'.','_') '_vs_' char(ranged_stringa(1)) '_m' char(ranged_stringa(3)) '_at_' char(ranged_stringa(2)) '' num2str(i) '_longn.png'];
            hgexport(fh,figure_name,mystyle,'Format','png');
        end


        for i=1:n_g_inh
            clear conditions;
            fh=figure();
            set(gcf,'Color',[1 1 1]);
            for j=1:n_k_ratio
                try
                    actual_color_ind=floor((ncolors/(1+n_k_ratio))*j);
                catch
                    actual_color_ind=1;
                end
                eval(['plot(ranged_par2_vect,squeeze(' field_names{kk} '_osc_all(j,:,i)),''o'',''Color'',cmap_parula(actual_color_ind,:),''LineStyle'',''-'');'])
                hold on;
            end
            for j=1:n_k_ratio
                try
                    actual_color_ind=floor((ncolors/(1+n_k_ratio))*j);
                catch
                    actual_color_ind=1;
                end
                eval(['plot(ranged_par2_vect,squeeze(' field_names{kk} '_ple_all(j,:,i)),''s'',''Color'',cmap_parula(actual_color_ind,:),''LineStyle'',''--'');'])
                hold on;
            end
            xlim(sort([ranged_par2_vect(1) ranged_par2_vect(end)]));
            stringa_legend='';
            for j=1:n_k_ratio
                % stringa_legend=[stringa_legend '''k_ratio=' num2str(ranged_par1_vect(j),'%.2f') ''',']; % only this works, options above do not work
                % eval(['stringa_legend=[stringa_legend ''''''' char(ranged_stringa(1)) '=' num2str(ranged_par1_vect(j),'%.2f') ''''''' '',''];']); % this works
                % eval(['stringa_legend=[stringa_legend ''''''' char(ranged_stringa(1)) '=' num2str(ranged_par1_vect(j),'%.0f') 'Hz' ''''''' '',''];']); % this works
                if strcmp(char(ranged_stringa_tex(1)),'\Sigma') || strcmp(char(ranged_stringa_tex(1)),'m')
                    eval(['stringa_legend=[stringa_legend ''''''' char(ranged_stringa_tex(1)) '=' num2str(ranged_par1_vect(j),'%.2f') ''''''' '',''];']); % this works
                elseif strcmp(char(ranged_stringa_tex(1)),'p_{fail}')
                    eval(['stringa_legend=[stringa_legend ''''''' char(ranged_stringa_tex(1)) '=' num2str(ranged_par1_vect(j),'%.1f') ''''''' '',''];']); % this works
                elseif strcmp(char(ranged_stringa_tex(1)),'f_0') || strcmp(char(ranged_stringa_tex(1)),'r_0')
                    eval(['stringa_legend=[stringa_legend ''''''' char(ranged_stringa_tex(1)) '=' num2str(ranged_par1_vect(j),'%.0f') 'Hz' ''''''' '',''];']); % this works
                end
            end
            if ismember(i,ylabel_ind)
                if strcmp(par.suf1,'osc') % we only put legend for osc trains
                    eval(['legh=legend(' stringa_legend(1:end-1) ',''Location'',''best'');']);
                end
                ylabel(field_names_long_wc_ms{kk});
            end
            % set(legh,'Interpreter','none');
            % xlabel(char(ranged_stringa(2)),'Interpreter','none');
            xlabel(char(ranged_stringa_tex(2)));
            % ylabel(field_names{kk},'Interpreter','none');
            % title([char(ranged_stringa(3)) '=' num2str(ranged_par3_vect(i),'%.2f')],'FontWeight','normal','Interpreter','none');
            % title([char(ranged_stringa(3)) '=' num2str(ranged_par3_vect(i),'%.0f') 'Hz'],'FontWeight','normal','Interpreter','none');
            set(gca,'Position',pos_this);
            figure_name=[stringa '_' strrep(field_names{kk},'.','_') '_vs_' char(ranged_stringa(2)) '_m' char(ranged_stringa(1)) '_at_' char(ranged_stringa(3)) '' num2str(i) '_longn.png'];
            hgexport(fh,figure_name,mystyle,'Format','png');

            clear conditions;
            fh=figure();
            set(gcf,'Color',[1 1 1]);
            for j=1:n_g_exc
                try
                    actual_color_ind=floor((ncolors/(1+n_g_exc))*j);
                catch
                    actual_color_ind=1;
                end
                eval(['plot(ranged_par1_vect,squeeze(' field_names{kk} '_osc_all(:,j,i)),''o'',''Color'',cmap_parula(actual_color_ind,:),''LineStyle'',''-'');'])
                hold on;
            end
            for j=1:n_g_exc
                try
                    actual_color_ind=floor((ncolors/(1+n_g_exc))*j);
                catch
                    actual_color_ind=1;
                end
                eval(['plot(ranged_par1_vect,squeeze(' field_names{kk} '_ple_all(:,j,i)),''s'',''Color'',cmap_parula(actual_color_ind,:),''LineStyle'',''--'');'])
                hold on;
            end
            xlim([ranged_par1_vect(1) ranged_par1_vect(end)]);
            stringa_legend='';
            for j=1:n_g_exc
                % stringa_legend=[stringa_legend '''g_exc=' num2str(ranged_par2_vect(j),'%.2f') ''','];
                % eval(['stringa_legend=[stringa_legend ''''''' char(ranged_stringa(2)) '=' num2str(ranged_par2_vect(j),'%.2f') ''''''' '',''];']); % this works
                % eval(['stringa_legend=[stringa_legend ''''''' char(ranged_stringa(2)) '=' num2str(ranged_par2_vect(j),'%.0f') 'Hz' ''''''' '',''];']); % this works
                if strcmp(char(ranged_stringa_tex(2)),'\Sigma') || strcmp(char(ranged_stringa_tex(2)),'m')
                    eval(['stringa_legend=[stringa_legend ''''''' char(ranged_stringa_tex(2)) '=' num2str(ranged_par2_vect(j),'%.2f') ''''''' '',''];']); % this works
                elseif strcmp(char(ranged_stringa_tex(2)),'p_{fail}')
                    eval(['stringa_legend=[stringa_legend ''''''' char(ranged_stringa_tex(2)) '=' num2str(ranged_par2_vect(j),'%.1f') ''''''' '',''];']); % this works
                elseif strcmp(char(ranged_stringa_tex(2)),'f_0') || strcmp(char(ranged_stringa_tex(2)),'r_0')
                    eval(['stringa_legend=[stringa_legend ''''''' char(ranged_stringa_tex(2)) '=' num2str(ranged_par2_vect(j),'%.0f') 'Hz' ''''''' '',''];']); % this works
                end
            end
            if ismember(i,ylabel_ind)
                if strcmp(par.suf1,'osc') % we only put legend for osc trains
                    eval(['legh=legend(' stringa_legend(1:end-1) ',''Location'',''best'');']);
                end
                ylabel(field_names_long_wc_ms{kk});
            end
            % set(legh,'Interpreter','none');
            % xlabel(char(ranged_stringa(1)),'Interpreter','none');
            xlabel(char(ranged_stringa_tex(1)));
            % ylabel(field_names{kk},'Interpreter','none');
            % title([char(ranged_stringa(3)) '=' num2str(ranged_par3_vect(i),'%.2f')],'FontWeight','normal','Interpreter','none');
            % title([char(ranged_stringa(3)) '=' num2str(ranged_par3_vect(i),'%.0f') 'Hz'],'FontWeight','normal','Interpreter','none');
            set(gca,'Position',pos_this);
            figure_name=[stringa '_' strrep(field_names{kk},'.','_') '_vs_' char(ranged_stringa(1)) '_m' char(ranged_stringa(2)) '_at_' char(ranged_stringa(3)) '' num2str(i) '_longn.png'];
            hgexport(fh,figure_name,mystyle,'Format','png');
        end
        close all;
    end
end

% keyboard; % plots below have already been generated





for kk=1:length(field_names)
    if kk==10 % only bursty with legend
        continue;
    end
    for i=1:n_k_ratio
        clear conditions;
        fh=figure();
        set(gcf,'Color',[1 1 1]);
        for j=1:n_g_exc
            try
                actual_color_ind=floor((ncolors/(1+n_g_exc))*j);
            catch
                actual_color_ind=1;
            end
            eval(['plot(ranged_par3_vect,squeeze(' field_names{kk} '_osc_all(i,j,:)),''o'',''Color'',cmap_parula(actual_color_ind,:),''LineStyle'',''-'');'])
            hold on;
        end
        for j=1:n_g_exc
            try
                actual_color_ind=floor((ncolors/(1+n_g_exc))*j);
            catch
                actual_color_ind=1;
            end
            eval(['plot(ranged_par3_vect,squeeze(' field_names{kk} '_ple_all(i,j,:)),''s'',''Color'',cmap_parula(actual_color_ind,:),''LineStyle'',''--'');'])
            hold on;
        end
        xlim(sort([ranged_par3_vect(1) ranged_par3_vect(end)]));
        stringa_legend='';
        for j=1:n_g_exc
            % stringa_legend=[stringa_legend '''' char(conditions{i}) ''','];
            % stringa_legend=[stringa_legend '''' conditions{i} ''','];
            % stringa_legend=[stringa_legend '''' conditions(i) ''','];
            % stringa_legend=[stringa_legend '''g_exc=' num2str(par.gmax_exc_vect(j),'%i') ''',']; % only this works, options above do not work
            % stringa_legend=[stringa_legend '''g_exc=' num2str(par.gmax_exc_vect(j),'%.2f') ''',']; % only this works, options above do not work
            % eval(['stringa_legend=[stringa_legend ''' char(ranged_stringa(2)) '=' num2str(ranged_par2_vect(j),'%.2f') ''''',''];']); % this doesn't work
            % eval(['stringa_legend=[stringa_legend ''''''' char(ranged_stringa_tex(2)) '=' num2str(ranged_par2_vect(j),'%.2f') ''''''' '',''];']); % this works
            eval(['stringa_legend=[stringa_legend ''''''' char(ranged_stringa_tex(2)) '=' num2str(ranged_par2_vect(j),'%.0f') 'Hz' ''''''' '',''];']); % this works
            % eval(['stringa_legend=[stringa_legend ''' char(ranged_stringa(2)) '=' num2str(ranged_par2_vect(j),'%.2f') ''' '',''];']); % this doesn't work
            % eval(['stringa_legend=[stringa_legend ''' char(ranged_stringa(2)) '=' num2str(ranged_par2_vect(j),'%.2f') ''',];']); % this doesn't work
        end
        % eval(['legh=legend(lh,' stringa_legend(1:end-1) ');']);
        % eval(['legh=legend(' stringa_legend(1:end-1) ',''Location'',''best'');']);
        % set(legh,'Interpreter','none');
        % xlabel(char(ranged_stringa_tex(3)),'Interpreter','none');
        xlabel(char(ranged_stringa_tex(3)));
        % ylabel(field_names{kk},'Interpreter','none');
        if ismember(i,ylabel_ind)
            ylabel(field_names_long_wc_ms{kk});
        end
        % title([char(ranged_stringa(1)) '=' num2str(ranged_par1_vect(i),'%.2f')],'FontWeight','normal','Interpreter','none');
        % title([char(ranged_stringa_tex(1)) '=' num2str(ranged_par1_vect(i),'%.0f') 'Hz'],'FontWeight','normal');
        set(gca,'Position',pos_this);
        figure_name=[stringa '_' strrep(field_names{kk},'.','_') '_vs_' char(ranged_stringa(3)) '_m' char(ranged_stringa(2)) '_at_' char(ranged_stringa(1)) '' num2str(i) '_longn.png']; % long measure name
        hgexport(fh,figure_name,mystyle,'Format','png');

        clear conditions;
        fh=figure();
        set(gcf,'Color',[1 1 1]);
        for j=1:n_g_inh
            try
                actual_color_ind=floor((ncolors/(1+n_g_inh))*j);
            catch
                actual_color_ind=1;
            end
            eval(['plot(ranged_par2_vect,squeeze(' field_names{kk} '_osc_all(i,:,j)),''o'',''Color'',cmap_parula(actual_color_ind,:),''LineStyle'',''-'');'])
            hold on;
        end
        for j=1:n_g_inh
            try
                actual_color_ind=floor((ncolors/(1+n_g_inh))*j);
            catch
                actual_color_ind=1;
            end
            eval(['plot(ranged_par2_vect,squeeze(' field_names{kk} '_ple_all(i,:,j)),''s'',''Color'',cmap_parula(actual_color_ind,:),''LineStyle'',''--'');'])
            hold on;
        end
        xlim(sort([ranged_par2_vect(1) ranged_par2_vect(end)]));
        stringa_legend='';
        for j=1:n_g_inh
            % stringa_legend=[stringa_legend '''g_inh=' num2str(ranged_par3_vect(j),'%.2f') ''','];
            % eval(['stringa_legend=[stringa_legend ''''''' char(ranged_stringa(3)) '=' num2str(ranged_par3_vect(j),'%.2f') ''''''' '',''];']); % this works
            eval(['stringa_legend=[stringa_legend ''''''' char(ranged_stringa(3)) '=' num2str(ranged_par3_vect(j),'%.0f') 'Hz' ''''''' '',''];']); % this works
        end
        % eval(['legh=legend(' stringa_legend(1:end-1) ',''Location'',''best'');']);
        % set(legh,'Interpreter','none');
        % xlabel(char(ranged_stringa(2)),'Interpreter','none');
        xlabel(char(ranged_stringa_tex(2)));
        % ylabel(field_names{kk},'Interpreter','none');
        if ismember(i,ylabel_ind)
            ylabel(field_names_long_wc_ms{kk});
        end
        % title([char(ranged_stringa(1)) '=' num2str(ranged_par1_vect(i),'%.2f')],'FontWeight','normal','Interpreter','none');
        % title([char(ranged_stringa(1)) '=' num2str(ranged_par1_vect(i),'%.0f') 'Hz'],'FontWeight','normal','Interpreter','none');
        if strcmp(par.suf1,'oscG') % we need to specify this explicitly for dual trains
            set(gca,'XTick',ranged_par2_vect([5 3 1]));
        end
        set(gca,'Position',pos_this);
        figure_name=[stringa '_' strrep(field_names{kk},'.','_') '_vs_' char(ranged_stringa(2)) '_m' char(ranged_stringa(3)) '_at_' char(ranged_stringa(1)) '' num2str(i) '_longn.png'];
        hgexport(fh,figure_name,mystyle,'Format','png');
    end


    for i=1:n_g_exc
        clear conditions;
        fh=figure();
        set(gcf,'Color',[1 1 1]);
        for j=1:n_k_ratio
            try
                actual_color_ind=floor((ncolors/(1+n_k_ratio))*j);
            catch
                actual_color_ind=1;
            end
            eval(['plot(ranged_par3_vect,squeeze(' field_names{kk} '_osc_all(j,i,:)),''o'',''Color'',cmap_parula(actual_color_ind,:),''LineStyle'',''-'');'])
            hold on;
        end
        for j=1:n_k_ratio
            try
                actual_color_ind=floor((ncolors/(1+n_k_ratio))*j);
            catch
                actual_color_ind=1;
            end
            eval(['plot(ranged_par3_vect,squeeze(' field_names{kk} '_ple_all(j,i,:)),''s'',''Color'',cmap_parula(actual_color_ind,:),''LineStyle'',''--'');'])
            hold on;
        end
        xlim(sort([ranged_par3_vect(1) ranged_par3_vect(end)]));
        stringa_legend='';
        for j=1:n_k_ratio
            % stringa_legend=[stringa_legend '''k_ratio=' num2str(ranged_par1_vect(j),'%.2f') ''',']; % only this works, options above do not work
            % eval(['stringa_legend=[stringa_legend ''''''' char(ranged_stringa(1)) '=' num2str(ranged_par1_vect(j),'%.2f') ''''''' '',''];']); % this works
            eval(['stringa_legend=[stringa_legend ''''''' char(ranged_stringa(1)) '=' num2str(ranged_par1_vect(j),'%.0f') 'Hz' ''''''' '',''];']); % this works
        end
        % eval(['legh=legend(' stringa_legend(1:end-1) ',''Location'',''best'');']);
        % set(legh,'Interpreter','none');
        % xlabel(char(ranged_stringa(3)),'Interpreter','none');
        xlabel(char(ranged_stringa_tex(3)));
        % ylabel(field_names{kk},'Interpreter','none');
        if ismember(i,ylabel_ind)
            ylabel(field_names_long_wc_ms{kk});
        end
        % title([char(ranged_stringa(2)) '=' num2str(ranged_par2_vect(i),'%.2f')],'FontWeight','normal','Interpreter','none');
        % title([char(ranged_stringa(2)) '=' num2str(ranged_par2_vect(i),'%.0f') 'Hz'],'FontWeight','normal','Interpreter','none');
        set(gca,'Position',pos_this);
        figure_name=[stringa '_' strrep(field_names{kk},'.','_') '_vs_' char(ranged_stringa(3)) '_m' char(ranged_stringa(1)) '_at_' char(ranged_stringa(2)) '' num2str(i) '_longn.png'];
        hgexport(fh,figure_name,mystyle,'Format','png');

        clear conditions;
        fh=figure();
        set(gcf,'Color',[1 1 1]);
        for j=1:n_g_inh
            try
                actual_color_ind=floor((ncolors/(1+n_g_inh))*j);
            catch
                actual_color_ind=1;
            end
            eval(['plot(ranged_par1_vect,squeeze(' field_names{kk} '_osc_all(:,i,j)),''o'',''Color'',cmap_parula(actual_color_ind,:),''LineStyle'',''-'');'])
            hold on;
        end
        for j=1:n_g_inh
            try
                actual_color_ind=floor((ncolors/(1+n_g_inh))*j);
            catch
                actual_color_ind=1;
            end
            eval(['plot(ranged_par1_vect,squeeze(' field_names{kk} '_ple_all(:,i,j)),''s'',''Color'',cmap_parula(actual_color_ind,:),''LineStyle'',''--'');'])
            hold on;
        end
        xlim([ranged_par1_vect(1) ranged_par1_vect(end)]);
        stringa_legend='';
        for j=1:n_g_inh
            % stringa_legend=[stringa_legend '''g_inh=' num2str(ranged_par3_vect(j),'%.2f') ''','];
            % eval(['stringa_legend=[stringa_legend ''''''' char(ranged_stringa(3)) '=' num2str(ranged_par3_vect(j),'%.2f') ''''''' '',''];']); % this works
            eval(['stringa_legend=[stringa_legend ''''''' char(ranged_stringa(3)) '=' num2str(ranged_par3_vect(j),'%.0f') 'Hz' ''''''' '',''];']); % this works
        end
        % eval(['legh=legend(' stringa_legend(1:end-1) ',''Location'',''best'');']);
        % set(legh,'Interpreter','none');
        % xlabel(char(ranged_stringa(1)),'Interpreter','none');
        xlabel(char(ranged_stringa_tex(1)));
        % ylabel(field_names{kk},'Interpreter','none');
        if ismember(i,ylabel_ind)
            ylabel(field_names_long_wc_ms{kk});
        end
        % title([char(ranged_stringa(2)) '=' num2str(ranged_par2_vect(i),'%.2f')],'FontWeight','normal','Interpreter','none');
        % title([char(ranged_stringa(2)) '=' num2str(ranged_par2_vect(i),'%.0f') 'Hz'],'FontWeight','normal','Interpreter','none');
        set(gca,'Position',pos_this);
        figure_name=[stringa '_' strrep(field_names{kk},'.','_') '_vs_' char(ranged_stringa(1)) '_m' char(ranged_stringa(3)) '_at_' char(ranged_stringa(2)) '' num2str(i) '_longn.png'];
        hgexport(fh,figure_name,mystyle,'Format','png');
    end


    for i=1:n_g_inh
        clear conditions;
        fh=figure();
        set(gcf,'Color',[1 1 1]);
        for j=1:n_k_ratio
            try
                actual_color_ind=floor((ncolors/(1+n_k_ratio))*j);
            catch
                actual_color_ind=1;
            end
            eval(['plot(ranged_par2_vect,squeeze(' field_names{kk} '_osc_all(j,:,i)),''o'',''Color'',cmap_parula(actual_color_ind,:),''LineStyle'',''-'');'])
            hold on;
        end
        for j=1:n_k_ratio
            try
                actual_color_ind=floor((ncolors/(1+n_k_ratio))*j);
            catch
                actual_color_ind=1;
            end
            eval(['plot(ranged_par2_vect,squeeze(' field_names{kk} '_ple_all(j,:,i)),''s'',''Color'',cmap_parula(actual_color_ind,:),''LineStyle'',''--'');'])
            hold on;
        end
        xlim(sort([ranged_par2_vect(1) ranged_par2_vect(end)]));
        stringa_legend='';
        for j=1:n_k_ratio
            % stringa_legend=[stringa_legend '''k_ratio=' num2str(ranged_par1_vect(j),'%.2f') ''',']; % only this works, options above do not work
            % eval(['stringa_legend=[stringa_legend ''''''' char(ranged_stringa(1)) '=' num2str(ranged_par1_vect(j),'%.2f') ''''''' '',''];']); % this works
            eval(['stringa_legend=[stringa_legend ''''''' char(ranged_stringa(1)) '=' num2str(ranged_par1_vect(j),'%.0f') 'Hz' ''''''' '',''];']); % this works
        end
        % eval(['legh=legend(' stringa_legend(1:end-1) ',''Location'',''best'');']);
        % set(legh,'Interpreter','none');
        % xlabel(char(ranged_stringa(2)),'Interpreter','none');
        xlabel(char(ranged_stringa_tex(2)));
        % ylabel(field_names{kk},'Interpreter','none');
        if ismember(i,ylabel_ind)
            ylabel(field_names_long_wc_ms{kk});
        end
        % title([char(ranged_stringa(3)) '=' num2str(ranged_par3_vect(i),'%.2f')],'FontWeight','normal','Interpreter','none');
        % title([char(ranged_stringa(3)) '=' num2str(ranged_par3_vect(i),'%.0f') 'Hz'],'FontWeight','normal','Interpreter','none');
        set(gca,'Position',pos_this);
        figure_name=[stringa '_' strrep(field_names{kk},'.','_') '_vs_' char(ranged_stringa(2)) '_m' char(ranged_stringa(1)) '_at_' char(ranged_stringa(3)) '' num2str(i) '_longn.png'];
        hgexport(fh,figure_name,mystyle,'Format','png');

        clear conditions;
        fh=figure();
        set(gcf,'Color',[1 1 1]);
        for j=1:n_g_exc
            try
                actual_color_ind=floor((ncolors/(1+n_g_exc))*j);
            catch
                actual_color_ind=1;
            end
            eval(['plot(ranged_par1_vect,squeeze(' field_names{kk} '_osc_all(:,j,i)),''o'',''Color'',cmap_parula(actual_color_ind,:),''LineStyle'',''-'');'])
            hold on;
        end
        for j=1:n_g_exc
            try
                actual_color_ind=floor((ncolors/(1+n_g_exc))*j);
            catch
                actual_color_ind=1;
            end
            eval(['plot(ranged_par1_vect,squeeze(' field_names{kk} '_ple_all(:,j,i)),''s'',''Color'',cmap_parula(actual_color_ind,:),''LineStyle'',''--'');'])
            hold on;
        end
        xlim([ranged_par1_vect(1) ranged_par1_vect(end)]);
        stringa_legend='';
        for j=1:n_g_exc
            % stringa_legend=[stringa_legend '''g_exc=' num2str(ranged_par2_vect(j),'%.2f') ''','];
            % eval(['stringa_legend=[stringa_legend ''''''' char(ranged_stringa(2)) '=' num2str(ranged_par2_vect(j),'%.2f') ''''''' '',''];']); % this works
            eval(['stringa_legend=[stringa_legend ''''''' char(ranged_stringa(2)) '=' num2str(ranged_par2_vect(j),'%.0f') 'Hz' ''''''' '',''];']); % this works
        end
        % eval(['legh=legend(' stringa_legend(1:end-1) ',''Location'',''best'');']);
        % set(legh,'Interpreter','none');
        % xlabel(char(ranged_stringa(1)),'Interpreter','none');
        xlabel(char(ranged_stringa_tex(1)));
        % ylabel(field_names{kk},'Interpreter','none');
        if ismember(i,ylabel_ind)
            ylabel(field_names_long_wc_ms{kk});
        end
        % title([char(ranged_stringa(3)) '=' num2str(ranged_par3_vect(i),'%.2f')],'FontWeight','normal','Interpreter','none');
        % title([char(ranged_stringa(3)) '=' num2str(ranged_par3_vect(i),'%.0f') 'Hz'],'FontWeight','normal','Interpreter','none');
        set(gca,'Position',pos_this);
        figure_name=[stringa '_' strrep(field_names{kk},'.','_') '_vs_' char(ranged_stringa(1)) '_m' char(ranged_stringa(2)) '_at_' char(ranged_stringa(3)) '' num2str(i) '_longn.png'];
        hgexport(fh,figure_name,mystyle,'Format','png');
    end
    close all;
end

output_struct=[];
cd ..
return;
