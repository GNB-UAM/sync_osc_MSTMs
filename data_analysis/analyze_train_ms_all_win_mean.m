function output_struct=analyze_train_ms_all_win_mean(stringa_dir_batch,par)
% groups win bias and precision estimates from all synth spike train families

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
    FontSizeThisCb=16;
elseif strcmp(par.png_tail,'_bs')
    get_field_names_bs;
    FontSizeThis=14;
    FontSizeThisCb=16;
else
    keyboard;
end


for indf=1:nf
    suf_vect={par.f{indf}.suf1,par.f{indf}.suf2}; % better to do it this way
    for isuf=1:length(suf_vect)
        for i=1:f{indf}.n_par1
            for j=1:f{indf}.n_par2
                for k=1:f{indf}.n_par3
                    for ind_out=1:length(output_mat_files)
                        eval(['output_this{' num2str(ind_out) '}=load(''' par.f{indf}.stringa_dir '_' num2str(i) '_' num2str(j) '_' num2str(f{indf}.ranged3_vect_plot(k)) '_' suf_vect{isuf} '/' output_mat_files{ind_out} '.mat'');']);
                    end

                    for kk=1:length(field_names)
                        try
                            eval([field_names{kk} '_' suf_vect{isuf} '_all(i,j,k)=output_this{file_ind(kk)}.' field_names{kk} ';']); % can't use dynamic field referencing here
                        catch
                            eval([field_names{kk} '_' suf_vect{isuf} '_all(i,j,k)=NaN;']);
                        end
                    end

                end
            end
        end
    end
end
clear output_this;


for indf=1:nf
    suf_vect={par.f{indf}.suf1,par.f{indf}.suf2}; % better to do it this way
    for isuf=1:length(suf_vect)
        for i=1:f{indf}.n_par1
            for j=1:f{indf}.n_par2
                for kk=1:length(field_names)
                    eval([field_names{kk} '_' suf_vect{isuf} '_nan_count(i,j)=sum(isnan(' field_names{kk} '_' suf_vect{isuf} '_all(i,j,:)),3);']);
                    eval([field_names{kk} '_' suf_vect{isuf} '_mean(i,j)=nanmean(' field_names{kk} '_' suf_vect{isuf} '_all(i,j,:),3);']);
                    eval([field_names{kk} '_' suf_vect{isuf} '_std(i,j)=nanstd(' field_names{kk} '_' suf_vect{isuf} '_all(i,j,:),[],3);']);
                end
            end
        end
    end
end

clear suf_vect;
indsf=0; % sub-family index
for indf=1:nf
    indsf=indsf+1;
    suf_vect{indsf}=par.f{indf}.suf1;
    indsf=indsf+1;
    suf_vect{indsf}=par.f{indf}.suf2;
end

eval(['mkdir ' stringa_dir_batch '_all']);
eval(['cd ' stringa_dir_batch '_all']);

stringa=['feat_analyze_' stringa_dir_batch];

mystyle = hgexport('factorystyle');
mystyle.Units='normalized';
mystyle.FontMode='none';

mystyle_highres=mystyle;
mystyle_highres.Resolution=300;

PLOT.print=0; % comment to print figures

xtick_vect=logspace(3,5,3);

% win_vect=par.f{1}.sim_time_vect; % always equal for each stf
win_vect=f{1}.ranged_par2_vect; % more general, works for both win and nneu sims
nwin=f{indf}.n_par3; % always equal to f{indf}.n_par3 in this scheme


for isuf=1:length(suf_vect)
    for kk=1:length(field_names)
        for i=1:f{ceil(isuf/2)}.n_par1
            eval([field_names{kk} '_' suf_vect{isuf} '_bias(i,:)=(' field_names{kk} '_' suf_vect{isuf} '_mean(i,1:end-1)-' field_names{kk} '_' suf_vect{isuf} '_mean(i,end))./' field_names{kk} '_' suf_vect{isuf} '_std(i,1:end-1);']);
            eval([field_names{kk} '_' suf_vect{isuf} '_cv(i,:)=' field_names{kk} '_' suf_vect{isuf} '_std(i,:)./' field_names{kk} '_' suf_vect{isuf} '_mean(i,:);']); % with this approach we can also include the last value
            eval([field_names{kk} '_' suf_vect{isuf} '_nan_percent(i,:)=' field_names{kk} '_' suf_vect{isuf} '_nan_count(i,:)./nwin;']);
        end
        % Inf set to NaN so they will be later ignored by nanmean
        eval([field_names{kk} '_' suf_vect{isuf} '_bias(find(' field_names{kk} '_' suf_vect{isuf} '_bias==Inf))=NaN;']);
        eval([field_names{kk} '_' suf_vect{isuf} '_bias(find(' field_names{kk} '_' suf_vect{isuf} '_bias==-Inf))=NaN;']);
    end
end



% n_par1 is not the same for every stf!!!
for isuf=1:length(suf_vect)
    all_measures_bias{isuf}=nan(f{ceil(isuf/2)}.n_par1,length(win_vect)-1,length(field_names));
    all_measures_absbias{isuf}=nan(f{ceil(isuf/2)}.n_par1,length(win_vect)-1,length(field_names));
    all_measures_cv{isuf}=nan(f{ceil(isuf/2)}.n_par1,length(win_vect),length(field_names));
    all_measures_abscv{isuf}=nan(f{ceil(isuf/2)}.n_par1,length(win_vect),length(field_names));
    all_measures_nan_percent{isuf}=nan(f{ceil(isuf/2)}.n_par1,length(win_vect),length(field_names));
end

for isuf=1:length(suf_vect)
    for i=1:f{ceil(isuf/2)}.n_par1
        for w_ind=1:(length(win_vect))
            for kk=1:length(field_names)
                if w_ind~=length(win_vect)
                    eval(['all_measures_bias{isuf}(i,w_ind,kk)=' field_names{kk} '_' suf_vect{isuf} '_bias(i,w_ind);']);
                    eval(['all_measures_absbias{isuf}(i,w_ind,kk)=abs(' field_names{kk} '_' suf_vect{isuf} '_bias(i,w_ind));']);
                end
                eval(['all_measures_cv{isuf}(i,w_ind,kk)=' field_names{kk} '_' suf_vect{isuf} '_cv(i,w_ind);']);
                eval(['all_measures_abscv{isuf}(i,w_ind,kk)=abs(' field_names{kk} '_' suf_vect{isuf} '_cv(i,w_ind));']);
                eval(['all_measures_nan_percent{isuf}(i,w_ind,kk)=' field_names{kk} '_' suf_vect{isuf} '_nan_percent(i,w_ind);']);
            end
        end
    end
end


% first we average across all (relevant) r_osc_ampl (par1) values
for isuf=1:length(suf_vect)
    if f{ceil(isuf/2)}.ranged_par1_vect(1)==0 % sin and sinseq
        all_measures_bias_mean(isuf,:,:)=squeeze(nanmean(all_measures_bias{isuf}(2:f{ceil(isuf/2)}.n_par1,:,:),1));
        all_measures_absbias_mean(isuf,:,:)=squeeze(nanmean(all_measures_absbias{isuf}(2:f{ceil(isuf/2)}.n_par1,:,:),1));
        all_measures_cv_mean(isuf,:,:)=squeeze(nanmean(all_measures_cv{isuf}(2:f{ceil(isuf/2)}.n_par1,:,:),1));
        all_measures_abscv_mean(isuf,:,:)=squeeze(nanmean(all_measures_abscv{isuf}(2:f{ceil(isuf/2)}.n_par1,:,:),1));
        all_measures_nan_percent_mean(isuf,:,:)=squeeze(nanmean(all_measures_nan_percent{isuf}(2:f{ceil(isuf/2)}.n_par1,:,:),1));
        f{ceil(isuf/2)}.n_par1_plot=f{ceil(isuf/2)}.n_par1-1;
        f{ceil(isuf/2)}.ind_par1_plot=2:f{ceil(isuf/2)}.n_par1;
    else % G and Gseq
        all_measures_bias_mean(isuf,:,:)=squeeze(nanmean(all_measures_bias{isuf}(:,:,:),1));
        all_measures_absbias_mean(isuf,:,:)=squeeze(nanmean(all_measures_absbias{isuf}(:,:,:),1));
        all_measures_cv_mean(isuf,:,:)=squeeze(nanmean(all_measures_cv{isuf}(:,:,:),1));
        all_measures_abscv_mean(isuf,:,:)=squeeze(nanmean(all_measures_abscv{isuf}(:,:,:),1));
        all_measures_nan_percent_mean(isuf,:,:)=squeeze(nanmean(all_measures_nan_percent{isuf}(:,:,:),1));
        f{ceil(isuf/2)}.n_par1_plot=f{ceil(isuf/2)}.n_par1;
        f{ceil(isuf/2)}.ind_par1_plot=1:f{ceil(isuf/2)}.n_par1;
    end
end

% then I average across stf (so each stf will contribute equally to Mean, even if it might have more or less n_par1)
all_measures_bias_Mean=squeeze(nanmean(all_measures_bias_mean,1));
all_measures_absbias_Mean=squeeze(nanmean(all_measures_absbias_mean,1));
all_measures_cv_Mean=squeeze(nanmean(all_measures_cv_mean,1));
all_measures_abscv_Mean=squeeze(nanmean(all_measures_abscv_mean,1));
all_measures_nan_percent_Mean=squeeze(nanmean(all_measures_nan_percent_mean,1));

% then I average across win or nneu values to get a grand average

all_measures_bias_grandmean=squeeze(nanmean(all_measures_bias_Mean,1));
all_measures_absbias_grandmean=squeeze(nanmean(all_measures_absbias_Mean,1));
all_measures_cv_grandmean=squeeze(nanmean(all_measures_cv_Mean,1));
all_measures_abscv_grandmean=squeeze(nanmean(all_measures_abscv_Mean,1));
all_measures_nan_percent_grandmean=squeeze(nanmean(all_measures_nan_percent_Mean,1));


ff=0.1;
cmap_parula=colormap(parula(64));
ncolors=64;

% bias vect for each win value
% bias_vect_stf=[-0.3 -0.15 0.15 0.3];
% bias_vect_stf=linspace(-0.3,0.3,length(suf_vect)); % we could group them in pairs
bias_vect_f=linspace(-0.26,0.26,length(f)); % we could group them in pairs
bias_within_stf=[-0.04,0.04];
for isuf=1:length(suf_vect)
    bias_vect_stf(isuf)=bias_vect_f(ceil(isuf/2))+bias_within_stf(2-mod(isuf,2));
end
for isuf=1:length(suf_vect)
    bias_vect{isuf}=bias_vect_stf(isuf)+linspace(-.028,.028,f{ceil(isuf/2)}.n_par1_plot); % osc
    for i=1:(f{ceil(isuf/2)}.n_par1_plot)
        try
            actual_color_ind=floor((ncolors/(1+f{ceil(isuf/2)}.n_par1_plot))*i);
        catch
            actual_color_ind=1;
        end
        f{ceil(isuf/2)}.color_mat(i,:)=cmap_parula(actual_color_ind,:);
        if mod(ceil(isuf/2),2)==0 % seq
            f{ceil(isuf/2)}.face_color_mat(i,:)=cmap_parula(actual_color_ind,:);
        else % non-seq
            f{ceil(isuf/2)}.face_color_mat(i,:)='none';
        end
    end
end


