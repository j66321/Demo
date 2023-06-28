import paramiko
import time

private_key = paramiko.RSAKey.from_private_key_file('/Users/jimpan/.ssh/key.pem')
transport = paramiko.Transport(("172.31.7.666", 22))
transport.connect(username="ubuntu", pkey=private_key)
ssh = paramiko.SSHClient()
ssh._transport = transport
ssh.exec_command('sudo service nginx reload')
time.sleep(3)
transport.close()

