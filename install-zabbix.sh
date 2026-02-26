#!/bin/bash
# ===========================================
# Zabbix 6.4 Docker Startup Script
# Autor: Marek Findrik
# Verzia: 1.0
# Popis: Vytvori adresare, nastavi prava, spusti docker-compose stack.
# ===========================================

set -e

PROJECT_DIR="/srv/zabbix"
COMPOSE_FILE="${PROJECT_DIR}/docker-compose.yml"
ENV_FILE="${PROJECT_DIR}/.env"

echo "=== ZACINAM INSTALACIU ZABBIX DOCKER PROSTREDIA ==="
echo "Cas spustenia: $(date)"
echo

# -------------------------------------------
# Krok 1: Kontrola root opravneni
# -------------------------------------------
if [[ $EUID -ne 0 ]]; then
  echo "[CHYBA] Tento skript musi byt spusteny ako root alebo cez sudo."
  exit 1
fi

# -------------------------------------------
# Krok 2: Kontrola Dockeru a Docker Compose
# -------------------------------------------
echo ">> Kontrolujem instalaciu Dockeru..."
if ! command -v docker &> /dev/null; then
  echo "Docker nie je nainstalovany. Instalujem..."
  apt-get update -y && apt-get install -y docker.io docker-compose
fi

echo ">> Overujem, ci Docker bezi..."
systemctl enable --now docker

# -------------------------------------------
# Krok 3: Priprava adresarovej struktury
# -------------------------------------------
echo ">> Pripravujem adresarovu strukturu v ${PROJECT_DIR} ..."
mkdir -p ${PROJECT_DIR}/postgres
chown -R 1000:1000 ${PROJECT_DIR}/postgres
chmod -R 755 ${PROJECT_DIR}

# -------------------------------------------
# Krok 4: Vytvorenie .env, ak neexistuje
# -------------------------------------------
if [[ ! -f ${ENV_FILE} ]]; then
  echo ">> Vytvaram .env subor..."
  cat <<EOF > ${ENV_FILE}
POSTGRES_USER=zabbix
POSTGRES_PASSWORD=zabbixpass
POSTGRES_DB=zabbix
EOF
else
  echo ">> Subor .env uz existuje – ponechavam."
fi

# -------------------------------------------
# Krok 5: Kontrola docker-compose.yml
# -------------------------------------------
if [[ ! -f ${COMPOSE_FILE} ]]; then
  echo "[CHYBA] Subor docker-compose.yml sa nenasiel v ${PROJECT_DIR}."
  echo "Uloz ho tam a spusti skript znova."
  exit 1
fi

# -------------------------------------------
# Krok 6: Spustenie stacku
# -------------------------------------------
echo ">> Spustam Zabbix stack..."
cd ${PROJECT_DIR}
docker compose pull
docker compose up -d

# -------------------------------------------
# Krok 7: Overenie behu
# -------------------------------------------
echo
echo ">> Overujem stav kontajnerov..."
docker ps --filter "name=zabbix" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo
echo "=== INSTALACIA DOKONCENA ==="
echo "Frontend: http://localhost:8080"
echo "Login: Admin | Heslo: zabbix"
echo "Data su ulozene v: ${PROJECT_DIR}/postgres"
echo

