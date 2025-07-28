clear zmcorrTest zmcorrTrain stdcorrTrain stdcorrTest CC

if isempty(png_tail)
    get_field_names_cb;
    FontSizeThis=7;
    FontSizeThisCb=16;
elseif strcmp(png_tail,'_bs')
    get_field_names_cb_bs;
    FontSizeThis=14;
    FontSizeThisCb=16;
else
    keyboard;
end


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

sign_level_vect=[99 99.9 99.99 99.999];

decodeResultFilename = ['single_' ...
    Job.decodeType '_' data_file '_norm.mat' ];

decodeNullResultFilename = strrep(decodeResultFilename,'.mat',['_' Job.NullString '_' names_string '.mat']);
DN=load([sleepDir,'/' decodeNullResultFilename] ,'-mat','zmcorrTrain','zmcorrTest','stdcorrTrain','stdcorrTest','nTrialsPerClass');

decodeResultFilename = strrep(decodeResultFilename,'.mat',['_' C.LambdaString '_' names_string '.mat']);
D=load([sleepDir,'/' decodeResultFilename] ,'-mat','zmcorrTrain','zmcorrTest','stdcorrTrain','stdcorrTest','nTrialsPerClass');

zmcorrNullTestAll=[];

Aprime=nan(1,length(field_names));
Aprime_std=nan(1,length(field_names));
Aprime_thr=nan(1,length(field_names));

for kk=1:length(field_names)
    Aprime(kk)=D.zmcorrTest.(field_names{kk});
    Aprime_std(kk)=D.stdcorrTest.(field_names{kk});
    Aprime_thr(kk)=prctile(DN.zmcorrTest.(field_names{kk}),sign_level_vect(1));
    zmcorrNullTestAll=[zmcorrNullTestAll DN.zmcorrTest.(field_names{kk})]; % p=0.001 thr is calculated by lumping across measures
end

for sign_level_i=1:length(sign_level_vect);
    sign_level=sign_level_vect(sign_level_i);
    Aprime_thr_all(sign_level_i)=prctile(zmcorrNullTestAll,sign_level);
end
clear zmcorrNullTestAll DN;

Aprime_thr_maxdiff=max(abs(Aprime_thr-Aprime_thr_all(1))); % 0.0766 for M1R1 not really infinitesimal

mystyle = hgexport('factorystyle');
mystyle.Units='normalized';
mystyle.FontMode='none';

mystyle_highres=mystyle;
mystyle_highres.Resolution=300;

dist_colors = distinguishable_colors(50);

figure();
set(gcf,'Color',[1 1 1]);
[Aprime_sorted Aprime_sorted_ind]=sort(squeeze(Aprime),'descend');
bh=bar(Aprime_sorted);
hold on;
x1=get(bh(1),'XData');
BarWidthThis=get(bh(1),'BarWidth');
for ind=1:length(x1)
    plot([x1(ind)-BarWidthThis.*0.5 x1(ind)+BarWidthThis.*0.5],Aprime_thr(Aprime_sorted_ind(ind)).*ones(1,2),'Color',0.8*ones(1,3),'LineWidth',2,'LineStyle',':');
end
plot(xlim,Aprime_thr_all(2).*ones(1,2),'Color',0.8*ones(1,3),'LineWidth',2,'LineStyle','--');
plot(xlim,Aprime_thr_all(3).*ones(1,2),'Color',0.6*ones(1,3),'LineWidth',2,'LineStyle',':');
plot(xlim,Aprime_thr_all(4).*ones(1,2),'Color',0.6*ones(1,3),'LineWidth',2,'LineStyle','--');
set(gca,'XTick',[1:length(field_names)]);
set(gca,'XTickLabels',strrep(field_names_wc_ms(Aprime_sorted_ind),'_','\_'),'FontSize',FontSizeThis);
xtickangle(gca,45);
ax=gca;
yrule=ax.YAxis; % this allows to set the font size independently from the x axis
yrule.FontSize = FontSizeThisCb;
ylabel('A''','Rotation',0,'FontSize',FontSizeThisCb);
title({[data_file ' ' Job.decodeMode ' ' Job.decodeType ' decoding : ' num2str(nwin) ' win; ' num2str(D.nTrialsPerClass(1)) ' ' c1_string ' ' num2str(D.nTrialsPerClass(2)) ' ' c2_string ' ; ' num2str(n_neu_this) ' neurons']},'FontWeight','normal','Interpreter','none','FontSize',FontSizeThisCb); % here we show n_neu_this, but only n_neu_min were considered for calculating the measures
set(gcf,'Position',[5         267        1914         702]);
figure_name=[sleepDir filesep data_file '_decodeAprime_' Job.decodeMode '_' Job.decodeType '_cb' png_tail '_' names_string];
hgexport(gcf,figure_name,mystyle,'Format','png');


