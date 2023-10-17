#!/bin/sh
#
# tmstatus.sh
#
# A simple script to summarize the Time Machine backup status
#
# Copyright (c) 2018-2023 Matteo Corti <matteo@corti.li>
#
# This module is free software; you can redistribute it and/or modify it
# under the terms of the Apache License v2
# See the LICENSE file for details.
#

# shellcheck disable=SC2034
VERSION=1.20.0

export LC_ALL=C

parse_destination_info() {

    key=$1

    if tmutil destinationinfo | grep -q '^>'; then
        # multiple destinations
        result="$(tmutil destinationinfo | grep -A 100 '^>')"
        if echo "${result}" | grep -q '^='; then
            result="$(echo "${result}" | grep -B 100 '^=' | grep "^${key}" | sed 's/.*:\ //')"
        else
            result="$(echo "${result}" | grep "^${key}" | sed 's/.*:\ //')"
        fi
    else
        result="$(tmutil destinationinfo | grep "^${key}" | sed 's/.*:\ //')"
    fi
    KEY="${result}"
}

format_size() {
    while read -r B; do
        [ "${B}" -lt 1024 ] && echo "${B}" B && break
        KB=$(((B + 512) / 1024))
        [ "${KB}" -lt 1024 ] && echo "${KB}" KB && break
        MB=$(((KB + 512) / 1024))
        [ "${MB}" -lt 1024 ] && echo "${MB}" MB && break
        GB=$(((MB + 512) / 1024))
        [ "${GB}" -lt 1024 ] && echo "${GB}" GB && break
        echo $(((GB + 512) / 1024)) TB
    done
}

days_since() {

    start_date=$1

    start=$(date -j -f "%Y-%m-%d-%H%M%S" "${start_date}" "+%s")

    end=$(date -j '+%s')

    seconds=$((end - start))
    days=$((seconds / 60 / 60 / 24))

    echo "${days}"

}

format_days_ago() {

    days=$1

    if [ "${days}" -eq 0 ]; then
        echo 'less than one day ago'
    elif [ "${days}" -eq 1 ]; then
        echo "${days} day ago"
    else
        echo "${days} days ago"
    fi

}

# adapted from https://unix.stackexchange.com/questions/27013/displaying-seconds-as-days-hours-mins-seconds
format_timespan() {

    input_in_seconds=$1

    days=$((input_in_seconds / 60 / 60 / 24))
    hours=$((input_in_seconds / 60 / 60 % 24))
    minutes=$((input_in_seconds / 60 % 60))
    seconds=$((input_in_seconds % 60))

    if [ "${days}" -gt 0 ]; then
        [ "${days}" = 1 ] && printf "%d day " "${days}" || printf "%d days " "${days}"
    fi
    if [ "${hours}" -gt 0 ]; then
        [ "${hours}" = 1 ] && printf "%d hour " "${hours}" || printf "%d hours " "${hours}"
    fi
    if [ "${minutes}" -gt 0 ]; then
        [ "${minutes}" = 1 ] && printf "%d minute " "${minutes}" || printf "%d minutes " "${minutes}"
    fi
    if [ "${seconds}" -gt 0 ]; then
        [ "${seconds}" = 1 ] && printf "%d second" "${seconds}" || printf "%d seconds" "${seconds}"
    fi

}

usage() {

    echo
    echo "Usage: tmstatus.sh [OPTIONS]"
    echo
    echo "Options:"
    # Delimiter at 78 chars ############################################################
    echo "   -a,--all                        Show information for all the volumes"
    echo "   -h,--help,-?                    This help message"
    echo "   -l,--log [lines]                Show the last log lines"
    echo "   -p,--progress                   Show a progress bar"
    echo "   -q,--quick                      Skip the backup listing"
    echo "   -s,--speed                      Show the speed of the running backup"
    echo "   -t,--today                      List today's backups"
    echo "   -v,--verbose                    Show all the available information"
    echo "   -V,--version                    Version"
    echo
    echo "Report bugs to https://github.com/matteocorti/tmstatus.sh/issues"
    echo

    exit

}

