clear zmcorrTest zmcorrTrain stdcorrTrain stdcorrTest CC

if isempty(png_tail)
    get_field_names;
    FontSizeThis=7;
    FontSizeThisCb=16;
    MarkerSizeThis=4;
elseif strcmp(png_tail,'_bs')
    get_field_names_bs;
    FontSizeThis=14;
    FontSizeThisCb=16;
    MarkerSizeThis=8;
else
    keyboard;
end

nfiles=length(filenames);

% sign_level_vect=[99 99.9];
sign_level_vect=[99 99.9 99.99 99.999];
% zmcorrNullTestAll=cell(1,nfiles);
zmcorrNullTestAll=[];

Aprime=nan(nfiles,length(field_names));
Aprime_std=nan(nfiles,length(field_names));
AprimeNull=nan(nfiles,length(field_names),Job.nPerm);
Aprime_thr=nan(nfiles,length(field_names));

clear filethis data ss_data;

decodeResultFilename = ['single_' ...
    Job.decodeType '_loro_norm.mat' ];

decodeNullResultFilename = strrep(decodeResultFilename,'.mat',['_' Job.NullString '_' names_string '.mat']);
DN=load([sleepDir,'/' decodeNullResultFilename] ,'-mat','zmcorrTrain','zmcorrTest','stdcorrTrain','stdcorrTest','nTrialsPerClass');

decodeResultFilename = strrep(decodeResultFilename,'.mat',['_' C.LambdaString '_' names_string '.mat']);
D=load([sleepDir,'/' decodeResultFilename] ,'-mat','zmcorrTrain','zmcorrTest','stdcorrTrain','stdcorrTest','nTrialsPerClass');

for kk=1:length(field_names)
    Aprime(:,kk)=D.zmcorrTest.(field_names{kk});
    Aprime_std(:,kk)=D.stdcorrTest.(field_names{kk});
    Aprime_thr(:,kk)=prctile(DN.zmcorrTest.(field_names{kk}),sign_level_vect(1),2); % not used for calculating Aprime_thr_median, just for single-recording significance
    AprimeNull(:,kk,:)=DN.zmcorrTest.(field_names{kk});
    zmcorrNullTestAll=[zmcorrNullTestAll DN.zmcorrTest.(field_names{kk})]; % p=0.001 thr is calculated by lumping across measures, but not recordings
end

% zmcorrNullTestAll_mat=nan(nfiles,length(zmcorrNullTestAll{1}));
% for ifile=1:nfiles
%     zmcorrNullTestAll_mat(ifile,:)=zmcorrNullTestAll{ifile};
% end
% zmcorrNullTestAll=zmcorrNullTestAll_mat;
for ifile=1:nfiles
    for sign_level_i=1:length(sign_level_vect);
        sign_level=sign_level_vect(sign_level_i);
        Aprime_thr_all_eachfile(ifile,sign_level_i)=prctile(zmcorrNullTestAll(ifile,:),sign_level);
    end
end
clear zmcorrNullTestAll_mat DN;

Aprime_median=squeeze(median(Aprime,1));
% Aprime_thr_median=squeeze(median(Aprime_thr,1)); % NO, single-recording Aprime_thr is not used for calculating Aprime_thr_median
AprimeNull_median=squeeze(median(AprimeNull,1)); % first median across recordings
Aprime_thr_median=prctile(AprimeNull_median,sign_level_vect(1),2); % then prctile for p=0.01

% for ifile=1:nfiles
%     for sign_level_i=1:length(sign_level_vect);
%         sign_level=sign_level_vect(sign_level_i);
%         Aprime_thr_all(ifile,sign_level_i)=prctile(zmcorrNullTestAll{ifile},sign_level);
%     end
% end

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
% mystyle_highres.Resolution=600; % too high, figures are too big and slow down pdf viewers
% mystyle_highres.Resolution=400; % still too high
mystyle_highres.Resolution=300; % best option for final figures
% mystyle_highres.Resolution=200; % good, but not great

bias_vect=linspace(-.3,.3,nfiles);

