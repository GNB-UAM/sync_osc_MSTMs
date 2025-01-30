function output_struct=multi_train_4Drange_qsub(stringa,stringa_mfile_osc,stringa_mfile_ple,par,ranged_par)
% organises simulations (ranging 4 parameters) and m files to be submitted to a Slurm queue
par_this=par;
BigN=10000000000000000;
bigN=BigN/10^11;

suf1=par.suf1;
suf2=par.suf2;

eval(['n_par1=length(' char(ranged_par(1)) ');']);
eval(['n_par2=length(' char(ranged_par(2)) ');']);
eval(['n_par3=length(' char(ranged_par(3)) ');']);
eval(['n_par4=length(' char(ranged_par(4)) ');']);

eval(['ranged_par1_vect=' char(ranged_par(1)) ';']);
eval(['ranged_par2_vect=' char(ranged_par(2)) ';']);
eval(['ranged_par3_vect=' char(ranged_par(3)) ';']);
eval(['ranged_par4_vect=' char(ranged_par(4)) ';']);

par=rmfield(par,strrep(char(ranged_par(1)),'par.',''));
par=rmfield(par,strrep(char(ranged_par(2)),'par.',''));
par=rmfield(par,strrep(char(ranged_par(3)),'par.',''));
par=rmfield(par,strrep(char(ranged_par(4)),'par.',''));
par=rmfield(par,'suf1');
par=rmfield(par,'suf2');


ranged_par1_start=strrep(strrep(char(ranged_par(1)),'par.',''),'_vect','_start');
if(isfield(par_this,ranged_par1_start))
    eval(['par1_start=par_this.' ranged_par1_start ';'])
else
    par1_start=1;
end
ranged_par1_stop=strrep(strrep(char(ranged_par(1)),'par.',''),'_vect','_stop');
if(isfield(par_this,ranged_par1_stop))
    eval(['par1_stop=par_this.' ranged_par1_stop ';'])
else
    par1_stop=n_par1;
end


ranged_par2_start=strrep(strrep(char(ranged_par(2)),'par.',''),'_vect','_start');
if(isfield(par_this,ranged_par2_start))
    eval(['par2_start=par_this.' ranged_par2_start ';'])
else
    par2_start=1;
end
ranged_par2_stop=strrep(strrep(char(ranged_par(2)),'par.',''),'_vect','_stop');
if(isfield(par_this,ranged_par2_stop))
    eval(['par2_stop=par_this.' ranged_par2_stop ';'])
else
    par2_stop=n_par2;
end


ranged_par3_start=strrep(strrep(char(ranged_par(3)),'par.',''),'_vect','_start');
if(isfield(par_this,ranged_par3_start))
    eval(['par3_start=par_this.' ranged_par3_start ';'])
else
    par3_start=1;
end
ranged_par3_stop=strrep(strrep(char(ranged_par(3)),'par.',''),'_vect','_stop');
if(isfield(par_this,ranged_par3_stop))
    eval(['par3_stop=par_this.' ranged_par3_stop ';'])
else
    par3_stop=n_par3;
end



ranged_par4_start=strrep(strrep(char(ranged_par(4)),'par.',''),'_vect','_start');
if(isfield(par_this,ranged_par4_start))
    eval(['par4_start=par_this.' ranged_par4_start ';'])
else
    par4_start=1;
end
ranged_par4_stop=strrep(strrep(char(ranged_par(4)),'par.',''),'_vect','_stop');
if(isfield(par_this,ranged_par4_stop))
    eval(['par4_stop=par_this.' ranged_par4_stop ';'])
else
    par4_stop=n_par4;
end


% keyboard;

