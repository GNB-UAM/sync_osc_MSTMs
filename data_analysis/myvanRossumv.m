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

    D=D1+D2-2*D3;

    D=sqrt(D);

else                                                                   % tc = Inf --- pure rate code

    % D = x_num_spikes * (x_num_spikes - y_num_spikes) + y_num_spikes * (y_num_spikes-x_num_spikes);
    D = abs(x_num_spikes - y_num_spikes);

end

D=D./sqrt(tc); % original normalization as in van Rossum 2001. With this normalization, adding or removing one spike increases the distance by 1/sqrt(2)

Dn=sqrt(2).*D./sqrt(x_num_spikes + y_num_spikes); % always included in [0,1]