% symbol_vect={'o','s'}; % corresponding to those used in multi_train_range_anal_ms_v2.m
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
% color_mat(1,:)=cherry;
% color_mat(2,:)=dark_green_2;
% % color_mat(3,:)=blue_2; % better to avoid this, it is already associated with power decoding
% color_mat(3,:)=dist_colors(12,:); % dark blue
% color_mat(4,:)=dist_colors(38,:); % purple
% color_mat(5,:)=dist_colors(23,:); % cyan
% color_mat(6,:)=dist_colors(36,:); % skin
% color_mat(7,:)=dist_colors(39,:); % dark green
% color_mat(8,:)=dist_colors(42,:); % brown
% color_mat(9,:)=dist_colors(48,:); % gray-blue
% color_mat(10,:)=dist_colors(21,:); % orange
% color_mat(11,:)=dist_colors(4,:); % black
% color_mat(12,:)=0.8.*ones(1,3); % light gray

color_mat(1,:)=dark_green_2; % M1R1
color_mat(2,:)=dist_colors(39,:); % dark green - M1R2
color_mat(3,:)=cherry; % M2R2
color_mat(4,:)=dist_colors(21,:); % orange - M4R1

% symbol_vect={'o','x','+','*','s','d','v','^','<','>'};
symbol_vect={'x','+','o','s'};



figure();
set(gcf,'Color',[1 1 1]);
% [Aprime_sorted Aprime_sorted_ind]=sort(Aprime(isuf,i,w_ind,:));
[Aprime_sorted Aprime_sorted_ind]=sort(squeeze(Aprime_median),'descend');
bh=bar(Aprime_sorted);
hold on;
x1=get(bh(1),'XData');
% set(bh,'FaceColor',cyan);
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
% set(gca,'YScale','log');
set(gca,'XTick',[1:length(field_names)]);
set(gca,'XTickLabels',strrep(field_names_wc_ms(Aprime_sorted_ind),'_','\_'),'FontSize',FontSizeThis);
xtickangle(gca,45);
ax=gca;
yrule=ax.YAxis; % this allows to set the font size independently from the x axis
yrule.FontSize = FontSizeThisCb;
% set(gca,'YTick',[0.001 0.01 0.1 1. 10. 100. 1000.]); % mejor dejar los automaticos, eventualmente arreglar manualmente las versiones finales si necesario
% set(gca,'YTickLabel',{'10^{-3}','10^{-2}','10^{-1}','10^{0}','10^{1}','10^{2}','10^{3}'});
% ylabel('A prime');
ylabel('A''','Rotation',0,'FontSize',FontSizeThisCb);
title({['all recordings : LORO ' Job.decodeMode ' ' Job.decodeType ' decoding']},'FontWeight','normal','Interpreter','none','FontSize',FontSizeThisCb);
set(gcf,'Position',[5         267        1914         702]);
figure_name=[sleepDir filesep 'loro_decodeAprime_' Job.decodeMode '_' Job.decodeType png_tail '_' names_string];
hgexport(gcf,figure_name,mystyle,'Format','png');


figure();
set(gcf,'Color',[1 1 1]);
% [Aprime_sorted Aprime_sorted_ind]=sort(Aprime(isuf,i,w_ind,:));
[Aprime_sorted Aprime_sorted_ind]=sort(squeeze(Aprime_median),'descend');
bh=bar(Aprime_sorted);
hold on;
x1=get(bh(1),'XData');
% set(bh,'FaceColor',cyan);
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
% set(gca,'YScale','log');
set(gca,'XTick',[1:length(field_names)]);
set(gca,'XTickLabels',strrep(field_names_long_wc_ms(Aprime_sorted_ind),'_','\_'),'FontSize',FontSizeThis);
xtickangle(gca,45);
ax=gca;
yrule=ax.YAxis; % this allows to set the font size independently from the x axis
yrule.FontSize = FontSizeThisCb;
% set(gca,'YTick',[0.001 0.01 0.1 1. 10. 100. 1000.]); % mejor dejar los automaticos, eventualmente arreglar manualmente las versiones finales si necesario
% set(gca,'YTickLabel',{'10^{-3}','10^{-2}','10^{-1}','10^{0}','10^{1}','10^{2}','10^{3}'});
% ylabel('A prime');
ylabel('A''','Rotation',0,'FontSize',FontSizeThisCb);
title({['all recordings : LORO ' Job.decodeMode ' ' Job.decodeType ' decoding']},'FontWeight','normal','Interpreter','none','FontSize',FontSizeThisCb);
set(gcf,'Position',[5         267        1914         702]);
figure_name=[sleepDir filesep 'loro_decodeAprime_' Job.decodeMode '_' Job.decodeType '_longn' png_tail '_' names_string];
hgexport(gcf,figure_name,mystyle_highres,'Format','png');


