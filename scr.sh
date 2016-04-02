# This module has a dependency to c package
# vim: ft=sh

if [ -n "$STY" ]; then

    PEARL_SESSION_NAME=$(echo $STY | cut -d . -f 2)
    PEARL_WINDOW_INDEX=${WINDOW}
    [ -f $PEARL_HOME/envs/default ] && source $PEARL_HOME/envs/default
    [ -f $PEARL_HOME/envs/$PEARL_SESSION_NAME ] && source $PEARL_HOME/envs/$PEARL_SESSION_NAME
fi

function scr(){

    local screen_command=screen

    local OPT_GO=""
    local OPT_KILL=""
    local OPT_HELP=false
    local args=()
    while [ "$1" != "" ] ; do
	case "$1" in
	    -g|--go) shift; OPT_GO="$1" ; shift ;;
	    -k|--kill) shift; OPT_KILL="$1" ; shift ;;
            -h|--help) OPT_HELP=true ; shift ;;
            --) shift ; break ;;
	    *) args+=("$1") ; shift ;;
	esac
    done

    #################### END OPTION PARSING ############################

    if $OPT_HELP
    then
        $screen_command --help
        echo ""
        echo -e "Extra usage form the scr wrapper: scr [options]"
        echo -e "Options:"
        echo -e "\t-g, --go <key>        Go to the directory selected by the key and create a screen session"
        echo -e "\t-k, --kill <key>      Kill the screen session identified by the key"
        echo -e "\t-h, --help            Show this help message"
        return 0
    fi

    if [ "$OPT_GO" != "" ] && [ "$OPT_KILL" != "" ]
    then
        echo "The options --go and --kill cannot stay togheter."
        return 1
    fi

    if [ "$OPT_GO" != "" ]
    then
        local dir=$(cd -p $OPT_GO)
        [ "$dir" == "" ] && local dir="$PWD"
        builtin cd "$dir"
        $screen_command -S "${OPT_GO}" -aARd
        clear
        builtin cd "$OLDPWD"
    elif [ "$OPT_KILL" != "" ]
    then
        $screen_command -S "${OPT_KILL}" -X quit

    else
        $screen_command ${args[@]}
    fi

    return 0
}

