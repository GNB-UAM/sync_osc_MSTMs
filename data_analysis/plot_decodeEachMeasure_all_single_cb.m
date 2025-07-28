clear zmcorrTest zmcorrTrain stdcorrTrain stdcorrTest CC

if isempty(png_tail)
    get_field_names_cb;
    FontSizeThis=7;
    FontSizeThisCb=16;
    MarkerSizeThis=4;
elseif strcmp(png_tail,'_bs')
    get_field_names_cb_bs;
    FontSizeThis=14;
    FontSizeThisCb=16;
    MarkerSizeThis=8;
else
    keyboard;
end

nfiles=length(filenames);

sign_level_vect=[99 99.9 99.99 99.999];
zmcorrNullTestAll=cell(1,nfiles);

Aprime=nan(nfiles,length(field_names));
Aprime_std=nan(nfiles,length(field_names));
AprimeNull=nan(nfiles,length(field_names),Job.nPerm);
Aprime_thr=nan(nfiles,length(field_names));

for ifile=1:nfiles
    data_file=filenames{ifile};
    filethis=load(fullfile(dataDir,data_file));
    if isfield(filethis,'spk')
        n_neu_this=length(filethis.spk);
    elseif isfield(filethis,'spiketimes')
        n_neu_this=length(filethis.spiketimes);
    elseif isfield(filethis,'spiketimes_clean')
        n_neu_this=length(filethis.spiketimes_clean);
    else
        fieldnamesthis=fieldnames(filethis);
        n_neu_this=length(filethis.(fieldnamesthis{1})); % if there is more than one variable, this might not work
        keyboard;
    end
    if isfield(filethis,'par')
        if isfield(filethis.par,'sim_time') % use recording-specific sim_time if available
            sim_time=filethis.par.sim_time;
            nwin=floor(sim_time/win_duration);
        end
    end
    if n_neu_this<n_neu_min
        return;
    else
        if n_neu_this==n_neu_min % minimum number of neurons: no sampling
            n_sample=1;
        elseif n_neu_this==(n_neu_min+1) % just one more neuron than the minimum number:exhaustive sampling is feasible
            n_sample=n_neu_this; % all possible combinations
        else
            n_sample=max_n_sample; % max_n_sample=100<nchoosek(29,2)=406 , hence we just select random samplings without repetitions
        end
    end

    clear filethis data ss_data;

    decodeResultFilename = ['single_' ...
        Job.decodeType '_' data_file '_norm.mat' ];

    decodeNullResultFilename = strrep(decodeResultFilename,'.mat',['_' Job.NullString '_' names_string '.mat']);
    DN=load([sleepDir,'/' decodeNullResultFilename] ,'-mat','zmcorrTrain','zmcorrTest','stdcorrTrain','stdcorrTest','nTrialsPerClass');

    decodeResultFilename = strrep(decodeResultFilename,'.mat',['_' C.LambdaString '_' names_string '.mat']);
    D=load([sleepDir,'/' decodeResultFilename] ,'-mat','zmcorrTrain','zmcorrTest','stdcorrTrain','stdcorrTest','nTrialsPerClass');

    for kk=1:length(field_names)
        Aprime(ifile,kk)=D.zmcorrTest.(field_names{kk});
        Aprime_std(ifile,kk)=D.stdcorrTest.(field_names{kk});
        Aprime_thr(ifile,kk)=prctile(DN.zmcorrTest.(field_names{kk}),sign_level_vect(1)); % not used for calculating Aprime_thr_median, just for single-recording significance
        AprimeNull(ifile,kk,:)=DN.zmcorrTest.(field_names{kk});
        zmcorrNullTestAll{ifile}=[zmcorrNullTestAll{ifile} DN.zmcorrTest.(field_names{kk})]; % p=0.001 thr is calculated by lumping across measures, but not recordings
    end
end
zmcorrNullTestAll_mat=nan(nfiles,length(zmcorrNullTestAll{1}));
for ifile=1:nfiles
    zmcorrNullTestAll_mat(ifile,:)=zmcorrNullTestAll{ifile};
