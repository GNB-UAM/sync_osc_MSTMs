function output_struct=analyze_sleep_scoring_Form22(dataDir,filenames,stringa,par)
% analyzes sleep scoring data and yields aggregate scores corresponding to the temporal resolution of the spike train data (30s in the original paper)

figDir=['~/neuron/sync_osc/' stringa]; % this might have to be set according to users' preferences

if ~exist(figDir,'dir')
    mkdir(figDir);
end

par_global=par; % probably unused

win_duration=30000; % 30s, used in analyze_osc_train_ms_win_data
ss_win_duration=10000; % as replied in email from Formozov
ss_win_overlap=5000;

light_gray=0.8*ones(1,3);

nfiles=length(filenames);
n_neu_vect=nan(1,nfiles);
n_neu_wo_silence_vect=nan(1,nfiles);
min_n_spikes=nan(1,nfiles);
mean_n_spikes=nan(1,nfiles);
median_n_spikes=nan(1,nfiles);
max_n_spikes=nan(1,nfiles);
max_all_isi=nan(1,nfiles);


t_refr=4.;
n_neu=400;    % number of neurons
rate=12.; % avg rate [Hz]
r_osc_ampl=0.5;    % relative amplitude of the sinusoidal modulation (between 0 and 1)
transient=0.0;      % simulation time with STDP off
sim_time=10000;
seed=0;
inct=0.01;        % simulation time step
Rp_dt=10.*inct; % time step for population spike binning

par_string={'t_refr','n_neu','rate','r_osc_ampl','transient','sim_time','seed','inct','Rp_dt'};


for i=1:length(par_string)
    if(isfield(par,par_string(i)))
        eval([char(par_string(i)) '=par.' char(par_string(i)) ';']);
    end
end


for i=1:length(par_string)
    eval(['par.' char(par_string(i)) '=' char(par_string(i)) ';']);
end



mystyle = hgexport('factorystyle');
mystyle.Units='normalized';
mystyle.FontMode='none';

par.PLOT=1;
par.figDir=figDir;

