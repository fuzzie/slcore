# t-utc0/slimpl.m4: this file is part of the SL toolchain.
# 
# Copyright (C) 2008,2009,2010 The SL project
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# The complete GNU General Public Licence Notice can be found as the
# `COPYING' file in the root directory.
#
#
# ###############################################
#  Macro definitions for the core compiler syntax
# ###############################################

# Pass transparently thread definitions.
m4_define([[sl_def]],[[m4_dnl
m4_pushdef([[return]],[[sl_end_thread]])m4_dnl
m4_define([[_sl_crcnt]],0)m4_dnl
m4_define([[sl_thparms]],[[m4_shiftn(2,$@)]])m4_dnl
thread [[$2]] [[$1]]m4_if((sl_thparms),(),(void),(sl_thparms))m4_dnl
{m4_dnl
]])

# end of thread
m4_define([[sl_end_thread]], [[goto __sl_end_thread]])

# No special action at the end of a definition
m4_define([[sl_enddef]],[[m4_dnl
m4_ifdef([[_sl_increate]],[[m4_fatal(missing sync after create)]])m4_dnl
__sl_end_thread: (void)0;  }m4_dnl
m4_popdef([[return]])
]])

# With the corecc syntax, a declaration looks the same as a definition.
m4_define([[sl_decl]],[[m4_dnl
m4_define([[sl_thparms]],[[m4_shiftn(2,$@)]])m4_dnl
thread [[$2]] [[$1]]m4_if((sl_thparms),(),(void),(sl_thparms))m4_dnl
]])
m4_define([[sl_decl_fptr]], [[sl_decl((*[[$1]]), m4_shift($@))]])

# Pass transparently parameter declarations.
m4_define([[sl_shparm]], [[shared [[$1]] __p_[[]]m4_ifblank([[$2]],sl_anonymous,[[$2]])]])
m4_define([[sl_glparm]], [[/*global*/ [[$1]] __p_[[]]m4_ifblank([[$2]],sl_anonymous,[[$2]])]])
m4_define([[sl_glparm_mutable]], [[m4_error([[sl_glparm_mutable not implemented yet for this target]])]])

m4_copy([[sl_shparm]],[[sl_shfparm]])
m4_copy([[sl_glparm]],[[sl_glfparm]])
m4_copy([[sl_glparm_mutable]],[[sl_glfparm_mutable]])

# Pass transparently the index declaration. Work around bug #34 where core compiler
# does not have a type for "index".
m4_define([[sl_index]], [[index long [[$1]];m4_dnl
__asm__ __volatile__("#MTREG_SET: $l0")]])

# Pull shared and global argument declarations.
m4_define([[sl_sharg]],[[[[$1]]:__a_[[]]m4_ifblank([[$2]],sl_anonymous,[[$2]]):m4_ifblank([[$3]],[[= *([[$1]]*)(void*)4]],[[= [[$3]]]])]])
m4_define([[sl_glarg]],[[[[$1]] const:__a_[[]]m4_ifblank([[$2]],sl_anonymous,[[$2]]):m4_ifblank([[$3]],[[= *([[$1]]*)(void*)4]],[[= [[$3]]]])]])
m4_copy([[sl_sharg]],[[sl_shfarg]])
m4_copy([[sl_glarg]],[[sl_glfarg]])


m4_define([[sl_declarg]],[[m4_dnl
register [[$1]] [[$2]] m4_joinall([[:]],m4_shiftn(2,$@)); m4_dnl
]])

m4_define([[sl_givearg]],[[ m4_dnl
m4_car(m4_unquote(m4_cdr(m4_unquote(m4_split([[$1]],:))))) m4_dnl
]])

m4_define([[sl_create]], [[m4_dnl
m4_ifdef([[_sl_increate]],[[m4_fatal(cannot nest create)]])m4_dnl
m4_define([[_sl_increate]],1)m4_dnl
m4_define([[_sl_crcnt]],m4_incr(_sl_crcnt))m4_dnl
m4_define([[_sl_lbl]],__child[[]]_sl_crcnt)m4_dnl
m4_define([[_sl_fid]],m4_ifblank([[$1]],_sl_lbl,[[$1]]))m4_dnl
m4_ifblank([[$1]],[[register sl_family_t _sl_fid;]]) m4_dnl
m4_define([[_sl_brk]],m4_if(sl_breakable([[$7]]),1,[[_sl_fid[[]]_brk]],))m4_dnl
m4_if(sl_breakable([[$7]]),1,[[register [[$7]] _sl_brk;]],) m4_dnl
m4_define([[_sl_thargs]],m4_dquote(m4_shiftn(8,$@)))m4_dnl
m4_foreach([[_sl_arg]],m4_quote(_sl_thargs),[[m4_apply([[sl_declarg]],m4_split(_sl_arg,:))]]) m4_dnl
create(_sl_fid;[[$2]];[[$3]];[[$4]];[[$5]];[[$6]];_sl_brk) [[$8]](m4_dnl
m4_mapall_sep([[sl_givearg]],[[,]],m4_quote(_sl_thargs)) m4_dnl
)m4_dnl
]])


# Pass transparently the sync construct.
m4_define([[sl_sync]],[[m4_dnl
m4_ifndef([[_sl_increate]],[[m4_fatal(sync without create)]])m4_dnl
m4_ifblank([[$2]],,[[$2 = ]])sync(m4_ifblank([[$1]],_sl_fid,[[$1]]))m4_dnl
m4_undefine([[_sl_increate]])m4_dnl
]])

# Pass transparently all references to argument/parameter
# names.
m4_define([[sl_geta]],[[__a_$1]])
m4_define([[sl_seta]],[[__a_$1 = $2]])
m4_define([[sl_getp]],[[__p_$1]])
m4_define([[sl_setp]],[[__p_$1 = $2]])

# Pass transparently break and kill
m4_define([[sl_break]],[[break ($1)]])
m4_define([[sl_kill]],[[__builtin_ut_kill($1)]])

# Pass transparently the family id
m4_define([[sl_getfid]],[[$1]])

# Pass transparently the break id
m4_define([[sl_getbr]],[[$1]]_brk)

# Spawn stuff
m4_define([[sl_spawndecl]], [[m4_dnl
[[long $1 __attribute__((unused))]]m4_dnl
]])
m4_define([[sl_spawnsync]], [[(void)0]])

m4_define([[sl_spawn]], [[m4_dnl
do { sl_create($@); sl_sync([[$1]]); } while(0)m4_dnl
]])


# ## End macros for core compiler syntax ###