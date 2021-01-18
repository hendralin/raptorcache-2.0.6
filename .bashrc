# ~/.bashrc: executed by bash(1) for non-login shells.

# Note: PS1 and umask are already set in /etc/profile. You should not
# need this unless you want different defaults for root.
# PS1='${debian_chroot:+($debian_chroot)}\h:\w\$ '
# umask 022

# You may uncomment the following lines if you want `ls' to be colorized:
# export LS_OPTIONS='--color=auto'
# eval "`dircolors`"
# alias ls='ls $LS_OPTIONS'
# alias ll='ls $LS_OPTIONS -l'
# alias l='ls $LS_OPTIONS -lA'
#
# Some more alias to avoid making mistakes:
# alias rm='rm -i'
# alias cp='cp -i'
# alias mv='mv -i'

# This file attempts to add color to command shells
 
# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi
 
# Set colorful PS1 only on colorful terminals.
# dircolors --print-database uses its own built-in database
# instead of using /etc/DIR_COLORS.  Try to use the external file
# first to take advantage of user additions.  Use internal bash
# globbing instead of external grep binary.
use_color=false
safe_term=${TERM//[^[:alnum:]]/?}   # sanitize TERM
match_lhs=""
[[ -f ~/.dir_colors   ]] && match_lhs="${match_lhs}$(<~/.dir_colors)"
[[ -f /etc/DIR_COLORS ]] && match_lhs="${match_lhs}$(</etc/DIR_COLORS)"
[[ -z ${match_lhs}    ]] \
        && type -P dircolors >/dev/null \
        && match_lhs=$(dircolors --print-database)
[[ $'\n'${match_lhs} == *$'\n'"TERM "${safe_term}* ]] && use_color=true
 
if ${use_color} ; then
        # Enable colors for ls, etc.  Prefer ~/.dir_colors #64489
        if type -P dircolors >/dev/null ; then
                if [[ -f ~/.dir_colors ]] ; then
                        eval $(dircolors -b ~/.dir_colors)
                elif [[ -f /etc/DIR_COLORS ]] ; then
                        eval $(dircolors -b /etc/DIR_COLORS)
                fi
        fi
 
        if [[ ${EUID} == 0 ]] ; then
                PS1='\[\033[01;31m\][\[\033[01;37m\]\u\[\033[01;31m\]@\[\033[01;37m\]\h\[\033[01;31m\]](\033[01;32m\]\d\[\033[01;31m\]@\[\033[01;32m\]\t\[\033[01;31m\]) \[\033[01;34m\][\w]\n\[\e[36m\]\# \[\033[00m\]\$ '
        else
                PS1='\[\033[01;31m\][\[\033[01;37m\]\u\[\033[01;31m\]@\[\033[01;37m\]\h\[\033[01;31m\]](\033[01;32m\]\d\[\033[01;31m\]@\[\033[01;32m\]\t\[\033[01;31m\]) \[\033[01;34m\][\w]\n\[\e[36m\]\# \[\033[00m\]\$ '
        fi
 
        alias ls='ls --color=auto'
        alias grep='grep --colour=auto'
else
        PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
 
# Try to keep environment pollution down, EPA loves us.
unset use_color safe_term match_lhs