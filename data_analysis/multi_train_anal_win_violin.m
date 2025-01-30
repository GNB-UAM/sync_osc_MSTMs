function output_struct=multi_train_anal_win_violin(dataDir,filenames,stringa,par)
% this code generates violin plots for each recording and condition

PLOT.print=1;

figDir=['~/neuron/sync_osc/' stringa]; % these might have to be set according to users' preferences
sleepDir=['~/neuron/sync_osc/' stringa]; % processed sleep scoring data

if ~exist(figDir,'dir')
    mkdir(figDir);
end

par_global=par; % probably unused

nfiles=length(filenames);

t_refr=4.;
n_neu=400;    % number of neurons
rate=12.; % avg rate [Hz]
r_osc_ampl=0.5;    % relative amplitude of the sinusoidal modulation (between 0 and 1)
transient=0.0;      % simulation time with STDP off
sim_time=10000;
seed=0;
inct=0.01;        % simulation time step
Rp_dt=10.*inct; % time step for population spike binning
n_neu_min=27; % we only consider recordings with n_neu_this>n_neu_min (that is, we disregard site5-rn1 - 16 neu - and site6-rn16 - 23 neu)

par_string={'t_refr','n_neu','rate','r_osc_ampl','transient','sim_time','seed','inct','Rp_dt','n_neu_min'};

for i=1:length(par_string)
    if(isfield(par,par_string(i)))
        eval([char(par_string(i)) '=par.' char(par_string(i)) ';']);
    end
end


for i=1:length(par_string)
    eval(['par.' char(par_string(i)) '=' char(par_string(i)) ';']);
end

if isempty(par.png_tail)
    get_field_names;
    % FontSizeThis=7;
    FontSizeThis=4;
elseif strcmp(par.png_tail,'_bs')
    get_field_names_bs;
    % FontSizeThis=14; % these have to be a bit smaller after inclusion of FOOOF features
    FontSizeThis=10;
else
    keyboard;
end

fprintf(['Total nuber of ' strrep(par.png_tail,'_','') ' measures:%i\n'],length(field_names_wc_ms));
fprintf('Uni:%i\n',n_uni);
fprintf('Bi:%i\n',n_bi);
fprintf('Multi:%i\n',n_multi);
fprintf('Bi+Multi:%i\n\n',n_bi+n_multi);


win_duration=30000; % 30s
max_n_sample=100; % max number of samples of n_neu_min neurons extracted from the total number of available neurons
par_this=par;
par_this.n_neu=n_neu_min;    % number of neurons
nwin=floor(sim_time/win_duration);
par_this.sim_time=win_duration;
par_this.plot_win_zoom=win_duration/3;

nfiles2use=nfiles-2;

i_train=0;

color_vect_eachfile=distinguishable_colors(nfiles);
ifile2use=0;
% win_names=cell(1,nfiles2use*nwin); % nwin might be different for each recording, we can't easily know it in advance
% filenames2use=cell(1,nfiles2use);

nfiles=length(filenames);
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
        if exist(fullfile(dataDir,strcat(data_file,'_measures_ms.mat')),'file')
            for ind_out=1:length(measure_mat_files)
                data{ind_out}=load(fullfile(dataDir,strcat(data_file,['_' measure_mat_files{ind_out} '.mat'])));
            end
        else
            for ind_out=1:length(measure_mat_files)
                data{ind_out}=load(fullfile(dataDir,strcat(data_file,['_' measure_mat_files{ind_out} '_sofar.mat'])));
            end
        end
    end

    ss_data=load(strcat(sleepDir,filesep,strrep(data_file,'.mat','_'),'_ss'));


    % checking if the number of win in spiking data and sleep scoring data is the same; if not, discard extra data from longer data
    nwin=length(data{1}.output_measures.f_rate_all);
    nwin_ss=length(ss_data.wake_4ormore_vect);

    ss_names={'wake_4ormore_vect','nrem_4ormore_vect','unclass_4ormore_vect','wake_3ormore_vect','nrem_3ormore_vect','unclass_3ormore_vect'};
    printf(data_file);

    if nwin<nwin_ss
        printf('spiking data has less win than sleep scoring data:');
        printf(['nwin spiking data = ' num2str(nwin)]);
        printf(['nwin sleep scoring = ' num2str(nwin_ss)]);

    elseif nwin>nwin_ss
        printf('spiking data has more win than sleep scoring data:');
        printf(['nwin spiking data = ' num2str(nwin)]);
        printf(['nwin sleep scoring = ' num2str(nwin_ss)]);

    else
        printf('spiking data has same win than sleep scoring data:');
        printf(['nwin spiking data = ' num2str(nwin)]);
        printf(['nwin sleep scoring = ' num2str(nwin_ss)]);
    end

    for iss=1:length(ss_names)
        if isfield(ss_data,ss_names(iss))
            eval([char(ss_names(iss)) '{ifile}=ss_data.' char(ss_names(iss)) '(1:min(nwin,nwin_ss));']); % we just retain the first min(nwin,nwin_ss)
        else
            keyboard;
        end
    end

    for ifn=1:length(field_names)
        data_this=data{file_ind(ifn)}.output_measures.([field_names{ifn} '_all'])(1,:); % for the time being we consider only i_sample==1
        data_now{ifile}.([field_names{ifn} '_all'])=data_this(1:min(nwin,nwin_ss));
    end
