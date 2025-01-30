% field_names_ms no color
% field_names_wc_ms with color
% field_names_label with color, like field_names_wc_ms but without tau value - probably unused
% field_names_long_ms long labels, no color
% field_names_long_wc_ms long labels, with color

field_names={'f_rate','cv_ISI','cv2_ISI','Lv_ISI','LvR_ISI','LCV_ISI','IR_ISI','ent_ISI','SM_ISI','bursty','MPC','PPC','vR','vRn','VP','VPN','psd_max','psd_max_f','ampl_gauss','mean_gauss','sigma_gauss','spec_beta','spec_rmse','golomb_sync','sttc','corr_ind','Sc','LZdist','SPIKY_ISI','SPIKY_SPIKE','SPIKY_SPIKE_synchro','SPIKY_SPIKE_order','schreiber_c','kruskal_c','HM','QQ','qq','QQA','qqa','emd','emdn','modulus_m','modulus_mn'}; % 150222 updated with additional measures
% field_names_long={'firing rate','ISI CV','ISI CV2','ISI local variation','ISI revised local variation','ISI log CV','ISI irregularity','log ISI entropy','Miura ISI irregularity','Tiesinga-Sejnowski','mean phase coherence','pairwise phase consistency','Van Rossum','Van Rossum norm','Victor-Purpura','Victor-Purpura norm','psd_max','psd_max_f','ampl_gauss','mean_gauss','sigma_gauss','spec_beta','spec_rmse','Golomb-Rinzel','spike time tiling coefficient','correlation index','spike-contrast','LZ distance','ISI-distance','SPIKE-distance','SPIKE synchronization','synfire indicator','Schreiber correlation','Kruskal correlation','Hunter-Milton','Quian Quiroga sync','Quian Quiroga asym','Quian Quiroga sync adapt','Quian Quiroga asym adapt','earth mover%s distance','earth mover s distance norm','modulus-metric distance','modulus-metric distance norm'};
field_names_long={'firing rate','ISI CV','ISI CV2','ISI local variation','ISI revised local variation','ISI log CV','ISI irregularity','log ISI entropy','Miura ISI irregularity','Tiesinga-Sejnowski sync','mean phase coherence','pairwise phase consistency','Van Rossum dist','Van Rossum dist norm','Victor-Purpura dist','Victor-Purpura dist norm','psd_max','psd_max_f','ampl_gauss','mean_gauss','sigma_gauss','spec_beta','spec_rmse','Golomb-Rinzel sync','spike time tiling coefficient','correlation index','spike-contrast','LZ distance','ISI-distance','SPIKE-distance','SPIKE synchronization','synfire indicator','Schreiber correlation','Kruskal correlation','Hunter-Milton similarity','Quian Quiroga sync','Quian Quiroga asym','Quian Quiroga sync adapt','Quian Quiroga asym adapt','earth mover’s dist','earth mover’s dist norm','modulus-metric dist','modulus-metric dist norm'}; % shortening some of the labels
field_name_types={'uni','uni','uni','uni','uni','uni','uni','uni','uni','multi','bi','bi','bi','bi','bi','bi','multi','multi','multi','multi','multi','multi','multi','multi','bi','bi','multi','bi','bi','bi','multi','multi','bi','bi','bi','bi','bi','bi','bi','bi','bi','bi','bi'}; % 150222 updated with additional measures
color_mat=[0.1961    0.8039    0.1961; 0 0 1; 1 0 0]; % uni; bi; multi

dark_gray=0.6*ones(1,3);
light_gray=0.8*ones(1,3);

PLOT.print=1;

ms_names={'VP','VPN','corr_ind','golomb_sync','sttc','vR','vRn','schreiber_c','kruskal_c','HM','QQ','qq'};

field_names_2brm={'psd_max','psd_max_f','ampl_gauss','mean_gauss','sigma_gauss','spec_beta','spec_rmse'}; % we should find the indexes and remove from both field_names and field_name_types
inds_2brm=[];
for ifn=1:length(field_names_2brm)
    ind_2brm=find(ismember(field_names,field_names_2brm{ifn}));
    inds_2brm=[inds_2brm ind_2brm];
end
field_names(inds_2brm)=[]; % check if it really works... yes
field_name_types(inds_2brm)=[];
field_names_long(inds_2brm)=[];

file_ind=ones(1,length(field_names)); % this determines which output*mat files the measure is extracted from