end
zmcorrNullTestAll=zmcorrNullTestAll_mat;
for ifile=1:nfiles
    for sign_level_i=1:length(sign_level_vect);
        sign_level=sign_level_vect(sign_level_i);
        Aprime_thr_all_eachfile(ifile,sign_level_i)=prctile(zmcorrNullTestAll(ifile,:),sign_level);
    end
end
clear zmcorrNullTestAll_mat DN;

Aprime_median=squeeze(median(Aprime,1));
AprimeNull_median=squeeze(median(AprimeNull,1)); % first median across recordings
Aprime_thr_median=prctile(AprimeNull_median,sign_level_vect(1),2); % then prctile for p=0.01

zmcorrNullTestAll_median=squeeze(median(zmcorrNullTestAll,1));
clear zmcorrNullTestAll;
for sign_level_i=1:length(sign_level_vect);
    sign_level=sign_level_vect(sign_level_i);
    Aprime_thr_all(sign_level_i)=prctile(zmcorrNullTestAll_median,sign_level); % p=0.001 and higher are evaluated after lumping across measures
end
clear zmcorrNullTestAll_median;

Aprime_thr_all_median=squeeze(median(Aprime_thr_all,1)); % doesn't do anything, just for consistent naming with plot_decodeEachMeasureEachFile_single

clear zmcorrNullTestAll DN;

mystyle = hgexport('factorystyle');
mystyle.Units='normalized';
mystyle.FontMode='none';

mystyle_highres=mystyle;
mystyle_highres.Resolution=300; % best option for final figures
% mystyle_highres.Resolution=200; % good, but not great

bias_vect=linspace(-.3,.3,nfiles);

symbol_vect={'o','+'};

dist_colors = distinguishable_colors(50);
orange=dist_colors(21,:); % orange
cyan=dist_colors(23,:); % cyan
dark_green_2=dist_colors(20,:);
blue_2=dist_colors(1,:);
cherry=dist_colors(37,:);
brown=dist_colors(42,:);
purple=dist_colors(38,:);
pink=dist_colors(14,:);
magenta=dist_colors(15,:);

color_mat(1,:)=dark_green_2; % M1R1
color_mat(2,:)=dist_colors(39,:); % dark green - M1R2
color_mat(3,:)=cherry; % M2R2
color_mat(4,:)=dist_colors(21,:); % orange - M4R1

symbol_vect={'x','+','o','s'};



xtext=[1 4.5 7.5];
ytext1=1:0.3:2.5;
ytext2=1:0.3:2.5;
ytext3=1.6:-.3:1;
ind_suf_leg=[1 2 5 6];
ind_suf_seq_leg=[1 3];

xoff=0.6;
line_len=1.; % too long
line_len=.6;

figure;
set(gcf,'Color',[1 1 1]);
set(gca,'YDir','reverse');

for i=1:nfiles
    plot(xtext(1),ytext1(i),symbol_vect{i},'Color',color_mat(i,:),'MarkerFaceColor',color_mat(i,:),'MarkerSize',20);
    th=text(xtext(1)+xoff,ytext1(i),filenames{i},'FontUnits','normalized','FontSize',0.1,'Color',color_mat(i,:),'Interpreter','none','HorizontalAlignment','left','VerticalAlignment','middle');
    hold on;
end

xlim([0 4]);
ylim([0.8 2.1]);
set(gcf,'Position',[   608   609   225   267]);
set(gca,'YDir','reverse'); % this has to be done again, not sure why
axis off;
if PLOT.print
    figure_name=[sleepDir filesep 'all_decodeAprime_legend'];
    export_fig(gcf,[figure_name '.png']); % using exportfig so it's nicely cropped
end



xtext=[1 4];
ytext1=1:0.2:2.5;

figure;
set(gcf,'Color',[1 1 1]);
set(gca,'YDir','reverse');

