function output_struct=write_m_file_train(stringa,stringa_mfile,par)
script_name=['script_' stringa '.m'];
fid = fopen(script_name,'w');
%keyboard;
eval(['fprintf(fid,[''stringa=''''' char(stringa) ''''';\n'']);']);
% eval(['fprintf(fid,[''stringa_dir=''''' char(stringa_dir) ''''';\n'']);']);
% eval(['fprintf(fid,[''flag_simulate=' num2str(flag_simulate) ';\n'']);']);
% eval(['fprintf(fid,[''flag_simulate=' '''' '''' char(flag_simulate) '''' '''' ';\n'']);']);
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
    if nargin_this==1
        fprintf(fid,[stringa_mfile{i} '(stringa);\n']);
    elseif nargin_this==2
        fprintf(fid,[stringa_mfile{i} '(stringa,par);\n']);
    end
end

% % uncomment below for saving output
% fprintf(fid,['cd ' stringa_dir ';\n']);
% fprintf(fid,['save output;\n']);
% fprintf(fid,['cd ..;\n']);

fclose(fid);
output_struct=1;