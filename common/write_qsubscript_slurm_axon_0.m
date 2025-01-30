function write_qsubscript_slurm_axon_0(script_name,comm)
% writes a bash script that submits jobs to the queue using scratch
% script_name : name of the script (not really important)
% comm : command string (for instance: './executable_file input_file1 input_file2 output_file1 output_file2 par1 par2')

fid = fopen(script_name,'w');
fprintf(fid,'#!/bin/bash\n');
fprintf(fid,'#SBATCH --cpus-per-task=1\n');
fprintf(fid,['#SBATCH --job-name=' script_name '\n']);
fprintf(fid,'#SBATCH --ntasks=1\n');

% fprintf(fid,'#SBATCH --time=00:30:00\n'); % 30 m  for short jobs
% fprintf(fid,'#SBATCH --time=01:00:00\n'); % 1 h  for short jobs
% fprintf(fid,'#SBATCH --time=01:30:00\n'); % 1:30 h  for short jobs
% fprintf(fid,'#SBATCH --time=02:00:00\n'); % 2:00 h  for short-medium jobs
% fprintf(fid,'#SBATCH --time=03:00:00\n'); % 3 h  for medium jobs
fprintf(fid,'#SBATCH --time=12:00:00\n'); % 12 h for long jobs
% fprintf(fid,'#SBATCH --time=24:00:00\n'); % 24 h for very long jobs (THIS MIGHT STAY A LONG TIME IN THE QUEUE)

% fprintf(fid,'#SBATCH --mem-per-cpu=4096\n'); % 4 G for small jobs
% fprintf(fid,'#SBATCH --mem-per-cpu=8G\n'); % 8 G for medium jobs
% fprintf(fid,'#SBATCH --mem-per-cpu=16G\n'); % 16 G for medium-big jobs
fprintf(fid,'#SBATCH --mem-per-cpu=32G\n'); % 32 G for big jobs
% fprintf(fid,'#SBATCH --mem-per-cpu=64G\n'); % 64 G for very big jobs

fprintf(fid,['#SBATCH --output=' script_name '_%%J.out\n']); % so if the same code is running multiple times out and err files are not overwritten
fprintf(fid,['#SBATCH --error=' script_name '_%%J.err\n']);
fprintf(fid,'echo "Running on " `hostname`\n');
fprintf(fid,'\n');
fprintf(fid,'\n');
fprintf(fid,[comm '\n']);

fclose(fid);
unix(['chmod +x ' script_name]);