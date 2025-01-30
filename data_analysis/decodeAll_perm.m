function decodeAll_perm(dataDir,filenames,stringa,par)
par_string={'Job','n_neu_min','win_duration','max_n_sample'};

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
C.nPerm = Job.nPerm;
C.randomSampleTest = .3; % 30% for test, 70% for training
C.task = 'sleep';

C.LambdaString=Job.NullString;

decodeEachMeasureAll_perm