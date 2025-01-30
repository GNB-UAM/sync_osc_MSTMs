field_names={'f_rate','cv_ISI','cv2_ISI','Lv_ISI','LvR_ISI','LCV_ISI','IR_ISI','ent_ISI','SM_ISI','bursty','MPC','PPC','vR','vRn','VP','VPN','psd_max','psd_max_f','ampl_gauss','mean_gauss','sigma_gauss','spec_beta','spec_rmse','golomb_sync','sttc','corr_ind','Sc','LZdist','SPIKY_ISI','SPIKY_SPIKE','SPIKY_SPIKE_synchro','SPIKY_SPIKE_order','schreiber_c','kruskal_c','HM','QQ','qq','QQA','qqa','emd','emdn','modulus_m','modulus_mn'}; % 150222 updated with additional measures
% field_names_latex={'r','CV$_\mathrm{ISI}$','CV2$_\mathrm{ISI}$','Lv$_\mathrm{ISI}$','LvR$_\mathrm{ISI}$','LCV$_\mathrm{ISI}$','IR','Ent','S$_\mathrm{M}$','S$_\mathrm{TS}$','MPC','PPC','vR','vRn','VP','VPN','psd_max','psd_max_f','ampl_gauss','mean_gauss','sigma_gauss','spec_beta','spec_rmse','S$_\mathrm{GR}$','STTC','C$_\mathrm{i}$','S$_\mathrm{C}$','D$_\mathrm{LZ}$','D$_\mathrm{ISI}$','D$_\mathrm{S}$','S$_\mathrm{S}$','SPIKY_SPIKE_order','C$_\mathrm{S}$','C$_\mathrm{K}$','S$_\mathrm{HM}$','S$_\mathrm{QQ}$','S$_\mathrm{qq}$','S$_\mathrm{QQA}$','S$_\mathrm{qqa}$','D$_\mathrm{EMD}$','D$_\mathrm{EMDN}$','D$_\mathrm{MM}$','D$_\mathrm{MMN}$'};
field_names_latex={'r','CV$_\mathrm{ISI}$','CV2$_\mathrm{ISI}$','Lv','LvR','LCV$_\mathrm{ISI}$','IR','Ent','S$_\mathrm{M}$','S$_\mathrm{TS}$','MPC','PPC','vR','vRn','VP','VPN','psd_max','psd_max_f','ampl_gauss','mean_gauss','sigma_gauss','spec_beta','spec_rmse','S$_\mathrm{GR}$','STTC','C$_\mathrm{i}$','S$_\mathrm{C}$','D$_\mathrm{LZ}$','D$_\mathrm{ISI}$','D$_\mathrm{S}$','S$_\mathrm{S}$','SPIKY_SPIKE_order','C$_\mathrm{S}$','C$_\mathrm{K}$','S$_\mathrm{HM}$','S$_\mathrm{QQ}$','S$_\mathrm{qq}$','S$_\mathrm{QQA}$','S$_\mathrm{qqa}$','D$_\mathrm{EMD}$','D$_\mathrm{EMDN}$','D$_\mathrm{MM}$','D$_\mathrm{MMN}$'};  % removing from $_\mathrm{ISI}$ Lv and LvR
% field_names_long={'firing rate','ISI CV','ISI CV2','ISI local variation','ISI revised local variation','ISI log CV','ISI irregularity','log ISI entropy','Miura ISI irregularity','Tiesinga-Sejnowski','mean phase coherence','pairwise phase consistency','Van Rossum','Van Rossum norm','Victor-Purpura','Victor-Purpura norm','psd_max','psd_max_f','ampl_gauss','mean_gauss','sigma_gauss','spec_beta','spec_rmse','Golomb-Rinzel','spike time tiling coefficient','correlation index','spike-contrast','LZ distance','ISI-distance','SPIKE-distance','SPIKE synchronization','synfire indicator','Schreiber correlation','Kruskal correlation','Hunter-Milton','Quian Quiroga sync','Quian Quiroga asym','Quian Quiroga sync adapt','Quian Quiroga asym adapt','earth mover%s distance','earth mover s distance norm','modulus-metric distance','modulus-metric distance norm'};
field_names_long={'firing rate','ISI CV','ISI CV2','ISI local variation','ISI revised local variation','ISI log CV','ISI irregularity','log ISI entropy','Miura ISI irregularity','Tiesinga-Sejnowski sync','mean phase coherence','pairwise phase consistency','Van Rossum dist','Van Rossum dist norm','Victor-Purpura dist','Victor-Purpura dist norm','psd_max','psd_max_f','ampl_gauss','mean_gauss','sigma_gauss','spec_beta','spec_rmse','Golomb-Rinzel sync','spike time tiling coefficient','correlation index','spike-contrast','LZ distance','ISI-distance','SPIKE-distance','SPIKE synchronization','synfire indicator','Schreiber correlation','Kruskal correlation','Hunter-Milton similarity','Quian Quiroga sync','Quian Quiroga asym','Quian Quiroga sync adapt','Quian Quiroga asym adapt','earth mover’s dist','earth mover’s dist norm','modulus-metric dist','modulus-metric dist norm'}; % shortening some of the labels
field_name_types={'uni','uni','uni','uni','uni','uni','uni','uni','uni','multi','bi','bi','bi','bi','bi','bi','multi','multi','multi','multi','multi','multi','multi','multi','bi','bi','multi','bi','bi','bi','multi','multi','bi','bi','bi','bi','bi','bi','bi','bi','bi','bi','bi'}; % 150222 updated with additional measures
color_mat=[0.1961    0.8039    0.1961; 0 0 1; 1 0 0;... % uni; bi; multi
    0.1961    0.8039 1; 1    0.8039    0.1961; 1 0 1]; % uni-bi; uni-multi; bi-multi