field_names_fooof={'fooof_1p_offset','fooof_1p_exp','fooof_1p_f','fooof_1p_pw','fooof_1p_sigma','fooof_1p_beta','fooof_1p_err','fooof_1p_r_squared','fooof_2p_offset','fooof_2p_exp','fooof_2p_f1','fooof_2p_pw1','fooof_2p_sigma1','fooof_2p_beta1','fooof_2p_f2','fooof_2p_pw2','fooof_2p_sigma2','fooof_2p_beta2','fooof_2p_err','fooof_2p_r_squared','fooof_r_squared_ratio','psd_max','psd_max_f'};
field_names_fooof_long={'FOOOF 1p broadband offset','FOOOF 1p aperiodic exponent','FOOOF 1p center frequency','FOOOF 1p power','FOOOF 1p sigma','FOOOF 1p beta','FOOOF 1p error','FOOOF 1p R-squared','FOOOF 2p broadband offset','FOOOF 2p aperiodic exponent','FOOOF 2p center frequency1','FOOOF 2p power1','FOOOF 2p sigma1','FOOOF 2p beta1','FOOOF 2p center frequency2','FOOOF 2p power2','FOOOF 2p sigma2','FOOOF 2p beta2','FOOOF 2p error','FOOOF 2p R-squared','FOOOF R-squared ratio','PSD max','PSD max frequency'};
field_name_types_fooof=cell(1,length(field_names_fooof));
field_name_types_fooof(:)={'multi'};
file_ind_fooof=2*ones(1,length(field_names_fooof));

field_names=[field_names field_names_fooof];
field_names_long=[field_names_long field_names_fooof_long];
field_name_types=[field_name_types field_name_types_fooof];
file_ind=[file_ind file_ind_fooof];

clear field_names_ms;
clear field_names_long_ms;

ifnms=0;
n_uni=0;
n_bi=0;
n_multi=0;
for ifn=1:length(field_names)
    if ismember(field_names{ifn},ms_names)
        for tau_ind=1:length(par.tau_vect)
            tau=par.tau_vect(tau_ind);
            ifnms=ifnms+1;
            field_names_ms{ifnms}=[field_names{ifn} num2str(tau)];
            if tau_ind>1 % we only add tau value to the long field name if > 1
                field_names_long_ms{ifnms}=[field_names_long{ifn} ' ' num2str(tau)];
            else
                field_names_long_ms{ifnms}=[field_names_long{ifn}];
            end
            switch field_name_types{ifn}
                case 'uni'
                    field_colors{ifnms}=color_mat(1,:);
                    n_uni=n_uni+1;
                case 'bi'
                    field_colors{ifnms}=color_mat(2,:);
                    n_bi=n_bi+1;
                case 'multi'
                    field_colors{ifnms}=color_mat(3,:);
                    n_multi=n_multi+1;
            end
            field_names_wc_ms{ifnms}=['\color[rgb]{' sprintf('%f,%f,%f',field_colors{ifnms}(1),field_colors{ifnms}(2),field_colors{ifnms}(3)) '}' field_names_ms{ifnms}];
            field_names_label{ifnms}=['\color[rgb]{' sprintf('%f,%f,%f',field_colors{ifnms}(1),field_colors{ifnms}(2),field_colors{ifnms}(3)) '}' field_names{ifn}]; % we'll have to be changed for final version
            field_names_long_wc_ms{ifnms}=['\color[rgb]{' sprintf('%f,%f,%f',field_colors{ifnms}(1),field_colors{ifnms}(2),field_colors{ifnms}(3)) '}' field_names_long_ms{ifnms}];
            file_ind_ms(ifnms)=file_ind(ifn);
        end
    else
        ifnms=ifnms+1;
        field_names_ms{ifnms}=field_names{ifn};
        field_names_long_ms{ifnms}=field_names_long{ifn};
        switch field_name_types{ifn}
            case 'uni'
                field_colors{ifnms}=color_mat(1,:);
                n_uni=n_uni+1;
            case 'bi'
                field_colors{ifnms}=color_mat(2,:);
                n_bi=n_bi+1;
            case 'multi'
                field_colors{ifnms}=color_mat(3,:);
                n_multi=n_multi+1;
        end
        field_names_wc_ms{ifnms}=['\color[rgb]{' sprintf('%f,%f,%f',field_colors{ifnms}(1),field_colors{ifnms}(2),field_colors{ifnms}(3)) '}' field_names_ms{ifnms}];
        field_names_label{ifnms}=['\color[rgb]{' sprintf('%f,%f,%f',field_colors{ifnms}(1),field_colors{ifnms}(2),field_colors{ifnms}(3)) '}' field_names{ifn}];
        field_names_long_wc_ms{ifnms}=['\color[rgb]{' sprintf('%f,%f,%f',field_colors{ifnms}(1),field_colors{ifnms}(2),field_colors{ifnms}(3)) '}' field_names_long_ms{ifnms}];
        file_ind_ms(ifnms)=file_ind(ifn);
    end
end

field_names=field_names_ms;
file_ind=file_ind_ms;
names_string=par.names_string;