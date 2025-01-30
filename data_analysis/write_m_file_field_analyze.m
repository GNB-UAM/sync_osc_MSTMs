function output_struct=write_m_file_field_analyze(dataDir,filenames,stringa,stringa_mfile,par)
% trange_freq = [-0.5 1.];
% trange_phrase = [-1. 3.1740];
% trange = trange_phrase;
%
% getSub;
% setDir;
% getBestElectrode;
% iElectrode=bestElectrode;
% stringa_dir=[subID '_' task '_'  num2str(iElectrode)];

script_name=['script_' stringa '_' num2str(par.ifn_this) '.m']; % m file names cannot contain "-"
% script_name=['script_' stringa '_' strrep(data_file,'-','_') '.m']; % m file names cannot contain "-"
fid = fopen(script_name,'w');
%keyboard;
eval(['fprintf(fid,[''dataDir=''''' char(dataDir) ''''';\n'']);']);
filenames_2bprinted=sprintf('''''%s'''',',filenames{:});
eval(['fprintf(fid,[''filenames={' filenames_2bprinted(1:end-1) '};\n'']);']);
% eval(['fprintf(fid,[''filenames={''''' char(filenames) '.mat''''};\n'']);']);
% eval(['fprintf(fid,[''data_file={''''' char(data_file) '.mat''''};\n'']);']);
eval(['fprintf(fid,[''stringa=''''' char(stringa) ''''';\n'']);']);

% eval(['fprintf(fid,[''stringa=''''' char(stringa) ''''';\n'']);']);
% eval(['fprintf(fid,[''stringa_dir=''''' char(stringa_dir) ''''';\n'']);']);
% eval(['fprintf(fid,[''flag_simulate=' num2str(flag_simulate) ';\n'']);']);
fields1=fieldnames(par);
for i=1:length(fields1)
    eval(['flag_isstruct=isstruct(par.' char(fields1(i)) ');']);
    if flag_isstruct
        eval(['fields2=fieldnames(par.' char(fields1(i)) ');']);
        for j=1:length(fields2)
            eval(['this_par=par.' char(fields1(i)) '.' char(fields2(j)) ';']);
            if(ischar(this_par))
                eval(['fprintf(fid,''par.' char(fields1(i)) '.' char(fields2(j)) '=' '''''' eval(['char(par.' char(fields1(i)) '.' char(fields2(j)) ')']) '''''' ';\n'');']);
            elseif(isvector(this_par))
                eval(['fprintf(fid,''par.' char(fields1(i)) '.' char(fields2(j)) '=[' eval(['num2str(par.' char(fields1(i)) '.' char(fields2(j)) ')']) '];\n'');']);
            else
                eval(['fprintf(fid,''par.' char(fields1(i)) '.' char(fields2(j)) '=' eval(['num2str(par.' char(fields1(i)) '.' char(fields2(j)) ')']) ';\n'');']);
            end
        end
    else
        eval(['this_par=par.' char(fields1(i)) ';']);
        if(ischar(this_par))
            eval(['fprintf(fid,''par.' char(fields1(i)) '=' '''''' eval(['char(par.' char(fields1(i)) ')']) '''''' ';\n'');']);
        elseif(isvector(this_par))
            eval(['fprintf(fid,''par.' char(fields1(i)) '=[' eval(['num2str(par.' char(fields1(i)) ')']) '];\n'');']);
        else
            eval(['fprintf(fid,''par.' char(fields1(i)) '=' eval(['num2str(par.' char(fields1(i)) ')']) ';\n'');']);
        end
    end
end

for i=1:length(stringa_mfile)
    eval(['nargin_this=nargin(''' stringa_mfile{i} ''');']);
    eval(['nargout_this=nargout(''' stringa_mfile{i} ''');']);
    if nargin_this==2
        fprintf(fid,[stringa_mfile{i} '(filenames,par.Job);\n']);
    elseif nargin_this==3
        fprintf(fid,['output_struct=' stringa_mfile{i} '(filenames,stringa,par);\n']);
    elseif nargin_this==4
        if nargout_this==1
            fprintf(fid,['output_struct=' stringa_mfile{i} '(dataDir,filenames,stringa,par);\n']);
        else
            fprintf(fid,[stringa_mfile{i} '(dataDir,filenames,stringa,par);\n']);
        end
    end
end
% % uncomment below for saving output
% fprintf(fid,['cd ' stringa_dir ';\n']);
% fprintf(fid,['save output;\n']);
% fprintf(fid,['cd ..;\n']);

% % most recent version 270312 does not save output here, output is saved
% % inside ento_gsyn_qsub....m
% % current version only saves output if it does not exist.. not a smart
% % choice better to rename before running the code
% fprintf(fid,['cd ' stringa_dir ';\n']);
% %fprintf(fid,['if(exist(''output.mat'')==0)\n']);
% fprintf(fid,[' save output;\n']);
% %fprintf(fid,['end\n']);
% fprintf(fid,['cd ..;\n']);
output_struct=1;