COMMAND_LINE_ARGUMENTS=$*

while true; do

    case "$1" in
    -a | --all)
        ALL=1
        shift
        ;;
    -h | --help)
        usage
        ;;
    -l | --log)
        SHOWLOG=20
        if [ $# -gt 1 ]; then
            # shellcheck disable=SC2295
            if [ "${2%${2#?}}"x = '-x' ]; then
                shift
            else
                SHOWLOG=$2
                shift 2
            fi
        else
            shift
        fi
        ;;
    -p | --progress)
        PROGRESS=1
        shift
        ;;
    -q | --quick)
        QUICK=1
        shift
        ;;
    -s | --speed)
        SHOW_SPEED=1
        shift
        ;;
    -t | --today)
        TODAY=1
        shift
        ;;
    -v | --verbose)
        SHOWLOG=20
        PROGRESS=1
        SHOW_SPEED=1
        TODAY=1
        ALL=1
        shift
        ;;
    -V | --version)
        echo "tmstatus.sh version ${VERSION}"
        exit
        ;;
    *)
        if [ -n "$1" ]; then
            echo "Error: unknown option: ${1}" 1>&2
            exit 1
        fi
        break
        ;;
    esac

done

COMPUTER_TMP="$(scutil --get ComputerName)"
printf 'Backups for "%s"\n' "${COMPUTER_TMP}"

##############################################################################
# Backup statistics

parse_destination_info Kind
KIND="${KEY}"

if [ "${KIND}" = "Local" ]; then
    KIND="Local disk"
fi

if [ -z "${QUICK}" ]; then

    tmutil destinationinfo | grep '^Mount Point' | sed -e 's/.*: //' | while read -r tm_mount_point; do

        LISTBACKUPS=$(tmutil listbackups -d "${tm_mount_point}" 2>&1)

        if echo "${LISTBACKUPS}" | grep -q -F 'listbackups requires Full Disk Access privileges'; then

            cat <<'EOF'
Error:

tmutil: listbackups requires Full Disk Access privileges.

To allow this operation, select Full Disk Access in the Privacy
tab of the Security & Privacy preference pane, and add Terminal
to the list of applications which are allowed Full Disk Access.

