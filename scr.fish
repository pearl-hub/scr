
# This module has a dependency to c package
# vim: ft=sh

if [ -n "$STY" ]
    set PEARL_SESSION_NAME (echo $STY | cut -d . -f 2)
    PEARL_WINDOW_INDEX=$WINDOW
    [ -f $PEARL_HOME/envs/default ]; and source $PEARL_HOME/envs/default
    [ -f $PEARL_HOME/envs/$PEARL_SESSION_NAME ]; and source $PEARL_HOME/envs/$PEARL_SESSION_NAME
end

function scr
    set -l OPT_GO false
    set -l OPT_KEY ""
    set -l OPT_KILL false
    set -l OPT_HELP false
    set -l i 1
    while math "$i <=" (count $argv) > /dev/null
        switch $argv[$i]
            case -g --go
                set OPT_GO true
                set i (math "$i + 1")
                set OPT_KEY "$argv[$i]"
            case -k --kill
                set OPT_KILL true;
                set i (math "$i + 1")
                set OPT_KEY "$argv[$i]"
            case -h --help
                set OPT_HELP true
            case --
                set i (math "$i + 1")
            case -
                set ARGS -
                break
            case '-*'
                echo "Invalid option $argv[$i]"
                return 1
            case '*'
                set ARGS $argv[$i..-1]
                break
        end
        set i (math "$i + 1")
    end

    if eval $OPT_HELP
        eval screen --help
        echo ""
        echo -e "Extra usage from the scr wrapper: scr [options]"
        echo -e "Options:"
        echo -e "\t-g, --go <key>        Go to the directory selected by the key and create a screen session"
        echo -e "\t-k, --kill <kill>     Kill the screen session identified by the key"
        echo -e "\t-h, --help            Show this help message"
        return 0
    end

    if begin; eval $OPT_GO; and eval $OPT_KILL; end
        echo "The options --go and --kill cannot stay togheter."
        return 1
    end

    if eval $OPT_GO
        set -l owd $PWD
        set -l wd (c -p $OPT_KEY)
        [ -d "$wd" ]; or set wd $PWD
        cd $wd
        screen -S $OPT_KEY -aARd
        clear
        cd $owd
    else if eval $OPT_KILL
        screen -S $OPT_KEY -X quit
    else
        screen $ARGS
    end
    return 0
end
