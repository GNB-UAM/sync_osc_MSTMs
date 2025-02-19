function myyscale_symlog(h)
% yscale_symlog applies symmetric logarithmic scale to Y axis of current axis (negative
% logarithmic scale on the bottom, positive logarithmic scale on the top)
%
% yscale_symlog(AX) applies to axes AX instead of current axes.

if nargin<1
    h = gca;
end

% get all objects from current axis
O = findobj(h);
Otype = get(O, 'type');
O(strcmp(Otype, 'axes') | strcmp(Otype, 'legend')) = [];  % exclude axes and legend types

% get Y values from all objects
Y = get(O,'YData');
if ~iscell(Y)
    Y = {Y};
end

% single vector of values
Yall = cellfun(@(x) x(:)', Y, 'uniformoutput',0);
Yall = [Yall{:}];

yl = ylim(h); %

% if all positive values, then we can simply use built-in log scale option
if yl(1)>=0
    set(h, 'yscale','log')
    return;
end

min_negval = max(Yall(Yall<0)); % maximum value from all negative values
min_negval = floor(log10(-min_negval)-.1); % get negative log value and round up

min_posval = min(Yall(Yall>0)); % minimum value from all positive values
min_posval = floor(log10(min_posval)-.1); % get log value and round up

% transform Y values for each object
for u=1:length(O)
    this_y = Y{u};
    this_y(this_y>0) = posvalpos(this_y(this_y>0),min_posval); % for positive values
    this_y(this_y<0) =negvalpos(this_y(this_y<0),min_negval); % for negative values
    set(O(u), 'YData',this_y);
end

set(h, 'YTickLabelMode','auto');

% set new limits for yaxis
new_yl(1) = negvalpos(yl(1),min_negval);
if new_yl(1)>-1 % make sure at least one neg tick with integer value (in log10 space)
    new_yl(1) = -1;
end
if yl(2)>0
    new_yl(2) = posvalpos(yl(2),min_posval);
    if new_yl(2)<1 % make sure at least one tick with integer value (in log10 space)
        new_yl(2) = 1;
    end
elseif yl(2)<0
    new_yl(2) = negvalpos(yl(2),min_negval);
else
    new_yl(2) = 0;
end
ylim(h, new_yl);

% set tick labels
tick = get(h,'YTick');
% if all(tick<=0) % adding 2 positive ticks if there are none
extreme_pos_tick=floor(max(this_y)); % adding extreme positive tick for better readibility
if ~ismember(extreme_pos_tick,tick) % if not already included
    tick=unique([tick extreme_pos_tick]);
    pos_tick=tick(tick>=0);
    neg_tick=tick(tick<=0);
    % tick=unique([neg_tick 0 1:extreme_pos_tick]); % this puts all ticks
    if length(pos_tick)>=3 % we need at least 2 ticks >= 0
        pos_tick_diff=pos_tick(2:end)-pos_tick(1:end-1);
        if length(pos_tick_diff)>1 % not evenly spaced
            tick=unique([neg_tick 0 1:extreme_pos_tick]); % this puts all ticks
        end
    else
        tick=unique([neg_tick 0 1:extreme_pos_tick]); % this puts all ticks
    end
end
% tick=[tick ceil(extreme_pos_tick/2) extreme_pos_tick];
% tick=unique([tick 1 ceil(extreme_pos_tick/2) extreme_pos_tick]); % this can yield unevenly spaced ticks
% end

extreme_neg_tick=ceil(min(this_y)); % adding extreme negative tick for better readibility
if ~ismember(extreme_neg_tick,tick)
    % tick=[extreme_neg_tick tick];
    % tick=sort([extreme_neg_tick -1 tick]); % this can yield unevenly spaced ticks
    tick=unique([extreme_neg_tick tick]);
    pos_tick=tick(tick>=0);
    neg_tick=tick(tick<=0);
    % tick=unique([extreme_neg_tick:-1:0 pos_tick]); % this puts all ticks
    if length(neg_tick)>=3 % we need at least 2 ticks <= 0
        neg_tick_diff=neg_tick(2:end)-neg_tick(1:end-1);
        if length(neg_tick_diff)>1 % not evenly spaced
            tick=unique([extreme_neg_tick:-1:0 pos_tick]); % this puts all ticks
        end
    else
        tick=unique([extreme_neg_tick:-1:0 pos_tick]); % this puts all ticks
    end
end

ticklabel = cell(1,length(tick));
excl_tick = mod(tick,1)~=0; % exclude ticks that do not fall on integer value in log10 space
tick(excl_tick) = [];

% add intermediate ticks in log scale
if  mean(excl_tick)>.3
    add_intermediate = log10(2:9); % add intermediate ticks for all  integers
elseif mean(excl_tick)>0
    add_intermediate = log10(2:6); % add intermediate ticks for integers 2 to 6
else
    add_intermediate = []; % do not add intermediate ticks
end
for u = length(tick)-1:-1:find(tick==0) % ticks in positive log scale
    tick = [tick(1:u) tick(u)+add_intermediate tick(u+1:end)];
end
for u = find(tick==0)-1:-1:1 % ticks in negaive log scale
    tick = [tick(1:u) tick(u)+1-fliplr(add_intermediate) tick(u+1:end)];
end


for u=1:length(tick)
    if mod(tick(u),1)% for non-integer, keep tick without label
        ticklabel{u} = '';
    else
        if tick(u)<0 % negative values
            switch -tick(u)+min_negval
                case 0
                    ticklabel{u} = '-1';
                case 1
                    ticklabel{u} = '-10';
                case -1
                    ticklabel{u} = '-0.1';
                otherwise
                    ticklabel{u} = ['-10^{' num2str(-tick(u)+min_negval) '}'];
            end
        elseif tick(u)>0
            switch tick(u)+min_posval
                case 0
                    ticklabel{u} = '1';
                case 1
                    ticklabel{u} = '10';
                case -1
                    ticklabel{u} = '0.1';
                otherwise
                    ticklabel{u} = ['10^{' num2str(tick(u)+min_posval) '}'];
            end
        else
            ticklabel{u} = '0';
        end
    end
end
[tick_unique i_tick_unique]=unique(tick);
if length(tick_unique)==length(tick)
    set(h, 'ytick',tick,'yticklabel',ticklabel); % can give if "Error using matlab.graphics.axis.Axes/set Value must be a numeric vector whose values increase." not unique
else
    % set(h, 'ytick',tick_unique,'yticklabel',ticklabel{i_tick_unique}); % The property name '0' is not a valid MATLAB identifier.
    set(h, 'ytick',tick_unique,'yticklabel',ticklabel(i_tick_unique));
end
end

% position for positive values
function V = posvalpos(Z, ref)
V = log10(Z) - ref';
end

% position for negative values
function V = negvalpos(Z, ref)
V = - log10(-Z) + ref';
end