EOF
            exit 1

        elif echo "${LISTBACKUPS}" | grep -q 'No machine directory found for host.'; then

            if tmutil status 2>&1 | grep -q 'HealthCheckFsck'; then

                printf 'Time Machine: no information available (performing backup verification)\n'

            else

                printf 'Time Machine (%s):\n' "${KIND}"
                printf '  Oldest:\toffline\n'
                printf '  Last:\toffline\n'
                printf '  Number:\toffline\n'

                # shellcheck disable=SC2030
                OFFLINE=1

            fi

        elif echo "${LISTBACKUPS}" | grep -q 'No backups found for host.'; then

            printf 'Time Machine: no backups found\n'

        else

            # sometimes df on network volumes throws a 'df: getattrlist failed: Permission denied' error but delivers
            # the expected result anyway
            tm_total=$(df -H "${tm_mount_point}" 2>/dev/null | tail -n 1 | awk '{ print $2 "\t" }' | sed 's/[[:blank:]]//g')
            tm_available=$(df -H "${tm_mount_point}" 2>/dev/null | tail -n 1 | awk '{ print $4 "\t" }' | sed 's/[[:blank:]]//g')

            tm_total_raw=$(df "${tm_mount_point}" 2>/dev/null | tail -n 1 | awk '{ print $2 "\t" }' | sed 's/[[:blank:]]//g')
            tm_available_raw=$(df "${tm_mount_point}" 2>/dev/null | tail -n 1 | awk '{ print $4 "\t" }' | sed 's/[[:blank:]]//g')
            tm_percent_available=$(echo "${tm_available_raw} * 100 / ${tm_total_raw}" | bc)

            printf '\nVolume (%s) "%s": %s (%s available, %s%%)\n' "${KIND}" "${tm_mount_point}" "${tm_total}" "${tm_available}" "${tm_percent_available}"

            DATE="$(echo "${LISTBACKUPS}" | head -n 1 | sed 's/.*\///' | sed 's/[.].*//')"
            days="$(days_since "${DATE}")"
            backup_date=$(echo "${LISTBACKUPS}" | head -n 1 | sed 's/.*\///' | sed 's/[.].*//' | sed 's/-\([^\-]*\)$/\ \1/' | sed 's/\([0-9][0-9]\)\([0-9][0-9]\)\([0-9][0-9]\)/\1:\2:\3/')
            DAYS_AGO="$(format_days_ago "${days}")"
            printf '  Oldest:\t%s (%s)\n' "${backup_date}" "${DAYS_AGO}"

            LATESTBACKUP="$(tmutil latestbackup -d "${tm_mount_point}")"
            if echo "${LATESTBACKUP}" | grep -q '[0-9]'; then
                # a date was returned (should implement a better test)
                DATE="$(echo "${LATESTBACKUP}" | sed 's/.*\///' | sed 's/[.].*//')"
                days=$(days_since "${DATE}")
                backup_date=$(echo "${LATESTBACKUP}" | sed 's/.*\///' | sed 's/[.].*//' | sed 's/-\([^\-]*\)$/\ \1/' | sed 's/\([0-9][0-9]\)\([0-9][0-9]\)\([0-9][0-9]\)/\1:\2:\3/')
                DAYS_AGO="$(format_days_ago "${days}")"
                printf '  Last:\t\t%s (%s)\n' "${backup_date}" "${DAYS_AGO}"
            else
                printf '  Last:\t\t%s\n' "${LATESTBACKUP}"
            fi

            number=$(echo "${LISTBACKUPS}" | wc -l | sed 's/\ //g')
            printf '  Number:\t%s\n' "${number}"

            # shellcheck disable=SC2030
            FOUND=1

        fi

    done

    ##############################################################################
    # Local backup statistics

    LOCALSNAPSHOTDATES=$(tmutil listlocalsnapshotdates / 2>&1)

    if echo "${LOCALSNAPSHOTDATES}" | grep -q '[0-9]'; then

        tm_total=$(df -H / | tail -n 1 | awk '{ print $2 "\t" }' | sed 's/[[:blank:]]//g')
        tm_available=$(df -H / | tail -n 1 | awk '{ print $4 "\t" }' | sed 's/[[:blank:]]//g')

        tm_total_raw=$(df / | tail -n 1 | awk '{ print $2 "\t" }' | sed 's/[[:blank:]]//g')
        tm_available_raw=$(df / | tail -n 1 | awk '{ print $4 "\t" }' | sed 's/[[:blank:]]//g')
        tm_percent_available=$(echo "${tm_available_raw} * 100 / ${tm_total_raw}" | bc)

        printf '\nLocal: %s (%s available, %s%%)\n' "${tm_total}" "${tm_available}" "${tm_percent_available}"

        DATE="$(echo "${LOCALSNAPSHOTDATES}" | sed -n 2p)"
        days="$(days_since "${DATE}")"
        DAYS_AGO="$(format_days_ago "${days}")"
        BACKUP_DATE="$(echo "${LOCALSNAPSHOTDATES}" | sed -n 2p | sed 's/-\([^\-]*\)$/\ \1/' | sed 's/\([0-9][0-9]\)\([0-9][0-9]\)\([0-9][0-9]\)/\1:\2:\3/')"

        printf '  Local oldest:\t%s (%s)\n' "${BACKUP_DATE}" "${DAYS_AGO}"

        DATE="$(echo "${LOCALSNAPSHOTDATES}" | tail -n 1)"
        days="$(days_since "${DATE}")"
        DAYS_AGO="$(format_days_ago "${days}")"
        BACKUP_DATE="$(echo "${LOCALSNAPSHOTDATES}" | tail -n 1 | sed 's/.*\///' | sed 's/-\([^\-]*\)$/\ \1/' | sed 's/\([0-9][0-9]\)\([0-9][0-9]\)\([0-9][0-9]\)/\1:\2:\3/')"
        printf '  Local last:\t%s (%s)\n' "${BACKUP_DATE}" "${DAYS_AGO}"

        printf '  Local number:\t'
        echo "${LOCALSNAPSHOTDATES}" | wc -l | sed 's/\ //g'

        echo

    fi

