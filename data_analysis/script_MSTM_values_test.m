% Value-checking unit tests for several MSTMs, on small spike trains with known answers
% see also script_MPC_test.m and
% https://www.mathworks.com/help/matlab/matlab_prog/write-script-based-unit-tests.html
% Spike times are in ms. The MEX-based tests need the MEX files compiled for this platform

tol=1e-10;

% small sequential population: neuron j fires once per 100 ms cycle with a lag of 5*j ms plus jitter,
% so that neuron index tracks phase (as in the sequential trains of the paper)
rng(1,'twister');
n_seq=6;
sim_time_seq=2000;
seq=struct('t',cell(1,n_seq));
for j=1:n_seq
    t_this=(3+5*j:100:sim_time_seq-10)';
    seq(j).t=sort(t_this+0.5*randn(size(t_this)));
end
perm=n_seq:-1:1; % reversed neuron order

%% Test 1: PPC is Vinck et al 2010's pairwise phase consistency
% spikes of A at known phases of B's cycles: PPC is the mean of cos(theta_j-theta_k) over pairs of phases
B=(0:100:2000)';
phases=mod((1:20)'*0.37,0.2)+0.4; % phases in [0.4,0.6[
A=B(1:end-1)+100*phases;
theta=2*pi*phases;
ppc_ref=0;
for j=1:length(theta)
    for k=j+1:length(theta)
        ppc_ref=ppc_ref+cos(theta(j)-theta(k));
    end
end
ppc_ref=ppc_ref/(length(theta)*(length(theta)-1)/2);
assert(abs(pairwise_phase_consistency_pairs(A,B)-ppc_ref)<=tol);
% constant phase lag (here, antiphase): perfect phase consistency
assert(abs(pairwise_phase_consistency_pairs(B(1:end-1)+50,B)-1)<=tol);

%% Test 2: population averages of bivariate measures do not depend on neuron order
seqp=seq(perm);
[VP,VPN]=VictorPurpuramex_allpairs(seq,n_seq,1/4);
[VPp,VPNp]=VictorPurpuramex_allpairs(seqp,n_seq,1/4);
assert(abs(VP-VPp)<=tol*VP && abs(VPN-VPNp)<=tol*VPN);
[vR,vRn]=vanRossumv_allpairs(seq,n_seq,4);
[vRp,vRnp]=vanRossumv_allpairs(seqp,n_seq,4);
assert(abs(vR-vRp)<=tol && abs(vRn-vRnp)<=tol);
assert(abs(spike_time_tiling_coefficient_wrapper(seq,sim_time_seq,16)-spike_time_tiling_coefficient_wrapper(seqp,sim_time_seq,16))<=tol);
assert(abs(correlation_index_wrapper(seq,sim_time_seq,16)-correlation_index_wrapper(seqp,sim_time_seq,16))<=tol);
[emd,emdn]=Wasserstein_allpairs(seq,n_seq,sim_time_seq);
[emdp,emdnp]=Wasserstein_allpairs(seqp,n_seq,sim_time_seq);
assert(abs(emd-emdp)<=tol && abs(emdn-emdnp)<=tol);
[sc,kc]=schreiber_corr(seq,sim_time_seq,4,0.1);
[scp,kcp]=schreiber_corr(seqp,sim_time_seq,4,0.1);
assert(abs(sc-scp)<=tol && abs(kc-kcp)<=tol);
assert(abs(modulus_metric_wrapper(seq,sim_time_seq)-modulus_metric_wrapper(seqp,sim_time_seq))<=tol*modulus_metric_wrapper(seq,sim_time_seq));
assert(abs(LZ_distance(seq,sim_time_seq,1.)-LZ_distance(seqp,sim_time_seq,1.))<=tol);

%% Test 3: population average is the uniform mean over all pairs
sttc_pairs=[];
for i=1:n_seq
    for j=i+1:n_seq
        sttc_pairs(end+1)=spike_time_tiling_coefficient_mex(int32(length(seq(i).t)),int32(length(seq(j).t)),16,[0 sim_time_seq],seq(i).t,seq(j).t);
    end
end
assert(abs(spike_time_tiling_coefficient_wrapper(seq,sim_time_seq,16)-mean(sttc_pairs))<=tol);

%% Test 4: van Rossum distance normalized as in van Rossum 2001
% one spike against an empty train: D=1/sqrt(2) for any timescale
for tau=[1 4 64]
    [D,Dn]=myvanRossumv(500,zeros(0,1),tau);
    assert(abs(D-1/sqrt(2))<=tol);
    assert(abs(Dn-1)<=tol);
end
% two spikes 3 ms apart, tau=4 ms: D^2=(1/tau)*integral of the squared difference of the filtered trains
[D,Dn]=myvanRossumv(10,13,4);
assert(abs(D-sqrt(1-exp(-3/4)))<=tol);
% non-overlapping sparse trains: normalized distance is 1
[D,Dn]=myvanRossumv((100:100:1000)',(150:100:1050)',1);
assert(abs(Dn-1)<=1e-6);

%% Test 5: adaptive Quian Quiroga synchrony uses the ISIs around the two spikes being compared (Eq. 4)
% the match of x=100 with y=101.5 is rejected: tau=min(90,2.5)/2=1.25 < 1.5
[QQA,qqa]=QuianQuirogaA([10;100],[11;99;101.5]);
assert(abs(QQA-2/sqrt(6))<=tol);
assert(abs(qqa)<=tol);

%% Test 6: correlation index uses only the first N2 spikes of train 2
% one coincidence within dt=5 ms over T=1000 ms: Ci=1000*1/(1*1*2*5)=100. Train 2 is passed with two extra
% values after its single spike, which must not be read
ci=correlation_index_mex(int32(1),int32(1),5,[0 1000],100,[101;102;103]);
assert(abs(ci-100)<=tol);

%% Test 7: synfire indicator ordering is reproducible with MATLAB's rng
rng(2,'twister');
D=randn(15);
D=D-D'; % antisymmetric matrix, as for spike train order
rng(0,'twister');
[p1,A1,it1]=SPIKE_order_sim_ann_MEX(D);
pause(1.1); % the original implementation seeded from the clock (in seconds)
rng(0,'twister');
[p2,A2,it2]=SPIKE_order_sim_ann_MEX(D);
assert(isequal(p1,p2) && A1==A2 && it1==it2); % same ordering, and the same annealing path

%% Test 8: CV, LCV and log ISI entropy are averaged across neurons, not pooled
% two perfectly regular neurons at 10 and 40 Hz: every per-neuron value is 0
st2=struct('t',{(0:100:10000)',(0:25:10000)'});
[cv_vect,cv]=spiketimes_stat_cv(st2);
[lcv_vect,lcv]=spiketimes_stat_lcv(st2);
[ent_vect,ent]=spiketimes_stat_entropy(st2);
assert(abs(cv)<=tol && abs(lcv)<=tol && abs(ent)<=tol);
% neurons with fewer than 2 ISIs are left out
st3=struct('t',{(0:100:10000)',[5;50],zeros(0,1)});
[cv_vect,cv]=spiketimes_stat_cv(st3);
assert(abs(cv)<=tol && all(isnan(cv_vect(2:3))));
