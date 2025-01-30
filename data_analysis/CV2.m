function outData = CV2(spikeTimes, order)
% function CV2_value = CV2(spikeTimes, order)
% order is a vector with default 1
% if spikeTimes is a single number or no arguements are passed then a
% poisson process is assumed with spikeTimes events (default = 10000)

% analysis after Holt GR, Softky WR, Koch C, Douglas RJ.  Comparison of
% discharge variability in vitro and in vivo in cat visual cortex neurons.
% J Neurophysiol. 75, 1806-15.

if nargin < 1 || numel(spikeTimes) == 1
%     % generate some random poison process data
%     if nargin < 1
%         spikeTimes = 10000;
%     end
%     refractoryPeriod = 1;
%     spikeTimes = exprnd(1, spikeTimes, 1);
%     spikeTimes = cumsum(spikeTimes(spikeTimes > refractoryPeriod));
    error('numel(spikeTimes) == 1 : at least two spike times are needed to compute CV2');
end

if nargin < 2
    order = 1;
end

if numel(order) > 1
    outData = [];
    for i = order
        outData(end + 1) = CV2(spikeTimes, i);
    end
    figure, plot(order, outData);
    xlabel('ISI order');
    ylabel('Mean CV2');
    return
end

ISI = spikeTimes(1 + order:end) - spikeTimes(1:end - order);

CVval = 2 * abs((ISI(2:end) - ISI(1:end - 1))) ./ (ISI(2:end) + ISI(1:end - 1));
outData = mean(CVval);

if ~nargout
    figure;
    plot((ISI(2:end) + ISI(1:end - 1)) / 2, CVval, 'lineStyle', 'non', 'marker', '.');
   	[orderedData indices] = sort((ISI(2:end) + ISI(1:end - 1)) / 2);
    meanData = nan(10, 1);
    stdData = meanData;
    for i = 1:10
        meanData(i) = mean(CVval(indices(round((i - 1) * numel(CVval) / 10 + (1:numel(CVval) / 10)))));
        stdData(i) =  std(CVval(indices(round((i - 1) * numel(CVval) / 10 + (1:numel(CVval) / 10)))));
    end
    hold on
    errorbar(orderedData(round(numel(CVval) .* (.05:.1:.95))), meanData, stdData ./ sqrt(numel(CVval) / 10 - 1), 'color', [0 0 0]);
    xlabel('Mean ISI of pair');
    ylabel('CV2');
end

