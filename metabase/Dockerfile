# Použijeme najnovšiu stabilnú verziu
FROM metabase/metabase:latest

# Prepnutie na root, aby sme mohli manipulovať s priečinkami
USER root

# Vytvoríme adresár pre pluginy (ak neexistuje)
RUN mkdir -p /plugins

# Skopírujeme driver z lokálneho adresára 'plugins'
COPY ./plugins/db2.metabase-driver.jar /plugins/

# Nastavíme rekurzívne práva na čítanie a zápis pre všetkých (777) 
# To zaručí, že Metabase (nech beží pod akýmkoľvek UID) driver uvidí a dokáže ho inicializovať
RUN chmod -R 777 /plugins

# Vrátime sa k pôvodnému správaniu obrazu (spustenie ako ne-root)
# Namiesto mena 'metabase' použijeme UID 2000, ktoré Metabase oficiálne používa
USER 2000

# Definujeme cestu k pluginom pre Metabase proces
ENV MB_PLUGINS_DIR=/plugins
