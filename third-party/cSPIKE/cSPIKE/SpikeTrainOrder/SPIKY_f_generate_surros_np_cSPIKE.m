function synf=SPIKY_f_generate_surros_np_cSPIKE(sto_profs,so_profs,num_surros)

num_pairs=size(sto_profs,1);
num_trains=(1+sqrt(1+8*num_pairs))/2;
[seconds,firsts]=find(triu(ones(num_trains),1)');

[leader_pos,pair]=find(so_profs'==1);
[follower_pos,dummy]=find(so_profs'==-1);
ddd=sto_profs';
xxx=ddd(so_profs'==1);
num_coins=length(dummy);
num_spikes=size(sto_profs,2);

indies=[pair firsts(pair).*(xxx==1)+seconds(pair).*(xxx==-1) seconds(pair).*(xxx==1)+firsts(pair).*(xxx==-1) leader_pos follower_pos]';
num_swaps=num_spikes;         % eliminate transients !!!!!
%disp(['First surrogate with long transient: ',num2str(num_swaps),' swaps --- All others without transient: ',num2str(round(num_swaps/2)),' swaps'])

synf=zeros(1,num_surros);
for suc=1:num_surros
    if suc==2
        num_swaps=round(num_swaps/2);
    end
    %disp('Start surro_MEX')
    [indies,error_count]=SPIKE_order_surro_MEX(indies,firsts,seconds,num_swaps);
    %disp('Stop surro_MEX')
    %disp([num2str(suc),')  Error_count: ',num2str(error_count)]);
    surro_sto_profs=zeros(size(sto_profs));
    for cc=1:num_coins
        surro_sto_profs(indies(1,cc),indies([4 5],cc))=(indies(2,cc)<indies(3,cc))-(indies(2,cc)>indies(3,cc))*ones(1,2);
    end
    
    surro_mat_entries=sum(surro_sto_profs,2)/2;
    surro_mat = tril(ones(num_trains),-1);
    surro_mat(~~surro_mat) = surro_mat_entries';
    surro_mat=surro_mat'-surro_mat;
    %disp('Start SPIKE_order_sim_ann_MEX')
    [st_indy_simann,synf(suc),total_iter]=SPIKE_order_sim_ann_MEX(surro_mat);
    %disp('Stop SPIKE_order_sim_ann_MEX')
    if suc==num_surros
        %disp(['S#',num2str(suc),'  ',regexprep(num2str(synf*2/(num_trains-1)/sum(num_spikes),3),'   ',' ')])
    end
end

end


