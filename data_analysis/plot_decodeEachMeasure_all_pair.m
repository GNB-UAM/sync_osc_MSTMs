clear zmcorrTest zmcorrTrain stdcorrTrain stdcorrTest CC

if isempty(png_tail)
    get_field_names;
    FontSizeThis=5;
    FontSizeThisCb=16;
elseif strcmp(png_tail,'_bs')
    get_field_names_bs;
    XFontSizeThis=10; % a bit smaller for x axis
    FontSizeThis=11;
    FontSizeThisCb=16;
else
    keyboard;
end

nfiles=length(filenames);

sign_level_vect=[99 99.9 99.99 99.999];
zmcorrNullTestAll=cell(1,nfiles);

Aprime=nan(nfiles,length(field_names));
Aprime_std=nan(nfiles,length(field_names));
Aprime_thr=nan(nfiles,length(field_names));

Aprime_pair=nan(nfiles,length(field_names),length(field_names));
AprimeNull_pair=nan(nfiles,length(field_names),length(field_names),Job.nPerm);
Aprime_pair_std=nan(nfiles,length(field_names),length(field_names));
Aprime_pair_syn=nan(nfiles,length(field_names),length(field_names));

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
        % data=load(fullfile(dataDir,strcat(data_file,'_measures_ms.mat')));
    end

    clear filethis data ss_data;

    decodeResultFilename = ['single_' ...
        Job.decodeType '_' data_file '_norm.mat' ];

    decodeResultFilename = strrep(decodeResultFilename,'.mat',['_' C.LambdaString '_' names_string '.mat']);
    D=load([sleepDir,'/' decodeResultFilename] ,'-mat','zmcorrTrain','zmcorrTest','stdcorrTrain','stdcorrTest','nTrialsPerClass');


    for kk=1:length(field_names)
        Aprime(ifile,kk)=D.zmcorrTest.(field_names{kk});
        Aprime_std(ifile,kk)=D.stdcorrTest.(field_names{kk});
    end

    decodeResultFilename = ['pair_' ...
        Job.decodeType '_' data_file '_norm.mat' ];

    decodeNullResultFilename = strrep(decodeResultFilename,'.mat',['_' Job.NullString '_' names_string '.mat']);
    DN=load([sleepDir,'/' decodeNullResultFilename] ,'-mat','zmcorrTrain','zmcorrTest','stdcorrTrain','stdcorrTest','nTrialsPerClass');

    decodeResultFilename = strrep(decodeResultFilename,'.mat',['_' C.LambdaString '_' names_string '.mat']);
    D=load([sleepDir,'/' decodeResultFilename] ,'-mat','zmcorrTrain','zmcorrTest','stdcorrTrain','stdcorrTest','nTrialsPerClass');


    for ifn=1:length(field_names)
        for jfn=(ifn+1):length(field_names)
            Aprime_pair(ifile,ifn,jfn)=D.zmcorrTest.([field_names{ifn} '__' field_names{jfn}]);
            Aprime_pair_std(ifile,ifn,jfn)=D.stdcorrTest.([field_names{ifn} '__' field_names{jfn}]);
            Aprime_pair_syn(ifile,ifn,jfn)=(Aprime_pair(ifile,ifn,jfn)-max(Aprime(ifile,ifn),Aprime(ifile,jfn)))/max(Aprime(ifile,ifn),Aprime(ifile,jfn));
            Aprime_pair(ifile,jfn,ifn)=Aprime_pair(ifile,ifn,jfn);
            Aprime_pair_std(ifile,jfn,ifn)=Aprime_pair_std(ifile,ifn,jfn);
            Aprime_pair_syn(ifile,jfn,ifn)=Aprime_pair_syn(ifile,ifn,jfn);

            zmcorrNullTestAll{ifile}=[zmcorrNullTestAll{ifile} DN.zmcorrTest.([field_names{ifn} '__' field_names{jfn}])]; % p=0.001 thr is calculated by lumping across measures, but not recordings
        end
        Aprime_pair(ifile,ifn,ifn)=Aprime(ifile,ifn);
        Aprime_pair_std(ifile,ifn,ifn)=Aprime_std(ifile,ifn);
        Aprime_pair_syn(ifile,ifn,ifn)=0;
    end
end
clear D DN;
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
clear zmcorrNullTestAll_mat;

Aprime_median=squeeze(median(Aprime,1));
Aprime_pair_median=squeeze(median(Aprime_pair,1));
Aprime_pair_syn_median=squeeze(median(Aprime_pair_syn,1));

zmcorrNullTestAll_median=squeeze(median(zmcorrNullTestAll,1));
clear zmcorrNullTestAll;
for sign_level_i=1:length(sign_level_vect);
    sign_level=sign_level_vect(sign_level_i);
    Aprime_thr_all(sign_level_i)=prctile(zmcorrNullTestAll_median,sign_level); % p=0.001 and higher are evaluated after lumping across measures
end
clear zmcorrNullTestAll_median;

Aprime_thr_all_median=squeeze(median(Aprime_thr_all,1)); % doesn't do anything, just for consistent naming with plot_decodeEachMeasureEachFile_single



mystyle = hgexport('factorystyle');
mystyle.Units='normalized';
mystyle.FontMode='none';

mystyle_highres=mystyle;
mystyle_highres.Resolution=300;

% sorting according to (single) Aprime
figure();
set(gcf,'Color',[1 1 1]);
[Aprime_sorted Aprime_sorted_ind]=sort(squeeze(Aprime_median),'descend');
Aprime_pair_sorted=Aprime_pair_median(:,Aprime_sorted_ind); % sort columns
Aprime_pair_sorted=Aprime_pair_sorted(Aprime_sorted_ind,:); % sort rows

set(gcf,'Position',[1 1 1200 1000]);

ut=triu(true(size(Aprime_pair_sorted))); % we only consider the upper triangular part including the diagonal
Aprime_pair_2plot=nan(size(Aprime_pair_sorted));
Aprime_pair_2plot(ut)=Aprime_pair_sorted(ut);

imAlpha=ones(size(Aprime_pair_2plot));
imAlpha(isnan(Aprime_pair_2plot))=0;
imagesc(Aprime_pair_2plot,'AlphaData',imAlpha);
set(gca,'color',0.95*[1 1 1]);
axis square
set(gca,'xaxisLocation','top')
set(gca,'XTick',1:1:length(field_names_wc_ms));
set(gca,'XTickLabels',strrep(field_names_wc_ms(Aprime_sorted_ind),'_','\_'),'fontsize',FontSizeThis);
xtickangle(gca,45);
set(gca,'YTick',1:1:length(field_names_wc_ms));
set(gca,'YTickLabels',strrep(field_names_wc_ms(Aprime_sorted_ind),'_','\_'));
cbh=colorbar;
set(cbh,'FontSize',FontSizeThisCb);
pos_vect=get(cbh,'Position');
th2=annotation('textbox',[pos_vect(1)+pos_vect(3)+0.01 pos_vect(2)+0.46*pos_vect(4) 0.012 0.046],'String','A''','FontSize',24,'LineStyle','none','VerticalAlignment','middle');
figure_name=[sleepDir filesep 'all_decodeAprime_' Job.decodeMode '_' Job.decodeType png_tail '_' names_string];
hgexport(gcf,figure_name,mystyle,'Format','png');



figure();
set(gcf,'Color',[1 1 1]);
[Aprime_sorted Aprime_sorted_ind]=sort(squeeze(Aprime_median),'descend');
Aprime_pair_sorted=Aprime_pair_median(:,Aprime_sorted_ind); % sort columns
Aprime_pair_sorted=Aprime_pair_sorted(Aprime_sorted_ind,:); % sort rows

set(gcf,'Position',[1 1 1200 1000]);

ut=triu(true(size(Aprime_pair_sorted))); % we only consider the upper triangular part including the diagonal
Aprime_pair_2plot=nan(size(Aprime_pair_sorted));
Aprime_pair_2plot(ut)=Aprime_pair_sorted(ut);

imAlpha=ones(size(Aprime_pair_2plot));
imAlpha(isnan(Aprime_pair_2plot))=0;
imagesc(Aprime_pair_2plot,'AlphaData',imAlpha);
set(gca,'color',0.95*[1 1 1]);
axis square
set(gca,'xaxisLocation','top')
set(gca,'XTick',1:1:length(field_names_long_wc_ms));
set(gca,'XTickLabels',strrep(field_names_long_wc_ms(Aprime_sorted_ind),'_','\_'),'fontsize',FontSizeThis);
xtickangle(gca,45);
set(gca,'YTick',1:1:length(field_names_long_wc_ms));
set(gca,'YTickLabels',strrep(field_names_long_wc_ms(Aprime_sorted_ind),'_','\_'));
if exist('XFontSizeThis','var')
    ca=get(gca);
    ca.XAxis.FontSize=XFontSizeThis;
end
cbh=colorbar;
set(cbh,'FontSize',FontSizeThisCb);
pos_vect=get(gca,'Position');
cb_pos_vect=get(cbh,'Position');
if strcmp(png_tail,'_bs')
    cb_pos_vect=[pos_vect(1)+pos_vect(3)+0.05*pos_vect(3) cb_pos_vect(2:end)];
