#!/bin/bash

ACTION=$1

SCRIPT_NAME=$(basename "$0")

REPORT_DIR="./reports"
mkdir -p $REPORT_DIR

monitor() {
    while true; do
        TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
        DATE=$(date +"%Y-%m-%d")
        REPORT_FILE="$REPORT_DIR/report_$TIMESTAMP_$DATE.csv"

        # unix
        df -i | awk 'NR==1{print $0; next} {print $0}' > "$REPORT_FILE"
	

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

    # Если процесс не запущен, то запускаем его
    monitor &
    PID=$!
    echo "Процесс запущен с PID: $PID"
    echo $PID > "$REPORT_DIR/monitor.pid"
}

stop() {
    if [ -f "$REPORT_DIR/monitor.pid" ]; then
        PID=$(cat "$REPORT_DIR/monitor.pid")
        if ps -p $PID > /dev/null; then
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
        if ps -p $PID > /dev/null; then
            echo "Процесс запущен с PID: $PID."
        else
            echo "Процесс не запущен."
        fi
    else
        echo "Процесс не запущен."
    fi
}

# rules
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