figure();
set(gcf,'Color',[1 1 1]);
[Aprime_sorted Aprime_sorted_ind]=sort(squeeze(Aprime),'descend');
bh=bar(Aprime_sorted);
hold on;
x1=get(bh(1),'XData');
BarWidthThis=get(bh(1),'BarWidth');
for ind=1:length(x1)
    plot([x1(ind)-BarWidthThis.*0.5 x1(ind)+BarWidthThis.*0.5],Aprime_thr(Aprime_sorted_ind(ind)).*ones(1,2),'Color',0.8*ones(1,3),'LineWidth',2,'LineStyle',':');
end
plot(xlim,Aprime_thr_all(2).*ones(1,2),'Color',0.8*ones(1,3),'LineWidth',2,'LineStyle','--');
plot(xlim,Aprime_thr_all(3).*ones(1,2),'Color',0.6*ones(1,3),'LineWidth',2,'LineStyle',':');
plot(xlim,Aprime_thr_all(4).*ones(1,2),'Color',0.6*ones(1,3),'LineWidth',2,'LineStyle','--');
ylim([0 1.]);
set(gca,'XTick',[1:length(field_names)]);
set(gca,'XTickLabels',strrep(field_names_long_wc_ms(Aprime_sorted_ind),'_','\_'),'FontSize',FontSizeThis);
set(gca,'YTick',[0:0.2:1]);
xtickangle(gca,45);
ax=gca;
yrule=ax.YAxis; % this allows to set the font size independently from the x axis
yrule.FontSize = FontSizeThisCb;
ylabel('A''','Rotation',0,'FontSize',FontSizeThisCb);
title({[data_file ': wake vs. NREM decoding']},'FontWeight','normal','Interpreter','none','FontSize',FontSizeThisCb); % here we show n_neu_this, but only n_neu_min were considered for calculating the measures
set(gcf,'Position',[5         267        1914         702]);
figure_name=[sleepDir filesep data_file '_decodeAprime_' Job.decodeMode '_' Job.decodeType '_longn' '_cb' png_tail '_' names_string];
hgexport(gcf,figure_name,mystyle_highres,'Format','png');

figure();
set(gcf,'Color',[1 1 1]);
[Aprime_sorted Aprime_sorted_ind]=sort(squeeze(Aprime),'descend');
bh=bar(Aprime_sorted);
set(bh,'FaceColor',dist_colors(40,:)); % lighter shade of blue enables better discrimination of overlaid colored symbols (constently with plot_decodeEachMeasure_all_single.m)
hold on;
x1=get(bh(1),'XData');
BarWidthThis=get(bh(1),'BarWidth');
for ind=1:length(x1)
    plot([x1(ind)-BarWidthThis.*0.5 x1(ind)+BarWidthThis.*0.5],Aprime_thr(Aprime_sorted_ind(ind)).*ones(1,2),'Color',0.8*ones(1,3),'LineWidth',2,'LineStyle',':');
end
plot(xlim,Aprime_thr_all(2).*ones(1,2),'Color',0.7*ones(1,3),'LineWidth',2,'LineStyle',':');
plot(xlim,Aprime_thr_all(3).*ones(1,2),'Color',0.6*ones(1,3),'LineWidth',2,'LineStyle',':');
plot(xlim,Aprime_thr_all(4).*ones(1,2),'Color',0.5*ones(1,3),'LineWidth',2,'LineStyle',':');
ylim([0 1.]);
set(gca,'XTick',[1:length(field_names)]);
set(gca,'XTickLabels',strrep(field_names_long_wc_ms(Aprime_sorted_ind),'_','\_'),'FontSize',FontSizeThis);
set(gca,'YTick',[0:0.2:1]);
xtickangle(gca,45);
ax=gca;
yrule=ax.YAxis; % this allows to set the font size independently from the x axis
yrule.FontSize = FontSizeThisCb;
ylabel('A''','Rotation',0,'FontSize',FontSizeThisCb);
title({[data_file ': wake vs. NREM decoding']},'FontWeight','normal','Interpreter','none','FontSize',FontSizeThisCb); % here we show n_neu_this, but only n_neu_min were considered for calculating the measures
set(gcf,'Position',[5         267        1914         702]);
figure_name=[sleepDir filesep data_file '_decodeAprime_' Job.decodeMode '_' Job.decodeType '_longn_v3' '_cb' png_tail '_' names_string];
hgexport(gcf,figure_name,mystyle_highres,'Format','png');