plot(xtext(1)+[0 line_len],ytext1(1)*ones(1,2),'Color',0.8*ones(1,3),'LineWidth',2,'LineStyle',':');
hold on;
text(xtext(1)+xoff,ytext1(1),'A_{thr}^{p=10^{-2}}','FontUnits','normalized','FontSize',0.13,'Color',0.8*ones(1,3),'HorizontalAlignment','left','VerticalAlignment','middle');
plot(xtext(1)+[0 line_len],ytext1(2)*ones(1,2),'Color',0.8*ones(1,3),'LineWidth',2,'LineStyle','--');
text(xtext(1)+xoff,ytext1(2),'A_{thr}^{p=10^{-3}}','FontUnits','normalized','FontSize',0.13,'Color',0.8*ones(1,3),'HorizontalAlignment','left','VerticalAlignment','middle');

plot(xtext(2)+[0 line_len],ytext1(1)*ones(1,2),'Color',0.6*ones(1,3),'LineWidth',2,'LineStyle',':');
text(xtext(2)+xoff,ytext1(1),'A_{thr}^{p=10^{-4}}','FontUnits','normalized','FontSize',0.13,'Color',0.6*ones(1,3),'HorizontalAlignment','left','VerticalAlignment','middle');
plot(xtext(2)+[0 line_len],ytext1(2)*ones(1,2),'Color',0.6*ones(1,3),'LineWidth',2,'LineStyle','--');
text(xtext(2)+xoff,ytext1(2),'A_{thr}^{p=10^{-5}}','FontUnits','normalized','FontSize',0.13,'Color',0.6*ones(1,3),'HorizontalAlignment','left','VerticalAlignment','middle');


ylim([0.8 1.5]);
xlim([0.8 7]);
set(gca,'YDir','reverse'); % needs to be done again, not sure why
set(gca,'Position',[0 0 1 1])
set(gcf,'Position',[675   686   337   276]);
set(gca,'YDir','reverse'); % this has to be done again, not sure why
axis off;
if PLOT.print
    figure_name=[sleepDir filesep 'all_decodeAprime_thr_legend'];
    export_fig(gcf,[figure_name '.png']); % using exportfig so it's nicely cropped
end


xtext=[1:3:10];

figure;
set(gcf,'Color',[1 1 1]);
hold on;
text(xtext(1)+xoff,ytext1(1),'A_{thr}^{p=10^{-2}}','FontUnits','normalized','FontSize',0.1,'Color',0.8*ones(1,3),'HorizontalAlignment','left','VerticalAlignment','middle');
text(xtext(1)+xoff,ytext1(2),'A_{thr}^{p=10^{-3}}','FontUnits','normalized','FontSize',0.1,'Color',0.7*ones(1,3),'HorizontalAlignment','left','VerticalAlignment','middle');
text(xtext(1)+xoff,ytext1(3),'A_{thr}^{p=10^{-4}}','FontUnits','normalized','FontSize',0.1,'Color',0.6*ones(1,3),'HorizontalAlignment','left','VerticalAlignment','middle');
text(xtext(1)+xoff,ytext1(4),'A_{thr}^{p=10^{-5}}','FontUnits','normalized','FontSize',0.1,'Color',0.5*ones(1,3),'HorizontalAlignment','left','VerticalAlignment','middle');
ylim([0.8 1.8]);
xlim([0.8 7]);
set(gca,'Position',[0 0 1 1])
set(gcf,'Position',[675   686   337   276]);
axis off;
if PLOT.print
    figure_name=[sleepDir filesep 'all_decodeAprime_thr_legend_v2'];
    export_fig(gcf,[figure_name '.png'],'-m2'); % using exportfig so it's nicely cropped
end


figure;
set(gcf,'Color',[1 1 1]);
hold on;
text(xtext(1)+xoff,ytext1(2),'A_{thr}^{p=10^{-3}}','FontUnits','normalized','FontSize',0.1,'Color',0.7*ones(1,3),'HorizontalAlignment','left','VerticalAlignment','middle');
text(xtext(1)+xoff,ytext1(3),'A_{thr}^{p=10^{-4}}','FontUnits','normalized','FontSize',0.1,'Color',0.6*ones(1,3),'HorizontalAlignment','left','VerticalAlignment','middle');
text(xtext(1)+xoff,ytext1(4),'A_{thr}^{p=10^{-5}}','FontUnits','normalized','FontSize',0.1,'Color',0.5*ones(1,3),'HorizontalAlignment','left','VerticalAlignment','middle');
ylim([0.8 1.8]);
xlim([0.8 7]);
set(gca,'Position',[0 0 1 1])
set(gcf,'Position',[675   686   337   276]);
axis off;
if PLOT.print
    figure_name=[sleepDir filesep 'all_decodeAprime_thr_legend_v3'];
    export_fig(gcf,[figure_name '.png']); % using exportfig so it's nicely cropped
