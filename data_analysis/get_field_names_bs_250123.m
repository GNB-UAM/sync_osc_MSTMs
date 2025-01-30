field_names={'f_rate','cv_ISI','cv2_ISI','Lv_ISI','LvR_ISI','LCV_ISI','IR_ISI','ent_ISI','SM_ISI','bursty','MPC','PPC','vR','vRn','VP','VPN','psd_max','psd_max_f','ampl_gauss','mean_gauss','sigma_gauss','spec_beta','spec_rmse','golomb_sync','sttc','corr_ind','Sc','LZdist','SPIKY_ISI','SPIKY_SPIKE','SPIKY_SPIKE_synchro','SPIKY_SPIKE_order','schreiber_c','kruskal_c','HM','QQ','qq','QQA','qqa','emd','emdn','modulus_m','modulus_mn'}; % 150222 updated with additional measures
field_name_types={'uni','uni','uni','uni','uni','uni','uni','uni','uni','multi','bi','bi','bi','bi','bi','bi','multi','multi','multi','multi','multi','multi','multi','multi','bi','bi','multi','bi','bi','bi','multi','multi','bi','bi','bi','bi','bi','bi','bi','bi','bi','bi','bi'}; % 150222 updated with additional measures
color_mat=[0.1961    0.8039    0.1961; 0 0 1; 1 0 0]; % uni; bi; multi

dark_gray=0.6*ones(1,3);
light_gray=0.8*ones(1,3);

PLOT.print=1;

ms_names={'VP','VPN','corr_ind','golomb_sync','sttc','vR','vRn','schreiber_c','kruskal_c','HM','QQ','qq'};

clear field_names_ms;

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
        end
    else
        ifnms=ifnms+1;
        field_names_ms{ifnms}=field_names{ifn};
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
    end
end

field_names=field_names_ms;
