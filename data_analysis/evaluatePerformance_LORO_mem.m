function [P] =evaluatePerformance_LORO_mem(cResp,C,ind_train,ind_test)
ff = C;

PLOT.ROC = 0;

nfiles=size(cResp,1);
for ifile=1:nfiles % recording to test
    clear corrTrainEachFile corrTestEachFile; % watch out that currently these are accumulated over ifile
    for iSample = 1:ff.nFoldValidation
        cl=cell(1,2);
        ts=cell(1,2);
        switch ff.task
            case {'sleep'}
                for jfile=1:nfiles % recording in training set
                    cl{1} = [cl{1}; cResp{jfile,1}(squeeze(ind_train{ifile,jfile,iSample,1}),:)]; % concatenate across recordings in training set
                    cl{2} = [cl{2}; cResp{jfile,2}(squeeze(ind_train{ifile,jfile,iSample,2}),:)];
                    ts{1} = [ts{1}; cResp{jfile,1}(squeeze(ind_test{ifile,jfile,iSample,1}),:)];
                    ts{2} = [ts{2}; cResp{jfile,2}(squeeze(ind_test{ifile,jfile,iSample,2}),:)];
                end
        end

        [cl,ts]=normalizePatternsEachFold(cl,ts);

        [nClTrial(1)] = size(cl{1},1);
        [nClTrial(2)] = size(cl{2},1);
        [nTsTrial(1)] = size(ts{1},1);
        [nTsTrial(2)] = size(ts{2},1);

        ff.nClTrial = nClTrial;
        ff.nTsTrial = nTsTrial;

        y = [ones(nClTrial(1),1);-ones(nClTrial(2),1)];
        x = [cl{1};cl{2}];
        testX = [ts{1};ts{2}];

        iLambda = 1;
        lambda = ff.vLambda(iLambda);
        w = trainRLSC(x,y,[],lambda);
        trainY = w*[ones(size(x,1),1),x]';
        predY = w*[ones(size(testX,1),1), testX]';

        trainYcriterion = sort(trainY,'descend');
        clear trainPHit trainPFA
        for iCriterion = 1:length(trainYcriterion)
            trainPHit(iCriterion) = sum(trainY(1:ff.nClTrial(1)) > trainYcriterion(iCriterion) ) /ff.nClTrial(1) ;
            trainPFA(iCriterion)  = sum(trainY(ff.nClTrial(1)+1 : sum(ff.nClTrial(:)) ) > trainYcriterion(iCriterion) ) / ff.nClTrial(2);
        end
        corrTrainEachFile(iSample) = AreaUnderROC([trainPHit',trainPFA']);

        %% area under R
        predYcriterion = sort(predY,'descend');
        clear pHit pFA
        for iCriterion = 1:length(predYcriterion)
            pHit(iCriterion) = sum(predY(1:ff.nTsTrial(1)) ...
                > predYcriterion(iCriterion) ) / ff.nTsTrial(1);
            pFA(iCriterion) = sum(predY(ff.nTsTrial(1)+1: ...
                sum(ff.nTsTrial(:))) > predYcriterion(iCriterion) ) ...
                / ff.nTsTrial(2);
        end
        corrTestEachFile(iSample) = AreaUnderROC([pHit',pFA']);

        if PLOT.ROC
            figure(800000),clf, hold on
            plot(trainPFA,trainPHit,'g','linewidth',3)
            plot(pFA,pHit,'b','linewidth',3)
            plot([0 1],[0 1],'k')
            axis square
            xlabel('pFA')
            ylabel('pHit')
        end

    end
    corrTrain(ifile)=mean(corrTrainEachFile); % mean and std over crossval folds, for each test recording
    corrTest(ifile)=mean(corrTestEachFile);
    stdcorrTrain(ifile)=std(corrTrainEachFile);
    stdcorrTest(ifile)=std(corrTestEachFile);
end

P.zmcorrTrain = corrTrain;
P.zmcorrTest = corrTest;
P.stdcorrTrain = stdcorrTrain;
P.stdcorrTest = stdcorrTest;