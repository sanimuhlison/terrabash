#!/bin/bash
STAGE="$1"
STAGE_UPPER=$(echo $STAGE | tr '[:lower:]' '[:upper:]')

# COLOR
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
RESET=$(tput sgr0)
# END of COLOR

box() {
    echo "${YELLOW}----------------------------------------------------------------------------------"
    echo $@
    echo "----------------------------------------------------------------------------------${RESET}"
}

data() {
    FILEPATH_NOT_UNIQ=($(cd $TF_DIR && git show --pretty="format:" --name-status origin/master..HEAD | sed 's/locals.tf/main.tf/g' | grep -v '\bD' | sed 's/R[^.]*.tf//'))
    FILEPATH=($(printf "%s\n" "${FILEPATH_NOT_UNIQ[@]}" | sort -u))
}

list() {
    data
    if [ -z "$FILEPATH" ]; then
        echo "NO Changes..............................................................[SKIP]"
        echo "Exit..................................................................[EXITED]"
        exit
    else
        for ((i = 0; i < ${#FILEPATH[@]}; i++)); do
            if [[ ${FILEPATH[$i]} == *.tf* ]] && [[ ${FILEPATH[$i]} != *"/common/"* ]] && [[ ${FILEPATH[$i]} != *"/modules/"* ]]; then
                y=$(echo ${FILEPATH[$i]} | sed 's/\(.*\/\).*/\1/')
				echo "[$i]-$y"
            fi
        done
    fi
}

check_state() {
    MAIN_FILE="main.tf"
    STATE_GCP=$(cat $TF_DIR$x$MAIN_FILE | grep -o 'prefix = ".*' | sed 's/\prefix\ =\ //g' | sed 's/\"//g')
    STATE_AWS=$(cat $TF_DIR$x$MAIN_FILE | grep -o '".*states.tfstate' | sed 's/\states.tfstate//g' | sed 's/\"//g')
    
    if [[ $STATE_AWS != "" ]]; then
        STATE=$STATE_AWS
    elif [[ $STATE_GCP != "" ]]; then
        STATE=$STATE_GCP
    else
        echo "${RED}No matching STATE for AWS or GCP...!!!${RESET}"
        exit
    fi

    echo "STATE Location: " $STATE

    if [ "$x" == "$STATE" ]; then
		echo "${GREEN}STATE Location:  OK..........................................................[OK]${RESET}"
    else
        echo "${RED}STATE Location:  WRONG....................................................[ERROR]${RESET}"
        read -p "Do you want to continue checking (YES/no) ? Enter for yes: " choice
        if [ "$choice" == "no" ]; then
            echo "EXIT"
            exit 1
        elif [ "$choice" == "" ] || [ "$choice" == "yes" ]; then
            echo "Continue Checking....."
        else
            echo "${RED}Wrong Input${RESET}"
            exit 1
        fi
    fi
}

execute() {
    cd $TF_DIR/$x
    if [ "$STAGE" == "init" ]; then
        rm -rf .terraform
    fi
    pwd
    terraform $STAGE
    pre-commit run --files *.tf
}

simple_view() {
    cd $TF_DIR/$x
    if [ "$STAGE" == "init" ]; then
        rm -rf .terraform
    fi
    pwd

    COMMAND=$(terraform $STAGE | grep "No\ changes\|Terraform\ has\ been\ successfully\ initialized")
    if [[ $COMMAND == *"No changes"* ]] || [[ $COMMAND == *"successfully"* ]]; then
        echo "${GREEN} $COMMAND ${RESET}"
    else
        echo ${RED} "SOMETHING WENT WRONG" ${RESET}
    fi
    
    pre-commit run --files *.tf
}

input() {
    box
    read -p "Choose array number to be $STAGE_UPPER: " number
    if [ "$number" == "all" ]; then
        data
        for ((i = 0; i < ${#FILEPATH[@]}; i++)); do
            if [[ ${FILEPATH[$i]} == *.tf* ]] && [[ ${FILEPATH[$i]} != *"/common/"* ]] && [[ ${FILEPATH[$i]} != *"/modules/"* ]]; then
                x=$(echo ${FILEPATH[$i]} | sed 's/\(.*\/\).*/\1/')
                box GO TO ">>" [$i]-$x
                check_state
                $1
            fi
        done
    elif [[ "$number" =~ [0-9]{1,3}[-][0-9]{1,3} ]]; then
        start=$(echo $number | sed 's/\-[0-9]\{1,\}//')
        finish=$(echo $number | sed 's/[0-9]\{1,\}\-//')
        for ((i = $start; i < $finish + 1; i++)); do
            if [[ ${FILEPATH[$i]} == *.tf* ]] && [[ ${FILEPATH[$i]} != *"/common/"* ]] && [[ ${FILEPATH[$i]} != *"/modules/"* ]]; then
                x=$(echo ${FILEPATH[$i]} | sed 's/\(.*\/\).*/\1/')
                box GO TO ">>" [$i]-$x
                check_state
                $1
            fi
        done
    elif [[ "$number" =~ [0-9]{1,3} ]]; then
        data
        if [[ ${FILEPATH[$number]} == *.tf* ]]; then
            x=$(echo ${FILEPATH[$number]} | sed 's/\(.*\/\).*/\1/' | sort -u)
            box GO TO ">>" [$number]-$x
            check_state
            $1
        fi
    else
        echo "${RED}Wrong Input${RESET}"
    fi
}

if [[ $1 == "init" ]] || [[ $1 == "plan" ]] && [[ $2 == "--simple-view" ]]; then
    box LIST OF DIRECTORY [ TERRAFORM $STAGE_UPPER ]:
    list
    input simple_view
elif [[ $1 == "init" ]] || [[ $1 == "plan" ]] || [[ $1 == "apply" ]]; then
    box LIST OF DIRECTORY [ TERRAFORM $STAGE_UPPER ]:
    list
    input execute
elif [[ $1 == "list" ]]; then
    box LIST OF DIRECTORY
    list
else
    box Bad Argument
    echo "Please input ${YELLOW}init${RESET} OR ${YELLOW}plan${RESET} OR ${YELLOW}apply${RESET} after run-pre-commit.sh"
    echo "Please input ${YELLOW}--simple-view${RESET} after init/plan/apply to view in simple mode"
    echo "eg: ${YELLOW}bash run-post-commit.sh init${RESET}"
    echo "eg: ${YELLOW}bash run-post-commit.sh init --simple-view${RESET}"
    exit 1   
fi