for ifile=1:nfiles
    clear spiketimes n_spikes t_first t_last min_isi n_short_isi percent_short_isi;
    filethis=load(fullfile(dataDir,filenames{ifile}));
    if isfield(filethis,'SleepScoring')
        sleep_scoring=filethis.SleepScoring;
    else
        keyboard;
    end

    figure
    plot(sleep_scoring.Wake,'b');
    hold on;
    plot(sleep_scoring.NREM,'r');
    plot(sleep_scoring.REM,'g');
    legend('wake','NREM','REM');
    xlabel('sample');
    ylabel('sleep scoring');
    title([strrep(filenames{ifile},'.mat','')],'FontWeight','normal','Interpreter','none');
    set(gcf,'Position',[4         549        1916         413]);
    figure_name=strcat(figDir,filesep,strrep(filenames{ifile},'.mat','_'),'_sleep_scoring','.png');
    hgexport(gcf,figure_name,mystyle,'Format','png');


    n_sample=length(sleep_scoring.Wake);
    nss_per_win=win_duration./ss_win_overlap-(ss_win_duration/ss_win_overlap)/2; % number of ss 2 consider for each win
    nss_2skip=(ss_win_duration/ss_win_overlap)/2; % number of ss to skip before next win begins
    nss_per_win_total=nss_per_win+nss_2skip;
    nwin=floor(n_sample/nss_per_win_total);

    % these count the number of small wins of each type inside each win
    wake_vect=zeros(1,nwin);
    nrem_vect=zeros(1,nwin);
    rem_vect=zeros(1,nwin);
    unclass_vect=zeros(1,nwin);

    % these are binary
    wake_4ormore_vect=zeros(1,nwin);
    nrem_4ormore_vect=zeros(1,nwin);
    unclass_4ormore_vect=zeros(1,nwin);

    wake_3ormore_vect=zeros(1,nwin);
    nrem_3ormore_vect=zeros(1,nwin);
    unclass_3ormore_vect=zeros(1,nwin);

    iss=1;

    for iwin=1:nwin
        wake_this=sleep_scoring.Wake(iss:iss+nss_per_win-1);
        nrem_this=sleep_scoring.NREM(iss:iss+nss_per_win-1);
        rem_this=sleep_scoring.REM(iss:iss+nss_per_win-1);

        wake_vect(iwin)=sum(wake_this);
        nrem_vect(iwin)=sum(nrem_this);
        rem_vect(iwin)=sum(rem_this);

        if wake_vect(iwin)>=4 && (nrem_vect(iwin)==0 && rem_vect(iwin)==0) % at least 4 of the kind, none classified as another kind
            wake_4ormore_vect(iwin)=1;
        elseif nrem_vect(iwin)>=4 && (wake_vect(iwin)==0 && rem_vect(iwin)==0)
            nrem_4ormore_vect(iwin)=1;
        else
            unclass_4ormore_vect(iwin)=1;
        end
        if wake_vect(iwin)>=3 && (nrem_vect(iwin)==0 && rem_vect(iwin)==0) % at least 3 of the kind, none classified as another kind
            wake_3ormore_vect(iwin)=1;
        elseif nrem_vect(iwin)>=3 && (wake_vect(iwin)==0 && rem_vect(iwin)==0)
            nrem_3ormore_vect(iwin)=1;
        else
            unclass_3ormore_vect(iwin)=1;
        end

        iss=iss+nss_per_win_total;
    end

    unclass_vect=nss_per_win-(wake_vect+nrem_vect+rem_vect);
    t_ss_vect=win_duration*(1:nwin)-win_duration./ss_win_overlap;

    figure
    plot(t_ss_vect,wake_vect,'b');
    hold on;
    plot(t_ss_vect,nrem_vect,'r');
    plot(t_ss_vect,rem_vect,'g');
    legend('wake','NREM','REM');
    xlabel('t [ms]');
    ylabel('sleep scoring');
    title([strrep(filenames{ifile},'.mat','')],'FontWeight','normal','Interpreter','none');
    set(gcf,'Position',[4         549        1916         413]);
    figure_name=strcat(figDir,filesep,strrep(filenames{ifile},'.mat','_'),'_sleep_scoring_win','.png');
    hgexport(gcf,figure_name,mystyle,'Format','png');

    n_wake_4ormore=sum(wake_4ormore_vect);
    n_nrem_4ormore=sum(nrem_4ormore_vect);
    n_unclass_4ormore=sum(unclass_4ormore_vect);
    n_wake_3ormore=sum(wake_3ormore_vect);
    n_nrem_3ormore=sum(nrem_3ormore_vect);
    n_unclass_3ormore=sum(unclass_3ormore_vect);

    ss_mat=[n_wake_4ormore n_nrem_4ormore n_unclass_4ormore;n_wake_3ormore n_nrem_3ormore n_unclass_3ormore];

    figure
    bh=bar(ss_mat,'stacked');
    bh(1).FaceColor=[0 0 1];
    bh(2).FaceColor=[1 0 0];
    bh(3).FaceColor=light_gray;
    set(gca,'XLim',[0 3]);
    set(gca,'XTickLabel',{'4 or more','3 or more'});
    ylabel('# windows');
    title({[strrep(filenames{ifile},'.mat','') ' : ' num2str(nwin) ' win; ' num2str(n_wake_4ormore) ' wake ' num2str(n_nrem_4ormore) ' nrem'], [num2str(n_wake_3ormore) ' wake ' num2str(n_nrem_3ormore) ' nrem']},'FontWeight','normal','Interpreter','none');
    figure_name=strcat(figDir,filesep,strrep(filenames{ifile},'.mat','_'),'_sleep_scoring_bar','.png');
    hgexport(gcf,figure_name,mystyle,'Format','png');

    save(strcat(figDir,filesep,strrep(filenames{ifile},'.mat','_'),'_ss'),'n*','*vect');
end

output_struct=[];

return;