set(cbh,'Position',cb_pos_vect);
set(gca,'Position',pos_vect); % we need to reset this after setting cb pos
th2=annotation('textbox',[cb_pos_vect(1)+cb_pos_vect(3)+0.035 cb_pos_vect(2)+0.46*cb_pos_vect(4) 0.012 0.046],'String','A''','FontSize',24,'LineStyle','none','VerticalAlignment','middle');
else
th2=annotation('textbox',[cb_pos_vect(1)+cb_pos_vect(3)+0.01 cb_pos_vect(2)+0.46*cb_pos_vect(4) 0.012 0.046],'String','A''','FontSize',24,'LineStyle','none','VerticalAlignment','middle');
end
figure_name=[sleepDir filesep 'all_decodeAprime_' Job.decodeMode '_' Job.decodeType '_longn' png_tail '_' names_string];
hgexport(gcf,figure_name,mystyle_highres,'Format','png');







figure();
set(gcf,'Color',[1 1 1]);
Aprime_pair_syn_sorted=Aprime_pair_syn_median(:,Aprime_sorted_ind); % sort columns
Aprime_pair_syn_sorted=Aprime_pair_syn_sorted(Aprime_sorted_ind,:); % sort rows

set(gcf,'Position',[1 1 1200 1000]);

ut=triu(true(size(Aprime_pair_syn_sorted)),1); % we only consider the upper triangular part excluding the diagonal
Aprime_pair_syn_2plot=nan(size(Aprime_pair_syn_sorted));
Aprime_pair_syn_2plot(ut)=Aprime_pair_syn_sorted(ut);

imAlpha=ones(size(Aprime_pair_syn_2plot));
imAlpha(isnan(Aprime_pair_syn_2plot))=0;
imagesc(Aprime_pair_syn_2plot,'AlphaData',imAlpha);
set(gca,'color',0.95*[1 1 1]);
axis square
set(gca,'xaxisLocation','top')
set(gca,'XTick',1:1:length(field_names_wc_ms));
set(gca,'XTickLabels',strrep(field_names_wc_ms(Aprime_sorted_ind),'_','\_'),'fontsize',FontSizeThis);
xtickangle(gca,45);
set(gca,'YTick',1:1:length(field_names_wc_ms));
set(gca,'YTickLabels',strrep(field_names_wc_ms(Aprime_sorted_ind),'_','\_'));
cbh=colorbar;
set(cbh,'FontSize',FontSizeThisCb);
pos_vect=get(cbh,'Position');
th2=annotation('textbox',[pos_vect(1)+pos_vect(3)+0.01 pos_vect(2)+0.46*pos_vect(4) 0.012 0.046],'String','S_{A''}','FontSize',24,'LineStyle','none','VerticalAlignment','middle');
figure_name=[sleepDir filesep 'all_decodeAprime_syn_' Job.decodeMode '_' Job.decodeType png_tail '_' names_string];
hgexport(gcf,figure_name,mystyle,'Format','png');



figure();
set(gcf,'Color',[1 1 1]);
Aprime_pair_syn_sorted=Aprime_pair_syn_median(:,Aprime_sorted_ind); % sort columns
Aprime_pair_syn_sorted=Aprime_pair_syn_sorted(Aprime_sorted_ind,:); % sort rows

set(gcf,'Position',[1 1 1200 1000]);

ut=triu(true(size(Aprime_pair_syn_sorted)),1); % we only consider the upper triangular part excluding the diagonal
Aprime_pair_syn_2plot=nan(size(Aprime_pair_syn_sorted));
Aprime_pair_syn_2plot(ut)=Aprime_pair_syn_sorted(ut);

imAlpha=ones(size(Aprime_pair_syn_2plot));
imAlpha(isnan(Aprime_pair_syn_2plot))=0;
imagesc(Aprime_pair_syn_2plot,'AlphaData',imAlpha);
set(gca,'color',0.95*[1 1 1]);
axis square
set(gca,'xaxisLocation','top')
set(gca,'XTick',1:1:length(field_names_long_wc_ms));
set(gca,'XTickLabels',strrep(field_names_long_wc_ms(Aprime_sorted_ind),'_','\_'),'fontsize',FontSizeThis);
xtickangle(gca,45);
set(gca,'YTick',1:1:length(field_names_long_wc_ms));
set(gca,'YTickLabels',strrep(field_names_long_wc_ms(Aprime_sorted_ind),'_','\_'));
if exist('XFontSizeThis','var')
    ca=get(gca);
    ca.XAxis.FontSize=XFontSizeThis;
end
cbh=colorbar;
set(cbh,'FontSize',FontSizeThisCb);
pos_vect=get(gca,'Position');
cb_pos_vect=get(cbh,'Position');
if strcmp(png_tail,'_bs')
    cb_pos_vect=[pos_vect(1)+pos_vect(3)+0.05*pos_vect(3) cb_pos_vect(2:end)];
set(cbh,'Position',cb_pos_vect);
set(gca,'Position',pos_vect); % we need to reset this after setting cb pos
th2=annotation('textbox',[cb_pos_vect(1)+cb_pos_vect(3)+0.035 cb_pos_vect(2)+0.54*cb_pos_vect(4) 0.012 0.046],'String','S_{A''}','FontSize',24,'LineStyle','none','VerticalAlignment','middle');
else
th2=annotation('textbox',[cb_pos_vect(1)+cb_pos_vect(3)+0.01 cb_pos_vect(2)+0.46*cb_pos_vect(4) 0.012 0.046],'String','S_{A''}','FontSize',24,'LineStyle','none','VerticalAlignment','middle');
end
figure_name=[sleepDir filesep 'all_decodeAprime_syn_' Job.decodeMode '_' Job.decodeType '_longn' png_tail '_' names_string];
hgexport(gcf,figure_name,mystyle_highres,'Format','png');



dist_colors = distinguishable_colors(50);
orange=dist_colors(21,:); % orange
cyan=dist_colors(23,:); % cyan

stringa_pair_vect{1}=['\color[rgb]{' sprintf('%f ',color_mat(1,:)) '}uni\color[rgb]{0 0 0}-\color[rgb]{' sprintf('%f ',color_mat(1,:)) '}uni'];
stringa_pair_vect{2}=['\color[rgb]{' sprintf('%f ',color_mat(2,:)) '}bi\color[rgb]{0 0 0}-\color[rgb]{' sprintf('%f ',color_mat(2,:)) '}bi'];
stringa_pair_vect{3}=['\color[rgb]{' sprintf('%f ',color_mat(3,:)) '}multi\color[rgb]{0 0 0}-\color[rgb]{' sprintf('%f ',color_mat(3,:)) '}multi'];
stringa_pair_vect{4}=['\color[rgb]{' sprintf('%f ',color_mat(1,:)) '}uni\color[rgb]{0 0 0}-\color[rgb]{' sprintf('%f ',color_mat(2,:)) '}bi'];
stringa_pair_vect{5}=['\color[rgb]{' sprintf('%f ',color_mat(1,:)) '}uni\color[rgb]{0 0 0}-\color[rgb]{' sprintf('%f ',color_mat(3,:)) '}multi'];
stringa_pair_vect{6}=['\color[rgb]{' sprintf('%f ',color_mat(2,:)) '}bi\color[rgb]{0 0 0}-\color[rgb]{' sprintf('%f ',color_mat(3,:)) '}multi'];




% most discriminating pairs
fid = fopen(['decode_' Job.decodeMode '_' Job.decodeType '_all' png_tail '_' C.LambdaString '_' names_string '.txt'],'w');
printf('best decoding results at the population level\n');
fprintf(fid,'\n%i measures',size(Aprime_pair_sorted,1));
fprintf(fid,'\n\ndecoding A''>0.80');
% most discriminating pair
ut=triu(true(size(Aprime_pair_syn_sorted)),1); % we only consider the upper triangular part excluding the diagonal
Aprime_pair_sorted_ut=Aprime_pair_sorted;
Aprime_pair_sorted_ut(~ut)=0; % we set to 0 all values, apart from upper triangular

Aprime_pair_sorted_above80=Aprime_pair_sorted_ut>0.80;
N80=sum(sum(Aprime_pair_sorted_above80));
N=(size(Aprime_pair_sorted,1)*(size(Aprime_pair_sorted,1)-1))/2;
P80=N80/N;
fprintf(fid,'\nN80=%i\nN=%i\nP80=%f\n',N80,N,P80);
[ind_row_above80 ind_col_above80]=find(Aprime_pair_sorted_above80);
Aprime_pair_sorted_vect_above80=zeros(1,length(ind_row_above80));

for ind=1:length(ind_row_above80)
    fprintf(fid,['\nA''=' num2str(Aprime_pair_sorted(ind_row_above80(ind),ind_col_above80(ind))) ' for '     field_names{Aprime_sorted_ind(ind_row_above80(ind))} ' - '     field_names{Aprime_sorted_ind(ind_col_above80(ind))}]);
    Aprime_pair_sorted_vect_above80(ind)=Aprime_pair_sorted(ind_row_above80(ind),ind_col_above80(ind));
