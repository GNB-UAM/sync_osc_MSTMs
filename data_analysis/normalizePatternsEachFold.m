function [cl,ts] = normalizePatternsEachFold(cl,ts)

nClass=length(cl);

% this code assumes that every class has the same number of trials
[nTrialsTr nAttributes]=size(cl{1});
[nTrialsTs nAttributes]=size(ts{1});

allPatterns=[];

for class=1:nClass
    allPatterns=[allPatterns; cl{class}];
end

meanPatterns=mean(allPatterns);
stdPatterns=std(allPatterns,0,1);

meanmat=repmat(meanPatterns,nTrialsTr,1);
stdmat=repmat(stdPatterns,nTrialsTr,1);

for class=1:nClass
    cl{class}=(cl{class}-meanmat)./stdmat;
end

meanmat=repmat(meanPatterns,nTrialsTs,1);
stdmat=repmat(stdPatterns,nTrialsTs,1);

for class=1:nClass
    ts{class}=(ts{class}-meanmat)./stdmat;
end