end


figure;
set(gcf,'Color',[1 1 1]);
hold on;
text(xtext(1)+xoff,ytext1(1),'A_{thr}^{p=10^{-3}}','FontUnits','normalized','FontSize',0.1,'Color',0.7*ones(1,3),'HorizontalAlignment','left','VerticalAlignment','middle');
text(xtext(2)+xoff,ytext1(1),'A_{thr}^{p=10^{-4}}','FontUnits','normalized','FontSize',0.1,'Color',0.6*ones(1,3),'HorizontalAlignment','left','VerticalAlignment','middle');
text(xtext(3)+xoff,ytext1(1),'A_{thr}^{p=10^{-5}}','FontUnits','normalized','FontSize',0.1,'Color',0.5*ones(1,3),'HorizontalAlignment','left','VerticalAlignment','middle');
ylim([0.8 1.8]);
xlim([0.8 12]);
set(gca,'Position',[0 0 1 1])
set(gcf,'Position',[675   686   337   276]);
axis off;
if PLOT.print
    figure_name=[sleepDir filesep 'all_decodeAprime_thr_legend_v4'];
    export_fig(gcf,[figure_name '.png']); % using exportfig so it's nicely cropped
end




figure();
set(gcf,'Color',[1 1 1]);
[Aprime_sorted Aprime_sorted_ind]=sort(squeeze(Aprime_median),'descend');
bh=bar(Aprime_sorted);
hold on;
x1=get(bh(1),'XData');
BarWidthThis=get(bh(1),'BarWidth');
for ind=1:length(x1)
    plot([x1(ind)-BarWidthThis.*0.5 x1(ind)+BarWidthThis.*0.5],Aprime_thr_median(Aprime_sorted_ind(ind)).*ones(1,2),'Color',0.8*ones(1,3),'LineWidth',2,'LineStyle',':');
end
plot(xlim,Aprime_thr_all_median(2).*ones(1,2),'Color',0.8*ones(1,3),'LineWidth',2,'LineStyle','--');
plot(xlim,Aprime_thr_all_median(3).*ones(1,2),'Color',0.6*ones(1,3),'LineWidth',2,'LineStyle',':');
plot(xlim,Aprime_thr_all_median(4).*ones(1,2),'Color',0.6*ones(1,3),'LineWidth',2,'LineStyle','--');
hold on;
for kk=1:length(field_names)
    for i=1:nfiles
        plot(kk+bias_vect(i),Aprime(i,Aprime_sorted_ind(kk)),symbol_vect{i},'Color',color_mat(i,:),'MarkerFaceColor',color_mat(i,:),'MarkerSize',MarkerSizeThis);
    end
end
set(gca,'XTick',[1:length(field_names)]);
set(gca,'XTickLabels',strrep(field_names_wc_ms(Aprime_sorted_ind),'_','\_'),'FontSize',FontSizeThis);
xtickangle(gca,45);
ax=gca;
yrule=ax.YAxis; % this allows to set the font size independently from the x axis
yrule.FontSize = FontSizeThisCb;
ylabel('A''','Rotation',0,'FontSize',FontSizeThisCb);
title({['all recordings : ' Job.decodeMode ' ' Job.decodeType ' decoding']},'FontWeight','normal','Interpreter','none','FontSize',FontSizeThisCb);
set(gcf,'Position',[5         267        1914         702]);
figure_name=[sleepDir filesep 'all_decodeAprime_' Job.decodeMode '_' Job.decodeType '_cb' png_tail '_' names_string];
hgexport(gcf,figure_name,mystyle,'Format','png');


