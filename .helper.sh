name=".helper.sh"
version="2022.07.27"

# ======================================================================================================================
# Configuration.

# Project Repository
REPO="https://raw.githubusercontent.com/xa2099/.helper.sh/main"

# Directory of this script.
DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Local list files.
COMMANDS_LIST="${DIR}/.helper.c"
DIRECTORIES_LIST="${DIR}/.helper.d"
FILES_LIST="${DIR}/.helper.f"
TEMPLATES_LIST="${DIR}/.helper.t"

# Editor
EDITOR="nano"


# ======================================================================================================================
# Help.

read -r -d '' usage << BLOCK

.c      Command to run.
.cx     Command to remove from the list.

.d      Directory to change to.
.dx     Derectory to delete from the list.

.f      File to edit.
.fx     File to remove from the list.

.sc     Service status.
.ss     Service start.
.sx     Service stop.
.sr     Service restart.

.h      This text. :)
.v      Script name and version.
.i      Systen info.
.s      Script service.

BLOCK


# ======================================================================================================================
# Implement colours and formating.

COLORS=${BS_COLORS:-$(tput colors 2>/dev/null || echo 0)}
if [ $? -eq 0 ] && [ "$COLORS" -gt 2 ]; then
    RC='\033[31m'; GC='\033[32m'; BC='\033[34m'; YC='\033[33m'; EC='\033[0m';
else
    RC=""; GC=""; BC=""; YC=""; EC="";
fi

function pr_br { printf "\n"; }  # Print New Line.
function pr_hr { printf "=%.0s" {1..120} ; pr_br; } # Print Horizontal Rule.
function h { printf "$2\n"; pr_hr; printf "%b" "${1}"; pr_br; pr_hr; printf "${EC}"; }
function pr_h { h "${1}" "${EC}"; } # Print Header.
function pr_h_e { h "${1}" "${RC}"; } # Print Header Error.
function pr_h_i { h "${1}" "${GC}"; } # Print Header Info.
function pr_h_d { h "${1}" "${BC}"; } # Print Header Debug.
function pr_h_w { h "${1}" "${YC}"; } # Print Header Warning.
function pr_p { printf "%s$@\n"; } # Print Paragraph.
function pr_p_e { printf "${RC}%s$@${EC}\n" 1>&2; } # Print Paragraph Error.
function pr_p_i { printf "${GC}%s$@${EC}\n"; } # Print Paragraph Info.
function pr_p_d { printf "${BC}%s$@${EC}\n"; }  # Print Paragraph Debug.
function pr_p_w { printf "${YC}%s$@${EC}\n"; } # Print Paragraph Warning.


# ======================================================================================================================
# Helper functions.

function .c {
    history -d $(history 1)
    if [ -z $1 ]; then
        if [ -f "${COMMANDS_LIST}" ]; then
            local list
            mapfile -t list < "${COMMANDS_LIST}"
            pr_h_d "Select Command to Execute"
            select option in "${list[@]}"; do
                pr_br
                pr_p_i "Executed : $option"
                pr_br
                history -s "$option"
                eval "$option"
                break
            done
        else
            pr_br
            pr_p_w "Command List is empty. Run '.h' for help on creating one."
            pr_br
        fi
    else
        echo "$@" >> "${COMMANDS_LIST}"
        history -s "$@"
        eval "$@"
    fi
}

function .cx {
    history -d $(history 1)
    if [ -z $1 ]; then
        if [ -f "${COMMANDS_LIST}" ]; then
            local list
            mapfile -t list < "${COMMANDS_LIST}"
            pr_h_d "Select Command to Remove From the List"
            select option in "${list[@]}"; do
                history -s "sed -i '${REPLY}d' ${COMMANDS_LIST}"
                eval "sed -i '${REPLY}d' ${COMMANDS_LIST}"
                pr_p_i "Removed : $REPLY) $option"
                pr_br
                break
            done
        else
            pr_br
            pr_p_w "Command List is empty. Run '.h' for help on creating one."
            pr_br
        fi
    fi
}

function .d {
    history -d $(history 1)
    if [ -z $1 ]; then
        if [ -f "${DIRECTORIES_LIST}" ]; then
            local list
            mapfile -t list < "${DIRECTORIES_LIST}"
            pr_h_d "Select Directory to Change to"
            select option in "${list[@]}"; do
                if [ -d $1 ]; then
                    pr_br
                    pr_p_i "Changed to : $option"
                    pr_br
                    history -s "cd $option"
                    eval "cd $option"
                    break
                else
                    pr_br
                    pr_p_e "Error : Directory '$1' does not exist."
                    pr_br
                fi
            done
        else
            pr_br
            pr_p_w "Directory List is empty. Run '.h' for help on creating one."
            pr_br
        fi
    else
        if [ -d $@ ]; then
            echo "$@" >> "${DIRECTORIES_LIST}"
            eval "cd $@"
        else
            pr_br
            pr_p_e "Directory '$@' does not exist."
            pr_br
        fi
    fi
}

function .dx {
    history -d $(history 1)
    if [ -z $1 ]; then
        if [ -f "${DIRECTORIES_LIST}" ]; then
            local list
            mapfile -t list < "${DIRECTORIES_LIST}"
            pr_h_d "Select Directory to remove From the List:"
            select option in "${list[@]}"; do
                history -s "sed -i '${REPLY}d' ${DIRECTORIES_LIST}"
                eval "sed -i '${REPLY}d' ${DIRECTORIES_LIST}"
                pr_p_i "Removed : $REPLY) $option"
                pr_br
                break
            done
        else
            pr_h_w "No Directory List created so far."; pr_br;
        fi
    fi
}