for i=par1_start:par1_stop
    eval(['par.' strrep(strrep(char(ranged_par(1)),'par.',''),'_vect','') '=par_this.' strrep(char(ranged_par(1)),'par.','') '(i);']);
    for j=par2_start:par2_stop
        eval(['par.' strrep(strrep(char(ranged_par(2)),'par.',''),'_vect','') '=par_this.' strrep(char(ranged_par(2)),'par.','') '(j);']);
        for k=par3_start:par3_stop
            eval(['par.' strrep(strrep(char(ranged_par(3)),'par.',''),'_vect','') '=par_this.' strrep(char(ranged_par(3)),'par.','') '(k);']);
            for l=par4_start:par4_stop
                eval(['par.' strrep(strrep(char(ranged_par(4)),'par.',''),'_vect','') '=par_this.' strrep(char(ranged_par(4)),'par.','') '(l);']);

                par.seed=round(mod(now*BigN,bigN));

                stringa_dir=[stringa '_' num2str(i) '_' num2str(j) '_' num2str(k) '_' num2str(l) '_' suf1];
                output_struct=write_m_file_train(stringa_dir,stringa_mfile_osc,par);
            end
        end
    end
end


for i=par1_start:par1_stop
    eval(['par.' strrep(strrep(char(ranged_par(1)),'par.',''),'_vect','') '=par_this.' strrep(char(ranged_par(1)),'par.','') '(i);']);
    for j=par2_start:par2_stop
        eval(['par.' strrep(strrep(char(ranged_par(2)),'par.',''),'_vect','') '=par_this.' strrep(char(ranged_par(2)),'par.','') '(j);']);
        for k=par3_start:par3_stop
            eval(['par.' strrep(strrep(char(ranged_par(3)),'par.',''),'_vect','') '=par_this.' strrep(char(ranged_par(3)),'par.','') '(k);']);
            for l=par4_start:par4_stop
                eval(['par.' strrep(strrep(char(ranged_par(4)),'par.',''),'_vect','') '=par_this.' strrep(char(ranged_par(4)),'par.','') '(l);']);

                par.seed=round(mod(now*BigN,bigN));

                stringa_dir=[stringa '_' num2str(i) '_' num2str(j) '_' num2str(k) '_' num2str(l) '_' suf2];
                output_struct=write_m_file_train(stringa_dir,stringa_mfile_ple,par);
            end
        end
    end
end




for i=par1_start:par1_stop
    for j=par2_start:par2_stop
        for k=par3_start:par3_stop
            for l=par4_start:par4_stop
                comm=['matlab -noopengl < script_' stringa '_' num2str(i) '_' num2str(j) '_' num2str(k) '_' num2str(l) '_' suf1 '.m > output_file_script_' stringa '_' num2str(i) '_' num2str(j) '_' num2str(k) '_' num2str(l) '_' suf1]; % without using Xvfb, -noopengl
                script_name=[stringa '_' num2str(i) '_' num2str(j) '_' num2str(k) '_' num2str(l) '_' suf1 '_slurmscriptfile'];
                write_qsubscript_slurm_axon_0(script_name,comm);

                comm=['matlab -noopengl < script_' stringa '_' num2str(i) '_' num2str(j) '_' num2str(k) '_' num2str(l) '_' suf2 '.m > output_file_script_' stringa '_' num2str(i) '_' num2str(j) '_' num2str(k) '_' num2str(l) '_' suf2]; % without using Xvfb, -noopengl
                script_name=[stringa '_' num2str(i) '_' num2str(j) '_' num2str(k) '_' num2str(l) '_' suf2 '_slurmscriptfile'];
                write_qsubscript_slurm_axon_0(script_name,comm);
            end
        end
    end
end

script_name=[stringa '_' suf1  '_' suf2 '_matched_submit.sh'];
fid = fopen(script_name,'w');
for i=par1_start:par1_stop
    for j=par2_start:par2_stop
        for k=par3_start:par3_stop
            for l=par4_start:par4_stop
                fprintf(fid,['sbatch ' stringa '_' num2str(i) '_' num2str(j) '_' num2str(k) '_' num2str(l) '_' suf1 '_slurmscriptfile\n']); % use this if all nodes work correctly
                fprintf(fid,['sbatch ' stringa '_' num2str(i) '_' num2str(j) '_' num2str(k) '_' num2str(l) '_' suf2 '_slurmscriptfile\n']);
            end
        end
    end
end
fclose(fid);
unix(['chmod +x ' script_name]);