fi

##############################################################################
# Current status

# we read the log file early (we need the log entries for the backup speed)
if [ -n "${SHOWLOG}" ] || [ -n "${SHOW_SPEED}" ] || [ -n "${PROGRESS}" ]; then

    printf "Reading the logs..."

    # check the last day for today's backups sizes
    LOG_LAST='--last 3600m'
    # shellcheck disable=SC2086
    LOG_ENTRIES=$(log show ${LOG_LAST} --color none --predicate 'subsystem == "com.apple.TimeMachine"' --info)

    # go back at the beginning of the line
    printf "\r                    \r"

    if [ -n "${PROGRESS}" ]; then
        PROGRESS=$(
            echo "${LOG_ENTRIES}" |
                grep 'CopyProgress\] \.' |
                tail -n 1 | sed -e 's/.*CopyProgress\] \./ |/' -e 's/[.]/|/'
        )
    fi

fi

status=$(tmutil status)

current_mount_point=$(tmutil status | grep DestinationMountPoint | sed -e 's/.* = "//' -e 's/".*//')

if echo "${status}" | grep -q 'BackupPhase'; then

    phase=$(echo "${status}" | grep BackupPhase | sed 's/.*\ =\ //' | sed 's/;.*//')

    case "${phase}" in
    'BackupNotRunning')
        phase='Not running'
        ;;
    'Copying')
        phase="Copying${PROGRESS}"
        ;;
    'DeletingOldBackups')
        phase='Deleting old backups'
        ;;
    'FindingBackupVol')
        phase='Looking for backup disk'
        ;;
    'FindingChanges')
        phase='Finding changes'
        ;;
    'HealthCheckCopyHFSMeta')
        phase='Verifying backup'
        ;;
    'HealthCheckFsck')
        phase='Verifying backup'
        ;;
    'LazyThinning')
        phase='Lazy thinning'
        ;;
    'MountingBackupVol')
        phase='Mounting backup volume'
        ;;
    'MountingBackupVolForHealthCheck')
        phase='Preparing verification'
        ;;
    'PreparingSourceVolumes')
        phase='Preparing source volumes'
        ;;
    'SizingChanges')
        phase='Sizing changes'
        ;;
    'ThinningPostBackup')
        phase='Finished: thinning backups'
        ;;
    'ThinningPreBackup')
        phase='Starting: thinning backups'
        ;;
    *) ;;

    esac

    if [ -n "${current_mount_point}" ]; then
        printf 'Status:\t\t%s on "%s"\n' "${phase}" "${current_mount_point}"
    else
        printf 'Status:\t\t%s\n' "${phase}"
    fi

    if echo "${status}" | grep -q 'totalBytes'; then
        total_size=$(echo "${status}" | grep 'totalBytes\ \=' | sed 's/.*totalBytes\ \=\ //' | sed 's/;.*//' | format_size)
        printf 'Backup size:\t%s\n' "${total_size}"
    fi

    if echo "${status}" | grep -q Remaining; then

        echo

        secs=$(echo "${status}" | grep Remaining | sed 's/.*\ =\ //' | sed -e 's/.*\ =\ //' -e 's/;.*//' -e 's/^"//' -e 's/"$//' -e 's/[.].*//')

        # sometimes the remaining time is negative (?)
        if ! echo "${secs}" | grep -q '^"-'; then

            now=$(date +'%s')
            end=$((now + secs))
            end_formatted=$(date -j -f '%s' "${end}" +'%Y-%m-%d %H:%M')
            duration=$(format_timespan "${secs}")

            DATE1="$(date -j -f '%s' "${end}" +'%Y-%m-%d')"
            DATE2="$(date +'%Y-%m-%d')"
            if [ "${DATE1}" != "${DATE2}" ]; then
                end_formatted=$(date -j -f '%s' "${end}" +'%Y-%m-%d %H:%M')
            else
                end_formatted=$(date -j -f '%s' "${end}" +'%H:%M')
            fi

            if [ "${secs}" -eq 0 ]; then
                printf 'Time remaining:\tunknown (finishing)\n'
            else
                printf 'Time remaining:\t%s (finish by %s)\n' "${duration}" "${end_formatted}"
            fi

        fi

    elif echo "${status}" | grep -q FindingChanges; then

        percent=$(echo "${status}" | grep FractionDone | sed -e 's/.*[.]\([0-9][0-9]\).*/\1%/')
        if echo "${percent}" | grep -q 'FractionDone = 1'; then
            percent='100%'
        elif echo "${percent}" | grep -q 'FractionDone = 0'; then
            percent='0%'
        elif echo "${percent}" | grep -q '^0'; then
            # remove the leading 0
            percent=$( echo "${percent}" | sed 's/^0//' )
        fi
        printf 'Percent:\t%s\n' "${percent}"

    fi

