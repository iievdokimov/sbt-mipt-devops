#!/bin/bash

ACTION=$1
REPORT_DIR="./reports"
mkdir -p $REPORT_DIR

monitor() {
    current_date=$(date +"%Y-%m-%d")
    timestamp=$(date +"%Y%m%d_%H%M%S")
    REPORT_FILE="$REPORT_DIR/report_${timestamp}_${current_date}.csv"


    echo "Timestamp,Filesystem,Size,Used,Available,Use%,Mounted,Inodes,InodesUsed,InodesFree,InodesUse%" > "$REPORT_FILE"

    while true; do
        # check date-change
        new_date=$(date +"%Y-%m-%d")
        if [[ "$new_date" != "$current_date" ]]; then
            timestamp=$(date +"%Y%m%d_%H%M%S")
            REPORT_FILE="$REPORT_DIR/report_${timestamp}_${new_date}.csv"
            echo "Timestamp,Filesystem,Size,Used,Available,Use%,Mounted,Inodes,InodesUsed,InodesFree,InodesUse%" > "$REPORT_FILE"
            current_date=$new_date
        fi

        # write new strings to CSV
        df -h --output=source,size,used,avail,pcent,target | tail -n +2 | while read line; do
            inode_info=$(df -i --output=itotal,iused,ifree,ipcent | grep "$(echo $line | awk '{print $1}')")
            timestamp=$(date +"%Y-%m-%d %H:%M:%S")
            echo "$timestamp,$line,$inode_info" >> "$REPORT_FILE"
        done

        sleep 60
    done
}


start() {
    if [ -f "$REPORT_DIR/monitor.pid" ]; then
        PID=$(cat "$REPORT_DIR/monitor.pid")
        if ps -p $PID > /dev/null 2>&1; then
            echo "Процесс уже запущен с PID: $PID!"
            return
        else
            echo "PID-файл найден, но процесс не запущен. Удаляю PID-файл."
            rm "$REPORT_DIR/monitor.pid"
        fi
    fi

    monitor &
    PID=$!
    echo "Процесс запущен с PID: $PID"
    echo $PID > "$REPORT_DIR/monitor.pid"
}

# Функция для остановки процесса
stop() {
    if [ -f "$REPORT_DIR/monitor.pid" ]; then
        PID=$(cat "$REPORT_DIR/monitor.pid")
        if ps -p $PID > /dev/null 2>&1; then
            kill $PID
            rm "$REPORT_DIR/monitor.pid"
            echo "Процесс $PID остановлен."
        else
            echo "Процесс не найден."
        fi
    else
        echo "PID-файл не найден. Возможно, процесс уже остановлен."
    fi
}


status() {
    if [ -f "$REPORT_DIR/monitor.pid" ]; then
        PID=$(cat "$REPORT_DIR/monitor.pid")
        if ps -p $PID > /dev/null 2>&1; then
            echo "Процесс запущен с PID: $PID."
        else
            echo "Процесс не запущен."
        fi
    else
        echo "Процесс не запущен."
    fi
}


case "$ACTION" in
    START)
        start
        ;;
    STOP)
        stop
        ;;
    STATUS)
        status
        ;;
    *)
        echo "Использование: $0 {START|STOP|STATUS}"
        exit 1
        ;;
esac