end
clear filethis data ss_data data_this;

field_names_ind=par.field_names_ind;

stringa=['feat_analyze_' stringa];

mystyle = hgexport('factorystyle');
mystyle.Units='normalized';
mystyle.FontMode='none';

mystyle_highres=mystyle;
mystyle_highres.Resolution=300; % best option for final figures

Job.decodeType='wake_vs_nrem';
nClass = 2;
c1_string_ind=strfind(Job.decodeType,'_vs_'); % Job.decodeType more generally, but only 'wake_vs_nrem' is used here
c1_string=Job.decodeType(1:c1_string_ind-1);
c2_string=Job.decodeType(c1_string_ind+4:end);
cnames={c1_string,c2_string};

dist_colors = distinguishable_colors(50);
orange=dist_colors(21,:); % orange
dark_green_2=dist_colors(20,:);
cherry=dist_colors(37,:);
clear color_mat;
color_mat(1,:)=dark_green_2; % M1R1
color_mat(2,:)=dist_colors(39,:); % dark green - M1R2
color_mat(3,:)=cherry; % M2R2
color_mat(4,:)=dist_colors(21,:); % orange - M4R1

color_mat_class=[0.8*ones(1,3);zeros(1,3)]; % wake, nrem

for ifile=1:nfiles
    filenames_wc{ifile}=['\color[rgb]{' sprintf('%f,%f,%f',color_mat(ifile,1),color_mat(ifile,2),color_mat(ifile,3)) '}' filenames{ifile}];
end


xtext=[1 4.5 7.5];
ytext1=1:0.3:2.5;
figure;
set(gcf,'Color',[1 1 1]);
set(gca,'YDir','reverse');

th=text(xtext(1),ytext1(1),c1_string,'FontUnits','normalized','FontSize',0.2,'Color',color_mat_class(1,:),'Interpreter','none','HorizontalAlignment','left','VerticalAlignment','middle');
th=text(xtext(1),ytext1(2),upper(c2_string),'FontUnits','normalized','FontSize',0.2,'Color',color_mat_class(2,:),'Interpreter','none','HorizontalAlignment','left','VerticalAlignment','middle');
hold on;

xlim([0 4]);
ylim([0.8 2.1]);
set(gcf,'Position',[   608   609   225   267]);
set(gca,'YDir','reverse'); % this has to be done again, not sure why
axis off;
if PLOT.print
    figure_name=[sleepDir filesep 'all_violin_legend'];
    export_fig(gcf,[figure_name '.png']); % using exportfig so it's nicely cropped
end

figure;
set(gcf,'Color',[1 1 1]);
set(gca,'YDir','reverse');

th=text(xtext(1),ytext1(1),c1_string,'FontUnits','normalized','FontSize',0.2,'Color',color_mat_class(1,:),'Interpreter','none','HorizontalAlignment','left','VerticalAlignment','middle');
th=text(xtext(2),ytext1(1),upper(c2_string),'FontUnits','normalized','FontSize',0.2,'Color',color_mat_class(2,:),'Interpreter','none','HorizontalAlignment','left','VerticalAlignment','middle');
hold on;

xlim([0 8]);
ylim([0.8 2.1]);
set(gcf,'Position',[603   604   350   260]);
set(gca,'YDir','reverse'); % this has to be done again, not sure why
axis off;
if PLOT.print
    figure_name=[sleepDir filesep 'all_violin_legend_v2'];
    export_fig(gcf,[figure_name '.png'],'-m2'); % using exportfig so it's nicely cropped
end