else

    printf 'Status:\t\tStopped\n'

fi

if echo "${status}" | grep -qi copying &&  [ -n "${SHOW_SPEED}" ]; then

    SPEED=$(
        echo "${LOG_ENTRIES}" |
            grep 'Progress: ' |
            tail -n 1 |
            sed 's/.*done, //'
    )

    if [ -n "${SPEED}" ]; then
        if ! echo "${SPEED}" | grep -q -- '-, '; then

            if echo "${SPEED}" | grep -q '%\/s'; then            
                PERC_PER_SECOND=$(echo "${SPEED}" | sed 's/%\/s.*//')            
                PERC_PER_HOUR=$(echo "scale=2;${PERC_PER_SECOND}*3600" | bc)
            elif echo "${SPEED}" | grep -q '%\/h'; then
                PERC_PER_HOUR=$(echo "${SPEED}" | sed 's/%\/h.*//')            
            fi
            
            if [ -n "${PERC_PER_HOUR}" ]; then
                if echo "${PERC_PER_HOUR}" | grep -q '^[.]'; then
                    PERC_PER_HOUR=$(echo "${PERC_PER_HOUR}" | sed 's/\([.][0-9]\)\(.*\)/\1/')
                    PERC_PER_HOUR=" (0${PERC_PER_HOUR} %/h)"
                else
                    PERC_PER_HOUR=$(echo "${PERC_PER_HOUR}" | sed 's/[.].*//')
                    PERC_PER_HOUR=" (${PERC_PER_HOUR} %/h)"
                fi
            fi
        fi
        DATA_SPEED=$(
            echo "${SPEED}" |
                sed -e 's/.*%\/s, //' -e 's/,[ 0-9.]*items.*//'
        )
        if [ -n "${DATA_SPEED}" ]; then
            DATA_SPEED=" (${DATA_SPEED})"
        fi

        ITEM_SPEED=$(
            echo "${SPEED}" |
                sed 's/.*MB\/s, //'
        )
    fi

fi

