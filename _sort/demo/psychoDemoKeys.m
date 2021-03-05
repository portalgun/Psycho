% psychoDemoKeys
n=containers.Map;
n(K.minus)     = 'zoom_out';
n(K.equal)     = 'zoom_in';
n(K.colon)     = 'cmd_menu_toggle';
%n(K.comma)     =
%n(K.period)    =
%n(K.space)     =
n(K.enter)     = 'flag_toggle';
n(K.escape)    = 'null';
n(K.shiftL)    = 'previous_mod';
n(K.shiftR)    = 'next_mod';
n(K.shiftU)    = 'in_mod';
n(K.shiftD)    = 'out_mod';
n(K.Uarrow)    = 'up_map'
n(K.Darrow)    = 'down_map'
n(K.Larrow)    = 'next';
n(K.Rarrow)    = 'previous';
%n(K.backsp)    =
n(K.backslash) = 'help_menu_toggle';
n(K.tab)       = 'info_toggle';
%n(K.a)         =
n(K.b)         = 'bg_toggle';
n(K.c)         = 'ch_toggle';
n(K.d)         = 'ch_shape_toggle';
%n(K.e)         =
n(K.f)         = 'flag_show_toggle';
n(K.g)         = 'go_mode';
n(K.h)         = 'left';
n(K.i)         = 'insert_mode';
n(K.j)         = 'down'
n(K.k)         = 'up'
n(K.l)         = 'right';
n(K.m)         = 'mask_toggle';
%n(K.n)         =
%n(K.o)         =
n(K.p)         = 'plate_toggle';
n(K.q)         = 'quit_prompt';
n(K.r)         = 'redraw';
n(K.s)         = 'sort_menu_toggle';
%n(K.t)         =
%n(K.u)         =
%n(K.v)         =
%n(K.w)         =
%n(K.x)         =
%n(K.y)         =
n(K.z)         = 'pause';
%n(K.one)       =
%n(K.two)       =
%n(K.three)     =
%n(K.four)      =
%n(K.five)      =
%n(K.six)       =
%n(K.seven)     =
%n(K.eight)     =
%n(K.nine)      =
n(K.zero)      = 'debug_prompt';
% XXX
% anchor toggle
% probe toggle

e=containers.Map;
e(K.Uarrow)    = 'up';
e(K.Darrow)    = 'down';
e(K.Larrow)    = 'next';
e(K.Rarrow)    = 'previous';
e(K.enter)     = 'flag_toggle';
e(K.escape)    = 'quit_prompt';

i=containers.Map;
i(K.Tab)       = 'next_fld';
i(k.ShiftTab)  = 'prev_fld';
i(K.Up)        = 'inc_fld';
i(K.Down)      = 'dec_fld';

modes=struct();
modes.n=n;
modes.i=i;