xvect=1:nfiles;
class_bias=[-.2 .2];
vwidth=0.15;
for ind=1:length(field_names_ind)
    clear data_this tmp nTrialsPerClass; % nTrialsPerClass can differ for different measures because of NaN
    for ifile=1:nfiles
        data_this{ifile} = data_now{ifile}.([field_names{field_names_ind(ind)} '_all']);
        eval(['data_this_1 = data_this{ifile}(logical(' c1_string '_3ormore_vect{ifile}));']);
        eval(['data_this_2 = data_this{ifile}(logical(' c2_string '_3ormore_vect{ifile}));']);
        tmp{ifile,1}=data_this_1;
        tmp{ifile,2}=data_this_2;
        for iClass = 1:nClass
            nTrialsPerClass(ifile,iClass) = length(tmp{ifile,iClass});
        end
    end
    nTrials=sum(sum(nTrialsPerClass));

    % prepare data for violinplot
    data4vp=nan(nTrials,1);
    data4vp_labels=cell(nTrials,1);
    ind_lab=1;
    for ifile=1:nfiles
        for iClass = 1:nClass
            data4vp(ind_lab:ind_lab+nTrialsPerClass(ifile,iClass)-1)=tmp{ifile,iClass};
            [data4vp_labels{ind_lab:ind_lab+nTrialsPerClass(ifile,iClass)-1}]=deal([filenames{ifile} cnames{iClass}]);
            grouporder{(ifile-1)*nClass+iClass}=[filenames{ifile} cnames{iClass}];
            ind_lab=ind_lab+nTrialsPerClass(ifile,iClass);
        end
    end
    min_this=min(data4vp);
    max_this=max(data4vp);
    range_this=max_this-min_this;
    ylim_vect=[min_this-range_this*0.02 max_this+range_this*0.02];

    figure();
    set(gcf,'Color',[1 1 1]);
    vp=violinplot(data4vp,data4vp_labels,'GroupOrder',grouporder,'Width',vwidth);
    for ifile=1:nfiles
        for iClass = 1:nClass
            vp((ifile-1)*nClass+iClass).ViolinColor={color_mat(ifile,:)};
            vp((ifile-1)*nClass+iClass).EdgeColor=color_mat_class(iClass,:);
            vp((ifile-1)*nClass+iClass).MedianColor=color_mat_class(iClass,:);
            vp((ifile-1)*nClass+iClass).ScatterPlot.XData=vp((ifile-1)*nClass+iClass).ScatterPlot.XData-((ifile-1)*nClass+iClass)+xvect(ifile)+class_bias(iClass);
            ver_this=vp((ifile-1)*nClass+iClass).ViolinPlot.Vertices;
            ver_this_x=ver_this(:,1);
            ver_this_x=ver_this_x-((ifile-1)*nClass+iClass)+xvect(ifile)+class_bias(iClass);
            vp((ifile-1)*nClass+iClass).ViolinPlot.Vertices=[ver_this_x ver_this(:,2)];
            vp((ifile-1)*nClass+iClass).MeanPlot.XData=vp((ifile-1)*nClass+iClass).MeanPlot.XData-((ifile-1)*nClass+iClass)+xvect(ifile)+class_bias(iClass);
            vp((ifile-1)*nClass+iClass).MedianPlot.XData=vp((ifile-1)*nClass+iClass).MedianPlot.XData-((ifile-1)*nClass+iClass)+xvect(ifile)+class_bias(iClass);
            ver_this=vp((ifile-1)*nClass+iClass).BoxPlot.Vertices;
            ver_this_x=ver_this(:,1);
            ver_this_x=ver_this_x-((ifile-1)*nClass+iClass)+xvect(ifile)+class_bias(iClass);
            vp((ifile-1)*nClass+iClass).BoxPlot.Vertices=[ver_this_x ver_this(:,2)];
            vp((ifile-1)*nClass+iClass).WhiskerPlot.XData=vp((ifile-1)*nClass+iClass).WhiskerPlot.XData-((ifile-1)*nClass+iClass)+xvect(ifile)+class_bias(iClass);
            vp((ifile-1)*nClass+iClass).ShowWhiskers=0; % better not showing whiskers
        end
    end
    ylabel(field_names_long_wc_ms{field_names_ind(ind)});
    xlim([1-vwidth*1.5+class_bias(1) nfiles+vwidth*1.5+class_bias(2)]);
    ylim(ylim_vect);
    set(gca,'XTickLabel',filenames_wc);
    if ind==2
        xlabel('recordings');
    end
    set(gca,'Position',[0.1907    0.1822    0.7143    0.7428]);
    figure_name=[sleepDir filesep 'all_decodeAprime_violin_' Job.decodeType '_' field_names{field_names_ind(ind)}];
    hgexport(gcf,figure_name,mystyle_highres,'Format','png');
end

output_struct=[];

return