dark_gray=0.6*ones(1,3);
light_gray=0.8*ones(1,3);

PLOT.print=1;

ms_names={'VP','VPN','corr_ind','golomb_sync','sttc','vR','vRn','schreiber_c','kruskal_c','HM','QQ','qq'};

field_names_2brm={'psd_max','psd_max_f','ampl_gauss','mean_gauss','sigma_gauss','spec_beta','spec_rmse','SPIKY_SPIKE_order'}; % we should find the indexes and remove from both field_names and field_name_types
inds_2brm=[];
for ifn=1:length(field_names_2brm)
    ind_2brm=find(ismember(field_names,field_names_2brm{ifn}));
    inds_2brm=[inds_2brm ind_2brm];
end
field_names(inds_2brm)=[]; % check if it really works... yes
field_names_latex(inds_2brm)=[];
field_names_long(inds_2brm)=[];
field_name_types(inds_2brm)=[];

file_ind=ones(1,length(field_names)); % this determines which output*mat files the measure is extracted from


% field_names_fooof={'fooof_1p_offset','fooof_1p_exp','fooof_1p_f','fooof_1p_pw','fooof_1p_sigma','fooof_1p_beta','fooof_1p_err','fooof_1p_r_squared','fooof_2p_offset','fooof_2p_exp','fooof_2p_f1','fooof_2p_pw1','fooof_2p_sigma1','fooof_2p_beta1','fooof_2p_f2','fooof_2p_pw2','fooof_2p_sigma2','fooof_2p_beta2','fooof_2p_err','fooof_2p_r_squared','fooof_r_squared_ratio','psd_max','psd_max_f'};
field_names_fooof={'fooof_1p_offset','fooof_1p_exp','fooof_1p_f','fooof_1p_pw','fooof_1p_sigma','fooof_1p_beta','fooof_1p_err','fooof_1p_r_squared','psd_max','psd_max_f'};
field_names_fooof_latex={'$b_L$','$\chi_L$','$f_\mathcal{G}$','$A_\mathcal{G}$','$\sigma_\mathcal{G}$','$\beta_\mathcal{G}$','MAE','$R^2$','PSD$_\mathrm{max}$','f$_\mathrm{max}$'};
field_names_fooof_long={'FOOOF broadband offset','FOOOF aperiodic exponent','FOOOF center frequency','FOOOF power','FOOOF sigma','FOOOF beta','FOOOF error','FOOOF R-squared','PSD max','PSD max frequency'};
field_name_types_fooof=cell(1,length(field_names_fooof));
field_name_types_fooof(:)={'multi'};
file_ind_fooof=2*ones(1,length(field_names_fooof));


field_names_synfireind={'synfire_ind'};
field_names_synfireind_latex={'F$_\mathrm{S}$'};
field_names_synfireind_long={'synfire indicator'};
field_name_types_synfireind=cell(1,length(field_names_synfireind));
field_name_types_synfireind(:)={'multi'};
file_ind_synfireind=3*ones(1,length(field_names_synfireind));


field_names=[field_names field_names_fooof field_names_synfireind];
field_names_latex=[field_names_latex field_names_fooof_latex field_names_synfireind_latex];
field_names_long=[field_names_long field_names_fooof_long field_names_synfireind_long];
field_name_types=[field_name_types field_name_types_fooof field_name_types_synfireind];
file_ind=[file_ind file_ind_fooof file_ind_synfireind];

clear field_names_ms;
clear field_names_latex_ms field_names_latex_wc_ms field_names_label;
clear field_names_long_ms field_names_long_wc_ms;
clear isuni;
clear isbi;
clear ismulti;
clear file_ind_ms;


