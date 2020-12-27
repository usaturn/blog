#!/bin/bash

function yes_or_no_recursive(){
    echo
    echo "Type yes or no."
    read answer
    case $answer in
        yes)
            echo -e "tyeped yes.\n"
            return 0
            ;;
        no)
            echo -e "tyeped no.\n"
            return 1
            ;;
        *)
            echo -e "cannot understand $answer.\n"
            yes_or_no_recursive
            ;;
    esac
}

yes_or_no_recursive
