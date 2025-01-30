InitializecSPIKE;

load('SpikeTrainOrder_spikes');% Replace with your own spike trains
tmin=0;
tmax=1000;
num_surros = 0;

STS = SpikeTrainSet(spikes,tmin,tmax);
SpikeTrainCount = size(spikes,2);

% Spike Train Order with 19 surrogates
[initialIteration,optimalIteration,synf,so_profs,sto_profs] = STS.SpikeTrainOrderWithSurrogates(num_surros);

% minimum and maximum boundaries for colour coding
Cmin = min(min(min(initialIteration.PairwiseMatrixD)),min(min(optimalIteration.PairwiseMatrixD)));
Cmax = max(max(max(initialIteration.PairwiseMatrixD)),max(max(optimalIteration.PairwiseMatrixD)));

% Making figure at size 800x600 pixels 
FigureSize = [800 600];
FontSize = 8;
ticksize = 7;
height = 0.13;
PositionArray = [0.05 0.05+(1:4)*0.195];


fig = figure('Position', [200, 70, 100+FigureSize(1), 100+FigureSize(2)]);
% Spike order profile
sb1 = subplot('Position',[0.1 PositionArray(5) 0.7 height]);
PlotColoredSpikes( initialIteration.SpikeTrains, initialIteration.SpikeOrderSpikeValues,tmin,tmax )
STs = initialIteration.SpikeTrains;
STS = SpikeTrainSet(STs,tmin,tmax);
set(sb1,'Ytick', (1:SpikeTrainCount)-0.5);
set(sb1,'YTickLabel', fliplr(initialIteration.Order) );
title('Spike trains','FontSize',FontSize)
box on
a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'fontsize',ticksize)
%Adding colorbar
axes('Position', [0.81 PositionArray(5) 0.01 height] ,'Visible', 'off');
c = colorbar;
% Adjusting colorbar width
cpos = c.Position;
cpos(3) = 0.03;
c.Position = cpos;
% Color bar range
caxis([-1 1])
% Adding D to indicate value range
xl = xlim;
yl = ylim;
right = 7;
up = 0.7;
text(xl(2)+(xl(2)-xl(1))*right, (yl(2)-yl(1))*up,'D')

% Spike Train Order profile
sb2 = subplot('Position',[0.1 PositionArray(4) 0.7 height]);
plot(initialIteration.TimeProfileE(2,:),initialIteration.TimeProfileE(1,:),'-ok','MarkerFaceColor','black')
hold on;
%Plotting the channel
plot(initialIteration.SynchronizationProfile(2,:),initialIteration.SynchronizationProfile(1,:),'--k','MarkerFaceColor','black')
plot(initialIteration.SynchronizationProfile(2,:),-initialIteration.SynchronizationProfile(1,:),'--k','MarkerFaceColor','black')
ylim([-1.15, 1.15])
title('Time profile E','FontSize',FontSize)
xl = xlim;
yl = ylim;
text(((xl(2)-xl(1))*1.05),yl(1)+(yl(2)-yl(1))*0.8,['C=' ,num2str(initialIteration.SynchronizationValueC, '%.3f')],'FontSize',FontSize)
text(((xl(2)-xl(1))*1.05),yl(1)+(yl(2)-yl(1))*0.3,['F_u=',num2str(initialIteration.SynfireIndicatorF, '%.3f')],'FontSize',FontSize)
hold on;
plot([xl(1) xl(2)],[0 0], ':k')
a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'fontsize',ticksize)

% D matrix for original
sb3 = subplot('Position',[0.11 PositionArray(3) height height]);
imagesc(initialIteration.PairwiseMatrixD)
caxis([Cmin Cmax]);
axis square
set(gca,'YDir','reverse')
title('Pairwise Matrix D','FontSize',FontSize)
set(sb3,'Ytick', 1:SpikeTrainCount);
set(sb3,'YTickLabel', 1:SpikeTrainCount);
set(sb3,'Xtick', 1:SpikeTrainCount);
set(sb3,'XTickLabel', 1:SpikeTrainCount);
%Form separator line(zig-zag)
for trc=1:SpikeTrainCount-1
    line((trc+0.5)*ones(1,2),[trc-0.5 trc+0.5],'Color','k','LineWidth',2)
    line([trc+0.5 trc+1.5],(trc+0.5)*ones(1,2),'Color','k','LineWidth',2)
end
line((SpikeTrainCount+0.5)*ones(1,2),[0.5 SpikeTrainCount-0.5],'Color','k','LineWidth',2)
line([1.5 SpikeTrainCount+0.5],0.5*ones(1,2),'Color','k','LineWidth',2)
a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'fontsize',ticksize)
colormap(sb3,jet(100));

% Sorted D matrix
sb4 = subplot('Position',[0.27 PositionArray(3) height height]);
imagesc(optimalIteration.PairwiseMatrixD)
caxis([Cmin Cmax]);
colormap(jet(100));
axis square
set(gca,'YDir','reverse')
title('Sorted pairwise Matrix D','FontSize',FontSize)
set(sb4,'Ytick', 1:SpikeTrainCount);
set(sb4,'YTickLabel', 1:SpikeTrainCount);
set(sb4,'Xtick', 1:SpikeTrainCount);
set(sb4,'XTickLabel', 1:SpikeTrainCount);
%Form separator line(zig-zag)
for trc=1:SpikeTrainCount-1
    line((trc+0.5)*ones(1,2),[trc-0.5 trc+0.5],'Color','k','LineWidth',2)
    line([trc+0.5 trc+1.5],(trc+0.5)*ones(1,2),'Color','k','LineWidth',2)
