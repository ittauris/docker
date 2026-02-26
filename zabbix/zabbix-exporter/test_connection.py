#!/usr/bin/env python3
from pyzabbix import ZabbixAPI
import os
import sys

def test_connection():
    zabbix_url = os.getenv('ZABBIX_URL', 'http://localhost:80')
    zabbix_user = os.getenv('ZABBIX_USER', 'zabbix-api')
    zabbix_password = os.getenv('ZABBIX_PASSWORD', 'Zabbix.365+-')
    
    # Přidání /api_jsonrpc.php pokud chybí
    if not zabbix_url.endswith('/api_jsonrpc.php'):
        if not zabbix_url.endswith('/'):
            zabbix_url += '/'
        zabbix_url += 'api_jsonrpc.php'
    
    print(f"Testing Zabbix API connection...")
    print(f"URL: {zabbix_url}")
    print(f"User: {zabbix_user}")
    
    try:
        zapi = ZabbixAPI(zabbix_url)
        zapi.timeout = 10
        zapi.session.verify = False
        zapi.login(zabbix_user, zabbix_password)
        
        print(f"✓ Successfully connected!")
        print(f"  API Version: {zapi.api_version()}")
        
        # Test queue
        queue = zapi.queue.get(limit=1)
        queue_count = queue[0].get('count', 0) if queue else 0
        print(f"  Queue items: {queue_count}")
        
        # Test hosts
        hosts = zapi.host.get(countOutput=True)
        print(f"  Total hosts: {hosts}")
        
        zapi.user.logout()
        return True
        
    except Exception as e:
        print(f"✗ Connection failed: {e}")
        return False

if __name__ == '__main__':
    success = test_connection()
    sys.exit(0 if success else 1)