end

[Aprime_pair_sorted_vect_above80_sorted Aprime_pair_sorted_vect_above80_sorted_ind]=sort(Aprime_pair_sorted_vect_above80,'descend');
fprintf(fid,'\n\nnow ordered\n');
for ind=1:length(ind_row_above80)
    fprintf(fid,['\nA''=' num2str(Aprime_pair_sorted_vect_above80_sorted(ind)) ' for '     field_names{Aprime_sorted_ind(ind_row_above80(Aprime_pair_sorted_vect_above80_sorted_ind(ind)))} ' - '     field_names{Aprime_sorted_ind(ind_col_above80(Aprime_pair_sorted_vect_above80_sorted_ind(ind)))}]);
end



% top 1% or 5% most discriminating pairs

Aprime_pair_vect=Aprime_pair_median(ut); % takes elements by columns
ind_pair_vect=[]; % better to just store indexes
field_names_pair_vect={};
clear isuni_vect isbi_vect ismulti_vect;
ind=0;
for icol=2:size(Aprime_pair_median,1)
    for irow=1:(icol-1)
        ind=ind+1;
        ind_pair_vect(ind,1)=irow;
        field_names_pair_vect{ind,1}=field_names{irow};
        isuni_vect(ind,1)=isuni(irow);
        isbi_vect(ind,1)=isbi(irow);
        ismulti_vect(ind,1)=ismulti(irow);

        ind_pair_vect(ind,2)=icol;
        field_names_pair_vect{ind,2}=field_names{icol};
        isuni_vect(ind,2)=isuni(icol);
        isbi_vect(ind,2)=isbi(icol);
        ismulti_vect(ind,2)=ismulti(icol);
    end
end

[Aprime_pair_vect_sorted Aprime_pair_vect_sorted_ind]=sort(Aprime_pair_vect,'descend');

% % double-checking ... ok
% for ind=1:5
%     printf(['\nA''=' num2str(Aprime_pair_vect_sorted(ind)) ' for '     field_names_pair_vect{Aprime_pair_vect_sorted_ind(ind),1} ' - '     field_names_pair_vect{Aprime_pair_vect_sorted_ind(ind),2}]);
% end



% expected values
Nuue=n_uni*(n_uni-1)/2; % order does not matter
Nbbe=n_bi*(n_bi-1)/2;
Nmme=n_multi*(n_multi-1)/2;
Nube=n_uni*n_bi;
Nume=n_uni*n_multi;
Nbme=n_bi*n_multi;

topp_vect=[0.01 0.05];
for topp=topp_vect
    Aprime_pair_vect_sorted_top=Aprime_pair_vect_sorted(1:round(topp*N));

    ind_pair_vect_top_2c=ind_pair_vect(Aprime_pair_vect_sorted_ind(1:round(topp*N)),:);
    ind_pair_vect_top=ind_pair_vect_top_2c(:); % takes elements by columns

    field_names_pair_vect_top=field_names_pair_vect(Aprime_pair_vect_sorted_ind(1:round(topp*N)),:);
    field_names_pair_vect_top=field_names_pair_vect_top(:); % takes elements by columns

    if topp==0.01
        fid = fopen(['decode_top' num2str(topp*100) '_' Job.decodeMode '_' Job.decodeType '_all' png_tail '_' C.LambdaString '_' names_string '.txt'],'w');
        fid_csv = fopen(['decode_top' num2str(topp*100) '_' Job.decodeMode '_' Job.decodeType '_all' png_tail '_' C.LambdaString '_' names_string '.csv'],'w');
        fprintf(fid,'median results over all recordings\n');
        fprintf(fid_csv,'A'',S'',MSTM1,MSTM2,A''1,A''2\n');
        for ind=1:round(topp*N)
            fprintf(fid,['\nA''=' num2str(Aprime_pair_vect_sorted(ind)) ' for '     field_names_pair_vect{Aprime_pair_vect_sorted_ind(ind),1} ' - '     field_names_pair_vect{Aprime_pair_vect_sorted_ind(ind),2}]);
            fprintf(fid_csv,[num2str(Aprime_pair_vect_sorted(ind))...
                ',' num2str(Aprime_pair_syn_median(ind_pair_vect_top_2c(ind,1),ind_pair_vect_top_2c(ind,2)))... % S'
                ',' field_names_long_pair_vect{Aprime_pair_vect_sorted_ind(ind),1} ',' field_names_long_pair_vect{Aprime_pair_vect_sorted_ind(ind),2} ...
                ',' num2str(Aprime_pair_median(ind_pair_vect_top_2c(ind,1),ind_pair_vect_top_2c(ind,1))) ',' num2str(Aprime_pair_median(ind_pair_vect_top_2c(ind,2),ind_pair_vect_top_2c(ind,2))) '\n']); % single decoding
        end
        fclose(fid);
        fclose(fid_csv);
    end

    [Nuu Nub Num Nbb Nbm Nmm]=deal(0);

    % Nuue+Nbbe+Nmme+Nube+Nume+Nbme==N % yes

    for ind=1:round(topp*N)
        ind_this=Aprime_pair_vect_sorted_ind(ind);
        switch true
            case isuni_vect(ind_this,1) && isuni_vect(ind_this,2)
                Nuu=Nuu+1;
            case isbi_vect(ind_this,1) && isbi_vect(ind_this,2)
                Nbb=Nbb+1;
            case ismulti_vect(ind_this,1) && ismulti_vect(ind_this,2)
                Nmm=Nmm+1;
            case (isuni_vect(ind_this,1) && isbi_vect(ind_this,2)) || (isuni_vect(ind_this,2) && isbi_vect(ind_this,1))
                Nub=Nub+1;
            case (isuni_vect(ind_this,1) && ismulti_vect(ind_this,2)) || (isuni_vect(ind_this,2) && ismulti_vect(ind_this,1))
                Num=Num+1;
            case (isbi_vect(ind_this,1) && ismulti_vect(ind_this,2)) || (isbi_vect(ind_this,2) && ismulti_vect(ind_this,1))
                Nbm=Nbm+1;
        end
    end

    % Nuu+Nbb+Nmm+Nub+Num+Nbm==round(topp*N) % yes


    N_vect=[Nuu Nbb Nmm Nub Num Nbm];
    Ne_vect=topp*[Nuue Nbbe Nmme Nube Nume Nbme];

    [N_vect_sorted N_vect_sorted_ind]=sort(N_vect,'descend');

    figure
    bh=bar(N_vect_sorted);
    hold on;
    x1=get(bh(1),'XData');
    set(bh,'FaceColor',cyan);
    BarWidthThis=get(bh(1),'BarWidth');
    for ind=1:length(x1)
        plot([x1(ind)-BarWidthThis.*0.5 x1(ind)+BarWidthThis.*0.5],Ne_vect(N_vect_sorted_ind(ind)).*ones(1,2),'Color',orange,'LineWidth',4,'LineStyle',':');
    end
    xlim(0.5+[0 length(x1)]);
    set(gca,'XTickLabels',stringa_pair_vect(N_vect_sorted_ind));
    ylh=ylabel(['measure pairs in top ' num2str(topp*100) '%']);
    ylh.Position(2) = ylh.Position(2) - abs(ylh.Position(2)*0.1);
    figure_name=[sleepDir filesep 'all_decodeAprime_top' num2str(topp*100) '_' Job.decodeMode '_' Job.decodeType png_tail '_' names_string];
    hgexport(gcf,figure_name,mystyle,'Format','png');


    N_norm_vect=N_vect./Ne_vect; % with respect to expected values

    [N_norm_vect_sorted N_norm_vect_sorted_ind]=sort(N_norm_vect,'descend');

    figure
    bh=bar(N_norm_vect_sorted);
    hold on;
    x1=get(bh(1),'XData');
    set(bh,'FaceColor',cyan);
    BarWidthThis=get(bh(1),'BarWidth');
    for ind=1:length(x1)
        plot([x1(ind)-BarWidthThis.*0.5 x1(ind)+BarWidthThis.*0.5],ones(1,2),'Color',orange,'LineWidth',4,'LineStyle',':');
    end
    xlim(0.5+[0 length(x1)]);
    set(gca,'XTickLabels',stringa_pair_vect(N_norm_vect_sorted_ind));
    ylh=ylabel(['measure pairs in top ' num2str(topp*100) '%']);
    ylh.Position(2) = ylh.Position(2) - abs(ylh.Position(2)*0.1);
    figure_name=[sleepDir filesep 'all_decodeAprime_top' num2str(topp*100) 'norm_' Job.decodeMode '_' Job.decodeType png_tail '_' names_string];
    hgexport(gcf,figure_name,mystyle,'Format','png');



    % word cloud
    figure
    wordcloud(field_names_pair_vect_top);
    figure_name=[sleepDir filesep 'all_decodeAprime_wordcloud_top' num2str(topp*100) '_' Job.decodeMode '_' Job.decodeType png_tail '_' names_string];
    hgexport(gcf,figure_name,mystyle,'Format','png');

    [ind_pair_vect_top_numOccurrences,ind_pair_vect_top_uniqueWords] = histcounts(categorical(ind_pair_vect_top)); % using categorical so each index is treated as a distinct category

    ind_pair_vect_top_unique=zeros(1,length(ind_pair_vect_top_uniqueWords));
    color_mat_top=zeros(length(ind_pair_vect_top_uniqueWords),3);
    for ind=1:length(ind_pair_vect_top_uniqueWords) % convert back to int
        ind_pair_vect_top_unique(ind)=str2num(ind_pair_vect_top_uniqueWords{ind});
        color_mat_top(ind,:)=field_colors{ind_pair_vect_top_unique(ind)};
    end

    field_names_long_table=table;
    field_names_long_table.meas=field_names_long(ind_pair_vect_top_unique)';
    field_names_long_table.freq=ind_pair_vect_top_numOccurrences';

    figure;
    wordcloud(field_names_long_table,'meas','freq','Color',color_mat_top);
    set(gca,'Title','') ;
    figure_name=[sleepDir filesep 'all_decodeAprime_wordcloud_top' num2str(topp*100) '_' Job.decodeMode '_' Job.decodeType '_longn' png_tail '_' names_string];
    hgexport(gcf,figure_name,mystyle_highres,'Format','png');