% bias vect for grand mean
bias_vect_b=linspace(-0.3,0.3,length(win_vect)-1);
bias_vect_v=linspace(-0.3,0.3,length(win_vect));
bias_vect_stf_grand=linspace(-0.07,0.07,length(suf_vect)); % has to be < 0.1 (half the distance between points in bias_vect_v)
for w_ind=1:(length(win_vect)-1)
    for isuf=1:length(suf_vect)
        bias_vect_par1_grand=linspace(-0.007,0.007,f{ceil(isuf/2)}.n_par1_plot); % has to be < 0.01 (half the distance between points in bias_vect_stf_grand)
        bias_vect_b_grand{w_ind,isuf}=bias_vect_b(w_ind)+bias_vect_stf_grand(isuf)+bias_vect_par1_grand;
    end
end

for w_ind=1:(length(win_vect))
    for isuf=1:length(suf_vect)
        bias_vect_par1_grand=linspace(-0.005,0.005,f{ceil(isuf/2)}.n_par1_plot);
        bias_vect_v_grand{w_ind,isuf}=bias_vect_v(w_ind)+bias_vect_stf_grand(isuf)+bias_vect_par1_grand;
    end
end


symbol_vect={'o','s','o','s','^','d','^','d'}; % osc sinple oscseq sinpleseq / oscG expG oscGseq expGseq



% xtext=[1 4.5 8.5];
xtext=[1 4.5 7.5];
ytext1=1:0.3:2.5;
ytext2=1:0.3:2.5;
% ytext3=1:0.3:2.5;
ytext3=1.6:-.3:1;
ind_suf_leg=[1 2 5 6];
ind_suf_seq_leg=[1 3];

face_color_mat=[1 1 1;0 0 0];

seq_string_vect={'non-seq','seq'};
sequential_string_vect={'non-sequential','sequential'};
sync_string_vect={'low sync','mid sync','high sync'};

xoff=0.6;

figure;
set(gcf,'Color',[1 1 1]);
set(gca,'YDir','reverse');

for isuf=1:length(ind_suf_leg)
    plot(xtext(1),ytext1(isuf),symbol_vect{ind_suf_leg(isuf)},'Color',[0 0 0],'MarkerFaceColor',[1 1 1],'MarkerSize',20);
    th=text(xtext(1)+xoff,ytext1(isuf),suf_vect{ind_suf_leg(isuf)},'FontUnits','normalized','FontSize',0.1,'Color',[0 0 0],'Interpreter','none','HorizontalAlignment','left','VerticalAlignment','middle');
    hold on;
end

for isuf=1:length(seq_string_vect)
    plot(xtext(2),ytext2(isuf),symbol_vect{1},'Color',[0 0 0],'MarkerFaceColor',face_color_mat(isuf,:),'MarkerSize',20);
    th=text(xtext(2)+xoff,ytext2(isuf),seq_string_vect{isuf},'FontUnits','normalized','FontSize',0.1,'Color',[0 0 0],'Interpreter','none','HorizontalAlignment','left','VerticalAlignment','middle');
    hold on;
end

for isuf=1:length(sync_string_vect)
    th=text(xtext(3)+xoff,ytext3(isuf),sync_string_vect{isuf},'FontUnits','normalized','FontSize',0.1,'Color',f{3}.color_mat(isuf,:),'Interpreter','none','HorizontalAlignment','left','VerticalAlignment','middle');
    hold on;
end

xlim([0 14]);
ylim([0.7 2.8]);
set(gcf,'Position',[1000         914        1070         420]);
set(gca,'YDir','reverse'); % this has to be done again, not sure why
axis off;
if PLOT.print
    figure_name='sync_all_legend';
    export_fig(gcf,[figure_name '_' names_string '.png']);
end


fam_name_vect={'single-scale rhythmic','single-scale non-rhythmic','single-scale rhythmic','single-scale non-rhythmic','dual-scale rhythmic','dual-scale non-rhythmic','dual-scale rhythmic','dual-scale non-rhythmic'}; % watch out, unlike suf_vect this is just set manually
xtext=[1 13.5 20.5];
figure;
set(gcf,'Color',[1 1 1]);
set(gca,'YDir','reverse');

for isuf=1:length(ind_suf_leg)
    plot(xtext(1),ytext1(isuf),symbol_vect{ind_suf_leg(isuf)},'Color',[0 0 0],'MarkerFaceColor',[1 1 1],'MarkerSize',20);
    th=text(xtext(1)+xoff,ytext1(isuf),fam_name_vect{ind_suf_leg(isuf)},'FontUnits','normalized','FontSize',0.1,'Color',[0 0 0],'Interpreter','none','HorizontalAlignment','left','VerticalAlignment','middle');
    hold on;
end

for isuf=1:length(seq_string_vect)
    plot(xtext(2),ytext2(isuf),symbol_vect{1},'Color',[0 0 0],'MarkerFaceColor',face_color_mat(isuf,:),'MarkerSize',20);
    th=text(xtext(2)+xoff,ytext2(isuf),sequential_string_vect{isuf},'FontUnits','normalized','FontSize',0.1,'Color',[0 0 0],'Interpreter','none','HorizontalAlignment','left','VerticalAlignment','middle');
    hold on;
end

for isuf=1:length(sync_string_vect)
    th=text(xtext(3)+xoff,ytext3(isuf),sync_string_vect{isuf},'FontUnits','normalized','FontSize',0.1,'Color',f{3}.color_mat(isuf,:),'Interpreter','none','HorizontalAlignment','left','VerticalAlignment','middle');
    hold on;
end

xlim([0 25]);
ylim([0.7 2.8]);
set(gcf,'Position',[671         544        1250         406]);
set(gca,'YDir','reverse'); % this has to be done again, not sure why
axis off;
if PLOT.print
    figure_name='sync_all_legend_v2';
    export_fig(gcf,[figure_name '_' names_string '.png']);
end





if strcmp(par.png_tail,'_bs')
    xtext=[1 4.5 7.5 10.5];

    figure;
    set(gcf,'Color',[1 1 1]);
    set(gca,'YDir','reverse');

    for kk=1:length(field_names)
        th=text(xtext(1)+xoff,kk,field_names{kk},'HorizontalAlignment','center','VerticalAlignment','middle','Interpreter','none','FontSize',12,'Color',field_colors{kk});
        hold on;
    end

    for kk=1:length(field_names)
        th=text(xtext(2)+xoff,kk,field_names_long{kk},'HorizontalAlignment','center','VerticalAlignment','middle','Interpreter','none','FontSize',12,'Color',field_colors{kk});
        hold on;
    end

    for kk=1:length(field_names)
        th=text(xtext(3)+xoff,kk,field_names_latex{kk},'HorizontalAlignment','center','VerticalAlignment','middle','Interpreter','tex','FontSize',12,'Color',field_colors{kk});
        hold on;
    end

    for kk=1:length(field_names)
        th=text(xtext(4)+xoff,kk,field_names_latex{kk},'HorizontalAlignment','center','VerticalAlignment','middle','Interpreter','latex','FontSize',12,'Color',field_colors{kk});
        hold on;
    end

    xlim([0 12.5]);
    ylim([0 47]);
    set(gcf,'Position',[680           9        1208         953]);
    set(gca,'YDir','reverse'); % this has to be done again, not sure why
    axis off;
    if PLOT.print
        figure_name='measures_all_names';
        export_fig(gcf,[figure_name '_' names_string '.png']);
    end
end




