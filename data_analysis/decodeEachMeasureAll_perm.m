clear zmcorrTest zmcorrTrain stdcorrTrain stdcorrTest CC

get_field_names;

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

clear tmp
switch Job.decodeType
    case {'wake_vs_nrem',... % 1
            }
        nClass = 2;
        c1_string_ind=strfind(Job.decodeType,'_vs_');
        c1_string=Job.decodeType(1:c1_string_ind-1);
        c2_string=Job.decodeType(c1_string_ind+4:end);
        for ifile=1:nfiles
            for ifn=1:length(field_names)
                data_this{ifile} = data_now{ifile}.([field_names{ifn} '_all']);
                eval(['data_this_1 = data_this{ifile}(logical(' c1_string '_3ormore_vect{ifile}));']);
                eval(['data_this_2 = data_this{ifile}(logical(' c2_string '_3ormore_vect{ifile}));']);
                tmp{ifile,1}.([field_names{ifn} '_all'])=data_this_1;
                tmp{ifile,2}.([field_names{ifn} '_all'])=data_this_2;
            end
            for iClass = 1:nClass
                nTrialsPerClass(ifile,iClass) = length(tmp{ifile,iClass}.([field_names{ifn} '_all']));
            end
        end

    otherwise
        disp([ Job.decodeType ' unrecognized option'])
        keyboard
end
clear data_now

min_n_samples=nTrialsPerClass;
clear P R CC
clear nan_ind
disp(['decode : ' stringa ' : ' data_file ' : ' datestr(now) ])
switch Job.decodeMode
    case 'single'
        for ifn=1:length(field_names)

            if mod(ifn,10) == 1
                disp([Job.decodeMode ' : ' Job.decodeType '  : ifn =' num2str(ifn) '/' num2str(length(field_names)) ' : ' datestr(now)])
            end
            %%
            for ifile=1:nfiles
                clear tmp2
                for iClass = 1:nClass
                    cResp{ifile,iClass} = tmp{ifile,iClass}.([field_names{ifn} '_all'])';

                    nan_ind{ifile,iClass}(ifn,:)=isnan(cResp{ifile,iClass});
                    if any(nan_ind{ifile,iClass}(ifn,:))
                        cResp{ifile,iClass} = cResp{ifile,iClass}(~nan_ind{ifile,iClass}(ifn,:)); % remove NaNs
                    end
                    min_n_samples(ifile,iClass)=min(min_n_samples(ifile,iClass),length(cResp{ifile,iClass}));
                end
            end
            % Pattern normalization... not here anymore, but inside evaluatePerformance_mem.m
            [ind_train,ind_test,perm_class_ind] = leaveOneOutRLSC_LORO_perm(cResp,C);
            [P] = evaluatePerformance_LORO_perm(cResp,C,ind_train,ind_test,perm_class_ind);

            % if P.zmcorrTrain<(1/nClass+0.01) % this can happen in the single case
            if (P.zmcorrTrain + P.stdcorrTrain)<(1/nClass+0.01)
                disp('something is wrong -- mostlikely due to nan value')
                keyboard
            end

            zmcorrTrain.(field_names{ifn}) = P.zmcorrTrain;
            zmcorrTest.(field_names{ifn}) = P.zmcorrTest;
            stdcorrTrain.(field_names{ifn}) = P.stdcorrTrain;
            stdcorrTest.(field_names{ifn}) = P.stdcorrTest;

        end
        decodeResultFilename = ['single_' ...
            Job.decodeType '_loro_norm.mat' ];

    case 'pair'
        for ifn=1:length(field_names)

            if mod(ifn,10) == 1
                disp([Job.decodeMode ' : ' Job.decodeType '  : ifn =' num2str(ifn) '/' num2str(length(field_names)) ' : ' datestr(now)])
            end

            for jfn=(ifn+1):length(field_names)

                %%
                for ifile=1:nfiles
                    clear tmp2
                    for iClass = 1:nClass
                        cResp{ifile,iClass} = [tmp{ifile,iClass}.([field_names{ifn} '_all'])' tmp{ifile,iClass}.([field_names{jfn} '_all'])'];

                        nan_ind{ifile,iClass}(ifn,jfn,:,:)=isnan(cResp{ifile,iClass});
                        if any(any(nan_ind{ifile,iClass}(ifn,jfn,:,:)))
                            nan_ind_this=squeeze(any(nan_ind{ifile,iClass}(ifn,jfn,:,:),4));
                            cResp{ifile,iClass} = cResp{ifile,iClass}(~nan_ind_this,:); % remove rows with at least one NaNs
                        end
                        min_n_samples(ifile,iClass)=min(min_n_samples(ifile,iClass),length(cResp{ifile,iClass}));
                    end
                end

                [ind_train,ind_test,perm_class_ind] = leaveOneOutRLSC_LORO_perm(cResp,C);
                [P] = evaluatePerformance_LORO_perm(cResp,C,ind_train,ind_test,perm_class_ind);

                zmcorrTrain.([field_names{ifn} '__' field_names{jfn}]) = P.zmcorrTrain;
                zmcorrTest.([field_names{ifn} '__' field_names{jfn}]) = P.zmcorrTest;
                stdcorrTrain.([field_names{ifn} '__' field_names{jfn}]) = P.stdcorrTrain;
                stdcorrTest.([field_names{ifn} '__' field_names{jfn}]) = P.stdcorrTest;

            end
        end

        decodeResultFilename = ['pair_' ...
            Job.decodeType '_loro_norm.mat' ];
end
%%
whos
decodeResultFilename = strrep(decodeResultFilename,'.mat',['_' C.LambdaString '_' names_string '.mat'])

save([sleepDir,'/' decodeResultFilename] ,'-mat','zmcorrTrain','zmcorrTest','stdcorrTrain','stdcorrTest','nTrialsPerClass','min_n_samples','nan_ind')

clear FaceOffData FaceOnData data ind_test ind_train log10S;

