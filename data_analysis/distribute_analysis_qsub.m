function output_struct=distribute_analysis_qsub(dataDir,filenames,stringa,stringa_mfile,par)
% organises m files to be submitted to a Slurm queue

nfiles=length(filenames);
par_this=par;

for ifile=1:nfiles
    filethis=strrep(filenames{ifile},'.mat','');
    par.seed=ifile; % every analysis script uses a different seed for initializing the RNG
    output_struct=write_m_file_analyze(dataDir,filethis,stringa,stringa_mfile,par);
end


for ifile=1:nfiles
    filethis=strrep(filenames{ifile},'.mat','');
    filethis=strrep(filethis,'-','_');
    comm=['matlab -nodesktop < script_' stringa '_' filethis '.m > output_file_script_' stringa '_' filethis];
    script_name=[stringa '_' filethis '_slurmscriptfile'];
    write_qsubscript_slurm_axon_0(script_name,comm);
end

script_name=[stringa '_submit.sh'];
fid = fopen(script_name,'w');
for ifile=1:nfiles
    filethis=strrep(filenames{ifile},'.mat','');
    filethis=strrep(filethis,'-','_');
    fprintf(fid,['sbatch ' stringa '_' filethis '_slurmscriptfile\n']);
end
fclose(fid);
unix(['chmod +x ' script_name]);