for w_ind=1:(length(win_vect))
    if w_ind~=length(win_vect)
        figure();
        set(gcf,'Color',[1 1 1]);
        [all_measures_bias_sorted all_measures_bias_sorted_ind]=sort(squeeze(all_measures_bias_Mean(w_ind,:)));
        bar(all_measures_bias_sorted);
        hold on;
        for isuf=1:length(suf_vect)
            for kk=1:length(field_names)
                for i=1:(f{ceil(isuf/2)}.n_par1_plot)
                    sh=plot(kk+bias_vect{isuf}(i),all_measures_bias{isuf}(f{ceil(isuf/2)}.ind_par1_plot(i),w_ind,all_measures_bias_sorted_ind(kk)),symbol_vect{isuf},'Color',f{ceil(isuf/2)}.color_mat(i,:),'MarkerFaceColor',f{ceil(isuf/2)}.face_color_mat(i,:),'MarkerSize',4);
                end
            end
        end
        set(gca,'XTick',[1:length(field_names)]);
        set(gca,'XTickLabels',strrep(field_names_wc_ms(all_measures_bias_sorted_ind),'_','\_'),'FontSize',FontSizeThis); % works well with 99 measures
        xtickangle(gca,45);
        title(['bias at ' num2str(win_vect(w_ind))  par.stringa_title],'FontWeight','normal','Interpreter','none');
        set(gcf,'Position',[5         267        1914         702]);
        figure_name=['all_measures_bias_mean' '_w' num2str(w_ind) par.png_tail '_' names_string '.png'];
        hgexport(gcf,figure_name,mystyle,'Format','png');

        figure();
        set(gcf,'Color',[1 1 1]);
        [all_measures_bias_sorted all_measures_bias_sorted_ind]=sort(squeeze(all_measures_bias_Mean(w_ind,:)));
        bar(all_measures_bias_sorted);
        hold on;
        for isuf=1:length(suf_vect)
            for kk=1:length(field_names)
                for i=1:(f{ceil(isuf/2)}.n_par1_plot)
                    plot(kk+bias_vect{isuf}(i),all_measures_bias{isuf}(f{ceil(isuf/2)}.ind_par1_plot(i),w_ind,all_measures_bias_sorted_ind(kk)),symbol_vect{isuf},'Color',f{ceil(isuf/2)}.color_mat(i,:),'MarkerFaceColor',f{ceil(isuf/2)}.face_color_mat(i,:),'MarkerSize',4);
                end
            end
        end
        myyscale_symlog;

        ind_veryneg=find(all_measures_bias_sorted<-1,1,'last')+.5;
        p_veryneg=patch([min(xlim) ind_veryneg ind_veryneg min(xlim)], [max(ylim) max(ylim) min(ylim) min(ylim)],dark_gray);
        set(p_veryneg,'EdgeColor',get(p_veryneg,'FaceColor'));
        uistack(p_veryneg,'bottom');
        ind_neg=find(all_measures_bias_sorted<-.1,1,'last')+.5;
        p_neg=patch([ind_veryneg ind_neg ind_neg ind_veryneg], [max(ylim) max(ylim) min(ylim) min(ylim)],light_gray);
        set(p_neg,'EdgeColor',get(p_veryneg,'FaceColor'));
        uistack(p_neg,'bottom');

        ind_verypos=find(all_measures_bias_sorted>1,1)-.5;
        p_verypos=patch([max(xlim) ind_verypos ind_verypos max(xlim)], [max(ylim) max(ylim) min(ylim) min(ylim)],dark_gray);
        set(p_verypos,'EdgeColor',get(p_verypos,'FaceColor'));
        uistack(p_verypos,'bottom');
        ind_pos=find(all_measures_bias_sorted>.1,1)-.5;
        p_pos=patch([ind_verypos ind_pos ind_pos ind_verypos], [max(ylim) max(ylim) min(ylim) min(ylim)],light_gray);
        set(p_pos,'EdgeColor',get(p_verypos,'FaceColor'));
        uistack(p_pos,'bottom');

        hold on;
        plot([min(xlim) max(xlim)],zeros(1,2),'k','LineWidth',.5);
        set(gca,'XTick',[1:length(field_names)]);
        set(gca,'XTickLabels',strrep(field_names_wc_ms(all_measures_bias_sorted_ind),'_','\_'),'FontSize',FontSizeThis); % works well with 99 measures
        xtickangle(gca,45);
        title(['bias at ' num2str(win_vect(w_ind))  par.stringa_title],'FontWeight','normal','Interpreter','none');
        % xlabel('measures'); % maybe it's not strictly needed to label the measure axis, it is already labelled in fig_corr
        ylabel('$\mathcal{B}_S$','Interpreter','latex','Rotation',0);
        set(gcf,'Position',[5         267        1914         702]);
        figure_name=['all_measures_bias_mean' '_w' num2str(w_ind) '_symlog' par.png_tail '_' names_string '.png'];
        hgexport(gcf,figure_name,mystyle,'Format','png');




        figure();
        set(gcf,'Color',[1 1 1]);
        set(gcf,'Position',[5           1        1914         961]); % full height on flaptop
        [all_measures_bias_sorted all_measures_bias_sorted_ind]=sort(squeeze(all_measures_bias_Mean(w_ind,:)));
        bh=bar(all_measures_bias_sorted);
        set(bh,'FaceColor',[240 128 128]./255); % light coral https://www.rapidtables.com/web/color/RGB_Color.html
        hold on;
        for isuf=1:length(suf_vect)
            for kk=1:length(field_names)
                for i=1:(f{ceil(isuf/2)}.n_par1_plot)
                    plot(kk+bias_vect{isuf}(i),all_measures_bias{isuf}(f{ceil(isuf/2)}.ind_par1_plot(i),w_ind,all_measures_bias_sorted_ind(kk)),symbol_vect{isuf},'Color',f{ceil(isuf/2)}.color_mat(i,:),'MarkerFaceColor',f{ceil(isuf/2)}.face_color_mat(i,:),'MarkerSize',4);
                end
            end
        end
        myyscale_symlog;

        ind_veryneg=find(all_measures_bias_sorted<-1,1,'last')+.5;
        p_veryneg=patch([min(xlim) ind_veryneg ind_veryneg min(xlim)], [max(ylim) max(ylim) min(ylim) min(ylim)],dark_gray);
        set(p_veryneg,'EdgeColor',get(p_veryneg,'FaceColor'));
        uistack(p_veryneg,'bottom');
        ind_neg=find(all_measures_bias_sorted<-.1,1,'last')+.5;
        p_neg=patch([ind_veryneg ind_neg ind_neg ind_veryneg], [max(ylim) max(ylim) min(ylim) min(ylim)],light_gray);
        set(p_neg,'EdgeColor',get(p_veryneg,'FaceColor'));
        uistack(p_neg,'bottom');

        ind_verypos=find(all_measures_bias_sorted>1,1)-.5;
        p_verypos=patch([max(xlim) ind_verypos ind_verypos max(xlim)], [max(ylim) max(ylim) min(ylim) min(ylim)],dark_gray);
        set(p_verypos,'EdgeColor',get(p_verypos,'FaceColor'));
        uistack(p_verypos,'bottom');
        ind_pos=find(all_measures_bias_sorted>.1,1)-.5;
        p_pos=patch([ind_verypos ind_pos ind_pos ind_verypos], [max(ylim) max(ylim) min(ylim) min(ylim)],light_gray);
        set(p_pos,'EdgeColor',get(p_verypos,'FaceColor'));
        uistack(p_pos,'bottom');

        hold on;
        plot([min(xlim) max(xlim)],zeros(1,2),'k','LineWidth',.5);
        set(gca,'XTick',[1:length(field_names)]);
        set(gca,'XTickLabels',strrep(field_names_long_wc_ms(all_measures_bias_sorted_ind),'_','\_'),'FontSize',FontSizeThis); % works well with 99 measures
        xtickangle(gca,45);
        ylabel('$\mathcal{B}_S$','Interpreter','latex','Rotation',0);
        set(gcf,'Position',[5         267        1914         702]);
        output_struct.bias_pos(w_ind,:)=get(gca,'Position');
        figure_name=['all_measures_bias_mean' '_w' num2str(w_ind) '_symlog_longn' par.png_tail '_' names_string '.png'];
        hgexport(gcf,figure_name,mystyle_highres,'Format','png');



        figure();
        set(gcf,'Color',[1 1 1]);
        [all_measures_absbias_sorted all_measures_absbias_sorted_ind]=sort(squeeze(all_measures_absbias_Mean(w_ind,:)));
        bar(all_measures_absbias_sorted);
        hold on;
        for isuf=1:length(suf_vect)
            for kk=1:length(field_names)
                for i=1:(f{ceil(isuf/2)}.n_par1_plot)
                    plot(kk+bias_vect{isuf}(i),all_measures_absbias{isuf}(f{ceil(isuf/2)}.ind_par1_plot(i),w_ind,all_measures_absbias_sorted_ind(kk)),symbol_vect{isuf},'Color',f{ceil(isuf/2)}.color_mat(i,:),'MarkerFaceColor',f{ceil(isuf/2)}.face_color_mat(i,:),'MarkerSize',4);
                end
            end
        end
        set(gca,'YScale','log');

        ind_verypos=find(all_measures_absbias_sorted>1,1)-.5;
        p_verypos=patch([max(xlim) ind_verypos ind_verypos max(xlim)], [max(ylim) max(ylim) min(ylim) min(ylim)],dark_gray);
        set(p_verypos,'EdgeColor',get(p_verypos,'FaceColor'));
        uistack(p_verypos,'bottom');
        ind_pos=find(all_measures_absbias_sorted>.1,1)-.5;
        p_pos=patch([ind_verypos ind_pos ind_pos ind_verypos], [max(ylim) max(ylim) min(ylim) min(ylim)],light_gray);
        set(p_pos,'EdgeColor',get(p_verypos,'FaceColor'));
        uistack(p_pos,'bottom');

        set(gca,'XTick',[1:length(field_names)]);
        set(gca,'XTickLabels',strrep(field_names_wc_ms(all_measures_absbias_sorted_ind),'_','\_'),'FontSize',FontSizeThis); % works well with 99 measures
        xtickangle(gca,45);
        title(['abs(bias) at ' num2str(win_vect(w_ind))  par.stringa_title],'FontWeight','normal','Interpreter','none');
        set(gcf,'Position',[5         267        1914         702]);
        figure_name=['all_measures_absbias_mean' '_w' num2str(w_ind) par.png_tail '_' names_string '.png'];
        hgexport(gcf,figure_name,mystyle,'Format','png');

    end

    figure();
    set(gcf,'Color',[1 1 1]);
    [all_measures_cv_sorted all_measures_cv_sorted_ind]=sort(squeeze(all_measures_cv_Mean(w_ind,:)));
    bar(all_measures_cv_sorted);
    hold on;
    for isuf=1:length(suf_vect)
        for kk=1:length(field_names)
            for i=1:(f{ceil(isuf/2)}.n_par1_plot)
                plot(kk+bias_vect{isuf}(i),all_measures_cv{isuf}(f{ceil(isuf/2)}.ind_par1_plot(i),w_ind,all_measures_cv_sorted_ind(kk)),symbol_vect{isuf},'Color',f{ceil(isuf/2)}.color_mat(i,:),'MarkerFaceColor',f{ceil(isuf/2)}.face_color_mat(i,:),'MarkerSize',4);
            end
        end
    end
    set(gca,'YScale','log');

    ind_verypos=find(all_measures_cv_sorted>1,1)-.5;
    if ~isempty(ind_verypos)
        p_verypos=patch([max(xlim) ind_verypos ind_verypos max(xlim)], [max(ylim) max(ylim) min(ylim) min(ylim)],dark_gray);
        set(p_verypos,'EdgeColor',get(p_verypos,'FaceColor'));
        uistack(p_verypos,'bottom');
    else
        ind_verypos=max(xlim);
    end
    ind_pos=find(all_measures_cv_sorted>.1,1)-.5;
    p_pos=patch([ind_verypos ind_pos ind_pos ind_verypos], [max(ylim) max(ylim) min(ylim) min(ylim)],light_gray);
    set(p_pos,'EdgeColor',get(p_verypos,'FaceColor'));
    uistack(p_pos,'bottom');

    set(gca,'XTick',[1:length(field_names)]);
    set(gca,'XTickLabels',strrep(field_names_wc_ms(all_measures_cv_sorted_ind),'_','\_'),'FontSize',FontSizeThis); % works well with 99 measures
    xtickangle(gca,45);
    title(['cv at ' num2str(win_vect(w_ind))  par.stringa_title],'FontWeight','normal','Interpreter','none');
    set(gcf,'Position',[5         267        1914         702]);
    figure_name=['all_measures_cv_mean' '_w' num2str(w_ind) par.png_tail '_' names_string '.png'];
    hgexport(gcf,figure_name,mystyle,'Format','png');




    figure();
    set(gcf,'Color',[1 1 1]);
    [all_measures_abscv_sorted all_measures_abscv_sorted_ind]=sort(squeeze(all_measures_abscv_Mean(w_ind,:)));
    bar(all_measures_abscv_sorted);
    hold on;
    for isuf=1:length(suf_vect)
        for kk=1:length(field_names)
            for i=1:(f{ceil(isuf/2)}.n_par1_plot)
                plot(kk+bias_vect{isuf}(i),all_measures_abscv{isuf}(f{ceil(isuf/2)}.ind_par1_plot(i),w_ind,all_measures_abscv_sorted_ind(kk)),symbol_vect{isuf},'Color',f{ceil(isuf/2)}.color_mat(i,:),'MarkerFaceColor',f{ceil(isuf/2)}.face_color_mat(i,:),'MarkerSize',4);
            end
        end
    end
    set(gca,'YScale','log');

    ind_verypos=find(all_measures_abscv_sorted>1,1)-.5;
    if ~isempty(ind_verypos)
        p_verypos=patch([max(xlim) ind_verypos ind_verypos max(xlim)], [max(ylim) max(ylim) min(ylim) min(ylim)],dark_gray);
        set(p_verypos,'EdgeColor',get(p_verypos,'FaceColor'));
        uistack(p_verypos,'bottom');
    else
        ind_verypos=max(xlim);
    end
    ind_pos=find(all_measures_abscv_sorted>.1,1)-.5;
    p_pos=patch([ind_verypos ind_pos ind_pos ind_verypos], [max(ylim) max(ylim) min(ylim) min(ylim)],light_gray);
    set(p_pos,'EdgeColor',get(p_verypos,'FaceColor'));
    uistack(p_pos,'bottom');

    set(gca,'XTick',[1:length(field_names)]);
    set(gca,'XTickLabels',strrep(field_names_wc_ms(all_measures_abscv_sorted_ind),'_','\_'),'FontSize',FontSizeThis); % works well with 99 measures
    xtickangle(gca,45);
    title(['|cv| at ' num2str(win_vect(w_ind))  par.stringa_title],'FontWeight','normal','Interpreter','none');
    ylabel('$\mathcal{V}_S$','Interpreter','latex','Rotation',0);
    set(gcf,'Position',[5         267        1914         702]);
    figure_name=['all_measures_abscv_mean' '_w' num2str(w_ind) par.png_tail '_' names_string '.png'];
    hgexport(gcf,figure_name,mystyle,'Format','png');




    figure();
    set(gcf,'Color',[1 1 1]);
    [all_measures_abscv_sorted all_measures_abscv_sorted_ind]=sort(squeeze(all_measures_abscv_Mean(w_ind,:)));
    bh=bar(all_measures_abscv_sorted);
    set(bh,'FaceColor',[240 128 128]./255); % light coral https://www.rapidtables.com/web/color/RGB_Color.html
    hold on;
    for isuf=1:length(suf_vect)
        for kk=1:length(field_names)
            for i=1:(f{ceil(isuf/2)}.n_par1_plot)
                plot(kk+bias_vect{isuf}(i),all_measures_abscv{isuf}(f{ceil(isuf/2)}.ind_par1_plot(i),w_ind,all_measures_abscv_sorted_ind(kk)),symbol_vect{isuf},'Color',f{ceil(isuf/2)}.color_mat(i,:),'MarkerFaceColor',f{ceil(isuf/2)}.face_color_mat(i,:),'MarkerSize',4);
            end
        end
    end
    set(gca,'YScale','log');

    ylim_vect=ylim;
    ind_verypos=find(all_measures_abscv_sorted>1,1)-.5;
    if ~isempty(ind_verypos)
        p_verypos=patch([max(xlim) ind_verypos ind_verypos max(xlim)], [max(ylim_vect) max(ylim_vect) min(ylim_vect) min(ylim_vect)],dark_gray);
        set(p_verypos,'EdgeColor',get(p_verypos,'FaceColor'));
        uistack(p_verypos,'bottom');
    else
        ind_verypos=max(xlim);
    end
    ind_pos=find(all_measures_abscv_sorted>.1,1)-.5;
    p_pos=patch([ind_verypos ind_pos ind_pos ind_verypos], [max(ylim_vect) max(ylim_vect) min(ylim_vect) min(ylim_vect)],light_gray);
    set(p_pos,'EdgeColor',get(p_verypos,'FaceColor'));
    uistack(p_pos,'bottom');

    set(gca,'XTick',[1:length(field_names)]);
    set(gca,'XTickLabels',strrep(field_names_long_wc_ms(all_measures_abscv_sorted_ind),'_','\_'),'FontSize',FontSizeThis); % works well with 99 measures
    xtickangle(gca,45);
    ylabel('$\mathcal{V}_S$','Interpreter','latex','Rotation',0);
    set(gcf,'Position',[5         267        1914         702]);
    set(gca,'YLim',ylim_vect);
    figure_name=['all_measures_abscv_mean' '_w' num2str(w_ind) '_longn' par.png_tail '_' names_string '.png'];
    hgexport(gcf,figure_name,mystyle_highres,'Format','png');




    figure();
    set(gcf,'Color',[1 1 1]);
    [all_measures_nan_percent_sorted all_measures_nan_percent_sorted_ind]=sort(squeeze(all_measures_nan_percent_Mean(w_ind,:)));
    bar(all_measures_nan_percent_sorted);
    hold on;
    for isuf=1:length(suf_vect)
        for kk=1:length(field_names)
            for i=1:(f{ceil(isuf/2)}.n_par1_plot)
                plot(kk+bias_vect{isuf}(i),all_measures_nan_percent{isuf}(f{ceil(isuf/2)}.ind_par1_plot(i),w_ind,all_measures_nan_percent_sorted_ind(kk)),symbol_vect{isuf},'Color',f{ceil(isuf/2)}.color_mat(i,:),'MarkerFaceColor',f{ceil(isuf/2)}.face_color_mat(i,:),'MarkerSize',4);
            end
        end
    end
    set(gca,'YScale','log');
    set(gca,'XTick',[1:length(field_names)]);
    set(gca,'XTickLabels',strrep(field_names_wc_ms(all_measures_nan_percent_sorted_ind),'_','\_'),'FontSize',FontSizeThis); % works well with 99 measures
    xtickangle(gca,45);
    title(['NaN % at ' num2str(win_vect(w_ind))  par.stringa_title],'FontWeight','normal','Interpreter','none');
    set(gcf,'Position',[5         267        1914         702]);
    figure_name=['all_measures_nan_percent_mean' '_w' num2str(w_ind) par.png_tail '_' names_string '.png'];
    hgexport(gcf,figure_name,mystyle,'Format','png');

    if w_ind~=length(win_vect)
        figure;
        set(gcf,'Color',[1 1 1]);
        set(gca,'XScale','log');
        set(gca,'YScale','log');
        for kk=1:length(field_names)
            plot(all_measures_bias_Mean(w_ind,kk),all_measures_cv_Mean(w_ind,kk),'wo'); % just so that the axis are set properly
            hold on;
            text(all_measures_bias_Mean(w_ind,kk),all_measures_cv_Mean(w_ind,kk),field_names{kk},'HorizontalAlignment','center','VerticalAlignment','middle','Interpreter','none','FontSize',12,'Color',field_colors{kk});
        end
        set(gca,'XScale','log');
        set(gca,'YScale','log');
        xlabel('bias');
        ylabel('precision');
        title(['bias and cv at ' num2str(win_vect(w_ind))  par.stringa_title],'FontWeight','normal','Interpreter','none');
        if PLOT.print
            figure_name=['all_measures_bias_cv_mean' '_w' num2str(w_ind)];
            export_fig(gcf,[figure_name par.png_tail '_' names_string '.png']);
        end


        figure;
        set(gcf,'Color',[1 1 1]);
        for kk=1:length(field_names)
            plot(all_measures_bias_Mean(w_ind,kk),all_measures_abscv_Mean(w_ind,kk),'wo'); % just so that the axis are set properly
            hold on;
            text(all_measures_bias_Mean(w_ind,kk),all_measures_abscv_Mean(w_ind,kk),field_names{kk},'HorizontalAlignment','center','VerticalAlignment','middle','Interpreter','none','FontSize',12,'Color',field_colors{kk});
        end
        xlim_vect=minmax(all_measures_bias_Mean(w_ind,:));
        ylim_vect=minmax(all_measures_abscv_Mean(w_ind,:));
        % xlim_vect=[xlim_vect(1)*1.2589 xlim_vect(2)*1.2589]; % 10^0.1 = 1.2589 % bias have both neg and pos values
        xlim_vect=[xlim_vect(1)*1.9953 xlim_vect(2)*1.9953]; % 10^0.3 = 1.9953 % bias have both neg and pos values
        ylim_vect=[ylim_vect(1)*0.7943 ylim_vect(2)*1.2589]; % 10^-0.1 = 0.7943 % variability has only pos values
        %         xlim_vect=[xlim_vect(1)*1.5849 xlim_vect(2)*1.5849]; % 10^0.2 = 1.5849
        %         ylim_vect=[ylim_vect(1)*0.6310 ylim_vect(2)*1.5849]; % 10^-0.2 = 0.6310
        plot(xlim_vect,ylim_vect,'wo'); % just so that the axis are set properly

        set(gca,'YScale','log');
        myxscale_symlog;
        xlabel('$\mathcal{B}_S$','Interpreter','latex','Rotation',0);
        ylabel('$\mathcal{V}_S$','Interpreter','latex','Rotation',0);
        title(['bias and abs(cv) at ' num2str(win_vect(w_ind))  par.stringa_title],'FontWeight','normal','Interpreter','none','FontSize',16);
        if PLOT.print
            figure_name=['all_measures_bias_abscv_mean' '_w' num2str(w_ind)];
            export_fig(gcf,[figure_name par.png_tail '_' names_string '.png']);
        end

        figure;
        set(gcf,'Color',[1 1 1]);
        for kk=1:length(field_names)
            scatter(all_measures_bias_Mean(w_ind,kk),all_measures_abscv_Mean(w_ind,kk),'wo','MarkerEdgeAlpha',0,'MarkerFaceAlpha',0); % just so that the axis are set properly
            hold on;
            text(all_measures_bias_Mean(w_ind,kk),all_measures_abscv_Mean(w_ind,kk),field_names_latex{kk},'HorizontalAlignment','center','VerticalAlignment','middle','Interpreter','latex','FontSize',12,'Color',field_colors{kk});
        end
        xlim_vect=minmax(all_measures_bias_Mean(w_ind,:));
        ylim_vect=minmax(all_measures_abscv_Mean(w_ind,:));
        % xlim_vect=[xlim_vect(1)*1.2589 xlim_vect(2)*1.2589]; % 10^0.1 = 1.2589 % bias have both neg and pos values
        if startsWith(stringa_dir_batch,'train_win_range')
            % xlim_vect=[xlim_vect(1)*1.9953 xlim_vect(2)*1.9953]; % 10^0.3 = 1.9953 % bias have both neg and pos values
            xlim_vect=[xlim_vect(1)*2.5119 xlim_vect(2)*2.5119]; % 10^0.4 = 2.5119 % bias have both neg and pos values
        elseif startsWith(stringa_dir_batch,'train_nneu_range')
            % xlim_vect=[xlim_vect(1)*3.1623 xlim_vect(2)*3.1623]; % 10^0.5 = 3.1623 % bias have both neg and pos values - this is worse than 10^0.4 , it's not monotonic for some reason
            % xlim_vect=[xlim_vect(1)*5.0119 xlim_vect(2)*5.0119]; % 10^0.7 = 5.0119 % bias have both neg and pos values - not enough for nneu
            xlim_vect=[xlim_vect(1)*6.3096 xlim_vect(2)*6.3096]; % 10^0.8 = 6.3096 % bias have both neg and pos values - best for nneu
        end
        ylim_vect=[ylim_vect(1)*0.7943 ylim_vect(2)*1.2589]; % 10^-0.1 = 0.7943 % variability has only pos values
        %         xlim_vect=[xlim_vect(1)*1.5849 xlim_vect(2)*1.5849]; % 10^0.2 = 1.5849
        %         ylim_vect=[ylim_vect(1)*0.6310 ylim_vect(2)*1.5849]; % 10^-0.2 = 0.6310
        scatter(xlim_vect,ylim_vect,'wo','MarkerEdgeAlpha',0,'MarkerFaceAlpha',0); % just so that the axis are set properly

        set(gca,'YScale','log');
        myxscale_symlog;
        xlabel('$\mathcal{B}_S$','Interpreter','latex','Rotation',0);
        ylabel('$\mathcal{V}_S$','Interpreter','latex','Rotation',0);
        title(['bias and abs(cv) at ' num2str(win_vect(w_ind))  par.stringa_title],'FontWeight','normal','Interpreter','none','FontSize',20);
        if PLOT.print
            figure_name=['all_measures_bias_abscv_mean_latex' '_w' num2str(w_ind)];
            export_fig(gcf,[figure_name par.png_tail '_' names_string '.png'],'-m2');
        end



