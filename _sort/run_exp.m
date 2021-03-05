function obj=run_exp(expType,Opts,bTest)
    switch expType
        case '2AFC'
            obj=exp2AFC(patchesExp,Opts,bTest)
        case 'demo'
            obj=expDemo(patchesExp,Opts,bTest)
    end
end