end







% Aprime for each measure pair kind
Aprime_uu_pair_vect=[];
Aprime_bb_pair_vect=[];
Aprime_mm_pair_vect=[];
Aprime_ub_pair_vect=[];
Aprime_um_pair_vect=[];
Aprime_bm_pair_vect=[];

for ind=1:length(Aprime_pair_vect)
    switch true
        case isuni_vect(ind,1) && isuni_vect(ind,2)
            Aprime_uu_pair_vect=[Aprime_uu_pair_vect Aprime_pair_vect(ind)];
            if Aprime_pair_vect(ind)<0.598 % easiest way to get the measure pair with lowest A'
                field_names_pair_vect{ind,:}
            end
        case isbi_vect(ind,1) && isbi_vect(ind,2)
            Aprime_bb_pair_vect=[Aprime_bb_pair_vect Aprime_pair_vect(ind)];
        case ismulti_vect(ind,1) && ismulti_vect(ind,2)
            Aprime_mm_pair_vect=[Aprime_mm_pair_vect Aprime_pair_vect(ind)];
        case (isuni_vect(ind,1) && isbi_vect(ind,2)) || (isuni_vect(ind,2) && isbi_vect(ind,1))
            Aprime_ub_pair_vect=[Aprime_ub_pair_vect Aprime_pair_vect(ind)];
        case (isuni_vect(ind,1) && ismulti_vect(ind,2)) || (isuni_vect(ind,2) && ismulti_vect(ind,1))
            Aprime_um_pair_vect=[Aprime_um_pair_vect Aprime_pair_vect(ind)];
        case (isbi_vect(ind,1) && ismulti_vect(ind,2)) || (isbi_vect(ind,2) && ismulti_vect(ind,1))
            Aprime_bm_pair_vect=[Aprime_bm_pair_vect Aprime_pair_vect(ind)];
    end
end

Aprime_uu_pair_vect_sorted=sort(Aprime_uu_pair_vect);
Aprime_bb_pair_vect_sorted=sort(Aprime_bb_pair_vect);
Aprime_mm_pair_vect_sorted=sort(Aprime_mm_pair_vect);
Aprime_ub_pair_vect_sorted=sort(Aprime_ub_pair_vect);
Aprime_um_pair_vect_sorted=sort(Aprime_um_pair_vect);
Aprime_bm_pair_vect_sorted=sort(Aprime_bm_pair_vect);

[new_sorted_x_uu new_sorted_y_uu]=create_stepvec(Aprime_uu_pair_vect_sorted);
[new_sorted_x_bb new_sorted_y_bb]=create_stepvec(Aprime_bb_pair_vect_sorted);
[new_sorted_x_mm new_sorted_y_mm]=create_stepvec(Aprime_mm_pair_vect_sorted);
[new_sorted_x_ub new_sorted_y_ub]=create_stepvec(Aprime_ub_pair_vect_sorted);
[new_sorted_x_um new_sorted_y_um]=create_stepvec(Aprime_um_pair_vect_sorted);
[new_sorted_x_bm new_sorted_y_bm]=create_stepvec(Aprime_bm_pair_vect_sorted);

figure;
set(gcf,'Color',[1 1 1]);
plot(new_sorted_x_uu,new_sorted_y_uu,'Color',color_mat(1,:));
hold on;
plot(new_sorted_x_bb,new_sorted_y_bb,'Color',color_mat(2,:));
plot(new_sorted_x_mm,new_sorted_y_mm,'Color',color_mat(3,:));
plot(new_sorted_x_ub,new_sorted_y_ub,'Color',color_mat(4,:));
plot(new_sorted_x_um,new_sorted_y_um,'Color',color_mat(5,:));
plot(new_sorted_x_bm,new_sorted_y_bm,'Color',color_mat(6,:));
xlabel('A''');
ylh=ylabel('proportion of measure pairs');
ylh.Position(2) = ylh.Position(2) - abs(ylh.Position(2)*0.1);
figure_name=[sleepDir filesep 'all_decodeAprime_cumhist' '_' Job.decodeMode '_' Job.decodeType png_tail '_' names_string];
hgexport(gcf,figure_name,mystyle,'Format','png');



figure;
set(gcf,'Color',[1 1 1]);
plot(new_sorted_x_uu,new_sorted_y_uu,'Color',color_mat(1,:));
hold on;
plot(new_sorted_x_bb,new_sorted_y_bb,'Color',color_mat(2,:));
plot(new_sorted_x_mm,new_sorted_y_mm,'Color',color_mat(3,:));
plot(new_sorted_x_ub,new_sorted_y_ub,'Color',color_mat(4,:));
plot(new_sorted_x_um,new_sorted_y_um,'Color',color_mat(5,:));
plot(new_sorted_x_bm,new_sorted_y_bm,'Color',color_mat(6,:));
plot(Aprime_thr_all_median(1).*ones(1,2),ylim,'Color',0.8*ones(1,3),'LineWidth',2,'LineStyle',':'); % light gray: p=0.01
plot(Aprime_thr_all_median(2).*ones(1,2),ylim,'Color',0.7*ones(1,3),'LineWidth',2,'LineStyle',':');
plot(Aprime_thr_all_median(3).*ones(1,2),ylim,'Color',0.6*ones(1,3),'LineWidth',2,'LineStyle',':');
plot(Aprime_thr_all_median(4).*ones(1,2),ylim,'Color',0.5*ones(1,3),'LineWidth',2,'LineStyle',':'); % dark gray: p=0.00001
plot([0.8 Aprime_pair_vect_sorted(1)*1.01],0.99*ones(1,2),'k','LineWidth',0.1);
plot([0.8 Aprime_pair_vect_sorted(1)*1.01],1.*ones(1,2),'k','LineWidth',0.1);
plot(0.8*ones(1,2),[0.99 1.],'k','LineWidth',0.1);
plot(Aprime_pair_vect_sorted(1)*1.01*ones(1,2),[0.99 1.],'k','LineWidth',0.1);
xlim([Aprime_thr_all_median(1) Aprime_pair_vect_sorted(1)*1.01]); % all Aprime values that are significant at p=0.01
xlabel('A''');
ylh=ylabel('proportion of measure pairs');
ylh.Position(2) = ylh.Position(2) - abs(ylh.Position(2)*0.15);
set(gca,'Position',[0.1661    0.1822    0.7389    0.7428]);
figure_name=[sleepDir filesep 'all_decodeAprime_cumhist_zoom' '_' Job.decodeMode '_' Job.decodeType png_tail '_' names_string];
hgexport(gcf,figure_name,mystyle,'Format','png');

figure;
set(gcf,'Color',[1 1 1]);
plot(new_sorted_x_uu,new_sorted_y_uu,'Color',color_mat(1,:));
hold on;
plot(new_sorted_x_bb,new_sorted_y_bb,'Color',color_mat(2,:));
plot(new_sorted_x_mm,new_sorted_y_mm,'Color',color_mat(3,:));
plot(new_sorted_x_ub,new_sorted_y_ub,'Color',color_mat(4,:));
plot(new_sorted_x_um,new_sorted_y_um,'Color',color_mat(5,:));
plot(new_sorted_x_bm,new_sorted_y_bm,'Color',color_mat(6,:));
plot(Aprime_thr_all_median(1).*ones(1,2),ylim,'Color',0.8*ones(1,3),'LineWidth',2,'LineStyle',':'); % light gray: p=0.01
plot(Aprime_thr_all_median(2).*ones(1,2),ylim,'Color',0.7*ones(1,3),'LineWidth',2,'LineStyle',':');
plot(Aprime_thr_all_median(3).*ones(1,2),ylim,'Color',0.6*ones(1,3),'LineWidth',2,'LineStyle',':');
plot(Aprime_thr_all_median(4).*ones(1,2),ylim,'Color',0.5*ones(1,3),'LineWidth',2,'LineStyle',':'); % dark gray: p=0.00001
xlim([0.8 Aprime_pair_vect_sorted(1)*1.01]);
ylim([0.99 1]);
xlabel('A''');
set(gca,'Position',[0.1661    0.1822    0.7389    0.7428]);
figure_name=[sleepDir filesep 'all_decodeAprime_cumhist_zoom2' '_' Job.decodeMode '_' Job.decodeType png_tail '_' names_string];
hgexport(gcf,figure_name,mystyle,'Format','png');



























