function output_struct=write_m_file_analyze(dataDir,data_file,stringa,stringa_mfile,par)

script_name=['script_' stringa '_' strrep(data_file,'-','_') '.m']; % m file names cannot contain "-"
fid = fopen(script_name,'w');
eval(['fprintf(fid,[''dataDir=''''' char(dataDir) ''''';\n'']);']);
eval(['fprintf(fid,[''data_file={''''' char(data_file) '.mat''''};\n'']);']);
eval(['fprintf(fid,[''stringa=''''' char(stringa) ''''';\n'']);']);

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
        fprintf(fid,[stringa_mfile{i} '(data_file,par.Job);\n']);
    elseif nargin_this==3
        fprintf(fid,['output_struct=' stringa_mfile{i} '(data_file,stringa,par);\n']);
    elseif nargin_this==4
        if nargout_this==1
            fprintf(fid,['output_struct=' stringa_mfile{i} '(dataDir,data_file,stringa,par);\n']);
        else
            fprintf(fid,[stringa_mfile{i} '(dataDir,data_file,stringa,par);\n']);
        end
    end
end

output_struct=1;