if echo "${status}" | grep '_raw_Percent' | grep -q -v '[0-9]e-'; then
    if echo "${status}" | grep -q '_raw_Percent" = 1;'; then
        percent='100%'
    else
        percent=$(echo "${status}" | grep '_raw_Percent" = "0' | sed 's/.*[.]//' | sed 's/\([0-9][0-9]\)\([0-9]\).*/\1.\2%/' | sed 's/^0//')
    fi
    printf 'Percent:\t%s%s\n' "${percent}" "${PERC_PER_HOUR}"

    raw_percent=$(echo "${status}" | grep '_raw_Percent' | sed 's/.*\ =\ "//' | sed 's/".*//')

    if echo "${status}" | grep -q 'bytes'; then
        size=$(echo "${status}" | grep 'bytes\ \=' | sed 's/.*bytes\ \=\ //' | sed 's/;.*//')
        copied_size=$(echo "${size} / ${raw_percent}" | bc | format_size)
        size=$(echo "${size}" | format_size)
        printf 'Size:\t\t%s of %s%s\n' "${size}" "${copied_size}" "${DATA_SPEED}"
    fi

    if [ -n "${ITEM_SPEED}" ]; then
        printf 'Speed:\t\t%s\n' "${ITEM_SPEED}"
    fi

fi

# Print verifying status
if echo "${status}" | grep -q -F HealthCheckFsck; then
    if echo "${status}" | grep -q -F 'Percent = "0'; then
        percent=$(echo "${status}" | grep 'Percent = ' | sed 's/.*Percent\ =\ \"0\.//' | sed 's/\".*//')
        printf 'Percent:\t%s%%\n' "${percent}"
    fi
fi

if [ -n "${TODAY}" ]; then

    TODAYS_DATE="$(date +"%Y-%m-%d")"

    if tmutil destinationinfo | grep -q '^Mount Point'; then
        echo
    fi

    tmutil destinationinfo | grep '^Mount Point' | sed -e 's/.*: //' | while read -r tm_mount_point; do

        LISTBACKUPS=$(tmutil listbackups -d "${tm_mount_point}" 2>&1)
        TODAYS_BACKUPS=$(echo "${LISTBACKUPS}" | grep "${TODAYS_DATE}" | sed -e 's/.*\///' -e 's/\.backup//' -e 's/.*\([0-9][0-9]\)\([0-9][0-9]\)\([0-9][0-9]\)$/\1:\2/')

        if [ -n "${LOG_ENTRIES}" ]; then

            # Information on backup size: https://eclecticlight.co/2021/04/09/time-machine-to-apfs-how-efficient-are-backups/
            for b in ${TODAYS_BACKUPS}; do

                # the log entry could also be a minute before. It is not accurate but we remove the last digit (could always be wrong if ending with 0 but better than nothing)
                b_short=$(echo "${b}" | sed 's/[0-9]$//')
                b_size=$(echo "${LOG_ENTRIES}" | grep -A 10 "${TODAYS_DATE} ${b_short}" | grep -A 10 'Finished copying from' | grep 'Total Items Added' | tail -n 1 | sed -e 's/.*p: //' -e 's/).*//')

                # size alignment
                
                # add .00 if the the number is round for a better alignment
                if echo "${b_size}" | grep -q '^[0-9] .B' ; then
                    b_size=$( echo "${b_size}" | sed 's/ \(.\)B/.00 \1B/' )
                fi
                
                # add a decimal 0 if the number has only one decimal digit
                if echo "${b_size}" | grep -q '\.[0-9] .B' ; then
                    b_size=$( echo "${b_size}" | sed 's/\.\([0-9]\) \(.\)B/.\10 \2B/' )
                fi

                # pad to three digits
                if echo "${b_size}" | grep -q '^[0-9]\.' ; then
                    b_size="  ${b_size}"
                fi
                # pad to three digits
                if echo "${b_size}" | grep -q '^[0-9][0-9]\.' ; then
                    b_size=" ${b_size}"
                fi
                
                TODAYS_BACKUPS=$(echo "${TODAYS_BACKUPS}" | sed "s/${b}/${b} (${b_size})/")
            done

        fi

        # without the grep ':' there is always one line (empty)
        NUMBER_OF_TODAYS_BACKUPS=$(echo "${TODAYS_BACKUPS}" | grep -c ':' | sed 's/[ ]//g')

        TODAYS_BACKUPS=$(echo "${TODAYS_BACKUPS}" | tr '\n' ',' | sed 's/,/, /g' | sed 's/, $//')

        if [ "${NUMBER_OF_TODAYS_BACKUPS}" -eq 0 ]; then
            echo "${NUMBER_OF_TODAYS_BACKUPS} backups today (${TODAYS_DATE}) on \"${tm_mount_point}\""
        else
            if [ "${NUMBER_OF_TODAYS_BACKUPS}" -eq 1 ]; then
                printf '%s backup today (%s) on "%s"\tat %s\n' "${NUMBER_OF_TODAYS_BACKUPS}" "${TODAYS_DATE}" "${tm_mount_point}" "${TODAYS_BACKUPS}"
            else
                printf '%s backups today (%s) on "%s"\tat %s\n' "${NUMBER_OF_TODAYS_BACKUPS}" "${TODAYS_DATE}" "${tm_mount_point}" "${TODAYS_BACKUPS}"
            fi
        fi

    done

