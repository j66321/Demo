import os
import requests

script_directory = os.path.dirname(os.path.abspath(__file__))
domain_list_directory = os.path.join(script_directory, 'domain_list')
with open(domain_list_directory, 'r') as file:
    domain_list = [line.strip() for line in file]

url = 'https://zabbix.abc.com.tw/api_jsonrpc.php'
headers = {
    'Content-Type': 'application/json'
}

for domain in domain_list:
    payload = {
        "jsonrpc": "2.0",
    "method": "host.create",
    "params": {
        "host":domain,
        "interfaces": [
            {
                "type": 1,
                "main": 1,
                "useip": 1,
                "ip": "172.31.7.666",
                "dns": "",
                "port": "10050"
            }
        ],
        "groups": [
            {
                "groupid": "21"
            }
        ],
        "templates": [
            {
                "templateid": "10413"
            }
        ],
        "macros": [
            {
                "macro": "{$CERT.WEBSITE.HOSTNAME}",
                "value": domain
            },
            {
                "macro": "{$CERT.EXPIRY.WARN}",
                "value": "7"
            }
        ] },
    "auth": "auth key",
    "id": 1
    }

    response = requests.post(url, headers=headers, json=payload)

    if response.status_code == 200:
        print("POST request succeeded for value:", domain)
        print("Response:")
        print(response.json())
    else:
        print("POST request failed for value:", domain)
        print("Response status code:", response.status_code)
        print("Response content:", response.text)