figure();
set(gcf,'Color',[1 1 1]);
[Aprime_sorted Aprime_sorted_ind]=sort(squeeze(Aprime_median),'descend');
bh=bar(Aprime_sorted);
hold on;
x1=get(bh(1),'XData');
BarWidthThis=get(bh(1),'BarWidth');
for ind=1:length(x1)
    plot([x1(ind)-BarWidthThis.*0.5 x1(ind)+BarWidthThis.*0.5],Aprime_thr_median(Aprime_sorted_ind(ind)).*ones(1,2),'Color',0.8*ones(1,3),'LineWidth',2,'LineStyle',':');
end
plot(xlim,Aprime_thr_all_median(2).*ones(1,2),'Color',0.8*ones(1,3),'LineWidth',2,'LineStyle','--');
plot(xlim,Aprime_thr_all_median(3).*ones(1,2),'Color',0.6*ones(1,3),'LineWidth',2,'LineStyle',':');
plot(xlim,Aprime_thr_all_median(4).*ones(1,2),'Color',0.6*ones(1,3),'LineWidth',2,'LineStyle','--');
hold on;
for kk=1:length(field_names)
    for i=1:nfiles
        plot(kk+bias_vect(i),Aprime(i,Aprime_sorted_ind(kk)),symbol_vect{i},'Color',color_mat(i,:),'MarkerFaceColor',color_mat(i,:),'MarkerSize',MarkerSizeThis);
    end
end
set(gca,'XTick',[1:length(field_names)]);
set(gca,'XTickLabels',strrep(field_names_long_wc_ms(Aprime_sorted_ind),'_','\_'),'FontSize',FontSizeThis);
xtickangle(gca,45);
ax=gca;
yrule=ax.YAxis; % this allows to set the font size independently from the x axis
yrule.FontSize = FontSizeThisCb;
ylabel('A''','Rotation',0,'FontSize',FontSizeThisCb);
title({['all recordings : ' Job.decodeMode ' ' Job.decodeType ' decoding']},'FontWeight','normal','Interpreter','none','FontSize',FontSizeThisCb);
set(gcf,'Position',[5         267        1914         702]);
figure_name=[sleepDir filesep 'all_decodeAprime_' Job.decodeMode '_' Job.decodeType '_longn' '_cb' png_tail '_' names_string];
hgexport(gcf,figure_name,mystyle_highres,'Format','png');


symbol_vect={'s','d','o','^'}; % M1R1 M1R2 M2R2 M4R1

% this version indicates significance for each recording
figure();
set(gcf,'Color',[1 1 1]);
[Aprime_sorted Aprime_sorted_ind]=sort(squeeze(Aprime_median),'descend');
bh=bar(Aprime_sorted);
hold on;
x1=get(bh(1),'XData');
BarWidthThis=get(bh(1),'BarWidth');
for ind=1:length(x1)
    plot([x1(ind)-BarWidthThis.*0.5 x1(ind)+BarWidthThis.*0.5],Aprime_thr_median(Aprime_sorted_ind(ind)).*ones(1,2),'Color',0.8*ones(1,3),'LineWidth',2,'LineStyle',':');
end
plot(xlim,Aprime_thr_all_median(2).*ones(1,2),'Color',0.8*ones(1,3),'LineWidth',2,'LineStyle','--');
plot(xlim,Aprime_thr_all_median(3).*ones(1,2),'Color',0.6*ones(1,3),'LineWidth',2,'LineStyle',':');
plot(xlim,Aprime_thr_all_median(4).*ones(1,2),'Color',0.6*ones(1,3),'LineWidth',2,'LineStyle','--');
hold on;
for kk=1:length(field_names)
    for i=1:nfiles
        if (Aprime(i,Aprime_sorted_ind(kk))>Aprime_thr(i,Aprime_sorted_ind(kk)) && Aprime(i,Aprime_sorted_ind(kk))>Aprime_thr_all_eachfile(i,2)) % p=0.001 - in some rare cases Aprime_thr(i,Aprime_sorted_ind(kk)) > Aprime_thr_all_eachfile(i,2) because of NaNs for some measures
            plot(kk+bias_vect(i),Aprime(i,Aprime_sorted_ind(kk)),symbol_vect{i},'Color',color_mat(i,:),'MarkerFaceColor',color_mat(i,:),'MarkerSize',MarkerSizeThis);
        elseif Aprime(i,Aprime_sorted_ind(kk))>Aprime_thr(i,Aprime_sorted_ind(kk)) % p=0.01
            plot(kk+bias_vect(i),Aprime(i,Aprime_sorted_ind(kk)),symbol_vect{i},'Color',color_mat(i,:),'MarkerSize',MarkerSizeThis);
        else
            plot(kk+bias_vect(i),Aprime(i,Aprime_sorted_ind(kk)),symbol_vect{i},'Color',0.8*ones(1,3),'MarkerSize',MarkerSizeThis);
        end
    end
