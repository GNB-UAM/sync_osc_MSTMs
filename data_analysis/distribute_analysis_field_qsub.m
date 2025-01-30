function output_struct=distribute_analysis_field_qsub(dataDir,filenames,stringa,stringa_mfile,par)
% organises m files to be submitted to a Slurm queue

nfiles=length(filenames);
par_this=par;
get_field_names;

for ifn=1:length(field_names)
    par.ifn_this=ifn;
    par.seed=ifn; % every analysis script uses a different seed for initializing the RNG
    output_struct=write_m_file_field_analyze(dataDir,filenames,stringa,stringa_mfile,par);
end


for ifn=1:length(field_names)
    comm=['matlab -nodesktop < script_' stringa '_' num2str(ifn) '.m > output_file_script_' stringa '_' num2str(ifn)];
    script_name=[stringa '_' num2str(ifn) '_slurmscriptfile'];
    write_qsubscript_slurm_axon_0(script_name,comm);
end

script_name=[stringa '_submit.sh'];
fid = fopen(script_name,'w');
for ifn=1:length(field_names)
    fprintf(fid,['sbatch ' stringa '_' num2str(ifn) '_slurmscriptfile\n']);
end
fclose(fid);
unix(['chmod +x ' script_name]);