ifnms=0;
n_uni=0;
n_bi=0;
n_multi=0;
for ifn=1:length(field_names)
    if ismember(field_names{ifn},ms_names)
        % for tau_ind=1:length(par.tau_vect)
        for tau_ind=1:1 % this assumes that the bs is tau_vect(1)
            tau=par.tau_vect(tau_ind);
            ifnms=ifnms+1;
            field_names_ms{ifnms}=[field_names{ifn} num2str(tau)];
            field_names_latex_ms{ifnms}=[field_names_latex{ifn}];
            field_names_long_ms{ifnms}=[field_names_long{ifn}];
            switch field_name_types{ifn}
                case 'uni'
                    field_colors{ifnms}=color_mat(1,:);
                    isuni(ifnms)=1;
                    isbi(ifnms)=0;
                    ismulti(ifnms)=0;
                    n_uni=n_uni+1;
                case 'bi'
                    field_colors{ifnms}=color_mat(2,:);
                    isuni(ifnms)=0;
                    isbi(ifnms)=1;
                    ismulti(ifnms)=0;
                    n_bi=n_bi+1;
                case 'multi'
                    field_colors{ifnms}=color_mat(3,:);
                    isuni(ifnms)=0;
                    isbi(ifnms)=0;
                    ismulti(ifnms)=1;
                    n_multi=n_multi+1;
            end
            field_names_wc_ms{ifnms}=['\color[rgb]{' sprintf('%f,%f,%f',field_colors{ifnms}(1),field_colors{ifnms}(2),field_colors{ifnms}(3)) '}' field_names_ms{ifnms}];
            field_names_label{ifnms}=['\color[rgb]{' sprintf('%f,%f,%f',field_colors{ifnms}(1),field_colors{ifnms}(2),field_colors{ifnms}(3)) '}' field_names{ifn}]; % we'll have to be changed for final version
            field_names_latex_wc_ms{ifnms}=['\color[rgb]{' sprintf('%f,%f,%f',field_colors{ifnms}(1),field_colors{ifnms}(2),field_colors{ifnms}(3)) '}' field_names_latex_ms{ifnms}];
            field_names_long_wc_ms{ifnms}=['\color[rgb]{' sprintf('%f,%f,%f',field_colors{ifnms}(1),field_colors{ifnms}(2),field_colors{ifnms}(3)) '}' field_names_long_ms{ifnms}];
            file_ind_ms(ifnms)=file_ind(ifn);
        end
    else
        ifnms=ifnms+1;
        field_names_ms{ifnms}=field_names{ifn};
        field_names_latex_ms{ifnms}=field_names_latex{ifn};
        field_names_long_ms{ifnms}=field_names_long{ifn};
        switch field_name_types{ifn}
            case 'uni'
                field_colors{ifnms}=color_mat(1,:);
                isuni(ifnms)=1;
                isbi(ifnms)=0;
                ismulti(ifnms)=0;
                n_uni=n_uni+1;
            case 'bi'
                field_colors{ifnms}=color_mat(2,:);
                isuni(ifnms)=0;
                isbi(ifnms)=1;
                ismulti(ifnms)=0;
                n_bi=n_bi+1;
            case 'multi'
                field_colors{ifnms}=color_mat(3,:);
                isuni(ifnms)=0;
                isbi(ifnms)=0;
                ismulti(ifnms)=1;
                n_multi=n_multi+1;
        end
        field_names_wc_ms{ifnms}=['\color[rgb]{' sprintf('%f,%f,%f',field_colors{ifnms}(1),field_colors{ifnms}(2),field_colors{ifnms}(3)) '}' field_names_ms{ifnms}];
        field_names_label{ifnms}=['\color[rgb]{' sprintf('%f,%f,%f',field_colors{ifnms}(1),field_colors{ifnms}(2),field_colors{ifnms}(3)) '}' field_names{ifn}];
        field_names_latex_wc_ms{ifnms}=['\color[rgb]{' sprintf('%f,%f,%f',field_colors{ifnms}(1),field_colors{ifnms}(2),field_colors{ifnms}(3)) '}' field_names_latex_ms{ifnms}];
        field_names_long_wc_ms{ifnms}=['\color[rgb]{' sprintf('%f,%f,%f',field_colors{ifnms}(1),field_colors{ifnms}(2),field_colors{ifnms}(3)) '}' field_names_long_ms{ifnms}];
        file_ind_ms(ifnms)=file_ind(ifn);
    end
end

field_names=field_names_ms;
field_names_latex=field_names_latex_ms; % actually they're equal, but just for consistency with the ms version
field_names_long=field_names_long_ms; % actually they're equal, but just for consistency with the ms version
file_ind=file_ind_ms;
names_string=par.names_string;

output_mat_files={'output_all_ms','output_all_fooof','output_all_synfireind'};
measure_mat_files=strrep(output_mat_files,'output_all','measures'); % the same thing, but these names are used for bio data