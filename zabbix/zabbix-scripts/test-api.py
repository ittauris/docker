import requests
import json

# --- KONFIGURÁCIA ---
# Použite priamu IP adresu Docker hostiteľa, nie localhost, ak ste v kontajneri
ZABBIX_URL = "http://127.0.0.1:8080/api_jsonrpc.php" 
API_TOKEN = "a877db08dedf561ba085ac49f82423da86ac2651e923531bb87892d310d62527"
# --------------------

def test_connection():
    headers = {
        "Content-Type": "application/json-rpc",
        "Authorization": f"Bearer {API_TOKEN}"
    }
    
    # Najjednoduchší možný request - vráti verziu API
    payload = {
        "jsonrpc": "2.0",
        "method": "apiinfo.version",
        "params": [],
        "id": 1
    }

    try:
        print(f"Pripájanie k: {ZABBIX_URL}...")
        response = requests.post(ZABBIX_URL, json=payload, headers=headers, timeout=10)
        print(f"HTTP Status: {response.status_code}")
        print(f"Odpoveď: {response.text}")
    except Exception as e:
        print(f"Chyba pripojenia: {e}")

if __name__ == "__main__":
    test_connection()