end
set(gca,'XTick',[1:length(field_names)]);
set(gca,'XTickLabels',strrep(field_names_long_wc_ms(Aprime_sorted_ind),'_','\_'),'FontSize',FontSizeThis);
xtickangle(gca,45);
ax=gca;
yrule=ax.YAxis; % this allows to set the font size independently from the x axis
yrule.FontSize = FontSizeThisCb;
ylabel('A''','Rotation',0,'FontSize',FontSizeThisCb);
title({['all recordings: wake vs. NREM decoding']},'FontWeight','normal','Interpreter','none','FontSize',FontSizeThisCb);
set(gcf,'Position',[5         267        1914         702]);
figure_name=[sleepDir filesep 'all_decodeAprime_' Job.decodeMode '_' Job.decodeType '_longn_v2' '_cb' png_tail '_' names_string];
hgexport(gcf,figure_name,mystyle_highres,'Format','png');


figure();
set(gcf,'Color',[1 1 1]);
[Aprime_sorted Aprime_sorted_ind]=sort(squeeze(Aprime_median),'descend');
bh=bar(Aprime_sorted);
set(bh,'FaceColor',dist_colors(40,:)); % lighter shade of blue enables better discrimination of overlaid colored symbols
hold on;
x1=get(bh(1),'XData');
BarWidthThis=get(bh(1),'BarWidth');
for ind=1:length(x1)
    plot([x1(ind)-BarWidthThis.*0.5 x1(ind)+BarWidthThis.*0.5],Aprime_thr_median(Aprime_sorted_ind(ind)).*ones(1,2),'Color',0.8*ones(1,3),'LineWidth',2,'LineStyle',':');
end
plot(xlim,Aprime_thr_all_median(2).*ones(1,2),'Color',0.7*ones(1,3),'LineWidth',2,'LineStyle',':');
plot(xlim,Aprime_thr_all_median(3).*ones(1,2),'Color',0.6*ones(1,3),'LineWidth',2,'LineStyle',':');
plot(xlim,Aprime_thr_all_median(4).*ones(1,2),'Color',0.5*ones(1,3),'LineWidth',2,'LineStyle',':');
hold on;
for kk=1:length(field_names)
    for i=1:nfiles
        if (Aprime(i,Aprime_sorted_ind(kk))>Aprime_thr(i,Aprime_sorted_ind(kk)) && Aprime(i,Aprime_sorted_ind(kk))>Aprime_thr_all_eachfile(i,2)) % p=0.001 - in some rare cases Aprime_thr(i,Aprime_sorted_ind(kk)) > Aprime_thr_all_eachfile(i,2) because of NaNs for some measures
            plot(kk+bias_vect(i),Aprime(i,Aprime_sorted_ind(kk)),symbol_vect{i},'Color',color_mat(i,:),'MarkerFaceColor',color_mat(i,:),'MarkerSize',MarkerSizeThis);
        elseif Aprime(i,Aprime_sorted_ind(kk))>Aprime_thr(i,Aprime_sorted_ind(kk)) % p=0.01
            plot(kk+bias_vect(i),Aprime(i,Aprime_sorted_ind(kk)),symbol_vect{i},'Color',color_mat(i,:),'MarkerSize',MarkerSizeThis);
        else
            plot(kk+bias_vect(i),Aprime(i,Aprime_sorted_ind(kk)),symbol_vect{i},'Color',0.8*ones(1,3),'MarkerSize',MarkerSizeThis);
        end
    end
