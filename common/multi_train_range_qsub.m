function output_struct=multi_train_range_qsub(stringa,stringa_mfile_osc,stringa_mfile_ple,par,ranged_par)
% organises simulations (ranging rate f_osc and r_osc_ampl) and m files to be submitted to a Slurm queue
par_this=par;
BigN=10000000000000000;
bigN=BigN/10^11;

suf1=par.suf1;
suf2=par.suf2;

eval(['n_rate=length(' char(ranged_par(1)) ');']);
eval(['n_f_osc=length(' char(ranged_par(2)) ');']);
eval(['n_r_osc_ampl=length(' char(ranged_par(3)) ');']);

eval(['ranged_par1_vect=' char(ranged_par(1)) ';']);
eval(['ranged_par2_vect=' char(ranged_par(2)) ';']);
eval(['ranged_par3_vect=' char(ranged_par(3)) ';']);

par=rmfield(par,strrep(char(ranged_par(1)),'par.',''));
par=rmfield(par,strrep(char(ranged_par(2)),'par.',''));
par=rmfield(par,strrep(char(ranged_par(3)),'par.',''));
par=rmfield(par,'suf1');
par=rmfield(par,'suf2');


ranged_par1_start=strrep(strrep(char(ranged_par(1)),'par.',''),'_vect','_start');
if(isfield(par_this,ranged_par1_start))
    eval(['rate_start=par_this.' ranged_par1_start ';'])
else
    rate_start=1;
end
ranged_par1_stop=strrep(strrep(char(ranged_par(1)),'par.',''),'_vect','_stop');
if(isfield(par_this,ranged_par1_stop))
    eval(['rate_stop=par_this.' ranged_par1_stop ';'])
else
    rate_stop=n_rate;
end


ranged_par2_start=strrep(strrep(char(ranged_par(2)),'par.',''),'_vect','_start');
if(isfield(par_this,ranged_par2_start))
    eval(['f_osc_start=par_this.' ranged_par2_start ';'])
else
    f_osc_start=1;
end
ranged_par2_stop=strrep(strrep(char(ranged_par(2)),'par.',''),'_vect','_stop');
if(isfield(par_this,ranged_par2_stop))
    eval(['f_osc_stop=par_this.' ranged_par2_stop ';'])
else
    f_osc_stop=n_f_osc;
end


ranged_par3_start=strrep(strrep(char(ranged_par(3)),'par.',''),'_vect','_start');
if(isfield(par_this,ranged_par3_start))
    eval(['r_osc_ampl_start=par_this.' ranged_par3_start ';'])
else
    r_osc_ampl_start=1;
end
ranged_par3_stop=strrep(strrep(char(ranged_par(3)),'par.',''),'_vect','_stop');
if(isfield(par_this,ranged_par3_stop))
    eval(['r_osc_ampl_stop=par_this.' ranged_par3_stop ';'])
else
    r_osc_ampl_stop=n_r_osc_ampl;
end



% keyboard;

for i=rate_start:rate_stop
    eval(['par.' strrep(strrep(char(ranged_par(1)),'par.',''),'_vect','') '=par_this.' strrep(char(ranged_par(1)),'par.','') '(i);']);
    for j=f_osc_start:f_osc_stop
        eval(['par.' strrep(strrep(char(ranged_par(2)),'par.',''),'_vect','') '=par_this.' strrep(char(ranged_par(2)),'par.','') '(j);']);
        for k=r_osc_ampl_start:r_osc_ampl_stop
            eval(['par.' strrep(strrep(char(ranged_par(3)),'par.',''),'_vect','') '=par_this.' strrep(char(ranged_par(3)),'par.','') '(k);']);

            par.seed=round(mod(now*BigN,bigN));

            stringa_dir=[stringa '_' num2str(i) '_' num2str(j) '_' num2str(k) '_' suf1];
            output_struct=write_m_file_train(stringa_dir,stringa_mfile_osc,par);
        end
    end
end


for i=rate_start:rate_stop
    eval(['par.' strrep(strrep(char(ranged_par(1)),'par.',''),'_vect','') '=par_this.' strrep(char(ranged_par(1)),'par.','') '(i);']);
    for j=f_osc_start:f_osc_stop
        eval(['par.' strrep(strrep(char(ranged_par(2)),'par.',''),'_vect','') '=par_this.' strrep(char(ranged_par(2)),'par.','') '(j);']);
        for k=r_osc_ampl_start:r_osc_ampl_stop
            eval(['par.' strrep(strrep(char(ranged_par(3)),'par.',''),'_vect','') '=par_this.' strrep(char(ranged_par(3)),'par.','') '(k);']);

            par.seed=round(mod(now*BigN,bigN));

            stringa_dir=[stringa '_' num2str(i) '_' num2str(j) '_' num2str(k) '_' suf2];
            output_struct=write_m_file_train(stringa_dir,stringa_mfile_ple,par);
        end
    end
end


for i=rate_start:rate_stop
    for j=f_osc_start:f_osc_stop
        for k=r_osc_ampl_start:r_osc_ampl_stop
            comm=['matlab -noopengl < script_' stringa '_' num2str(i) '_' num2str(j) '_' num2str(k) '_' suf1 '.m > output_file_script_' stringa '_' num2str(i) '_' num2str(j) '_' num2str(k) '_' suf1]; % without using Xvfb, -noopengl
            script_name=[stringa '_' num2str(i) '_' num2str(j) '_' num2str(k) '_' suf1 '_slurmscriptfile'];
            write_qsubscript_slurm_axon_0(script_name,comm);

            comm=['matlab -noopengl < script_' stringa '_' num2str(i) '_' num2str(j) '_' num2str(k) '_' suf2 '.m > output_file_script_' stringa '_' num2str(i) '_' num2str(j) '_' num2str(k) '_' suf2]; % without using Xvfb, -noopengl
            script_name=[stringa '_' num2str(i) '_' num2str(j) '_' num2str(k) '_' suf2 '_slurmscriptfile'];
            write_qsubscript_slurm_axon_0(script_name,comm);
        end
    end
end

script_name=[stringa '_' suf1  '_' suf2 '_matched_submit.sh'];
fid = fopen(script_name,'w');
for i=rate_start:rate_stop
    for j=f_osc_start:f_osc_stop
        for k=r_osc_ampl_start:r_osc_ampl_stop
            fprintf(fid,['sbatch ' stringa '_' num2str(i) '_' num2str(j) '_' num2str(k) '_' suf1 '_slurmscriptfile\n']);
            fprintf(fid,['sbatch ' stringa '_' num2str(i) '_' num2str(j) '_' num2str(k) '_' suf2 '_slurmscriptfile\n']);
        end
    end
end
fclose(fid);
unix(['chmod +x ' script_name]);