fi

echo

if [ -n "${SHOWLOG}" ]; then

    LOG_LAST=$(echo "${LOG_LAST}" | sed 's/--last //')

    echo "Last log entries (last ${SHOWLOG} entries in the last ${LOG_LAST}):"

    WIDTH=$(tput cols)
    SEQ=$(seq 1 "${WIDTH}")

    # per default TM runs each hour: check the last 60 minutes
    LOG_ENTRIES=$(
        echo "${LOG_ENTRIES}" |
            grep --line-buffered \
                --invert \
                --regexp '^Timestamp' \
                --regexp 'TMPowerState: [0-9]' \
                --regexp 'Running for notifyd event com.apple.powermanagement.systempowerstate' \
                --regexp 'com.apple.backupd.*.xpc: connection invalid' \
                --regexp 'Skipping scheduled' \
                --regexp 'Failed to find a disk' \
                --regexp 'notifyd ' \
                --regexp TMSession \
                --regexp BackupScheduling \
                --regexp 'Mountpoint.*is still valid' \
                --regexp Local \
                --regexp 'Accepting a new connection' \
                --regexp 'Backup list requested' \
                --regexp 'Spotlight' \
                --regexp 'fs_snapshot_list failed' \
                --regexp 'XPC error for connection' \
                --regexp 'LockState' \
                --regexp 'Tracker: ' \
                --regexp 'Lookups: ' \
                --regexp 'Comparisons: ' \
                --regexp 'ByPhysical' \
                --regexp 'ByItemCount' \
                --regexp 'ByEventPath' \
                --regexp 'time interval since last backup' \
                --regexp 'BACKUP_CANCELLED_NOT_ENOUGH_ELAPSED_TIME' \
                --regexp 'Did not match sparsebundle' \
                --regexp 'Found disk' \
                --regexp 'Found matching sparsebundle' \
                --regexp 'to allow volume' \
                --regexp 'bacuse volume' \
                --regexp 'Network destination already mounted' \
                --regexp 'Rejected a new connection' |
            sed -e 's/\.[0-9]*+[0-9][0-9][0-9][0-9] 0x[0-9a-f]* */ /' \
                -e 's/^\([^0-9]\)/\t\1/' \
                -e 's/\ *0x[0-9a-f]* *[0-9]* *[0]9* */ /' \
                -e 's/com.apple.TimeMachine://' \
                -e 's/(TimeMachine) //' \
                -e 's/backupd-helper: //' \
                -e 's/backupd: //' \
                -e 's/heard: //' \
                -e 's/lsd: //' \
                -e 's/\]/\t/' \
                -e 's/\[//' |
            expand -t 27 |
            cut -c -"${WIDTH}" |
            tail -n "${SHOWLOG}"
    )

    if [ -n "${LOG_ENTRIES}" ]; then

        # shellcheck disable=SC2086
        printf '%.s-' ${SEQ}
        echo

        echo "${LOG_ENTRIES}"

        # shellcheck disable=SC2086
        printf '%.s-' ${SEQ}
        echo

    else

        echo "No recent entries"

    fi

fi
