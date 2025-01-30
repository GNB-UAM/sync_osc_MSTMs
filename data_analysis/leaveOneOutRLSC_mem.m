function [ind_train,ind_test] = leaveOneOutRLSC_mem(cResp,C)
% divide data into X% (= C.randomSampleTest) for test and 100-X% for training.
% Then we will average the performance across n repetition

for iClass = 1:length(cResp)
    nTrialPerSession(iClass) = size(cResp{iClass},1);
end
nTest = round ( min(nTrialPerSession) * C.randomSampleTest );
nTrain = min(nTrialPerSession) - nTest;

for iSample = 1:C.nFoldValidation
    for iClass = 1:length(cResp)
        tmp = randperm(nTrialPerSession(iClass));

        ind_test(iSample,iClass,:)=tmp(1:nTest);
        ind_train(iSample,iClass,:)=tmp((nTest+1):(nTest+nTrain));

    end
end
