#!/bin/bash

# Adresar s vasim docker-compose.yml
PROJECT_DIR="/srv/zabbix"
LOG_FILE="/var/log/zabbix-update.log"

echo "$(date '+%Y-%m-%d %H:%M:%S') - Startovanie mesacnej aktualizacie..." >> $LOG_FILE

cd $PROJECT_DIR

# 1. Stiahnutie novych verzii pre image s tagmi (Loki, Postgres, Grafana...)
echo "Tahaju sa nove image..." >> $LOG_FILE
docker compose pull >> $LOG_FILE 2>&1

# 2. Prebudovanie vlastneho Zabbix Serveru (kvoli Chrome/Ubuntu updatom)
echo "Prebudovava sa zabbix-server custom build..." >> $LOG_FILE
docker compose build --no-cache zabbix-server >> $LOG_FILE 2>&1

# 3. Restartovanie sluzieb (Docker vymeni len tie, ktore maju novy image/build)
echo "Restartuju sa kontajnery..." >> $LOG_FILE
docker compose up -d --remove-orphans >> $LOG_FILE 2>&1

# 4. Cleanup starych obrazov (setrenie miesta na disku)
echo "Cistenie starych obrazov..." >> $LOG_FILE
docker image prune -f >> $LOG_FILE 2>&1

echo "$(date '+%Y-%m-%d %H:%M:%S') - Aktualizacia dokoncena uspesne." >> $LOG_FILE