% most synergistic pairs
fid = fopen(['decode_syn_' Job.decodeMode '_' Job.decodeType '_all' png_tail '_' C.LambdaString '_' names_string '.txt'],'w');
fprintf(fid,'median results over all recordings\n');
fprintf(fid,'\n%i measures',size(Aprime_pair_syn_sorted,1));
fprintf(fid,'\n\ndecoding S''>0.12');
% most discriminating pair
ut=triu(true(size(Aprime_pair_syn_sorted)),1); % we only consider the upper triangular part excluding the diagonal
Aprime_pair_syn_sorted_ut=Aprime_pair_syn_sorted;
Aprime_pair_syn_sorted_ut(~ut)=0; % we set to 0 all values, apart from upper triangular

Aprime_pair_syn_sorted_above99=Aprime_pair_syn_sorted_ut>0.12; % with the 050723 set of measures, there are no Aprime>0.99 - we just consider the upper triangular part
N99=sum(sum(Aprime_pair_syn_sorted_above99));
N=(size(Aprime_pair_syn_sorted,1)*(size(Aprime_pair_syn_sorted,1)-1))/2;
P99=N99/N;
fprintf(fid,'\nN99=%i\nN=%i\nP99=%f\n',N99,N,P99);
[ind_row_above99 ind_col_above99]=find(Aprime_pair_syn_sorted_above99);
for ind=1:length(ind_row_above99)
    fprintf(fid,['\nS''=' num2str(Aprime_pair_syn_sorted(ind_row_above99(ind),ind_col_above99(ind))) ' for '     field_names{Aprime_sorted_ind(ind_row_above99(ind))} ' - '     field_names{Aprime_sorted_ind(ind_col_above99(ind))}]);
end


fprintf(fid,'\n\ndecoding S''>0.10');
Aprime_pair_syn_sorted_above98=Aprime_pair_syn_sorted_ut>0.10;
N98=sum(sum(Aprime_pair_syn_sorted_above98));
P98=N98/N;
fprintf(fid,'\nN98=%i\nN=%i\nP98=%f\n',N98,N,P98);
[ind_row_above98 ind_col_above98]=find(Aprime_pair_syn_sorted_above98);
Aprime_pair_syn_sorted_vect_above98=zeros(1,length(ind_row_above98));

for ind=1:length(ind_row_above98)
    fprintf(fid,['\nS''=' num2str(Aprime_pair_syn_sorted(ind_row_above98(ind),ind_col_above98(ind))) ' for '     field_names{Aprime_sorted_ind(ind_row_above98(ind))} ' - '     field_names{Aprime_sorted_ind(ind_col_above98(ind))}]);
    Aprime_pair_syn_sorted_vect_above98(ind)=Aprime_pair_syn_sorted(ind_row_above98(ind),ind_col_above98(ind));
end

[Aprime_pair_syn_sorted_vect_above98_sorted Aprime_pair_syn_sorted_vect_above98_sorted_ind]=sort(Aprime_pair_syn_sorted_vect_above98,'descend');
fprintf(fid,'\n\nnow ordered\n');
for ind=1:length(ind_row_above98)
    fprintf(fid,['\nS''=' num2str(Aprime_pair_syn_sorted_vect_above98_sorted(ind)) ' for '     field_names{Aprime_sorted_ind(ind_row_above98(Aprime_pair_syn_sorted_vect_above98_sorted_ind(ind)))} ' - '     field_names{Aprime_sorted_ind(ind_col_above98(Aprime_pair_syn_sorted_vect_above98_sorted_ind(ind)))}]);
end



% top 1% or 5% most synergistic pairs

Aprime_pair_syn_vect=Aprime_pair_syn_median(ut); % takes elements by columns
ind_pair_vect=[]; % better to just store indexes
field_names_pair_vect={};
clear isuni_vect isbi_vect ismulti_vect;
ind=0;
for icol=2:size(Aprime_pair_syn_median,1)
    for irow=1:(icol-1)
        ind=ind+1;
        ind_pair_vect(ind,1)=irow;
        field_names_pair_vect{ind,1}=field_names{irow};
        isuni_vect(ind,1)=isuni(irow);
        isbi_vect(ind,1)=isbi(irow);
        ismulti_vect(ind,1)=ismulti(irow);

        ind_pair_vect(ind,2)=icol;
        field_names_pair_vect{ind,2}=field_names{icol};
        isuni_vect(ind,2)=isuni(icol);
        isbi_vect(ind,2)=isbi(icol);
        ismulti_vect(ind,2)=ismulti(icol);
    end
end

[Aprime_pair_syn_vect_sorted Aprime_pair_syn_vect_sorted_ind]=sort(Aprime_pair_syn_vect,'descend');

% % double-checking ... ok
% for ind=1:5
%     printf(['\nS''=' num2str(Aprime_pair_syn_vect_sorted(ind)) ' for '     field_names_pair_vect{Aprime_pair_syn_vect_sorted_ind(ind),1} ' - '     field_names_pair_vect{Aprime_pair_syn_vect_sorted_ind(ind),2}]);
% end


% expected values
Nuue=n_uni*(n_uni-1)/2; % order does not matter
Nbbe=n_bi*(n_bi-1)/2;
Nmme=n_multi*(n_multi-1)/2;
Nube=n_uni*n_bi;
Nume=n_uni*n_multi;
Nbme=n_bi*n_multi;

