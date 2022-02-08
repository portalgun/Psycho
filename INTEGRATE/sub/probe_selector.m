function prb=probe_selector(prbType,ptb,patch)
    switch prbType
    case 'probe_gauss_circImg_point_dvn'
        prb=probe_gauss_circImg_point_dvn(ptb,patch);
    end
end