end
set(gca,'XTick',[1:length(field_names)]);
set(gca,'XTickLabels',strrep(field_names_long_wc_ms(Aprime_sorted_ind),'_','\_'),'FontSize',FontSizeThis);
xtickangle(gca,45);
ax=gca;
yrule=ax.YAxis; % this allows to set the font size independently from the x axis
yrule.FontSize = FontSizeThisCb;
ylabel('A''','Rotation',0,'FontSize',FontSizeThisCb);
title({['all recordings: wake vs. NREM decoding']},'FontWeight','normal','Interpreter','none','FontSize',FontSizeThisCb);
set(gcf,'Position',[5         267        1914         702]);
figure_name=[sleepDir filesep 'all_decodeAprime_' Job.decodeMode '_' Job.decodeType '_longn_v3' '_cb' png_tail '_' names_string];
hgexport(gcf,figure_name,mystyle_highres,'Format','png');




figure();
set(gcf,'Color',[1 1 1]);
[Aprime_sorted Aprime_sorted_ind]=sort(squeeze(Aprime_median),'descend');
bh=bar(Aprime_sorted);
set(bh,'FaceColor',dist_colors(40,:)); % lighter shade of blue enables better discrimination of overlaid colored symbols
hold on;
x1=get(bh(1),'XData');
BarWidthThis=get(bh(1),'BarWidth');
for ind=1:length(x1)
    plot([x1(ind)-BarWidthThis.*0.5 x1(ind)+BarWidthThis.*0.5],Aprime_thr_median(Aprime_sorted_ind(ind)).*ones(1,2),'Color',0.8*ones(1,3),'LineWidth',2,'LineStyle',':');
end
plot(xlim,Aprime_thr_all_median(2).*ones(1,2),'Color',0.7*ones(1,3),'LineWidth',2,'LineStyle',':');
plot(xlim,Aprime_thr_all_median(3).*ones(1,2),'Color',0.6*ones(1,3),'LineWidth',2,'LineStyle',':');
plot(xlim,Aprime_thr_all_median(4).*ones(1,2),'Color',0.5*ones(1,3),'LineWidth',2,'LineStyle',':');
hold on;
for kk=1:length(field_names)
    for i=1:nfiles
        if (Aprime(i,Aprime_sorted_ind(kk))>Aprime_thr(i,Aprime_sorted_ind(kk)) && Aprime(i,Aprime_sorted_ind(kk))>Aprime_thr_all_eachfile(i,2)) % p=0.001 - in some rare cases Aprime_thr(i,Aprime_sorted_ind(kk)) > Aprime_thr_all_eachfile(i,2) because of NaNs for some measures
            plot(kk+bias_vect(i),Aprime(i,Aprime_sorted_ind(kk)),symbol_vect{i},'Color',color_mat(i,:),'MarkerFaceColor',color_mat(i,:),'MarkerSize',MarkerSizeThis);
        elseif Aprime(i,Aprime_sorted_ind(kk))>Aprime_thr(i,Aprime_sorted_ind(kk)) % p=0.01
            plot(kk+bias_vect(i),Aprime(i,Aprime_sorted_ind(kk)),symbol_vect{i},'Color',color_mat(i,:),'MarkerSize',MarkerSizeThis);
        else
            plot(kk+bias_vect(i),Aprime(i,Aprime_sorted_ind(kk)),symbol_vect{i},'Color',0.8*ones(1,3),'MarkerSize',MarkerSizeThis);
        end
    end
end
ylim([0.3 1.]);
set(gca,'XTick',[1:length(field_names)]);
set(gca,'XTickLabels',strrep(field_names_long_wc_ms(Aprime_sorted_ind),'_','\_'),'FontSize',FontSizeThis);
xtickangle(gca,45);
ax=gca;
yrule=ax.YAxis; % this allows to set the font size independently from the x axis
yrule.FontSize = FontSizeThisCb;
ylabel('A''','Rotation',0,'FontSize',FontSizeThisCb);
title({['all recordings: wake vs. NREM decoding']},'FontWeight','normal','Interpreter','none','FontSize',FontSizeThisCb);
set(gcf,'Position',[5         267        1914         702*0.666666666666]);
figure_name=[sleepDir filesep 'all_decodeAprime_' Job.decodeMode '_' Job.decodeType '_longn_v4' '_cb' png_tail '_' names_string];
hgexport(gcf,figure_name,mystyle_highres,'Format','png');





