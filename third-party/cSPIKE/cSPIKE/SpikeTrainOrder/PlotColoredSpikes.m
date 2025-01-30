function  PlotColoredSpikes(STs,SpikeOrderSpikeValues,tmin,tmax)

intervals = 100;
cmap = colormap(jet(100));
caxis([-1 1])
value = linspace(-1,1,intervals);
hold on;
STStoPlot=cell(1,size(STs,2));
for i = 1:intervals-1
    for ii = 1:size(STs,2)
        STStoPlot{ii} = STs{ii}(logical((SpikeOrderSpikeValues{ii} <= value(i+1)).*(SpikeOrderSpikeValues{ii} >= value(i))));
    end
    STS = SpikeTrainSet(STStoPlot,tmin,tmax);
    STS.plotSpikeTrainSet(cmap(i,:),3);    
end

for ii = 1:size(STs,2)
    STStoPlot{ii} = STs{ii}(isnan(SpikeOrderSpikeValues{ii}));
end
STS = SpikeTrainSet(STStoPlot,tmin,tmax);
STS.plotSpikeTrainSet('k',1);

end

