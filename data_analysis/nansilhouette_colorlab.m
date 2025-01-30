function [s,h] = nansilhouette_colorlab(X, clust, color_vect_all, filenames2use, distance, varargin)
%SILHOUETTE Silhouette plot for clustered data.
%   SILHOUETTE(X, CLUST) plots cluster silhouettes for the N-by-P data
%   matrix X, with clusters defined by CLUST.  Rows of X correspond to
%   points, columns correspond to coordinates.  CLUST is a categorical
%   variable, numeric vector, string array, character matrix, or cell array
%   of strings with a common value for points in the same cluster.
%   SILHOUETTE treats NaNs, or empty strings, in CLUST as missing values,
%   and ignores the corresponding rows of X.  By default, SILHOUETTE uses
%   the squared Euclidean distance between points in X.
%
%   S = SILHOUETTE(X, CLUST) returns the silhouette values in the N-by-1
%   vector S, but does not plot the cluster silhouettes.
%
%   [S,H] = SILHOUETTE(X, CLUST) plots the silhouettes, and returns the
%   silhouette values in the N-by-1 vector S, and the figure handle in H.
%
%   [...] = SILHOUETTE(X, CLUST, DISTANCE) plots the silhouettes using
%   the inter-point distance measure specified in DISTANCE.  Choices
%   for DISTANCE are:
%
%       'Euclidean'    - Euclidean distance
%      {'sqEuclidean'} - Squared Euclidean distance
%       'cityblock'    - Sum of absolute differences, a.k.a. L1
%       'cosine'       - One minus the cosine of the included angle
%                        between points (treated as vectors)
%       'correlation'  - One minus the sample correlation between
%                        points (treated as sequences of values)
%       'Hamming'      - Percentage of coordinates that differ
%       'Jaccard'      - Percentage of non-zero coordinates that differ
%       vector         - A numeric distance matrix in the vector form
%                        created by PDIST (X is not used in this case,
%                        and can safely be set to [])
%       function       - A distance function specified using @, for
%                        example @DISTFUN
%
%   A distance function must be of the form
%
%         function D = DISTFUN(X0, X, P1, P2, ...),
%
%   taking as arguments a single 1-by-P point X0 and an N-by-P matrix
%   of points X, plus zero or more additional problem-dependent arguments
%   P1, P2, ..., and returning an N-by-1 vector D of distances between X0
%   and each point (row) in X.
%
%   [...] = SILHOUETTE(X, CLUST, DISTFUN, P1, P2, ...) passes the
%   arguments P1, P2, ... directly to the function DISTFUN.
%
%   The silhouette value for each point is a measure of how similar that
%   point is to points in its own cluster vs. points in other clusters,
%   and ranges from -1 to +1.  It is defined as
%
%      S(i) = (min(AVGD_BETWEEN(i,k)) - AVGD_WITHIN(i))
%                              / max(AVGD_WITHIN(i), min(AVGD_BETWEEN(i,k)))
%
%   where AVGD_WITHIN(i) is the average distance from the i-th point to the
%   other points in its own cluster, and AVGD_BETWEEN(i,k) is the average
%   distance from the i-th point to points in another cluster k.
%
%   Example:
%
%      X = [randn(10,2)+ones(10,2); randn(10,2)-ones(10,2)];
%      cidx = kmeans(X, 2, 'distance', 'sqeuclid');
%      s = silhouette(X, cidx, 'sqeuclid');
%
%   See also KMEANS, LINKAGE, DENDROGRAM, PDIST.

%   References:
%     [1] Kaufman L. and Rousseeuw, P.J. Finding Groups in Data: An
%         Introduction to Cluster Analysis, Wiley, 1990

%   Copyright 1993-2019 The MathWorks, Inc.


if nargin > 1
    clust = convertStringsToChars(clust);
end

if nargin > 2
    distance = convertStringsToChars(distance);
end

narginchk(2,Inf);

% grp2idx sorts a numeric grouping variable in ascending order, and a
% string grouping variable in order of first occurrence
[idx,cnames] = grp2idx(clust);
nIn = length(idx);
if ~isempty(X) && (nIn ~= size(X,1))
    error(message('stats:silhouette:InputSizeMismatch'));
