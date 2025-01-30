function [P] =evaluatePerformance_mem(cResp,C,ind_train,ind_test)
ff = C;

PLOT.ROC = 0;

for iSample = 1:ff.nFoldValidation
    cl = [];
    switch ff.task
        case {'sleep'}
            cl{1} = cResp{1}(squeeze(ind_train(iSample,1,:)),:);
            cl{2} = cResp{2}(squeeze(ind_train(iSample,2,:)),:);
            ts{1} = cResp{1}(squeeze(ind_test(iSample,1,:)),:);
            ts{2} = cResp{2}(squeeze(ind_test(iSample,2,:)),:);
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
    corrTrain(iSample) = AreaUnderROC([trainPHit',trainPFA']);
    
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
    corrTest(iSample) = AreaUnderROC([pHit',pFA']);
        
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

P.zmcorrTrain = mean(corrTrain);
P.zmcorrTest = mean(corrTest);
P.stdcorrTrain = std(corrTrain);
P.stdcorrTest = std(corrTest);