end
line((SpikeTrainCount+0.5)*ones(1,2),[0.5 SpikeTrainCount-0.5],'Color','k','LineWidth',2)
line([1.5 SpikeTrainCount+0.5],0.5*ones(1,2),'Color','k','LineWidth',2)
a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'fontsize',ticksize)
colormap(sb4,jet(100));

% Colorbar for the matrices
cb = axes('Position', [0.33 PositionArray(3) height height], 'Visible', 'off');
c = colorbar();
cpos = c.Position;
cpos(3) = 0.03;
c.Position = cpos;
caxis([Cmin Cmax])
colormap(cb,jet(100));

% Synfire indicator graph
sb5 = subplot('Position',[0.60 PositionArray(3) height height]);
hist(synf,100);
set(get(gca,'child'),'FaceColor','red','EdgeColor','r');
yl = ylim;
x = optimalIteration.SynfireIndicatorF;
hold on;
xlabel('F')
axis square
% Adding standard deviation etc
ini = initialIteration.SynfireIndicatorF;
[~,b]=sort([ini synf]);
posi=num_surros+2-find(b==1);
pval=posi/(num_surros+1);
mean_surros=mean(synf);
min_surros=min(synf);
max_surros=max(synf);
min_val=min([ini min_surros]);
max_val=max([ini max_surros]);
abs_max_val=max(abs([ini max_surros]));
std_surros=std(synf);
if std_surros>0
    z_score=(ini-mean_surros)/std_surros;
else
    z_score=0;
end
line(mean_surros*ones(1,2),yl,'Color','r','LineWidth',3)
line(mean_surros+[-std_surros std_surros],(yl(1)+0.65*(yl(2)-yl(1)))*ones(1,2),'Color','r','LineWidth',3)
line((mean_surros-std_surros)*ones(1,2),yl(1)+[0.6 0.7]*(yl(2)-yl(1)),'Color','r','LineWidth',3)
line((mean_surros+std_surros)*ones(1,2),yl(1)+[0.6 0.7]*(yl(2)-yl(1)),'Color','r','LineWidth',3)
if pval<=0.05
    title(['z = ',num2str(z_score,3),'  ;  p = ',num2str(pval,2),'**'],'FontSize',FontSize,'FontWeight','bold')
elseif pval<0.3
    title(['z = ',num2str(z_score,3),'  ;  p > 0.05'],'FontSize',FontSize,'FontWeight','bold')
else
    title(['z = ',num2str(z_score,3),'  ;  p >> 0.05'],'FontSize',FontSize,'FontWeight','bold')
end
plot([x x],[yl(1) yl(2)],'--k','linewidth',1.5)
a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'fontsize',ticksize)

% Time profile E for sorted spike trains
sb6 = subplot('Position',[0.1 PositionArray(2) 0.7 height]);
plot(optimalIteration.TimeProfileE(2,:),optimalIteration.TimeProfileE(1,:),'-ok','MarkerFaceColor','black')
ylim([-1.15, 1.15])
xl = xlim;
yl = ylim;
text(((xl(2)-xl(1))*1.05),yl(1)+(yl(2)-yl(1))*0.8,['C=' ,num2str(optimalIteration.SynchronizationValueC, '%.3f')],'FontSize',FontSize)
text(((xl(2)-xl(1))*1.05),yl(1)+(yl(2)-yl(1))*0.3,['F_u=',num2str(optimalIteration.SynfireIndicatorF, '%.3f')],'FontSize',FontSize)
hold on;
% middle line
plot([xl(1) xl(2)],[0 0], ':k')
% Channel
plot(optimalIteration.SynchronizationProfile(2,:),optimalIteration.SynchronizationProfile(1,:),'--k','MarkerFaceColor','black')
plot(optimalIteration.SynchronizationProfile(2,:),-optimalIteration.SynchronizationProfile(1,:),'--k','MarkerFaceColor','black')
title('Time profile E for sorted spike trains','FontSize',FontSize)
a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'fontsize',ticksize)

% Sorted spike trains
sb7 = subplot('Position',[0.1 PositionArray(1) 0.7 height]);
PlotColoredSpikes( optimalIteration.SpikeTrains, optimalIteration.SpikeOrderSpikeValues,tmin,tmax )
STs = initialIteration.SpikeTrains;
STS = SpikeTrainSet(STs,tmin,tmax);
set(sb7,'Ytick', (1:SpikeTrainCount)-0.5);
set(sb7,'YTickLabel', fliplr(optimalIteration.Order) );
title('Sorted spike trains','FontSize',FontSize)
box on
a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'fontsize',ticksize)
%Adding colorbar
axes('Position', [0.81 PositionArray(1) 0.01 height] ,'Visible', 'off');
c = colorbar;
% Adjusting colorbar width
cpos = c.Position;
cpos(3) = 0.03;
c.Position = cpos;
% Color bar range
caxis([-1 1])
% Adding D to indicate value range
xl = xlim;
yl = ylim;
right = 7;
up = 0.7;
text(xl(2)+(xl(2)-xl(1))*right, (yl(2)-yl(1))*up,'D')


saveas(fig,'SpikeTrainOrderExample.jpg')