% it's better to use more vivid colors for more significant recordings
% NO, better to use different shades of green for M1R1 and M1R2
% color_mat(1,:)=dist_colors(21,:); % orange - M1R1
% color_mat(2,:)=cherry; % M1R2
% color_mat(3,:)=dist_colors(39,:); % dark (forest) green - M2R2
% color_mat(4,:)=dark_green_2; % M4R1

% symbol_vect={'o','x','+','*','s','d','v','^','<','>'};
% symbol_vect={'o','s','d','^'};
symbol_vect={'s','d','o','^'}; % M1R1 M1R2 M2R2 M4R1

% this version indicates significance for each recording
figure();
set(gcf,'Color',[1 1 1]);
% [Aprime_sorted Aprime_sorted_ind]=sort(Aprime(isuf,i,w_ind,:));
[Aprime_sorted Aprime_sorted_ind]=sort(squeeze(Aprime_median),'descend');
bh=bar(Aprime_sorted);
hold on;
x1=get(bh(1),'XData');
% set(bh,'FaceColor',cyan);
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
% set(gca,'YScale','log');
set(gca,'XTick',[1:length(field_names)]);
set(gca,'XTickLabels',strrep(field_names_long_wc_ms(Aprime_sorted_ind),'_','\_'),'FontSize',FontSizeThis);
xtickangle(gca,45);
ax=gca;
yrule=ax.YAxis; % this allows to set the font size independently from the x axis
yrule.FontSize = FontSizeThisCb;
% set(gca,'YTick',[0.001 0.01 0.1 1. 10. 100. 1000.]); % mejor dejar los automaticos, eventualmente arreglar manualmente las versiones finales si necesario
% set(gca,'YTickLabel',{'10^{-3}','10^{-2}','10^{-1}','10^{0}','10^{1}','10^{2}','10^{3}'});
% ylabel('A prime');
ylabel('A''','Rotation',0,'FontSize',FontSizeThisCb);
% title({['all recordings : ' Job.decodeMode ' ' Job.decodeType ' decoding']},'FontWeight','normal','Interpreter','none','FontSize',FontSizeThisCb);
% title({['all recordings: LORO wake vs. NREM decoding']},'FontWeight','normal','Interpreter','none','FontSize',FontSizeThisCb);
title({['LORO wake vs. NREM decoding']},'FontWeight','normal','Interpreter','none','FontSize',FontSizeThisCb);
set(gcf,'Position',[5         267        1914         702]);
figure_name=[sleepDir filesep 'loro_decodeAprime_' Job.decodeMode '_' Job.decodeType '_longn_v2' png_tail '_' names_string];
hgexport(gcf,figure_name,mystyle_highres,'Format','png');


figure();
set(gcf,'Color',[1 1 1]);
% [Aprime_sorted Aprime_sorted_ind]=sort(Aprime(isuf,i,w_ind,:));
[Aprime_sorted Aprime_sorted_ind]=sort(squeeze(Aprime_median),'descend');
bh=bar(Aprime_sorted);
set(bh,'FaceColor',dist_colors(40,:)); % lighter shade of blue enables better discrimination of overlaid colored symbols
hold on;
x1=get(bh(1),'XData');
% set(bh,'FaceColor',cyan);
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
% set(gca,'YScale','log');
set(gca,'XTick',[1:length(field_names)]);
set(gca,'XTickLabels',strrep(field_names_long_wc_ms(Aprime_sorted_ind),'_','\_'),'FontSize',FontSizeThis);
xtickangle(gca,45);
ax=gca;
yrule=ax.YAxis; % this allows to set the font size independently from the x axis
yrule.FontSize = FontSizeThisCb;
% set(gca,'YTick',[0.001 0.01 0.1 1. 10. 100. 1000.]); % mejor dejar los automaticos, eventualmente arreglar manualmente las versiones finales si necesario
% set(gca,'YTickLabel',{'10^{-3}','10^{-2}','10^{-1}','10^{0}','10^{1}','10^{2}','10^{3}'});
% ylabel('A prime');
ylabel('A''','Rotation',0,'FontSize',FontSizeThisCb);
% title({['all recordings : ' Job.decodeMode ' ' Job.decodeType ' decoding']},'FontWeight','normal','Interpreter','none','FontSize',FontSizeThisCb);
% title({['all recordings: wake vs. NREM decoding']},'FontWeight','normal','Interpreter','none','FontSize',FontSizeThisCb);
title({['LORO wake vs. NREM decoding']},'FontWeight','normal','Interpreter','none','FontSize',FontSizeThisCb);
set(gcf,'Position',[5         267        1914         702]);
figure_name=[sleepDir filesep 'loro_decodeAprime_' Job.decodeMode '_' Job.decodeType '_longn_v3' png_tail '_' names_string];
hgexport(gcf,figure_name,mystyle_highres,'Format','png');




