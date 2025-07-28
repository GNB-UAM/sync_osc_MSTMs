function output_struct=plot_train_all_win_cb(stringa_dir_batch,par,ranged_par,ranged_stringa,stringa_label)
% organises simulations (ranging gmax_inh and I_bias) and m files to be submitted to a PBS queue

eval(['n_par1=length(' char(ranged_par(1)) ');']);
eval(['n_par2=length(' char(ranged_par(2)) ');']);
eval(['n_par3=length(' char(ranged_par(3)) ');']);

eval(['ranged_par1_vect=' char(ranged_par(1)) ';']);
eval(['ranged_par2_vect=' char(ranged_par(2)) ';']);
eval(['ranged_par3_vect=' char(ranged_par(3)) ';']);

if isfield(par,'syn')
    if isfield(par.syn,'ranged3_vect_plot')
        ranged3_vect_plot=par.syn.ranged3_vect_plot;
        n_par3=length(ranged3_vect_plot);
    else
        ranged3_vect_plot=1:1:n_par3;
    end
else
    ranged3_vect_plot=1:1:n_par3;
end

eval(['ranged_par3_vect=' char(ranged_par(3)) '(ranged3_vect_plot);']);

get_field_names_cb_bs; % enough with bs measures for now

for i=1:n_par1
    for j=1:n_par2
        for k=1:n_par3
            for ind_out=1:length(output_mat_files)
                eval(['output_this{' num2str(ind_out) '}=load(''' stringa_dir_batch '_' num2str(i) '_' num2str(j) '_' num2str(ranged3_vect_plot(k)) '_' par.suf1 '/' output_mat_files{ind_out} '.mat'');']);
            end
            for kk=1:length(field_names)
                try
                    eval([field_names{kk} '_osc_all(i,j,k)=output_this{file_ind(kk)}.' field_names{kk} ';']);
                catch
                    eval([field_names{kk} '_osc_all(i,j,k)=NaN;']);
                    % keyboard;
                end
            end

        end
    end
end


for i=1:n_par1
    for j=1:n_par2
        for k=1:n_par3
            for ind_out=1:length(output_mat_files)
                eval(['output_this{' num2str(ind_out) '}=load(''' stringa_dir_batch '_' num2str(i) '_' num2str(j) '_' num2str(ranged3_vect_plot(k)) '_' par.suf2 '/' output_mat_files{ind_out} '.mat'');']);
            end
            for kk=1:length(field_names)
                try
                    eval([field_names{kk} '_ple_all(i,j,k)=output_this{file_ind(kk)}.' field_names{kk} ';']);
                catch
                    eval([field_names{kk} '_ple_all(i,j,k)=NaN;']);
                    % keyboard;
                end
            end

        end
    end
end

for i=1:n_par1
    for j=1:n_par2
        for kk=1:length(field_names)
            eval([field_names{kk} '_osc_nan_count(i,j)=sum(isnan(' field_names{kk} '_osc_all(i,j,:)),3);']);
            eval([field_names{kk} '_osc_mean(i,j)=nanmean(' field_names{kk} '_osc_all(i,j,:),3);']);
            eval([field_names{kk} '_osc_std(i,j)=nanstd(' field_names{kk} '_osc_all(i,j,:),[],3);']);
        end

        for kk=1:length(field_names)
            eval([field_names{kk} '_ple_nan_count(i,j)=sum(isnan(' field_names{kk} '_ple_all(i,j,:)),3);']);
            eval([field_names{kk} '_ple_mean(i,j)=nanmean(' field_names{kk} '_ple_all(i,j,:),3);']);
            eval([field_names{kk} '_ple_std(i,j)=nanstd(' field_names{kk} '_ple_all(i,j,:),[],3);']);
        end
    end
end

eval(['mkdir ' stringa_dir_batch '_' par.suf1 '_' par.suf2 '_all']);
eval(['cd ' stringa_dir_batch '_' par.suf1 '_' par.suf2 '_all']);

stringa=['feat_analyze_' stringa_dir_batch];

mystyle = hgexport('factorystyle');
mystyle.Units='normalized';
mystyle.FontMode='none';