end

% Remove NaNs, and get size of the non-missing data
% if ~isempty(X)
%     [~, wasnan, X, idx] = statremovenan(X, idx);
% else
%     [~, wasnan, idx] = statremovenan(idx);
% end
n = length(idx);
p = size(X,2);
k = length(cnames);
count = histc(idx(:)',1:k);

if nargin < 3 || isempty(distance)
    distType = 'sqeuclidean';
else
    if ischar(distance)
        distNames = {'euclidean','sqeuclidean','cityblock','cosine',...
            'correlation','hamming','jaccard'};
        i = find(strncmpi(distance, distNames, length(distance)));
        if length(i) > 1
            error(message('stats:silhouette:AmbiguousDistance', distance));
        elseif isempty(i)
            % Assume an unrecognized string is a function name, and
            % convert it to a handle.  Extra args will be picked up in
            % distArgs.
            distType = 'function'; % user-defined distance function name
            distance = str2func(distance);
        else
            distType = distNames{i};
        end
        % 'cosine' and 'correlation' distances need normalized points
        switch distType
            case 'cosine'
                Xnorm = sqrt(sum(X.^2, 2));
                if any(min(Xnorm) <= eps(max(Xnorm)))
                    error(message('stats:silhouette:InappropriateCosDistance'));
                end
                X = X ./ Xnorm(:,ones(1,p));
            case 'correlation'
                X = X - repmat(mean(X,2),1,p);
                Xnorm = sqrt(sum(X.^2, 2));
                if any(min(Xnorm) <= eps(max(Xnorm)))
                    error(message('stats:silhouette:InappropriateCorDistance'));
                end
                X = X ./ Xnorm(:,ones(1,p));
        end
    elseif isnumeric(distance)
        if (size(distance,1) == 1) && (size(distance,2) == .5*nIn*(nIn-1))
            if any(distance < 0)
                error(message('stats:silhouette:NegDistanceValues'));
            end
            distType = 'matrix'; % user-supplied distance upper triangle
            % Need to remove entries corresponding to nans in idx
            %             if any(wasnan)
            %                 distance = UTMatSub(distance, find(wasnan));
            %             end
        else
            error(message('stats:silhouette:DistanceMatrixNotUpperTri'));
        end
    elseif isa(distance,'function_handle') || isa(distance,'inline')
        distType = 'function'; % user-defined distance function
    else
        error(message('stats:silhouette:InvalidDistance'));
    end
    distArgs = varargin(1:end); % may be empty
end

% Create a list of members for each cluster
mbrs = (repmat(1:k,n,1) == repmat(idx,1,k));

% Get avg distance from every point to all (other) points in each cluster
myinf = zeros(1,1,class(X));
myinf(1) = Inf;
avgDWithin = repmat(myinf, n, 1);
avgDBetween = repmat(myinf, n, k);

if strcmp(distType,'matrix') || strcmp(distType,'function')
    for j = 1:n
        switch distType
            case 'matrix'
                distj = UTMatCol(distance, j);
            case 'function'
                try
                    distj = feval(distance, X(j,:), X, distArgs{:});
                    [numx,numy] = size(distj);
                    if numx == 1 && numy == n
                        distj = distj';
                    end
                catch ME
                    if isa(distance,'inline')
                        m = message('stats:silhouette:InlineDistanceFunctionError');
                        throw(addCause(MException(m.Identifier,'%s',getString(m)),ME));
                    elseif strcmp('MATLAB:UndefinedFunction', ME.identifier) ...
                            && ~isempty(strfind(ME.message, func2str(distance)))
                        error(message('stats:silhouette:DistanceFunctionNotFound', func2str( distance )));
                    else
                        m = message('stats:silhouette:DistanceFunctionError',func2str(distance));
                        throw(addCause(MException(m.Identifier,'%s',getString(m)),ME));
                    end
                end
        end

        % Compute average distance by cluster number
        [avgDWithin(j),avgDBetween(j,:)] = internal.stats.silhouette(...
            distj,mbrs,cast(count, 'like', distj),k,idx(j));
    end
else
    % If the distance is supported by pdist2, pass the data to C++ builtin
    % and compute pdist2 within it.
    [avgDWithin,avgDBetween] = internal.stats.silhouette(...
        X',mbrs,cast(count, 'like', X),k,idx,distType(1:3));
end
% Calculate the silhouette values
minavgDBetween = min(avgDBetween, [], 2);
silh = (minavgDBetween - avgDWithin) ./ max(avgDWithin,minavgDBetween);

if (nargout == 0) || (nargout > 1)
    % Create the bars:  group silhouette values into clusters, sort values
    % within each cluster.  Concatenate all the bars together, separated by
    % empty bars.  Locate each tick midway through each group of bars
    space = max(floor(.02*n), 2);
    bars = NaN(space,1);
    color_vect_bars=ones(space,3); % white, should not be plotted since corresponding values are NaN
    for i = 1:k
        bars = [bars; -sort(-silh(idx == i)); NaN(space,1)];
        tcks(i) = length(bars);
        color_vect_bars=[color_vect_bars; color_vect_all(idx == i,:); ones(space,3)];
    end
    tcks = tcks - 0.5*(diff([space tcks]) + space - 1);

    % Plot the bars, don't clutter the plot if there are lots of
    % clusters or bars
    if k > 20
        cnames = '';
    end
    % barsh = barh(bars, 1.0);
    for ibar=1:length(bars)
        barsh(ibar) = barh(ibar,bars(ibar), 1,'FaceColor',color_vect_bars(ibar,:),'EdgeColor',color_vect_bars(ibar,:));
        hold on;
    end
    axesh = get(barsh(1), 'Parent');
    % set(axesh, 'Xlim',[-Inf 1.1], 'Ylim',[1 length(bars)], 'YDir','reverse', 'YTick',tcks, 'YTickLabel',cnames);
    % set(axesh, 'Xlim',[-Inf 1.1], 'Ylim',[1 length(bars)], 'YDir','reverse', 'YTick',tcks, 'YTickLabel',strrep(filenames2use,'.mat',''));
    set(axesh, 'Xlim',[-Inf 1.], 'Ylim',[1 length(bars)], 'YDir','reverse', 'YTick',tcks, 'YTickLabel',strrep(filenames2use,'.mat',''));
    if n > 50
        shading flat
    end
    xlabel(getString(message('stats:silhouette:xlabel')));
    ylabel(getString(message('stats:silhouette:ylabel')));
end

if nargout > 0
    % s = statinsertnan(wasnan,silh); % this version does not insert NaNs back: it's supposed to be called with a distance fun that ignores NaNs
    s=silh;
end
if nargout > 1
    h = get(axesh, 'Parent');
end

%------------------------------------------------------------------

function Aj = UTMatCol(A, j)
% Get a column of a matrix that's in upper triangular vector form

n = ceil(sqrt(2*length(A))); % (1 + sqrt(1+8*length(A)))/2, but works for large A

% Start with the diagonal element
Aj = 0;
% Prepend any elements above the diagonal
if j > 1
    ii = 1:(j-1);
    Aj = [A((ii-1).*(n-ii/2)+j-ii)'; Aj];
end
% Append any elements below the diagonal
if j < n
    jj = (j+1):n;
    Aj = [Aj; A((j-1).*(n-j/2)+jj-j)'];
end


%------------------------------------------------------------------

function A = UTMatSub(A, cut)
% Cut columns and rows from a matrix that's in upper triangular vector form

n = ceil(sqrt(2*length(A))); % (1 + sqrt(1+8*length(A)))/2, but works for large A

% Create a list of elements to delete, then delete them
dels = [];
for j = cut
    % Add above-diagonal column elements to the delete list
    if j > 1
        ii = 1:(j-1);
        dels = [dels (ii-1).*(n-ii/2)+j-ii];
    end
    % Add right-of-diagonal row elements to the delete list
    if j < n
        jj = (j+1):n;
        dels = [dels (j-1).*(n-j/2)+jj-j];
    end
end
A(dels) = [];