if startsWith(stringa_dir_batch,'train_win_range')
    not_shown={'modulus_m','modulus_mn','schreiber_c1','Lv_ISI','LCV_ISI','IR_ISI','SM_ISI','qqa','fooof_1p_f','PPC','cv2_ISI','MPC','fooof_1p_beta','cv_ISI'};
elseif startsWith(stringa_dir_batch,'train_nneu_range')
    not_shown={'modulus_m','emdn','schreiber_c1','Lv_ISI','QQA','SPIKY_ISI','fooof_1p_f','f_rate','fooof_1p_sigma','IR_ISI','SM_ISI','fooof_1p_offset','qq1','LvR_ISI'};
end
        figure;
        set(gcf,'Color',[1 1 1]);
        if (( startsWith(stringa_dir_batch,'train_win_range') && w_ind==3) || startsWith(stringa_dir_batch,'train_nneu_range'))
        set(gcf,'Position',[1           1        1920         961]); % full screen on flaptop            
        else
        set(gcf,'Position',[675         149        1176         813]); % better option, yields all XTick we need
        end
        for kk=1:length(field_names)
        if (startsWith(stringa_dir_batch,'train_win_range') && w_ind==2)
    if any(strcmp(field_names{kk},not_shown))
        continue
    end
        end
            scatter(all_measures_bias_Mean(w_ind,kk),all_measures_abscv_Mean(w_ind,kk),'wo','MarkerEdgeAlpha',0,'MarkerFaceAlpha',0); % just so that the axis are set properly
            hold on;
    if any(strcmp(field_names{kk},not_shown))
        continue
    end
            text(all_measures_bias_Mean(w_ind,kk),all_measures_abscv_Mean(w_ind,kk),field_names_latex{kk},'HorizontalAlignment','center','VerticalAlignment','middle','Interpreter','latex','FontSize',12,'Color',field_colors{kk});
        end
        xlim_vect=minmax(all_measures_bias_Mean(w_ind,:));
        ylim_vect=minmax(all_measures_abscv_Mean(w_ind,:));
        % xlim_vect=[xlim_vect(1)*1.2589 xlim_vect(2)*1.2589]; % 10^0.1 = 1.2589 % bias have both neg and pos values
        if (startsWith(stringa_dir_batch,'train_win_range') && w_ind==2)
            % xlim_vect=[xlim_vect(1)*1.9953 xlim_vect(2)*1.9953]; % 10^0.3 = 1.9953 % bias have both neg and pos values
            xlim_vect=[xlim_vect(1)*2.5119 xlim_vect(2)*2.5119]; % 10^0.4 = 2.5119 % bias have both neg and pos values
        elseif startsWith(stringa_dir_batch,'train_win_range')
            % xlim_vect=[xlim_vect(1)*1.9953 xlim_vect(2)*1.9953]; % 10^0.3 = 1.9953 % bias have both neg and pos values
            xlim_vect=[xlim_vect(1)*2.5119 xlim_vect(2)*2.5119]; % 10^0.4 = 2.5119 % bias have both neg and pos values
        elseif startsWith(stringa_dir_batch,'train_nneu_range')
            % xlim_vect=[xlim_vect(1)*3.1623 xlim_vect(2)*3.1623]; % 10^0.5 = 3.1623 % bias have both neg and pos values - this is worse than 10^0.4 , it's not monotonic for some reason
            % xlim_vect=[xlim_vect(1)*5.0119 xlim_vect(2)*5.0119]; % 10^0.7 = 5.0119 % bias have both neg and pos values - not enough for nneu
            xlim_vect=[xlim_vect(1)*6.3096 xlim_vect(2)*6.3096]; % 10^0.8 = 6.3096 % bias have both neg and pos values - best for nneu
        end
        if (startsWith(stringa_dir_batch,'train_win_range') && w_ind==2 & 0) % disabled
        ylim_vect=[ylim_vect(1)*0.6310 ylim_vect(2)*1.5849]; % 10^-0.2 = 0.6310 % variability has only pos values
        else
        ylim_vect=[ylim_vect(1)*0.7943 ylim_vect(2)*1.2589]; % 10^-0.1 = 0.7943 % variability has only pos values
        end
        %         xlim_vect=[xlim_vect(1)*1.5849 xlim_vect(2)*1.5849]; % 10^0.2 = 1.5849
        %         ylim_vect=[ylim_vect(1)*0.6310 ylim_vect(2)*1.5849]; % 10^-0.2 = 0.6310
        scatter(xlim_vect,ylim_vect,'wo','MarkerEdgeAlpha',0,'MarkerFaceAlpha',0); % just so that the axis are set properly

        set(gca,'YScale','log');
        myxscale_symlog;
        xlabel('$\mathcal{B}_S$','Interpreter','latex','Rotation',0);
        ylabel('$\mathcal{V}_S$','Interpreter','latex','Rotation',0);
        set(gcf,'Position',[675   549   570   413]);        