topp_vect=[0.01 0.05];
for topp=topp_vect
    Aprime_pair_syn_vect_sorted_top=Aprime_pair_syn_vect_sorted(1:round(topp*N));

    ind_pair_vect_top_2c=ind_pair_vect(Aprime_pair_syn_vect_sorted_ind(1:round(topp*N)),:);
    ind_pair_vect_top=ind_pair_vect_top_2c(:); % takes elements by columns

    field_names_pair_vect_top=field_names_pair_vect(Aprime_pair_syn_vect_sorted_ind(1:round(topp*N)),:);
    field_names_pair_vect_top=field_names_pair_vect_top(:); % takes elements by columns

    if topp==0.01
        fid = fopen(['decode_syn_top' num2str(topp*100) '_' Job.decodeMode '_' Job.decodeType '_all' png_tail '_' C.LambdaString '_' names_string '.txt'],'w');
        fid_csv = fopen(['decode_syn_top' num2str(topp*100) '_' Job.decodeMode '_' Job.decodeType '_all' png_tail '_' C.LambdaString '_' names_string '.csv'],'w');
        fprintf(fid,'median results over all recordings\n');
        fprintf(fid_csv,'S'',A'',MSTM1,MSTM2,A''1,A''2\n');
        for ind=1:round(topp*N)
            fprintf(fid,['\nS''=' num2str(Aprime_pair_syn_vect_sorted(ind)) ' for '     field_names_pair_vect{Aprime_pair_syn_vect_sorted_ind(ind),1} ' - '     field_names_pair_vect{Aprime_pair_syn_vect_sorted_ind(ind),2} ...
                ' - - ' num2str(Aprime_pair_median(ind_pair_vect_top_2c(ind,1),ind_pair_vect_top_2c(ind,2)))... % pair decoding
                '  - -  ' num2str(Aprime_pair_median(ind_pair_vect_top_2c(ind,1),ind_pair_vect_top_2c(ind,1))) '-' num2str(Aprime_pair_median(ind_pair_vect_top_2c(ind,2),ind_pair_vect_top_2c(ind,2)))]); % single decoding
            fprintf(fid_csv,[num2str(Aprime_pair_syn_vect_sorted(ind)) ',' ...
                ',' num2str(Aprime_pair_median(ind_pair_vect_top_2c(ind,1),ind_pair_vect_top_2c(ind,2)))... % pair decoding
                ',' field_names_long_pair_vect{Aprime_pair_syn_vect_sorted_ind(ind),1} ',' field_names_long_pair_vect{Aprime_pair_syn_vect_sorted_ind(ind),2} ...
                ',' num2str(Aprime_pair_median(ind_pair_vect_top_2c(ind,1),ind_pair_vect_top_2c(ind,1))) ',' num2str(Aprime_pair_median(ind_pair_vect_top_2c(ind,2),ind_pair_vect_top_2c(ind,2))) '\n']); % single decoding
            % field_names{ind_pair_vect_top_2c(ind,1)} % ok
            % field_names{ind_pair_vect_top_2c(ind,2)}
        end
        fclose(fid);
        fclose(fid_csv);
    end

    [Nuu Nub Num Nbb Nbm Nmm]=deal(0);

    % Nuue+Nbbe+Nmme+Nube+Nume+Nbme==N % yes

    for ind=1:round(topp*N)
        ind_this=Aprime_pair_syn_vect_sorted_ind(ind);
        switch true
            case isuni_vect(ind_this,1) && isuni_vect(ind_this,2)
                Nuu=Nuu+1;
            case isbi_vect(ind_this,1) && isbi_vect(ind_this,2)
                Nbb=Nbb+1;
            case ismulti_vect(ind_this,1) && ismulti_vect(ind_this,2)
                Nmm=Nmm+1;
            case (isuni_vect(ind_this,1) && isbi_vect(ind_this,2)) || (isuni_vect(ind_this,2) && isbi_vect(ind_this,1))
                Nub=Nub+1;
            case (isuni_vect(ind_this,1) && ismulti_vect(ind_this,2)) || (isuni_vect(ind_this,2) && ismulti_vect(ind_this,1))
                Num=Num+1;
            case (isbi_vect(ind_this,1) && ismulti_vect(ind_this,2)) || (isbi_vect(ind_this,2) && ismulti_vect(ind_this,1))
                Nbm=Nbm+1;
        end
    end

    % Nuu+Nbb+Nmm+Nub+Num+Nbm==round(topp*N) % yes


    N_vect=[Nuu Nbb Nmm Nub Num Nbm];
    Ne_vect=topp*[Nuue Nbbe Nmme Nube Nume Nbme];

    [N_vect_sorted N_vect_sorted_ind]=sort(N_vect,'descend');


    figure
    bh=bar(N_vect_sorted);
    hold on;
    x1=get(bh(1),'XData');
    set(bh,'FaceColor',cyan);
    BarWidthThis=get(bh(1),'BarWidth');
    for ind=1:length(x1)
        plot([x1(ind)-BarWidthThis.*0.5 x1(ind)+BarWidthThis.*0.5],Ne_vect(N_vect_sorted_ind(ind)).*ones(1,2),'Color',orange,'LineWidth',4,'LineStyle',':');
    end
    xlim(0.5+[0 length(x1)]);
    set(gca,'XTickLabels',stringa_pair_vect(N_vect_sorted_ind));
    ylh=ylabel(['measure pairs in top ' num2str(topp*100) '%']);
    ylh.Position(2) = ylh.Position(2) - abs(ylh.Position(2)*0.1);
    figure_name=[sleepDir filesep 'all_decodeAprime_syn_top' num2str(topp*100) '_' Job.decodeMode '_' Job.decodeType png_tail '_' names_string];
    hgexport(gcf,figure_name,mystyle,'Format','png');


    N_norm_vect=N_vect./Ne_vect; % with respect to expected values

    [N_norm_vect_sorted N_norm_vect_sorted_ind]=sort(N_norm_vect,'descend');

    figure
    bh=bar(N_norm_vect_sorted);
    hold on;
    x1=get(bh(1),'XData');
    set(bh,'FaceColor',cyan);
    BarWidthThis=get(bh(1),'BarWidth');
    for ind=1:length(x1)
        plot([x1(ind)-BarWidthThis.*0.5 x1(ind)+BarWidthThis.*0.5],ones(1,2),'Color',orange,'LineWidth',4,'LineStyle',':');
    end
    xlim(0.5+[0 length(x1)]);
    set(gca,'XTickLabels',stringa_pair_vect(N_norm_vect_sorted_ind));
    ylh=ylabel(['measure pairs in top ' num2str(topp*100) '%']);
    ylh.Position(2) = ylh.Position(2) - abs(ylh.Position(2)*0.1);
    figure_name=[sleepDir filesep 'all_decodeAprime_syn_top' num2str(topp*100) 'norm_' Job.decodeMode '_' Job.decodeType png_tail '_' names_string];
    hgexport(gcf,figure_name,mystyle,'Format','png');



    % word cloud
    figure
    wordcloud(field_names_pair_vect_top);
    figure_name=[sleepDir filesep 'all_decodeAprime_syn_wordcloud_top' num2str(topp*100) '_' Job.decodeMode '_' Job.decodeType png_tail '_' names_string];
    hgexport(gcf,figure_name,mystyle,'Format','png');

    [ind_pair_vect_top_numOccurrences,ind_pair_vect_top_uniqueWords] = histcounts(categorical(ind_pair_vect_top)); % using categorical so each index is treated as a distinct category

    ind_pair_vect_top_unique=zeros(1,length(ind_pair_vect_top_uniqueWords));
    color_mat_top=zeros(length(ind_pair_vect_top_uniqueWords),3);
    for ind=1:length(ind_pair_vect_top_uniqueWords) % convert back to int
        ind_pair_vect_top_unique(ind)=str2num(ind_pair_vect_top_uniqueWords{ind});
        color_mat_top(ind,:)=field_colors{ind_pair_vect_top_unique(ind)};
    end

    field_names_long_table=table;
    field_names_long_table.meas=field_names_long(ind_pair_vect_top_unique)';
    field_names_long_table.freq=ind_pair_vect_top_numOccurrences';

    figure;
    wordcloud(field_names_long_table,'meas','freq','Color',color_mat_top);
    set(gca,'Title','') ;
    figure_name=[sleepDir filesep 'all_decodeAprime_syn_wordcloud_top' num2str(topp*100) '_' Job.decodeMode '_' Job.decodeType '_longn' png_tail '_' names_string];
    hgexport(gcf,figure_name,mystyle_highres,'Format','png');

    Aprime_pair_ut=Aprime_pair_median;
    Aprime_pair_ut(~ut)=NaN; % we set to NaN all values, apart from upper triangular
    Aprime_pair_syn_ut=Aprime_pair_syn_median;
    Aprime_pair_syn_ut(~ut)=NaN; % we set to NaN all values, apart from upper triangular

    figure
    plot(Aprime_pair_ut(:),Aprime_pair_syn_ut(:),'.');
    hold on;
    plot(Aprime_pair_vect(Aprime_pair_syn_vect_sorted_ind(1:round(topp*N))),Aprime_pair_syn_vect_sorted_top,'r.');
    ylim_vect=ylim; % for some reason it might change automatically
    plot(Aprime_thr_all_median(1).*ones(1,2),ylim_vect,'Color',0.8*ones(1,3),'LineWidth',2,'LineStyle',':'); % light gray: p=0.01
    plot(Aprime_thr_all_median(2).*ones(1,2),ylim_vect,'Color',0.7*ones(1,3),'LineWidth',2,'LineStyle',':');
    plot(Aprime_thr_all_median(3).*ones(1,2),ylim_vect,'Color',0.6*ones(1,3),'LineWidth',2,'LineStyle',':');
    plot(Aprime_thr_all_median(4).*ones(1,2),ylim_vect,'Color',0.5*ones(1,3),'LineWidth',2,'LineStyle',':'); % dark gray: p=0.00001
    xlabel('A''');
    ylabel('S_{A''}','Rotation',0);
    set(gcf,'Position',[675   549   670   413]);
    set(gca,'YLim',ylim_vect);
    figure_name=[sleepDir filesep 'all_decodeAprime_syn_vs_aprime_top' num2str(topp*100) '_' Job.decodeMode '_' Job.decodeType png_tail '_' names_string];
    hgexport(gcf,figure_name,mystyle,'Format','png');
end







% Aprime syn for each measure pair kind
Aprime_uu_pair_syn_vect=[];
Aprime_bb_pair_syn_vect=[];
Aprime_mm_pair_syn_vect=[];
Aprime_ub_pair_syn_vect=[];
Aprime_um_pair_syn_vect=[];
Aprime_bm_pair_syn_vect=[];

for ind=1:length(Aprime_pair_syn_vect)
    switch true
        case isuni_vect(ind,1) && isuni_vect(ind,2)
            Aprime_uu_pair_syn_vect=[Aprime_uu_pair_syn_vect Aprime_pair_syn_vect(ind)];
        case isbi_vect(ind,1) && isbi_vect(ind,2)
            Aprime_bb_pair_syn_vect=[Aprime_bb_pair_syn_vect Aprime_pair_syn_vect(ind)];
        case ismulti_vect(ind,1) && ismulti_vect(ind,2)
            Aprime_mm_pair_syn_vect=[Aprime_mm_pair_syn_vect Aprime_pair_syn_vect(ind)];
        case (isuni_vect(ind,1) && isbi_vect(ind,2)) || (isuni_vect(ind,2) && isbi_vect(ind,1))
            Aprime_ub_pair_syn_vect=[Aprime_ub_pair_syn_vect Aprime_pair_syn_vect(ind)];
        case (isuni_vect(ind,1) && ismulti_vect(ind,2)) || (isuni_vect(ind,2) && ismulti_vect(ind,1))
            Aprime_um_pair_syn_vect=[Aprime_um_pair_syn_vect Aprime_pair_syn_vect(ind)];
        case (isbi_vect(ind,1) && ismulti_vect(ind,2)) || (isbi_vect(ind,2) && ismulti_vect(ind,1))
            Aprime_bm_pair_syn_vect=[Aprime_bm_pair_syn_vect Aprime_pair_syn_vect(ind)];
    end
