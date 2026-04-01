import requests
import json

# --- KONFIGURÁCIA ---
ZABBIX_URL = "http://127.0.0.1:8080/api_jsonrpc.php" 
API_TOKEN = "a877db08dedf561ba085ac49f82423da86ac2651e923531bb87892d310d62527" # Ten dlhy retazec
GROUP_NAME = "Linux servers"       # Nazov skupiny v Zabbixe
MAP_NAME = "Automaticka Mapa"
# --------------------

def zabbix_request(method, params):
    headers = {
        "Content-Type": "application/json-rpc",
        "Authorization": f"Bearer {API_TOKEN}"
    }
    payload = {
        "jsonrpc": "2.0",
        "method": method,
        "params": params,
        "id": 1
    }
    response = requests.post(ZABBIX_URL, json=payload, headers=headers)
    res_json = response.json()
    
    if 'error' in res_json:
        print(f"!!! Chyba v API ({method}): {json.dumps(res_json['error'], indent=2)}")
        exit()
    return res_json['result']

# 1. Ziskanie ID skupiny
print(f"Hladam skupinu: {GROUP_NAME}...")
groups = zabbix_request("hostgroup.get", {"filter": {"name": GROUP_NAME}})

if not groups:
    print(f"!!! Skupina '{GROUP_NAME}' nebola najdena. Skontrolujte nazov v Zabbixe.")
    exit()

group_id = groups[0]['groupid']

# 2. Ziskanie hostov v skupine
hosts = zabbix_request("host.get", {
    "groupids": group_id, 
    "output": ["hostid", "name"]
})

if not hosts:
    print(f"!!! V skupine '{GROUP_NAME}' nie su ziadne zariadenia.")
    exit()

# 3. Priprava elementov (Grid 5 stlpcov)
selements = []
for i, host in enumerate(hosts):
    selements.append({
        "elementtype": 0, # Host
        "elements": [{"hostid": host['hostid']}],
        "iconid_off": "2", # ID ikony (napr. 'Server (64)')
        "x": (i % 5) * 150 + 50,
        "y": (i // 5) * 150 + 50,
        "label": host['name']
    })

# 4. Vytvorenie mapy
print(f"Vytvaram mapu so {len(hosts)} zariadeniami...")
map_params = {
    "name": MAP_NAME,
    "width": 1000,
    "height": 800,
    "selements": selements
}

# Skusime najprv, ci mapa uz neexistuje (ak ano, vymazeme ju alebo updatneme)
existing_maps = zabbix_request("map.get", {"filter": {"name": MAP_NAME}})
if existing_maps:
    zabbix_request("map.delete", [existing_maps[0]['sysmapid']])
    print("Stara mapa vymazana.")

result = zabbix_request("map.create", map_params)
print(f"Hotovo! Mapa bola vytvorena s ID: {result['sysmapids'][0]}")
