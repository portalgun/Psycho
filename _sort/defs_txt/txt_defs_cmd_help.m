function c=text_defs_cmd_help()
    c=containers.Map;
    c('zoom_in_mod')='Make stim larger by x units';
    c('zoom_out_mod')='Make stim smaller by x units';
    c('zoom_in')='Make stimulus larger by 1 unit';
    c('zoom_out')='Make stimulus larger by 1 unit';
    c('previous_mod')='Jump backwards x stimuli';
    c('next_mod')='Jump forward x stimuli';
    c('previous')='Show previous stimulus';
    c('next')='Show next stimulus';
    c('go_trial')

    c('pause')
    c('std_or_cmp_toggle')='Show standard or comparison stimuli';
    c('redraw')='Redraw stimulus';
    c('down_mod')='Move probe or stimulus down by 1 unit';
    c('up_mod')='Move probe or stimulus up by x units';
    c('up')='Move probe or stimulus up by 1 unit';
    c('down')='Move probe or stimulus down by 1 unit';
    c('right')='Move probe or stimulus right by 1 unit';
    c('left')='Move probe or stimulus left by 1 unit';
    c('right_mod')='Move probe or stimulus right by x unit';
    c('left_mod')='Move probe or stimulus left by x unit';
    c('flag_show_toggle')='Show flags';
    c('info_toggle')='Show parameters stats and info';
    c('escape')='Close windows, escape from prompts or fields';
    c('deg_or_pix_toggle')='Increment/show sizes in degrees or pixels';

    c('help_menu_toggle')='Show help menu';
    c('cmd_menu_toggle')='Open command prompt';
    c('sort_menu_toggle')='Open stimulus sorting menu';
    c('ch_menu_toggle')='Open crosshair menu';
    c('bg_menu_toggle')='Open background menu';
    c('plate_menu_toggle')='Open plate menu';
    c('mask_menu_toggle')='Open stimulus mask menu';
    c('debug_menu_toggle')='Open debugging menu';

    c('insert_mode')='Enter field values';
    c('next_fld')='Move to next field';
    c('prev_fld')='Move to previous field';
    c('flag_toggle')='Mark/toggle stimulus by flag';
    c('quit_prompt')='Prompt to quit experiment';
    %c('exp_toggle') XXX
end