figure();
set(gcf,'Color',[1 1 1]);
[Aprime_sorted Aprime_sorted_ind]=sort(squeeze(Aprime),'descend');
bh=bar(Aprime_sorted);
set(bh,'FaceColor',dist_colors(40,:)); % lighter shade of blue enables better discrimination of overlaid colored symbols (constently with plot_decodeEachMeasure_all_single.m)
hold on;
x1=get(bh(1),'XData');
BarWidthThis=get(bh(1),'BarWidth');
for ind=1:length(x1)
    plot([x1(ind)-BarWidthThis.*0.5 x1(ind)+BarWidthThis.*0.5],Aprime_thr(Aprime_sorted_ind(ind)).*ones(1,2),'Color',0.8*ones(1,3),'LineWidth',2,'LineStyle',':');
end
plot(xlim,Aprime_thr_all(2).*ones(1,2),'Color',0.7*ones(1,3),'LineWidth',2,'LineStyle',':');
plot(xlim,Aprime_thr_all(3).*ones(1,2),'Color',0.6*ones(1,3),'LineWidth',2,'LineStyle',':');
plot(xlim,Aprime_thr_all(4).*ones(1,2),'Color',0.5*ones(1,3),'LineWidth',2,'LineStyle',':');
ylim([0.3 1.]);
set(gca,'XTick',[1:length(field_names)]);
set(gca,'XTickLabels',strrep(field_names_long_wc_ms(Aprime_sorted_ind),'_','\_'),'FontSize',FontSizeThis);
set(gca,'YTick',[0:0.2:1]);
xtickangle(gca,45);
ax=gca;
yrule=ax.YAxis; % this allows to set the font size independently from the x axis
yrule.FontSize = FontSizeThisCb;
ylabel('A''','Rotation',0,'FontSize',FontSizeThisCb);
title({[data_file ': wake vs. NREM decoding']},'FontWeight','normal','Interpreter','none','FontSize',FontSizeThisCb); % here we show n_neu_this, but only n_neu_min were considered for calculating the measures
set(gcf,'Position',[5         267        1914         702*0.666666666666]);
figure_name=[sleepDir filesep data_file '_decodeAprime_' Job.decodeMode '_' Job.decodeType '_longn_v4' '_cb' png_tail '_' names_string];
hgexport(gcf,figure_name,mystyle_highres,'Format','png');



N=length(field_names);
fid = fopen(['decode_' Job.decodeMode '_' Job.decodeType '_' data_file png_tail '_' C.LambdaString '_' names_string '.txt'],'w');
fprintf(fid,data_file);
fprintf(fid,'\n%i measures',N);
fprintf(fid,'\n\ndecoding A''>0.95');

Aprime_sorted_above95=Aprime_sorted(Aprime_sorted>0.95);
N95=length(Aprime_sorted_above95);
P95=N95/N;
fprintf(fid,'\nN95=%i\nN=%i\nP95=%f\n',N95,N,P95);
for ind=1:N95
    fprintf(fid,['\nA''=' num2str(Aprime_sorted(ind)) ' for '     field_names{Aprime_sorted_ind(ind)}]);
end

topp=[0.05];

fid = fopen(['decode_top' num2str(topp*100) '_' Job.decodeMode '_' Job.decodeType '_' data_file png_tail '_' C.LambdaString '_' names_string '.txt'],'w');
fprintf(fid,data_file);
for ind=1:round(topp*N)
    fprintf(fid,['\nA''=' num2str(Aprime_sorted(ind)) ' for '     field_names{Aprime_sorted_ind(ind)}]);
end
