% Unit-test for an example measure - Mean Phase Coherence
% see also
% https://www.mathworks.com/help/matlab/matlab_prog/write-script-based-unit-tests.html
% for information on how to adapt this script for testing of novel measures

% spike train parameters
par.names_string='050723';
par.n_neu=[100];
par.sim_time=[10000];
par.t_refr=[4];
par.rate=[12];
par.f_osc=[12];
par.tau_OUnoise=[10];
par.transient=[100];
par.seed=[38528];
par.inct=[0.01];
par.Rp_dt=[0.1];
par.sigmaGpercent=[0.0]; % for (perfectly synchronous) oscG and expG trains
par.p_fail=[0.0]; % for (perfectly synchronous) oscG and expG trains
par.r_osc_ampl=[0]; % for (asynchronous) osc trains
tol = 1e-10; % tolerance for perfectly synchronous trains (can be very small for this measure)
tol_async=0.1; % tolerance for asynchronous trains (not that small, appropriate values depend on par.sim_time)

%% Test 1: perfectly synchronous pseudo-rhythmic spike train

stringa='train_sync_oscG';
generate_oscG_train(stringa,par);

test_this=load(fullfile(pwd,stringa,stringa),'spiketimes');
[MPC,MPCE,MPCI,phase_coherence_mat]=phase_coherence_ei(test_this.spiketimes,par.n_neu);

assert(abs(MPC-1.)<=tol); % target value: 1



%% Test 2: perfectly synchronous non-rhythmic spike train

stringa='train_sync_expG';
generate_expG_train(stringa,par);

test_this=load(fullfile(pwd,stringa,stringa),'spiketimes');
[MPC,MPCE,MPCI,phase_coherence_mat]=phase_coherence_ei(test_this.spiketimes,par.n_neu);

assert(abs(MPC-1.)<=tol); % target value: 1



%% Test 3: asynchronous spike train

stringa='train_async';
generate_osc_train(stringa,par);

test_this=load(fullfile(pwd,stringa,stringa),'spiketimes');
[MPC,MPCE,MPCI,phase_coherence_mat]=phase_coherence_ei(test_this.spiketimes,par.n_neu);

assert(MPC<=tol_async); % for async trains, MPC tends to 0 as window length increases. Note that it is possible for this test to fail due to finite-sampling effects, e.g. see Fig. S3A