if isfield(par,'bias_abscv_pos')
    set(gca,'Position',par.bias_abscv_pos);
end
        output_struct.bias_abscv_pos(w_ind,:)=get(gca,'Position');
        ylim_this=get(gca,'YLim');
        plot(zeros(1,2),ylim_this,'k:','LineWidth',0.5);
        set(gca,'YLim',ylim_this); % seems to be necessary for some reason
        if PLOT.print
            figure_name=['all_measures_bias_abscv_mean_latex_sel' '_w' num2str(w_ind)];
            hgexport(gcf,[figure_name par.png_tail '_' names_string '.png'],mystyle_highres,'Format','png'); % better to use hgexport since we need to assembly panels
            savefig(gcf,[figure_name par.png_tail '_' names_string '.fig'],'compact');
        end

    end
    % close all;
    pause(1);
end




% plotting grandmean



figure();
set(gcf,'Color',[1 1 1]);
[all_measures_bias_sorted all_measures_bias_sorted_ind]=sort(squeeze(all_measures_bias_grandmean));
bar(all_measures_bias_sorted);
hold on;
for w_ind=1:(length(win_vect)-1)
    for isuf=1:length(suf_vect)
        for kk=1:length(field_names)
            for i=1:(f{ceil(isuf/2)}.n_par1_plot)
                sh=plot(kk+bias_vect_b_grand{w_ind,isuf}(i),all_measures_bias{isuf}(f{ceil(isuf/2)}.ind_par1_plot(i),w_ind,all_measures_bias_sorted_ind(kk)),symbol_vect{isuf},'Color',f{ceil(isuf/2)}.color_mat(i,:),'MarkerFaceColor',f{ceil(isuf/2)}.face_color_mat(i,:),'MarkerSize',4);
            end
        end
    end
end
set(gca,'XTick',[1:length(field_names)]);
set(gca,'XTickLabels',strrep(field_names_wc_ms(all_measures_bias_sorted_ind),'_','\_'),'FontSize',FontSizeThis); % works well with 99 measures
xtickangle(gca,45);
set(gcf,'Position',[5         267        1914         702]);
figure_name=['all_measures_bias_mean' par.png_tail '_' names_string '.png'];
hgexport(gcf,figure_name,mystyle,'Format','png');

figure();
set(gcf,'Color',[1 1 1]);
[all_measures_bias_sorted all_measures_bias_sorted_ind]=sort(squeeze(all_measures_bias_grandmean));
bar(all_measures_bias_sorted);
hold on;
for w_ind=1:(length(win_vect)-1)
    for isuf=1:length(suf_vect)
        for kk=1:length(field_names)
            for i=1:(f{ceil(isuf/2)}.n_par1_plot)
                plot(kk+bias_vect_b_grand{w_ind,isuf}(i),all_measures_bias{isuf}(f{ceil(isuf/2)}.ind_par1_plot(i),w_ind,all_measures_bias_sorted_ind(kk)),symbol_vect{isuf},'Color',f{ceil(isuf/2)}.color_mat(i,:),'MarkerFaceColor',f{ceil(isuf/2)}.face_color_mat(i,:),'MarkerSize',4);
            end
        end
    end
end
myyscale_symlog;

ind_veryneg=find(all_measures_bias_sorted<-1,1,'last')+.5;
p_veryneg=patch([min(xlim) ind_veryneg ind_veryneg min(xlim)], [max(ylim) max(ylim) min(ylim) min(ylim)],dark_gray);
set(p_veryneg,'EdgeColor',get(p_veryneg,'FaceColor'));
uistack(p_veryneg,'bottom');
ind_neg=find(all_measures_bias_sorted<-.1,1,'last')+.5;
p_neg=patch([ind_veryneg ind_neg ind_neg ind_veryneg], [max(ylim) max(ylim) min(ylim) min(ylim)],light_gray);
set(p_neg,'EdgeColor',get(p_veryneg,'FaceColor'));
uistack(p_neg,'bottom');

ind_verypos=find(all_measures_bias_sorted>1,1)-.5;
p_verypos=patch([max(xlim) ind_verypos ind_verypos max(xlim)], [max(ylim) max(ylim) min(ylim) min(ylim)],dark_gray);
set(p_verypos,'EdgeColor',get(p_verypos,'FaceColor'));
uistack(p_verypos,'bottom');
ind_pos=find(all_measures_bias_sorted>.1,1)-.5;
p_pos=patch([ind_verypos ind_pos ind_pos ind_verypos], [max(ylim) max(ylim) min(ylim) min(ylim)],light_gray);
set(p_pos,'EdgeColor',get(p_verypos,'FaceColor'));
uistack(p_pos,'bottom');

hold on;
plot([min(xlim) max(xlim)],zeros(1,2),'k','LineWidth',.5);
set(gca,'XTick',[1:length(field_names)]);
set(gca,'XTickLabels',strrep(field_names_wc_ms(all_measures_bias_sorted_ind),'_','\_'),'FontSize',FontSizeThis); % works well with 99 measures
xtickangle(gca,45);
ylabel('$\mathcal{B}_S$','Interpreter','latex','Rotation',0);
set(gcf,'Position',[5         267        1914         702]);
figure_name=['all_measures_bias_mean' '_symlog' par.png_tail '_' names_string '.png'];
hgexport(gcf,figure_name,mystyle,'Format','png');




figure();
set(gcf,'Color',[1 1 1]);
[all_measures_bias_sorted all_measures_bias_sorted_ind]=sort(squeeze(all_measures_bias_grandmean));
bh=bar(all_measures_bias_sorted);
set(bh,'FaceColor',[240 128 128]./255); % light coral https://www.rapidtables.com/web/color/RGB_Color.html
hold on;
for w_ind=1:(length(win_vect)-1)
    for isuf=1:length(suf_vect)
        for kk=1:length(field_names)
            for i=1:(f{ceil(isuf/2)}.n_par1_plot)
                plot(kk+bias_vect_b_grand{w_ind,isuf}(i),all_measures_bias{isuf}(f{ceil(isuf/2)}.ind_par1_plot(i),w_ind,all_measures_bias_sorted_ind(kk)),symbol_vect{isuf},'Color',f{ceil(isuf/2)}.color_mat(i,:),'MarkerFaceColor',f{ceil(isuf/2)}.face_color_mat(i,:),'MarkerSize',4);
            end
        end
    end
end
myyscale_symlog;

ind_veryneg=find(all_measures_bias_sorted<-1,1,'last')+.5;
p_veryneg=patch([min(xlim) ind_veryneg ind_veryneg min(xlim)], [max(ylim) max(ylim) min(ylim) min(ylim)],dark_gray);
set(p_veryneg,'EdgeColor',get(p_veryneg,'FaceColor'));
uistack(p_veryneg,'bottom');
ind_neg=find(all_measures_bias_sorted<-.1,1,'last')+.5;
p_neg=patch([ind_veryneg ind_neg ind_neg ind_veryneg], [max(ylim) max(ylim) min(ylim) min(ylim)],light_gray);
set(p_neg,'EdgeColor',get(p_veryneg,'FaceColor'));
uistack(p_neg,'bottom');

