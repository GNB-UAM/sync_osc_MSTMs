function [ind_train,ind_test] = leaveOneOutRLSC_LORO_mem(cResp,C)
% LORO
nfiles=size(cResp,1);
nClass=size(cResp,2);
for ifile=1:nfiles
    for iClass = 1:nClass
        nTrialPerSession(ifile,iClass) = size(cResp{ifile,iClass},1);
    end
end
%         nTest = round ( min(min(nTrialPerSession)) * C.randomSampleTest );
%         nTrain = min(min(nTrialPerSession)) - nTest;
nTest = min(min(nTrialPerSession)); % nTest=nTrain for LORO, but I keep this for consistency with other schemes
nTrain = min(min(nTrialPerSession));

for ifile=1:nfiles % recording to test
    for jfile=1:nfiles % recording in training set
        for iSample = 1:C.nFoldValidation
            for iClass = 1:nClass
                tmpi = randperm(nTrialPerSession(ifile,iClass)); % test
                tmpj = randperm(nTrialPerSession(jfile,iClass)); % train
                if ifile==jfile
                    ind_test{ifile,jfile,iSample,iClass}=tmpi(1:nTest);
                    ind_train{ifile,jfile,iSample,iClass}=[];
                else
                    ind_test{ifile,jfile,iSample,iClass}=[];
                    ind_train{ifile,jfile,iSample,iClass}=tmpj(1:nTrain);
                end

            end
        end
    end
end


