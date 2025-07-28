function plot_decodeEachFile_cb(dataDir,data_file,stringa,par)
par_string={'Job','n_neu_min','win_duration','max_n_sample','png_tail'};

for i=1:length(par_string)
    if(isfield(par,par_string(i)))
        eval([char(par_string(i)) '=par.' char(par_string(i)) ';']);
    end
end

if ~isfield(Job,'iDecodeTypeMulti')
    Job.iDecodeTypeMulti = 1;
end
getDecodeTypeDecodeMode
Job.decodeType = decodeType{Job.iDecodeTypeMulti};
%%
if ~isfield(Job,'iDecodeMode')
    Job.iDecodeMode = 1; % 1 single, 2 pair
end
Job.decodeMode = decodeMode{Job.iDecodeMode};

sleepDir=['~/neuron/sync_osc/' stringa]; % processed sleep scoring data

C.vSession = 1;

C.nLam = 1;
C.vLambda =Job.Lambda;

C.nFoldValidation = Job.nFoldValidation; %% -- FOR WITHIN SESSION DECODING, repeat decoding 10 times.
C.randomSampleTest = .3;
C.task = 'sleep';

C.LambdaString=Job.LambdaString;

c1_string_ind=strfind(Job.decodeType,'_vs_');
c1_string=Job.decodeType(1:c1_string_ind-1);
c2_string=Job.decodeType(c1_string_ind+4:end);

switch Job.decodeMode
    case 'single'
        plot_decodeEachMeasureEachFile_single_cb
    case 'pair'
        plot_decodeEachMeasureEachFile_pair_cb
    otherwise
        keyboard
end
