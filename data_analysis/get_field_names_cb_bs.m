if ~isfield(par,'names_string')
    get_field_names_bs_250123;
    names_string='';
elseif strcmp(par.names_string,'090423')
    get_field_names_bs_090423;
elseif strcmp(par.names_string,'050723')
    get_field_names_cb_bs_050723;
else
    keyboard;
end