if strfind(stringa_dir_batch,'win')
    xtick_vect=logspace(3,5,3);
elseif strfind(stringa_dir_batch,'nneu')
    xtick_vect=ranged_par2_vect;
else
    keyboard;
end

% cmap_parula=colormap; % Colormap 'default' option for heatmap displays the blue colormap instead of parula - Behavior changed in R2020b
cmap_parula=colormap(parula(64));
% ncolors=48;
ncolors=64;
c_osc=[0 0 1];
c_ple=[0.9655    0.5172    0.0345];

% pos_this=[0.1879    0.2052    0.7171    0.7198]; % this allows 2 decimal digits, prob enough for main fig
pos_this=[0.2177    0.2052    0.6873    0.7198]; % this allows 3 decimal digits, prob required for SI - WE NEED THIS FOR BOTH

% here we only want to plot against win length
for kk=1:length(field_names)
    % for kk=11 % MPC can give NaN for the shorter win length
    % for kk=18 % sttc, longest long name
    for i=1:n_par1

        fh=figure();
        set(gcf,'Color',[1 1 1]);
        eval(['first_val=' field_names{kk} '_osc_mean(i,1);']);
        if ~isnan(first_val) % sometimes the first value can be NaN
            eval(['lh(i)=plot(ranged_par2_vect,squeeze(' field_names{kk} '_osc_mean(i,:)),''-o'');'])
            hold on;
            eval(['jbfill(ranged_par2_vect,' field_names{kk} '_osc_mean(i,:)-' field_names{kk} '_osc_std(i,:),' field_names{kk} '_osc_mean(i,:)+' field_names{kk} '_osc_std(i,:),[0 0 1],[0 0 1]);']);
            hold on;
        else
            eval(['lh(i)=plot(ranged_par2_vect(2:end),squeeze(' field_names{kk} '_osc_mean(i,2:end)),''-o'');'])
            hold on;
            eval(['jbfill(ranged_par2_vect(2:end),' field_names{kk} '_osc_mean(i,2:end)-' field_names{kk} '_osc_std(i,2:end),' field_names{kk} '_osc_mean(i,2:end)+' field_names{kk} '_osc_std(i,2:end),[0 0 1],[0 0 1]);']);
            hold on;
        end
        xlim(sort([ranged_par2_vect(1) ranged_par2_vect(end)]));
        set(gca,'XScale','log');
        % xlabel(char(ranged_stringa(2)),'Interpreter','none');
        xlabel(stringa_label,'Interpreter','none');
        if strcmp(par.suf1,'osc') % we only put meas name for osc trains
            ylabel(field_names_long_wc_ms{kk});
        end
        set(gca,'XTick',xtick_vect);
        % title([par.suf1 ' - ' char(ranged_stringa(1)) '=' num2str(ranged_par1_vect(i),'%.2f')],'FontWeight','normal','Interpreter','none');
        set(gca,'Position',pos_this);
        figure_name=[stringa '_' strrep(field_names{kk},'.','_') '_vs_' char(ranged_stringa(2)) '_at_' char(ranged_stringa(1)) num2str(i) '_' par.suf1 '_longn_cb.png'];
        hgexport(fh,figure_name,mystyle,'Format','png');

        fh=figure();
        set(gcf,'Color',[1 1 1]);
        eval(['first_val=' field_names{kk} '_ple_mean(i,1);']);
        if ~isnan(first_val) % sometimes the first value can be NaN
            eval(['lh(i)=plot(ranged_par2_vect,squeeze(' field_names{kk} '_ple_mean(i,:)),''-o'');'])
            hold on;
            eval(['jbfill(ranged_par2_vect,' field_names{kk} '_ple_mean(i,:)-' field_names{kk} '_ple_std(i,:),' field_names{kk} '_ple_mean(i,:)+' field_names{kk} '_ple_std(i,:),[0 0 1],[0 0 1]);']);
            hold on;
        else
            eval(['lh(i)=plot(ranged_par2_vect(2:end),squeeze(' field_names{kk} '_ple_mean(i,2:end)),''-o'');'])
            hold on;
            eval(['jbfill(ranged_par2_vect(2:end),' field_names{kk} '_ple_mean(i,2:end)-' field_names{kk} '_ple_std(i,2:end),' field_names{kk} '_ple_mean(i,2:end)+' field_names{kk} '_ple_std(i,2:end),[0 0 1],[0 0 1]);']);
            hold on;
        end
        xlim(sort([ranged_par2_vect(1) ranged_par2_vect(end)]));
        set(gca,'XScale','log');
        % xlabel(char(ranged_stringa(2)),'Interpreter','none');
        xlabel(stringa_label,'Interpreter','none');
        % ylabel(field_names_long_wc_ms{kk}); % we only put meas name for osc trains
        set(gca,'XTick',xtick_vect);
        % title([par.suf2 ' - ' char(ranged_stringa(1)) '=' num2str(ranged_par1_vect(i),'%.2f')],'FontWeight','normal','Interpreter','none');
        set(gca,'Position',pos_this);
        figure_name=[stringa '_' strrep(field_names{kk},'.','_') '_vs_' char(ranged_stringa(2)) '_at_' char(ranged_stringa(1)) num2str(i) '_' par.suf2 '_longn_cb.png'];
        hgexport(fh,figure_name,mystyle,'Format','png');
    end

    %     clear conditions;
    %     fh=figure();
    %     for i=1:n_par2
    %         try
    %             actual_color_ind=floor((ncolors/(1+n_par2))*i);
    %         catch
    %             actual_color_ind=1;
    %         end
    %         eval(['lh(i)=plot(ranged_par1_vect,squeeze(' field_names{kk} '_osc_mean(:,i)),''o'',''Color'',cmap_parula(actual_color_ind,:),''LineStyle'',''-'');'])
    %         hold on;
    %         eval(['jbfill(ranged_par1_vect,(' field_names{kk} '_osc_mean(:,i)-' field_names{kk} '_osc_std(:,i))'',(' field_names{kk} '_osc_mean(:,i)+' field_names{kk} '_osc_std(:,i))'',cmap_parula(actual_color_ind,:),cmap_parula(actual_color_ind,:));']);
    %         hold on;
    %     end
    %     for i=1:n_par2
    %         try
    %             actual_color_ind=floor((ncolors/(1+n_par2))*i);
    %         catch
    %             actual_color_ind=1;
    %         end
    %         eval(['plot(ranged_par1_vect,squeeze(' field_names{kk} '_ple_mean(:,i)),''s'',''Color'',cmap_parula(actual_color_ind,:),''LineStyle'',''--'');'])
    %         hold on;
    %         eval(['jbfill(ranged_par1_vect,(' field_names{kk} '_ple_mean(:,i)-' field_names{kk} '_ple_std(:,i))'',(' field_names{kk} '_ple_mean(:,i)+' field_names{kk} '_ple_std(:,i))'',cmap_parula(actual_color_ind,:),cmap_parula(actual_color_ind,:));']);
    %         hold on;
    %     end
    %     xlim([ranged_par1_vect(1) ranged_par1_vect(end)]);
    %     stringa_legend='';
    %     for i=1:n_par2
    %         % stringa_legend=[stringa_legend '''g_inh=' num2str(ranged_par3_vect(i),'%.2f') ''','];
    %         eval(['stringa_legend=[stringa_legend ''''''' char(ranged_stringa(2)) '=' num2str(ranged_par2_vect(i),'%.2f') ''''''' '',''];']); % this works
    %     end
    %     eval(['legh=legend(lh,' stringa_legend(1:end-1) ',''Location'',''best'');']);
    %     set(legh,'Interpreter','none');
    %     xlabel(char(ranged_stringa(1)),'Interpreter','none');
    %     ylabel(field_names{kk},'Interpreter','none');
    %     figure_name=[stringa '_' strrep(field_names{kk},'.','_') '_vs_' char(ranged_stringa(1)) '_m' char(ranged_stringa(2)) '.png'];
    %     hgexport(fh,figure_name,mystyle,'Format','png');


    close all;
end

output_struct=[];
cd ..
return;
