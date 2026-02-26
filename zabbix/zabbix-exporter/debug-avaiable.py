#!/usr/bin/env python3
# debug_available.py - Diagnostika available hodnôt

from pyzabbix import ZabbixAPI
import os

zabbix_url = os.getenv('ZABBIX_URL', 'http://zabbix-frontend:8080/api_jsonrpc.php')
zabbix_user = os.getenv('ZABBIX_USER', 'Admin')
zabbix_password = os.getenv('ZABBIX_PASSWORD', '')

zapi = ZabbixAPI(zabbix_url)
zapi.login(zabbix_user, zabbix_password)

# Získaj hosty s ROZŠÍRENÝMI výstupmi
hosts = zapi.host.get(
    output=['hostid', 'host', 'name', 'status', 'available', 'error'],
    selectInterfaces=['type', 'available', 'error'],  # Dôležité!
    limit=10
)

print(f"Našiel som {len(hosts)} hostov\n")

for host in hosts:
    print(f"Host: {host['host']}")
    print(f"  available: '{host.get('available')}' (type: {type(host.get('available'))})")
    print(f"  status: {host.get('status')}")
    print(f"  interfaces: {host.get('interfaces', [])}")
    print()