end
Aprime_uu_pair_syn_vect_sorted=sort(Aprime_uu_pair_syn_vect);
Aprime_bb_pair_syn_vect_sorted=sort(Aprime_bb_pair_syn_vect);
Aprime_mm_pair_syn_vect_sorted=sort(Aprime_mm_pair_syn_vect);
Aprime_ub_pair_syn_vect_sorted=sort(Aprime_ub_pair_syn_vect);
Aprime_um_pair_syn_vect_sorted=sort(Aprime_um_pair_syn_vect);
Aprime_bm_pair_syn_vect_sorted=sort(Aprime_bm_pair_syn_vect);

[new_sorted_x_uu new_sorted_y_uu]=create_stepvec(Aprime_uu_pair_syn_vect_sorted);
[new_sorted_x_bb new_sorted_y_bb]=create_stepvec(Aprime_bb_pair_syn_vect_sorted);
[new_sorted_x_mm new_sorted_y_mm]=create_stepvec(Aprime_mm_pair_syn_vect_sorted);
[new_sorted_x_ub new_sorted_y_ub]=create_stepvec(Aprime_ub_pair_syn_vect_sorted);
[new_sorted_x_um new_sorted_y_um]=create_stepvec(Aprime_um_pair_syn_vect_sorted);
[new_sorted_x_bm new_sorted_y_bm]=create_stepvec(Aprime_bm_pair_syn_vect_sorted);

figure;
set(gcf,'Color',[1 1 1]);
plot(new_sorted_x_uu,new_sorted_y_uu,'Color',color_mat(1,:));
hold on;
plot(new_sorted_x_bb,new_sorted_y_bb,'Color',color_mat(2,:));
plot(new_sorted_x_mm,new_sorted_y_mm,'Color',color_mat(3,:));
plot(new_sorted_x_ub,new_sorted_y_ub,'Color',color_mat(4,:));
plot(new_sorted_x_um,new_sorted_y_um,'Color',color_mat(5,:));
plot(new_sorted_x_bm,new_sorted_y_bm,'Color',color_mat(6,:));
xlabel('S_{A''}');
ylh=ylabel('proportion of measure pairs');
ylh.Position(2) = ylh.Position(2) - abs(ylh.Position(2)*0.1);
figure_name=[sleepDir filesep 'all_decodeAprime_syn_cumhist' '_' Job.decodeMode '_' Job.decodeType png_tail '_' names_string];
hgexport(gcf,figure_name,mystyle,'Format','png');



figure;
set(gcf,'Color',[1 1 1]);
plot(new_sorted_x_uu,new_sorted_y_uu,'Color',color_mat(1,:));
hold on;
plot(new_sorted_x_bb,new_sorted_y_bb,'Color',color_mat(2,:));
plot(new_sorted_x_mm,new_sorted_y_mm,'Color',color_mat(3,:));
plot(new_sorted_x_ub,new_sorted_y_ub,'Color',color_mat(4,:));
plot(new_sorted_x_um,new_sorted_y_um,'Color',color_mat(5,:));
plot(new_sorted_x_bm,new_sorted_y_bm,'Color',color_mat(6,:));
plot(0.01*ones(1,2),[0.98 1],'k','LineWidth',0.1);
plot(Aprime_pair_syn_vect_sorted(1)*1.01*ones(1,2),[0.98 1],'k','LineWidth',0.1);
plot([0.01 Aprime_pair_syn_vect_sorted(1)*1.01],0.98*ones(1,2),'k','LineWidth',0.1);
plot([0.01 Aprime_pair_syn_vect_sorted(1)*1.01],ones(1,2),'k','LineWidth',0.1);
xlim([-0.1 Aprime_pair_syn_vect_sorted(1)*1.01]);
xlabel('S_{A''}');
ylh=ylabel('proportion of measure pairs');
ylh.Position(2) = ylh.Position(2) - abs(ylh.Position(2)*0.18);
set(gca,'Position',[0.1661    0.2132    0.7389    0.7118]);
figure_name=[sleepDir filesep 'all_decodeAprime_syn_cumhist_zoom' '_' Job.decodeMode '_' Job.decodeType png_tail '_' names_string];
hgexport(gcf,figure_name,mystyle,'Format','png');

figure;
set(gcf,'Color',[1 1 1]);
plot(new_sorted_x_uu,new_sorted_y_uu,'Color',color_mat(1,:));
hold on;
plot(new_sorted_x_bb,new_sorted_y_bb,'Color',color_mat(2,:));
plot(new_sorted_x_mm,new_sorted_y_mm,'Color',color_mat(3,:));
plot(new_sorted_x_ub,new_sorted_y_ub,'Color',color_mat(4,:));
plot(new_sorted_x_um,new_sorted_y_um,'Color',color_mat(5,:));
plot(new_sorted_x_bm,new_sorted_y_bm,'Color',color_mat(6,:));
xlim([0.01 Aprime_pair_syn_vect_sorted(1)*1.01]);
ylim([0.98 1.]);
xlabel('S_{A''}');
set(gca,'Position',[0.1661    0.2132    0.7389    0.7118]);
figure_name=[sleepDir filesep 'all_decodeAprime_syn_cumhist_zoom2' '_' Job.decodeMode '_' Job.decodeType png_tail '_' names_string];
hgexport(gcf,figure_name,mystyle,'Format','png');





stringa_pair_vect_cumhist{1}=['\color[rgb]{' sprintf('%f ',color_mat(1,:)) '}uni-uni'];
stringa_pair_vect_cumhist{2}=['\color[rgb]{' sprintf('%f ',color_mat(2,:)) '}bi-bi'];
stringa_pair_vect_cumhist{3}=['\color[rgb]{' sprintf('%f ',color_mat(3,:)) '}multi-multi'];
stringa_pair_vect_cumhist{4}=['\color[rgb]{' sprintf('%f ',color_mat(4,:)) '}uni-bi'];
stringa_pair_vect_cumhist{5}=['\color[rgb]{' sprintf('%f ',color_mat(5,:)) '}uni-multi'];
stringa_pair_vect_cumhist{6}=['\color[rgb]{' sprintf('%f ',color_mat(6,:)) '}bi-multi'];

figure();
set(gcf,'Color',[1 1 1]);
set(gca,'YDir','reverse'); % needs to be done again, not sure why

ytext=-3:-1;
for i=1:3
    th=text(-1,ytext(i),stringa_pair_vect_cumhist{i},'fontsize',50);
    hold on;
end

xoffset=8;
for i = 1:3
    th=text(xoffset+-1,ytext(i),ytext(i),stringa_pair_vect_cumhist{3+i},'fontsize',50);
    hold on;
end


xlim([-2 14.5]); % to be updated
ylim([-4.5 -0.5]); % to be updated

set(gca,'Position',[0 0 1 1])
set(gcf,'Position',[670   681   804   269]);

axis off;
set(gca,'YDir','reverse'); % needs to be done again, not sure why

figure_name=[sleepDir filesep 'all_decodeAprime_syn_cumhist_legend' '_' Job.decodeMode '_' Job.decodeType '_' names_string];
export_fig(gcf,[figure_name '.png']); % using exportfig so it's nicely cropped







% clustering of measures using average distance


sync_all_dist_corr = pdist(Aprime_pair_median, 'correlation');
sync_all_link_corr_avg = linkage(sync_all_dist_corr, 'average');
sync_all_clust_corr = cluster(sync_all_link_corr_avg, 'cutoff', 1.2);


figure;
set(gcf,'Color',[1 1 1]);
[H,T,outperm] = dendrogram(sync_all_link_corr_avg,0);
set(gcf,'Position',[1000         392        1476         942]);
set(gca,'XTickLabels',strrep(field_names_wc_ms(outperm),'_','\_'),'FontSize',FontSizeThis);
xtickangle(gca,45);
if PLOT.print
    figure_name=[sleepDir filesep 'all_decodeAprime_corr_avg_dendro_color_' Job.decodeMode '_' Job.decodeType png_tail '_' names_string];
    hgexport(gcf,figure_name,mystyle,'Format','png');
end

sync_all_corr=1-sync_all_dist_corr;
sync_all_corr_mat=squareform(sync_all_corr);
sync_all_corr_mat_sorted=sync_all_corr_mat(outperm,outperm);
sync_all_corr_mat_2plot=nan(size(sync_all_corr_mat));
ut=triu(true(size(sync_all_corr_mat)),1); % we only consider the upper triangular part without the diagonal
sync_all_corr_mat_2plot(ut)=sync_all_corr_mat_sorted(ut);