function .f {
    history -d $(history 1)
    if [ -z $1 ]; then
        if [ -f "${FILES_LIST}" ]; then
            local list
            mapfile -t list < "${FILES_LIST}"
            pr_h_d "Select File to Edit:"
            select option in "${list[@]}"; do
                if [ -f $option ]; then
                    history -s "${E} $option"
                    eval "${EDITOR} $option"
                    break
                else
                    pr_br
                    pr_p_e "Error : File '$option' does not exist."
                    pr_br
                fi
            done
        else
            pr_br
            pr_p_w "No File List created so far. Run '.h' for help on creating one."
            pr_br
        fi
    else
        if [ -f $@ ]; then
            echo "$@" >> "${FILES_LIST}"
            history -s "${EDITOR} $@"
            eval "${EDITOR} $@"
        else
            pr_br
            pr_p_e "Error : File '$@' does not exist."
            pr_br
        fi
    fi
}

function .fx {
    history -d $(history 1)
    if [ -z $1 ]; then
        if [ -f "${FILES_LIST}" ]; then
            local list
            mapfile -t list < "${FILES_LIST}"
            pr_h_d "Select File to Remove From the List:"
            select option in "${list[@]}"; do
                history -s "sed -i '${REPLY}d' ${FILES_LIST}"
                eval "sed -i '${REPLY}d' ${FILES_LIST}"
                pr_p_i "Removed : $REPLY) $option"
                pr_br
                break
            done
        else
            pr_br
            pr_p_w "No File List created so far. Run '.h' for help on creating one."
            pr_br
        fi
    fi
}

function .h {
    history -d $(history 1)
    pr_h_i "$name Usage Help"
    pr_br
    pr_p_d "$usage"
    pr_br
}

function .o {
    history -d $(history 1)
    pr_h_d "Directory List | ${DIRECTORIES_LIST}"
    history -s "cat ${DIRECTORIES_LIST}"
    cat "${DIRECTORIES_LIST}"
    pr_h_d "Command List | ${COMMANDS_LIST}"
    history -s "cat ${COMMANDS_LIST}"
    cat "${COMMANDS_LIST}"
    pr_h_d "File List | ${FILES_LIST}"
    history -s "cat ${FILES_LIST}"
    cat "${FILES_LIST}"
    pr_br
}

function .rem {
    history -d $(history 1)
    local agree
    read -e -p "Are you sure you want to remove all of the .helper.sh files? Type 'yes' to agree. " agree
    if [ "${agree}" == "yes" ]; then
        history -s "rm ${DIR}/.helper.*"
        rm "${DIR}/.helper.sh"
    fi
}

function .sc {
    history -d $(history 1)
    pr_h_i "Checking '$1' service status."
    history -s "systemctl status $1"
    systemctl status "$1"
}

function .sr {
    history -d $(history 1)
    pr_h_i "Restarting '$1' service."
    history -s "systemctl restart $1"
    systemctl restart "$1"
    pr_h_i "Checking '$1' service status."
    history -s "systemctl status $1"
    systemctl status "$1"
}

function .ss {
    history -d $(history 1)
    pr_h_i "Starting '$1' service."
    history -s "systemctl start $1"
    systemctl start "$1"
    pr_h_i "Checking '$1' service status."
    history -s "systemctl status $1"
    systemctl status "$1"
}

function .sx {
    history -d $(history 1)
    pr_h_i "Stopping '$1' service."
    history -s "systemctl stop $1"
    systemctl stop "$1"
    pr_h_i "Checking '$1' service status."
    history -s "systemctl status $1"
    systemctl status "$1"
}

function .t {
    history -d $(history 1)
    history -s "wget -q --show-progress -O ${TEMPLATES_LIST} ${REPO}/.helper.t"
    wget -q --show-progress -O "${TEMPLATES_LIST}" "${REPO}/.helper.t"
    if [ -f "${TEMPLATES_LIST}" ]; then
        local list
        mapfile -t list < "${TEMPLATES_LIST}"
        history -s "rm ${TEMPLATES_LIST}"
        rm "${TEMPLATES_LIST}"
        pr_h_d "Select Template From the List:"
        select option in "${list[@]}"; do
            history -s "wget -q --show-progress -O ${DIRECTORIES_LIST} ${REPO}/${option}/.helper.d"
            history -s "wget -q --show-progress -O ${COMMANDS_LIST} ${REPO}/${option}/.helper.c"
            history -s "wget -q --show-progress -O ${FILES_LIST} ${REPO}/${option}/.helper.f"
            wget -q --show-progress -O "${DIRECTORIES_LIST}" "${REPO}/${option}/.helper.d"
            wget -q --show-progress -O "${COMMANDS_LIST}" "${REPO}/${option}/.helper.c"
            wget -q --show-progress -O "${FILES_LIST}" "${REPO}/${option}/.helper.f"
            pr_p_i "Downloaded : '$option' template."
            pr_br
            break
        done
    else
        pr_br
        pr_p_e "Templates List file does not exist."
        pr_br
    fi
}

function .u {
    history -d $(history 1)
    pr_h_i "Updating to the latest version."
    pr_p_i "Current Version : $version"
    history -s "wget -q --show-progress -O ${DIR}/.helper.sh ${REPO}/.helper.sh"
    wget -q --show-progress -O "${DIR}/.helper.sh" "${REPO}/.helper.sh"
    source "${DIR}/.helper.sh"
}

function .v {
    if [ -z $1 ]; then
        history -d $(history 1)
    fi
    pr_h_i "Name     : $name \\nVersion  : $version \\nLocation : $DIR"
    pr_br
}

.v -