ind_verypos=find(all_measures_bias_sorted>1,1)-.5;
p_verypos=patch([max(xlim) ind_verypos ind_verypos max(xlim)], [max(ylim) max(ylim) min(ylim) min(ylim)],dark_gray);
set(p_verypos,'EdgeColor',get(p_verypos,'FaceColor'));
uistack(p_verypos,'bottom');
ind_pos=find(all_measures_bias_sorted>.1,1)-.5;
p_pos=patch([ind_verypos ind_pos ind_pos ind_verypos], [max(ylim) max(ylim) min(ylim) min(ylim)],light_gray);
set(p_pos,'EdgeColor',get(p_verypos,'FaceColor'));
uistack(p_pos,'bottom');

hold on;
plot([min(xlim) max(xlim)],zeros(1,2),'k','LineWidth',.5);
set(gca,'XTick',[1:length(field_names)]);
set(gca,'XTickLabels',strrep(field_names_long_wc_ms(all_measures_bias_sorted_ind),'_','\_'),'FontSize',FontSizeThis); % works well with 99 measures
xtickangle(gca,45);
ax=gca;
yrule=ax.YAxis; % this allows to set the font size independently from the x axis
yrule.FontSize = FontSizeThisCb;
ylabel('$\mathcal{B}_S$','Interpreter','latex','Rotation',0,'FontSize',FontSizeThisCb);
set(gcf,'Position',[5         267        1914         702]);
figure_name=['all_measures_bias_mean' '_symlog_longn' par.png_tail '_' names_string '.png'];
hgexport(gcf,figure_name,mystyle_highres,'Format','png');


figure();
set(gcf,'Color',[1 1 1]);
set(gcf,'Position',[5           1        1914         961]); % full height on neurona4 (the same as flaptop)
bh=bar(all_measures_bias_sorted);
set(bh,'FaceColor',[240 128 128]./255); % light coral https://www.rapidtables.com/web/color/RGB_Color.html
hold on;
for w_ind=1:(length(win_vect)-1)
    for isuf=1:length(suf_vect)
        for kk=1:length(field_names)
            for i=1:(f{ceil(isuf/2)}.n_par1_plot)
                plot(kk+bias_vect_b_grand{w_ind,isuf}(i),all_measures_bias{isuf}(f{ceil(isuf/2)}.ind_par1_plot(i),w_ind,all_measures_bias_sorted_ind(kk)),symbol_vect{isuf},'Color',f{ceil(isuf/2)}.color_mat(i,:),'MarkerFaceColor',f{ceil(isuf/2)}.face_color_mat(i,:),'MarkerSize',4);
            end
        end
    end
end
myyscale_symlog;

ind_veryneg=find(all_measures_bias_sorted<-1,1,'last')+.5;
p_veryneg=patch([min(xlim) ind_veryneg ind_veryneg min(xlim)], [max(ylim) max(ylim) min(ylim) min(ylim)],dark_gray);
set(p_veryneg,'EdgeColor',get(p_veryneg,'FaceColor'));
uistack(p_veryneg,'bottom');
ind_neg=find(all_measures_bias_sorted<-.1,1,'last')+.5;
p_neg=patch([ind_veryneg ind_neg ind_neg ind_veryneg], [max(ylim) max(ylim) min(ylim) min(ylim)],light_gray);
set(p_neg,'EdgeColor',get(p_veryneg,'FaceColor'));
uistack(p_neg,'bottom');

ind_verypos=find(all_measures_bias_sorted>1,1)-.5;
p_verypos=patch([max(xlim) ind_verypos ind_verypos max(xlim)], [max(ylim) max(ylim) min(ylim) min(ylim)],dark_gray);
set(p_verypos,'EdgeColor',get(p_verypos,'FaceColor'));
uistack(p_verypos,'bottom');
ind_pos=find(all_measures_bias_sorted>.1,1)-.5;
p_pos=patch([ind_verypos ind_pos ind_pos ind_verypos], [max(ylim) max(ylim) min(ylim) min(ylim)],light_gray);
set(p_pos,'EdgeColor',get(p_verypos,'FaceColor'));
uistack(p_pos,'bottom');

hold on;
plot([min(xlim) max(xlim)],zeros(1,2),'k','LineWidth',.5);
set(gca,'XTick',[1:length(field_names)]);
set(gca,'XTickLabels',strrep(field_names_long_wc_ms(all_measures_bias_sorted_ind),'_','\_'),'FontSize',FontSizeThis); % works well with 99 measures
xtickangle(gca,45);
ax=gca;
yrule=ax.YAxis; % this allows to set the font size independently from the x axis
yrule.FontSize = FontSizeThisCb;
ylabel('$\mathcal{B}_S$','Interpreter','latex','Rotation',0,'FontSize',FontSizeThisCb);
set(gcf,'Position',[5         267        1914         702*0.666666666666]);
if startsWith(stringa_dir_batch,'train_win_range')
yticklabel=get(gca,'YTickLabel');
yticklabel{7}='';
set(gca,'YTickLabel',yticklabel);
end
output_struct.bias_pos(w_ind+1,:)=get(gca,'Position');
figure_name=['all_measures_bias_mean' '_symlog_longn_v2' par.png_tail '_' names_string '.png'];
hgexport(gcf,figure_name,mystyle_highres,'Format','png');
savefig(gcf,strrep(figure_name,'.png','.fig'),'compact');


figure();
set(gcf,'Color',[1 1 1]);
[all_measures_absbias_sorted all_measures_absbias_sorted_ind]=sort(squeeze(all_measures_absbias_grandmean));
bar(all_measures_absbias_sorted);
hold on;
for w_ind=1:(length(win_vect)-1)
    for isuf=1:length(suf_vect)
        for kk=1:length(field_names)
            for i=1:(f{ceil(isuf/2)}.n_par1_plot)
                plot(kk+bias_vect_b_grand{w_ind,isuf}(i),all_measures_absbias{isuf}(f{ceil(isuf/2)}.ind_par1_plot(i),w_ind,all_measures_absbias_sorted_ind(kk)),symbol_vect{isuf},'Color',f{ceil(isuf/2)}.color_mat(i,:),'MarkerFaceColor',f{ceil(isuf/2)}.face_color_mat(i,:),'MarkerSize',4);
            end
        end
    end
end
set(gca,'YScale','log');

ind_verypos=find(all_measures_absbias_sorted>1,1)-.5;
p_verypos=patch([max(xlim) ind_verypos ind_verypos max(xlim)], [max(ylim) max(ylim) min(ylim) min(ylim)],dark_gray);
set(p_verypos,'EdgeColor',get(p_verypos,'FaceColor'));
uistack(p_verypos,'bottom');
ind_pos=find(all_measures_absbias_sorted>.1,1)-.5;
p_pos=patch([ind_verypos ind_pos ind_pos ind_verypos], [max(ylim) max(ylim) min(ylim) min(ylim)],light_gray);
set(p_pos,'EdgeColor',get(p_verypos,'FaceColor'));
uistack(p_pos,'bottom');

set(gca,'XTick',[1:length(field_names)]);
set(gca,'XTickLabels',strrep(field_names_wc_ms(all_measures_absbias_sorted_ind),'_','\_'),'FontSize',FontSizeThis); % works well with 99 measures
xtickangle(gca,45);
set(gcf,'Position',[5         267        1914         702]);
figure_name=['all_measures_absbias_mean' par.png_tail '_' names_string '.png'];
hgexport(gcf,figure_name,mystyle,'Format','png');


figure();
set(gcf,'Color',[1 1 1]);
[all_measures_cv_sorted all_measures_cv_sorted_ind]=sort(squeeze(all_measures_cv_grandmean));
bar(all_measures_cv_sorted);
hold on;
for w_ind=1:(length(win_vect))
    for isuf=1:length(suf_vect)
        for kk=1:length(field_names)
            for i=1:(f{ceil(isuf/2)}.n_par1_plot)
                plot(kk+bias_vect_v_grand{w_ind,isuf}(i),all_measures_cv{isuf}(f{ceil(isuf/2)}.ind_par1_plot(i),w_ind,all_measures_cv_sorted_ind(kk)),symbol_vect{isuf},'Color',f{ceil(isuf/2)}.color_mat(i,:),'MarkerFaceColor',f{ceil(isuf/2)}.face_color_mat(i,:),'MarkerSize',4);
            end
        end
    end
end
set(gca,'YScale','log');

ind_verypos=find(all_measures_cv_sorted>1,1)-.5;
if ~isempty(ind_verypos)
    p_verypos=patch([max(xlim) ind_verypos ind_verypos max(xlim)], [max(ylim) max(ylim) min(ylim) min(ylim)],dark_gray);
    set(p_verypos,'EdgeColor',get(p_verypos,'FaceColor'));
    uistack(p_verypos,'bottom');
else
    ind_verypos=max(xlim);
end
ind_pos=find(all_measures_cv_sorted>.1,1)-.5;
p_pos=patch([ind_verypos ind_pos ind_pos ind_verypos], [max(ylim) max(ylim) min(ylim) min(ylim)],light_gray);
set(p_pos,'EdgeColor',get(p_verypos,'FaceColor'));
uistack(p_pos,'bottom');

set(gca,'XTick',[1:length(field_names)]);
set(gca,'XTickLabels',strrep(field_names_wc_ms(all_measures_cv_sorted_ind),'_','\_'),'FontSize',FontSizeThis); % works well with 99 measures
xtickangle(gca,45);
set(gcf,'Position',[5         267        1914         702]);
figure_name=['all_measures_cv_mean' par.png_tail '_' names_string '.png'];
hgexport(gcf,figure_name,mystyle,'Format','png');




figure();
set(gcf,'Color',[1 1 1]);
[all_measures_abscv_sorted all_measures_abscv_sorted_ind]=sort(squeeze(all_measures_abscv_grandmean));
bar(all_measures_abscv_sorted);
hold on;
for w_ind=1:(length(win_vect))
    for isuf=1:length(suf_vect)
        for kk=1:length(field_names)
            for i=1:(f{ceil(isuf/2)}.n_par1_plot)
                plot(kk+bias_vect_v_grand{w_ind,isuf}(i),all_measures_abscv{isuf}(f{ceil(isuf/2)}.ind_par1_plot(i),w_ind,all_measures_abscv_sorted_ind(kk)),symbol_vect{isuf},'Color',f{ceil(isuf/2)}.color_mat(i,:),'MarkerFaceColor',f{ceil(isuf/2)}.face_color_mat(i,:),'MarkerSize',4);
            end
        end
    end
end
set(gca,'YScale','log');

ind_verypos=find(all_measures_abscv_sorted>1,1)-.5;
if ~isempty(ind_verypos)
    p_verypos=patch([max(xlim) ind_verypos ind_verypos max(xlim)], [max(ylim) max(ylim) min(ylim) min(ylim)],dark_gray);
    set(p_verypos,'EdgeColor',get(p_verypos,'FaceColor'));
    uistack(p_verypos,'bottom');
else
    ind_verypos=max(xlim);
end
ind_pos=find(all_measures_abscv_sorted>.1,1)-.5;
p_pos=patch([ind_verypos ind_pos ind_pos ind_verypos], [max(ylim) max(ylim) min(ylim) min(ylim)],light_gray);
set(p_pos,'EdgeColor',get(p_verypos,'FaceColor'));
uistack(p_pos,'bottom');

set(gca,'XTick',[1:length(field_names)]);
set(gca,'XTickLabels',strrep(field_names_wc_ms(all_measures_abscv_sorted_ind),'_','\_'),'FontSize',FontSizeThis); % works well with 99 measures
xtickangle(gca,45);
ylabel('$\mathcal{V}_S$','Interpreter','latex','Rotation',0);
set(gcf,'Position',[5         267        1914         702]);
figure_name=['all_measures_abscv_mean' par.png_tail '_' names_string '.png'];
hgexport(gcf,figure_name,mystyle,'Format','png');