figure;
set(gcf,'Color',[1 1 1]);
set(gcf,'Position',[1 1 1200 1000]);
imAlpha=ones(size(sync_all_corr_mat_2plot));
imAlpha(isnan(sync_all_corr_mat_2plot))=0;
imagesc(sync_all_corr_mat_2plot,'AlphaData',imAlpha);
set(gca,'color',0.95*[1 1 1]);
axis square
set(gca,'xaxisLocation','top')
set(gca,'XTick',1:1:length(field_names_wc_ms));
set(gca,'XTickLabels',strrep(field_names_wc_ms(outperm),'_','\_'),'fontsize',FontSizeThis); % this sets the scale for all axis text properties... ok for now
xtickangle(gca,45);
set(gca,'YTick',1:1:length(field_names_wc_ms));
set(gca,'YTickLabels',strrep(field_names_wc_ms(outperm),'_','\_'));
cbh=colorbar;
set(cbh,'FontSize',FontSizeThisCb);
pos_vect=get(cbh,'Position');
th2=annotation('textbox',[pos_vect(1)+pos_vect(3)+0.01 pos_vect(2)+0.46*pos_vect(4) 0.012 0.046],'String','corr','FontSize',24,'LineStyle','none','VerticalAlignment','middle');
if PLOT.print
    figure_name=[sleepDir filesep 'all_decodeAprime_corr_avg_mat_color_' Job.decodeMode '_' Job.decodeType png_tail '_' names_string];
    hgexport(gcf,figure_name,mystyle,'Format','png');
end



% sorting according to hierarchical clustering results
figure();
set(gcf,'Color',[1 1 1]);
Aprime_pair_sorted=Aprime_pair_median(:,outperm); % sort columns
Aprime_pair_sorted=Aprime_pair_sorted(outperm,:); % sort rows

set(gcf,'Position',[1 1 1200 1000]);

ut=triu(true(size(Aprime_pair_sorted))); % we only consider the upper triangular part including the diagonal
Aprime_pair_2plot=nan(size(Aprime_pair_sorted));
Aprime_pair_2plot(ut)=Aprime_pair_sorted(ut);

imAlpha=ones(size(Aprime_pair_2plot));
imAlpha(isnan(Aprime_pair_2plot))=0;
imagesc(Aprime_pair_2plot,'AlphaData',imAlpha);
set(gca,'color',0.95*[1 1 1]);
axis square
set(gca,'xaxisLocation','top')
set(gca,'XTick',1:1:length(field_names_wc_ms));
set(gca,'XTickLabels',strrep(field_names_wc_ms(outperm),'_','\_'),'fontsize',FontSizeThis);
xtickangle(gca,45);
set(gca,'YTick',1:1:length(field_names_wc_ms));
set(gca,'YTickLabels',strrep(field_names_wc_ms(outperm),'_','\_'));
cbh=colorbar;
set(cbh,'FontSize',FontSizeThisCb);
pos_vect=get(cbh,'Position');
th2=annotation('textbox',[pos_vect(1)+pos_vect(3)+0.01 pos_vect(2)+0.46*pos_vect(4) 0.012 0.046],'String','A''','FontSize',24,'LineStyle','none','VerticalAlignment','middle');
figure_name=[sleepDir filesep 'all_decodeAprime_dendrosorted_' Job.decodeMode '_' Job.decodeType png_tail '_' names_string];
hgexport(gcf,figure_name,mystyle,'Format','png');



figure();
set(gcf,'Color',[1 1 1]);
Aprime_pair_sorted=Aprime_pair_median(:,outperm); % sort columns
Aprime_pair_sorted=Aprime_pair_sorted(outperm,:); % sort rows

set(gcf,'Position',[1 1 1200 1000]);

ut=triu(true(size(Aprime_pair_sorted))); % we only consider the upper triangular part including the diagonal
Aprime_pair_2plot=nan(size(Aprime_pair_sorted));
Aprime_pair_2plot(ut)=Aprime_pair_sorted(ut);

imAlpha=ones(size(Aprime_pair_2plot));
imAlpha(isnan(Aprime_pair_2plot))=0;
imagesc(Aprime_pair_2plot,'AlphaData',imAlpha);
set(gca,'color',0.95*[1 1 1]);
axis square
set(gca,'xaxisLocation','top')
set(gca,'XTick',1:1:length(field_names_long_wc_ms));
set(gca,'XTickLabels',strrep(field_names_long_wc_ms(outperm),'_','\_'),'fontsize',FontSizeThis);
xtickangle(gca,45);
set(gca,'YTick',1:1:length(field_names_long_wc_ms));
set(gca,'YTickLabels',strrep(field_names_long_wc_ms(outperm),'_','\_'));
cbh=colorbar;
set(cbh,'FontSize',FontSizeThisCb);
pos_vect=get(cbh,'Position');
th2=annotation('textbox',[pos_vect(1)+pos_vect(3)+0.01 pos_vect(2)+0.46*pos_vect(4) 0.012 0.046],'String','A''','FontSize',24,'LineStyle','none','VerticalAlignment','middle');
figure_name=[sleepDir filesep 'all_decodeAprime_dendrosorted_' Job.decodeMode '_' Job.decodeType '_longn' png_tail '_' names_string];
hgexport(gcf,figure_name,mystyle_highres,'Format','png');







figure();
set(gcf,'Color',[1 1 1]);
Aprime_pair_syn_sorted=Aprime_pair_syn_median(:,outperm); % sort columns
Aprime_pair_syn_sorted=Aprime_pair_syn_sorted(outperm,:); % sort rows

set(gcf,'Position',[1 1 1200 1000]);

ut=triu(true(size(Aprime_pair_syn_sorted)),1); % we only consider the upper triangular part excluding the diagonal
Aprime_pair_syn_2plot=nan(size(Aprime_pair_syn_sorted));
Aprime_pair_syn_2plot(ut)=Aprime_pair_syn_sorted(ut);

imAlpha=ones(size(Aprime_pair_syn_2plot));
imAlpha(isnan(Aprime_pair_syn_2plot))=0;
imagesc(Aprime_pair_syn_2plot,'AlphaData',imAlpha);
set(gca,'color',0.95*[1 1 1]);
axis square
set(gca,'xaxisLocation','top')
set(gca,'XTick',1:1:length(field_names_wc_ms));
set(gca,'XTickLabels',strrep(field_names_wc_ms(outperm),'_','\_'),'fontsize',FontSizeThis);
xtickangle(gca,45);
set(gca,'YTick',1:1:length(field_names_wc_ms));
set(gca,'YTickLabels',strrep(field_names_wc_ms(outperm),'_','\_'));
cbh=colorbar;
set(cbh,'FontSize',FontSizeThisCb);
pos_vect=get(cbh,'Position');
th2=annotation('textbox',[pos_vect(1)+pos_vect(3)+0.01 pos_vect(2)+0.46*pos_vect(4) 0.012 0.046],'String','S_{A''}','FontSize',24,'LineStyle','none','VerticalAlignment','middle');
figure_name=[sleepDir filesep 'all_decodeAprime_syn_dendrosorted_' Job.decodeMode '_' Job.decodeType png_tail '_' names_string];
hgexport(gcf,figure_name,mystyle,'Format','png');

figure();
set(gcf,'Color',[1 1 1]);
Aprime_pair_syn_sorted=Aprime_pair_syn_median(:,outperm); % sort columns
Aprime_pair_syn_sorted=Aprime_pair_syn_sorted(outperm,:); % sort rows

set(gcf,'Position',[1 1 1200 1000]);

ut=triu(true(size(Aprime_pair_syn_sorted)),1); % we only consider the upper triangular part excluding the diagonal
Aprime_pair_syn_2plot=nan(size(Aprime_pair_syn_sorted));
Aprime_pair_syn_2plot(ut)=Aprime_pair_syn_sorted(ut);

imAlpha=ones(size(Aprime_pair_syn_2plot));
imAlpha(isnan(Aprime_pair_syn_2plot))=0;
imagesc(Aprime_pair_syn_2plot,'AlphaData',imAlpha);
set(gca,'color',0.95*[1 1 1]);
axis square
set(gca,'xaxisLocation','top')
set(gca,'XTick',1:1:length(field_names_long_wc_ms));
set(gca,'XTickLabels',strrep(field_names_long_wc_ms(outperm),'_','\_'),'fontsize',FontSizeThis);
xtickangle(gca,45);
set(gca,'YTick',1:1:length(field_names_long_wc_ms));
set(gca,'YTickLabels',strrep(field_names_long_wc_ms(outperm),'_','\_'));
cbh=colorbar;
set(cbh,'FontSize',FontSizeThisCb);
pos_vect=get(cbh,'Position');
th2=annotation('textbox',[pos_vect(1)+pos_vect(3)+0.01 pos_vect(2)+0.46*pos_vect(4) 0.012 0.046],'String','S_{A''}','FontSize',24,'LineStyle','none','VerticalAlignment','middle');
figure_name=[sleepDir filesep 'all_decodeAprime_syn_dendrosorted_' Job.decodeMode '_' Job.decodeType '_longn' png_tail '_' names_string];
hgexport(gcf,figure_name,mystyle_highres,'Format','png');



clearvars -except sync_all_dist_corr sync_all_link_corr_avg ...
    sleepDir par names_string;
save([sleepDir filesep 'cluster' par.png_tail '_output' '_' names_string]);

close all;