figure;
set(gcf,'Color',[1 1 1]);
set(gca,'YDir','reverse');

for i=1:nfiles
    plot(xtext(1),ytext1(i),symbol_vect{i},'Color',color_mat(i,:),'MarkerFaceColor',color_mat(i,:),'MarkerSize',20);
    th=text(xtext(1)+xoff,ytext1(i),filenames{i},'FontUnits','normalized','FontSize',0.1,'Color',color_mat(i,:),'Interpreter','none','HorizontalAlignment','left','VerticalAlignment','middle');
    hold on;
end

xlim([0 4]);
ylim([0.8 2.1]);
set(gca,'Position',[0 0 1 1])
set(gcf,'Position',[   608   609   225   267]);
set(gca,'YDir','reverse'); % this has to be done again, not sure why
axis off;
if PLOT.print
    figure_name=[sleepDir filesep 'all_decodeAprime_legend_v2'];
    export_fig(gcf,[figure_name '.png'],'-m2'); % using exportfig so it's nicely cropped
end


figure;
set(gcf,'Color',[1 1 1]);
set(gca,'YDir','reverse');

plot(xtext(1),ytext1(1),symbol_vect{1},'Color',color_mat(1,:),'MarkerFaceColor',color_mat(1,:),'MarkerSize',20);
th=text(xtext(1)+xoff,ytext1(1),'p=0.001','FontUnits','normalized','FontSize',0.1,'Color',zeros(1,3),'Interpreter','none','HorizontalAlignment','left','VerticalAlignment','middle');
hold on;
plot(xtext(1),ytext1(2),symbol_vect{1},'Color',color_mat(1,:),'MarkerSize',20);
th=text(xtext(1)+xoff,ytext1(2),'p=0.01','FontUnits','normalized','FontSize',0.1,'Color',zeros(1,3),'Interpreter','none','HorizontalAlignment','left','VerticalAlignment','middle');
plot(xtext(1),ytext1(3),symbol_vect{1},'Color',0.8*ones(1,3),'MarkerSize',20);
th=text(xtext(1)+xoff,ytext1(3),'n.s.','FontUnits','normalized','FontSize',0.1,'Color',zeros(1,3),'Interpreter','none','HorizontalAlignment','left','VerticalAlignment','middle');

xlim([0 4]);
ylim([0.8 2.1]);
set(gca,'Position',[0 0 1 1])
set(gcf,'Position',[   608   609   225   267]);
set(gca,'YDir','reverse'); % this has to be done again, not sure why
axis off;
if PLOT.print
    figure_name=[sleepDir filesep 'all_decodeAprime_stat_legend_v2'];
    export_fig(gcf,[figure_name '.png'],'-m2'); % using exportfig so it's nicely cropped
end




N=length(field_names);
fid = fopen(['decode_' Job.decodeMode '_' Job.decodeType '_all' png_tail '_' C.LambdaString '_' names_string '.txt'],'w');
fprintf(fid,'best decoding results at the population level\n');
fprintf(fid,'\n%i measures',N);
fprintf(fid,'\n\ndecoding A''>0.70');

Aprime_sorted_above70=Aprime_sorted(Aprime_sorted>0.70);
N70=length(Aprime_sorted_above70);
P70=N70/N;
fprintf(fid,'\nN70=%i\nN=%i\nP70=%f\n',N70,N,P70);
for ind=1:N70
    fprintf(fid,['\nA''=' num2str(Aprime_sorted(ind)) ' for '     field_names{Aprime_sorted_ind(ind)}]);
end

topp=[0.05];

fid = fopen(['decode_top' num2str(topp*100) '_' Job.decodeMode '_' Job.decodeType '_all' png_tail '_' C.LambdaString '_' names_string '.txt'],'w');
fprintf(fid,data_file);
for ind=1:round(topp*N)
    fprintf(fid,['\nA''=' num2str(Aprime_sorted(ind)) ' for '     field_names{Aprime_sorted_ind(ind)}]);
end