figure();
set(gcf,'Color',[1 1 1]);
[all_measures_abscv_sorted all_measures_abscv_sorted_ind]=sort(squeeze(all_measures_abscv_grandmean));
bh=bar(all_measures_abscv_sorted);
set(bh,'FaceColor',[240 128 128]./255); % light coral https://www.rapidtables.com/web/color/RGB_Color.html
hold on;
for w_ind=1:(length(win_vect))
    for isuf=1:length(suf_vect)
        for kk=1:length(field_names)
            for i=1:(f{ceil(isuf/2)}.n_par1_plot)
                plot(kk+bias_vect_v_grand{w_ind,isuf}(i),all_measures_abscv{isuf}(f{ceil(isuf/2)}.ind_par1_plot(i),w_ind,all_measures_abscv_sorted_ind(kk)),symbol_vect{isuf},'Color',f{ceil(isuf/2)}.color_mat(i,:),'MarkerFaceColor',f{ceil(isuf/2)}.face_color_mat(i,:),'MarkerSize',4);
            end
        end
    end
end
set(gca,'YScale','log');

ylim_vect=ylim;
ind_verypos=find(all_measures_abscv_sorted>1,1)-.5;
if ~isempty(ind_verypos)
    p_verypos=patch([max(xlim) ind_verypos ind_verypos max(xlim)], [max(ylim_vect) max(ylim_vect) min(ylim_vect) min(ylim_vect)],dark_gray);
    set(p_verypos,'EdgeColor',get(p_verypos,'FaceColor'));
    uistack(p_verypos,'bottom');
else
    ind_verypos=max(xlim);
end
ind_pos=find(all_measures_abscv_sorted>.1,1)-.5;
p_pos=patch([ind_verypos ind_pos ind_pos ind_verypos], [max(ylim_vect) max(ylim_vect) min(ylim_vect) min(ylim_vect)],light_gray);
set(p_pos,'EdgeColor',get(p_verypos,'FaceColor'));
uistack(p_pos,'bottom');

set(gca,'XTick',[1:length(field_names)]);
set(gca,'XTickLabels',strrep(field_names_long_wc_ms(all_measures_abscv_sorted_ind),'_','\_'),'FontSize',FontSizeThis); % works well with 99 measures
xtickangle(gca,45);
ax=gca;
yrule=ax.YAxis; % this allows to set the font size independently from the x axis
yrule.FontSize = FontSizeThisCb;
ylabel('$\mathcal{V}_S$','Interpreter','latex','Rotation',0,'FontSize',FontSizeThisCb);
set(gcf,'Position',[5         267        1914         702]);
set(gca,'YLim',ylim_vect);
yl=get(gca,'YAxis');
ytickvalues_this=yl.TickValues;
yticklabels_this=yl.TickLabels;
yminortickvalues_this=yl.MinorTickValues;
figure_name=['all_measures_abscv_mean_longn' par.png_tail '_' names_string '.png'];
hgexport(gcf,figure_name,mystyle_highres,'Format','png');


figure();
set(gcf,'Color',[1 1 1]);
[all_measures_abscv_sorted all_measures_abscv_sorted_ind]=sort(squeeze(all_measures_abscv_grandmean));
bh=bar(all_measures_abscv_sorted);
set(bh,'FaceColor',[240 128 128]./255); % light coral https://www.rapidtables.com/web/color/RGB_Color.html
hold on;
for w_ind=1:(length(win_vect))
    for isuf=1:length(suf_vect)
        for kk=1:length(field_names)
            for i=1:(f{ceil(isuf/2)}.n_par1_plot)
                plot(kk+bias_vect_v_grand{w_ind,isuf}(i),all_measures_abscv{isuf}(f{ceil(isuf/2)}.ind_par1_plot(i),w_ind,all_measures_abscv_sorted_ind(kk)),symbol_vect{isuf},'Color',f{ceil(isuf/2)}.color_mat(i,:),'MarkerFaceColor',f{ceil(isuf/2)}.face_color_mat(i,:),'MarkerSize',4);
            end
        end
    end
end
set(gca,'YScale','log');

ylim_vect=ylim;
ind_verypos=find(all_measures_abscv_sorted>1,1)-.5;
if ~isempty(ind_verypos)
    p_verypos=patch([max(xlim) ind_verypos ind_verypos max(xlim)], [max(ylim_vect) max(ylim_vect) min(ylim_vect) min(ylim_vect)],dark_gray);
    set(p_verypos,'EdgeColor',get(p_verypos,'FaceColor'));
    uistack(p_verypos,'bottom');
else
    ind_verypos=max(xlim);
end
ind_pos=find(all_measures_abscv_sorted>.1,1)-.5;
p_pos=patch([ind_verypos ind_pos ind_pos ind_verypos], [max(ylim_vect) max(ylim_vect) min(ylim_vect) min(ylim_vect)],light_gray);
set(p_pos,'EdgeColor',get(p_verypos,'FaceColor'));
uistack(p_pos,'bottom');

set(gca,'XTick',[1:length(field_names)]);
set(gca,'XTickLabels',strrep(field_names_long_wc_ms(all_measures_abscv_sorted_ind),'_','\_'),'FontSize',FontSizeThis); % works well with 99 measures
xtickangle(gca,45);
ax=gca;
yrule=ax.YAxis; % this allows to set the font size independently from the x axis
yrule.FontSize = FontSizeThisCb;
ylabel('$\mathcal{V}_S$','Interpreter','latex','Rotation',0,'FontSize',FontSizeThisCb);
set(gcf,'Position',[5         267        1914         702*0.666666666666]);
set(gca,'YLim',ylim_vect);
yl=get(gca,'YAxis');
yl.TickValues=ytickvalues_this;
yl.TickLabels=yticklabels_this;
yl.MinorTickValues=yminortickvalues_this;
figure_name=['all_measures_abscv_mean_longn_v2' par.png_tail '_' names_string '.png'];
hgexport(gcf,figure_name,mystyle_highres,'Format','png');





figure();
set(gcf,'Color',[1 1 1]);
[all_measures_nan_percent_sorted all_measures_nan_percent_sorted_ind]=sort(squeeze(all_measures_nan_percent_grandmean));
bar(all_measures_nan_percent_sorted);
hold on;
for w_ind=1:(length(win_vect))
    for isuf=1:length(suf_vect)
        for kk=1:length(field_names)
            for i=1:(f{ceil(isuf/2)}.n_par1_plot)
                plot(kk+bias_vect_v_grand{w_ind,isuf}(i),all_measures_nan_percent{isuf}(f{ceil(isuf/2)}.ind_par1_plot(i),w_ind,all_measures_nan_percent_sorted_ind(kk)),symbol_vect{isuf},'Color',f{ceil(isuf/2)}.color_mat(i,:),'MarkerFaceColor',f{ceil(isuf/2)}.face_color_mat(i,:),'MarkerSize',4);
            end
        end
    end
end
set(gca,'YScale','log');
set(gca,'XTick',[1:length(field_names)]);
set(gca,'XTickLabels',strrep(field_names_wc_ms(all_measures_nan_percent_sorted_ind),'_','\_'),'FontSize',FontSizeThis); % works well with 99 measures
xtickangle(gca,45);
set(gcf,'Position',[5         267        1914         702]);
figure_name=['all_measures_nan_percent_mean' par.png_tail '_' names_string '.png'];
hgexport(gcf,figure_name,mystyle,'Format','png');

figure;
set(gcf,'Color',[1 1 1]);
set(gca,'XScale','log');
set(gca,'YScale','log');
for kk=1:length(field_names)
    plot(all_measures_bias_grandmean(kk),all_measures_cv_grandmean(kk),'wo'); % just so that the axis are set properly
    hold on;
    text(all_measures_bias_grandmean(kk),all_measures_cv_grandmean(kk),field_names{kk},'HorizontalAlignment','center','VerticalAlignment','middle','Interpreter','none','FontSize',12,'Color',field_colors{kk});
end
set(gca,'XScale','log');
set(gca,'YScale','log');
xlabel('bias');
ylabel('precision');
if PLOT.print
    figure_name=['all_measures_bias_cv_mean'];
    export_fig(gcf,[figure_name par.png_tail '_' names_string '.png']);
end


figure;
set(gcf,'Color',[1 1 1]);
for kk=1:length(field_names)
    plot(all_measures_bias_grandmean(kk),all_measures_abscv_grandmean(kk),'wo'); % just so that the axis are set properly
    hold on;
    text(all_measures_bias_grandmean(kk),all_measures_abscv_grandmean(kk),field_names{kk},'HorizontalAlignment','center','VerticalAlignment','middle','Interpreter','none','FontSize',12,'Color',field_colors{kk});
end
xlim_vect=minmax(all_measures_bias_grandmean);
ylim_vect=minmax(all_measures_abscv_grandmean);
% xlim_vect=[xlim_vect(1)*1.2589 xlim_vect(2)*1.2589]; % 10^0.1 = 1.2589 % bias have both neg and pos values
xlim_vect=[xlim_vect(1)*1.9953 xlim_vect(2)*1.9953]; % 10^0.3 = 1.9953 % bias have both neg and pos values
ylim_vect=[ylim_vect(1)*0.7943 ylim_vect(2)*1.2589]; % 10^-0.1 = 0.7943 % variability has only pos values
%         xlim_vect=[xlim_vect(1)*1.5849 xlim_vect(2)*1.5849]; % 10^0.2 = 1.5849
%         ylim_vect=[ylim_vect(1)*0.6310 ylim_vect(2)*1.5849]; % 10^-0.2 = 0.6310
plot(xlim_vect,ylim_vect,'wo'); % just so that the axis are set properly

set(gca,'YScale','log');
myxscale_symlog;
xlabel('$\mathcal{B}_S$','Interpreter','latex','Rotation',0);
ylabel('$\mathcal{V}_S$','Interpreter','latex','Rotation',0);
if PLOT.print
    figure_name=['all_measures_bias_abscv_mean'];
    export_fig(gcf,[figure_name par.png_tail '_' names_string '.png']);
end



figure;
set(gcf,'Color',[1 1 1]);
for kk=1:length(field_names)
    scatter(all_measures_bias_grandmean(kk),all_measures_abscv_grandmean(kk),'wo','MarkerEdgeAlpha',0,'MarkerFaceAlpha',0); % just so that the axis are set properly
    hold on;
    text(all_measures_bias_grandmean(kk),all_measures_abscv_grandmean(kk),field_names_latex{kk},'HorizontalAlignment','center','VerticalAlignment','middle','Interpreter','latex','FontSize',12,'Color',field_colors{kk});
end
xlim_vect=minmax(all_measures_bias_grandmean);
ylim_vect=minmax(all_measures_abscv_grandmean);
% xlim_vect=[xlim_vect(1)*1.2589 xlim_vect(2)*1.2589]; % 10^0.1 = 1.2589 % bias have both neg and pos values
xlim_vect=[xlim_vect(1)*1.9953 xlim_vect(2)*1.9953]; % 10^0.3 = 1.9953 % bias have both neg and pos values
ylim_vect=[ylim_vect(1)*0.7943 ylim_vect(2)*1.2589]; % 10^-0.1 = 0.7943 % variability has only pos values
%         xlim_vect=[xlim_vect(1)*1.5849 xlim_vect(2)*1.5849]; % 10^0.2 = 1.5849
%         ylim_vect=[ylim_vect(1)*0.6310 ylim_vect(2)*1.5849]; % 10^-0.2 = 0.6310
plot(xlim_vect,ylim_vect,'wo'); % just so that the axis are set properly

