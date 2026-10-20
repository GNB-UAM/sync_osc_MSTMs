% Calculates bivariate van Rossum-Distance based on eq5 in  Houghton C & Kreuz T 2012

function [D,Dn] = myvanRossumv(x_spikes,y_spikes,tc)

D =0;
x_num_spikes = length(x_spikes);
y_num_spikes = length(y_spikes);

if tc ~=Inf

    D1=0.;
    D2=0.;
    D3=0.;

    for i=1:x_num_spikes
        d_this=abs((x_spikes(i)-x_spikes))./tc;
        d_this=d_this(d_this<=100); % printf('%e',exp(-100)) = 3.720076e-44
        D1=D1+sum(exp(-d_this));
    end

    for i=1:y_num_spikes
        d_this=abs((y_spikes(i)-y_spikes))./tc;
        d_this=d_this(d_this<=100); % printf('%e',exp(-100)) = 3.720076e-44
        D2=D2+sum(exp(-d_this));
    end

    for i=1:x_num_spikes
        d_this=abs((x_spikes(i)-y_spikes))./tc;
        d_this=d_this(d_this<=100); % printf('%e',exp(-100)) = 3.720076e-44
        D3=D3+sum(exp(-d_this));
    end

    % van Rossum 2001: D^2=(1/tc)*integral((f-g)^2) with causal exponential kernels of time constant tc,
    % whose closed form is (D1+D2-2*D3)/2. Adding or removing one isolated spike increases D^2 by 1/2
    D=D1+D2-2*D3;

    D=sqrt(max(D,0)/2); % max guards against tiny negative values from roundoff

else                                                                   % tc = Inf --- pure rate code

    % D = x_num_spikes * (x_num_spikes - y_num_spikes) + y_num_spikes * (y_num_spikes-x_num_spikes);
    D = abs(x_num_spikes - y_num_spikes)/sqrt(2); % limit of the expression above for tc -> Inf

end

% D is normalized as in van Rossum 2001: one spike against an empty train gives D=1/sqrt(2) for any tc.
% (An earlier version divided D by sqrt(tc) here, which scaled it by sqrt(2/tc) relative to van Rossum 2001)

Dn=sqrt(2).*D./sqrt(x_num_spikes + y_num_spikes); % equals 1 for spike trains whose spikes are all separated by >>tc; can exceed 1 for trains with many spikes within tc of each other (e.g. bursts)