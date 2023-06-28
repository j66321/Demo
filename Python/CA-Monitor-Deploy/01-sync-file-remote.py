# Modify key path depend on your device key path.
import paramiko
import os
import time

private_key = paramiko.RSAKey.from_private_key_file('/Users/jimpan/.ssh/key.pem')

script_directory = os.path.dirname(os.path.abspath(__file__))
domain_list_directory = os.path.join(script_directory, 'domain_list')
with open(domain_list_directory, 'r') as file:
    domain_list = [line.strip() for line in file]

for file in domain_list:
    local_file = os.path.join(script_directory, 'camonitor', file)
    print(local_file)
    remote_file = os.path.join('/etc/nginx/camonitor', file)
    print(remote_file)
    
    transport = paramiko.Transport(("172.31.7.666", 22))
    transport.connect(username="ubuntu", pkey=private_key)
    sftp = paramiko.SFTPClient.from_transport(transport)
    sftp.put(local_file, remote_file)
    transport.close()