set(gca,'YScale','log');
myxscale_symlog;
xlabel('$\mathcal{B}_S$','Interpreter','latex','Rotation',0);
ylabel('$\mathcal{V}_S$','Interpreter','latex','Rotation',0);
if PLOT.print
    figure_name=['all_measures_bias_abscv_mean_latex'];
    export_fig(gcf,[figure_name par.png_tail '_' names_string '.png'],'-m2');
end


if startsWith(stringa_dir_batch,'train_win_range')
    not_shown={'modulus_m','modulus_mn','schreiber_c1','Lv_ISI','LCV_ISI','IR_ISI','SM_ISI','qqa','fooof_1p_f','PPC','cv2_ISI','MPC'};
elseif startsWith(stringa_dir_batch,'train_nneu_range')
    not_shown={'modulus_m','emdn','schreiber_c1','Lv_ISI','QQA','SPIKY_ISI','fooof_1p_f','f_rate'};
end
figure;
set(gcf,'Color',[1 1 1]);
set(gcf,'Position',[675         149        1176         813]); % better option, yields all XTick we need
for kk=1:length(field_names)
    scatter(all_measures_bias_grandmean(kk),all_measures_abscv_grandmean(kk),'wo','MarkerEdgeAlpha',0,'MarkerFaceAlpha',0); % just so that the axis are set properly
    hold on;
    if any(strcmp(field_names{kk},not_shown))
        continue
    end
    text(all_measures_bias_grandmean(kk),all_measures_abscv_grandmean(kk),field_names_latex{kk},'HorizontalAlignment','center','VerticalAlignment','middle','Interpreter','latex','FontSize',12,'Color',field_colors{kk});
end
xlim_vect=minmax(all_measures_bias_grandmean);
ylim_vect=minmax(all_measures_abscv_grandmean);
if startsWith(stringa_dir_batch,'train_win_range')
    xlim_vect=[xlim_vect(1)*2.5119 xlim_vect(2)*2.5119]; % 10^0.4 = 2.5119 % bias have both neg and pos values
elseif startsWith(stringa_dir_batch,'train_nneu_range')
    xlim_vect=[xlim_vect(1)*6.3096 xlim_vect(2)*6.3096]; % 10^0.8 = 6.3096 % bias have both neg and pos values - best for nneu
end
% xlim_vect=[xlim_vect(1)*10 xlim_vect(2)*10]; % 10^1 = 10 % bias have both neg and pos values - too much
ylim_vect=[ylim_vect(1)*0.7943 ylim_vect(2)*1.2589]; % 10^-0.1 = 0.7943 % variability has only pos values
%         xlim_vect=[xlim_vect(1)*1.5849 xlim_vect(2)*1.5849]; % 10^0.2 = 1.5849
%         ylim_vect=[ylim_vect(1)*0.6310 ylim_vect(2)*1.5849]; % 10^-0.2 = 0.6310
scatter(xlim_vect,ylim_vect,'wo','MarkerEdgeAlpha',0,'MarkerFaceAlpha',0); % just so that the axis are set properly

set(gca,'YScale','log');
myxscale_symlog;
xl=xlabel('$\mathcal{B}_S$','Interpreter','latex','Rotation',0);
ylabel('$\mathcal{V}_S$','Interpreter','latex','Rotation',0);
set(gcf,'Position',[675   549   570   413]);        
if isfield(par,'bias_abscv_pos')
    set(gca,'Position',par.bias_abscv_pos);
end
output_struct.bias_abscv_pos(w_ind,:)=get(gca,'Position');
output_struct.bias_abscv_xl=get(xl,'Position');
xl.Units='normalized';
if isfield(par,'bias_abscv_xl_norm')
    set(xl,'Position',par.bias_abscv_xl_norm);
end
output_struct.bias_abscv_xl_norm=get(xl,'Position');
        ylim_this=get(gca,'YLim');
        plot(zeros(1,2),ylim_this,'k:','LineWidth',0.5);
        set(gca,'YLim',ylim_this); % seems to be necessary for some reason
if PLOT.print
    figure_name=['all_measures_bias_abscv_mean_latex_sel'];
    export_fig(gcf,[figure_name par.png_tail '_' names_string '.png'],'-m2'); % double-size
    hgexport(gcf,[figure_name par.png_tail '_hg_' names_string '.png'],mystyle_highres,'Format','png'); % better to use hgexport since we need to assembly panels
end


% (PART BELOW DERIVED FROM multi_all_train_range_anal_bs_cluster_bal.m)

all_measures_bias_rs=reshape(all_measures_bias_mean,[size(all_measures_bias_mean,1)*size(all_measures_bias_mean,2),size(all_measures_bias_mean,3)]);
all_measures_abscv_rs=reshape(all_measures_abscv_mean,[size(all_measures_abscv_mean,1)*size(all_measures_abscv_mean,2),size(all_measures_abscv_mean,3)]);
all_measures_fs=[all_measures_bias_rs; all_measures_abscv_rs]; % finite-size from bias and abscv from all synth fam and par values
all_measures_fs=all_measures_fs'; % we need meas x fs effects

all_measures_fs_dist_absspearmancorr = pdist(all_measures_fs, @abs_spearman_corr_pairwise);
all_measures_fs_link_absspearmancorr_avg = linkage(all_measures_fs_dist_absspearmancorr, 'average');


all_measures_fs_dist_absspearmancorr_mat=squareform(all_measures_fs_dist_absspearmancorr);
NSYNC=size(all_measures_fs_dist_absspearmancorr_mat);
icMDS=[];

figure;
set(gcf,'Color',[1 1 1]);
[H,T,outperm_spearman] = dendrogram(all_measures_fs_link_absspearmancorr_avg,0);
ylabel('cluster distance');
set(gcf,'Position',[1000         392        1476         942]);
set(gca,'XTickLabels',strrep(field_names_long_wc_ms(outperm_spearman),'_','\_'),'FontSize',14);
xtickangle(gca,45);
if PLOT.print
    figure_name='all_measures_fs_absspearmancorr_avg_dendro_color_longn';
    export_fig(gcf,[figure_name par.png_tail '_' names_string '.png']);
end


% nanzscore = @(X,FLAG,DIM) bsxfun(@rdivide, bsxfun(@minus, X, nanmean(X,DIM)), nanstd(X,FLAG,DIM));
nanzscore = @(X) bsxfun(@rdivide, bsxfun(@minus, X, nanmean(X)), nanstd(X));
all_measures_fs_zs=nanzscore(all_measures_fs); % z-scoring across rows (measures), since there are only 2 values for each measure
all_measures_fs_dist_euclid = pdist(all_measures_fs_zs, @euclidean_pairwise); % this computes similarities (distances) between measures, hence it makes sense to z-score for each fs value (say bias at win= and par=) across measures
all_measures_fs_link_euclid_avg = linkage(all_measures_fs_dist_euclid, 'average');


all_measures_fs_dist_euclid_mat=squareform(all_measures_fs_dist_euclid);
NSYNC=size(all_measures_fs_dist_euclid_mat);
icMDS=[];

figure;
set(gcf,'Color',[1 1 1]);
[H,T,outperm_spearman] = dendrogram(all_measures_fs_link_euclid_avg,0);
ylabel('cluster distance');
set(gcf,'Position',[1000         392        1476         942]);
set(gca,'XTickLabels',strrep(field_names_long_wc_ms(outperm_spearman),'_','\_'),'FontSize',14);
xtickangle(gca,45);
if PLOT.print
    figure_name='all_measures_fs_euclid_avg_dendro_color_longn';
    export_fig(gcf,[figure_name par.png_tail '_' names_string '.png']);
end




all_measures_bv=[all_measures_bias_grandmean; all_measures_abscv_grandmean]; % bias and abscv grandmean (as in all_measures_bias_abscv_mean_latex_bs_050723.png)
all_measures_bv=all_measures_bv'; % we need meas x fs effects
all_measures_bv_zs=zscore(all_measures_bv); % z-scoring across rows (measures), since there are only 2 values for each measure
all_measures_bv_dist_euclid = pdist(all_measures_bv_zs, 'euclid'); % 2D patterns, needs to be euclid
all_measures_bv_link_euclid_avg = linkage(all_measures_bv_dist_euclid, 'average');


all_measures_bv_dist_euclid_mat=squareform(all_measures_bv_dist_euclid);
NSYNC=size(all_measures_bv_dist_euclid_mat);
icMDS=[];

figure;
set(gcf,'Color',[1 1 1]);
[H,T,outperm_spearman] = dendrogram(all_measures_bv_link_euclid_avg,0);
ylabel('cluster distance');
set(gcf,'Position',[1000         392        1476         942]);
set(gca,'XTickLabels',strrep(field_names_long_wc_ms(outperm_spearman),'_','\_'),'FontSize',14);
xtickangle(gca,45);
if PLOT.print
    figure_name='all_measures_bv_euclid_avg_dendro_color_longn';
    export_fig(gcf,[figure_name par.png_tail '_' names_string '.png']);
end




% as all_measures_bias_grandmean and all_measures_abscv_grandmean are actually plotted
all_measures_lbv=[symlog10(all_measures_bias_grandmean); log10(all_measures_abscv_grandmean)]; % bias and abscv grandmean (as in all_measures_bias_abscv_mean_latex_bs_050723.png)
all_measures_lbv=all_measures_lbv'; % we need meas x fs effects
all_measures_lbv_zs=zscore(all_measures_lbv); % z-scoring across rows (measures), since there are only 2 values for each measure
all_measures_lbv_dist_euclid = pdist(all_measures_lbv_zs, 'euclid'); % 2D patterns, needs to be euclid
all_measures_lbv_link_euclid_avg = linkage(all_measures_lbv_dist_euclid, 'average');


all_measures_lbv_dist_euclid_mat=squareform(all_measures_lbv_dist_euclid);
NSYNC=size(all_measures_lbv_dist_euclid_mat);
icMDS=[];

figure;
set(gcf,'Color',[1 1 1]);
[H,T,outperm_spearman] = dendrogram(all_measures_lbv_link_euclid_avg,0);
ylabel('cluster distance');
set(gcf,'Position',[1000         392        1476         942]);
set(gca,'XTickLabels',strrep(field_names_long_wc_ms(outperm_spearman),'_','\_'),'FontSize',14);
xtickangle(gca,45);
if PLOT.print
    figure_name='all_measures_lbv_euclid_avg_dendro_color_longn';
    export_fig(gcf,[figure_name par.png_tail '_' names_string '.png']);
end



clearvars -except all_measures_fs_dist_absspearmancorr all_measures_fs_link_absspearmancorr_avg  all_measures_fs_dist_euclid all_measures_fs_link_euclid_avg ...
    all_measures_bv_dist_euclid all_measures_bv_link_euclid_avg ...
    all_measures_lbv_dist_euclid all_measures_lbv_link_euclid_avg ...
    par names_string output_struct;
whos
save(['cluster' par.png_tail '_output' '_' names_string]);
cd ..


close all;
return;