figure();
set(gcf,'Color',[1 1 1]);
% [Aprime_sorted Aprime_sorted_ind]=sort(Aprime(isuf,i,w_ind,:));
[Aprime_sorted Aprime_sorted_ind]=sort(squeeze(Aprime_median),'descend');
bh=bar(Aprime_sorted);
set(bh,'FaceColor',dist_colors(40,:)); % lighter shade of blue enables better discrimination of overlaid colored symbols
hold on;
x1=get(bh(1),'XData');
% set(bh,'FaceColor',cyan);
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
% set(gca,'YScale','log');
set(gca,'XTick',[1:length(field_names)]);
set(gca,'XTickLabels',strrep(field_names_long_wc_ms(Aprime_sorted_ind),'_','\_'),'FontSize',FontSizeThis);
xtickangle(gca,45);
ax=gca;
yrule=ax.YAxis; % this allows to set the font size independently from the x axis
yrule.FontSize = FontSizeThisCb;
% set(gca,'YTick',[0.001 0.01 0.1 1. 10. 100. 1000.]); % mejor dejar los automaticos, eventualmente arreglar manualmente las versiones finales si necesario
% set(gca,'YTickLabel',{'10^{-3}','10^{-2}','10^{-1}','10^{0}','10^{1}','10^{2}','10^{3}'});
% ylabel('A prime');
ylabel('A''','Rotation',0,'FontSize',FontSizeThisCb);
% title({['all recordings : ' Job.decodeMode ' ' Job.decodeType ' decoding']},'FontWeight','normal','Interpreter','none','FontSize',FontSizeThisCb);
% title({['all recordings: wake vs. NREM decoding']},'FontWeight','normal','Interpreter','none','FontSize',FontSizeThisCb);
title({['LORO wake vs. NREM decoding']},'FontWeight','normal','Interpreter','none','FontSize',FontSizeThisCb);
set(gcf,'Position',[5         267        1914         702*0.666666666666]);
figure_name=[sleepDir filesep 'loro_decodeAprime_' Job.decodeMode '_' Job.decodeType '_longn_v4' png_tail '_' names_string];
hgexport(gcf,figure_name,mystyle_highres,'Format','png');








N=length(field_names);
fid = fopen(['decode_' Job.decodeMode '_' Job.decodeType '_loro' png_tail '_' C.LambdaString '_' names_string '.txt'],'w');
fprintf(fid,'best LORO decoding results\n');
fprintf(fid,'\n%i measures',N);
fprintf(fid,'\n\ndecoding A''>0.70');

Aprime_sorted_above70=Aprime_sorted(Aprime_sorted>0.70);
N70=length(Aprime_sorted_above70);
P70=N70/N;
fprintf(fid,'\nN70=%i\nN=%i\nP70=%f\n',N70,N,P70);
for ind=1:N70
    fprintf(fid,['\nA''=' num2str(Aprime_sorted(ind)) ' for '     field_names{Aprime_sorted_ind(ind)}]);
    % fprintf(fid,['\nA''=' num2str(Aprime_sorted(ind_row_above70(ind),ind_col_above70(ind))) ' for '     field_names{Aprime_sorted_ind(ind_row_above70(ind))}]);
    % field_names(Aprime_sorted_ind(ind_row_above70(ind)))
end

topp=[0.05];

fid = fopen(['decode_top' num2str(topp*100) '_' Job.decodeMode '_' Job.decodeType '_loro' png_tail '_' C.LambdaString '_' names_string '.txt'],'w');
fprintf(fid,'top LORO decoding results\n');
for ind=1:round(topp*N)
    fprintf(fid,['\nA''=' num2str(Aprime_sorted(ind)) ' for '     field_names{Aprime_sorted_ind(ind)}]);
end
