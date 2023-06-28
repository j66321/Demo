import os
import shutil

script_directory = os.path.dirname(os.path.abspath(__file__))
domain_list_directory = os.path.join(script_directory, 'domain_list')
with open(domain_list_directory, 'r') as file:
    domain_list = [line.strip() for line in file]

src = os.path.join(script_directory, 'nginx-template')

for domain in domain_list:
    dst = os.path.join(script_directory, 'camonitor', domain)
    shutil.copyfile(src, dst)
    
    with open(dst, 'r') as file:
        content = file.read()

    new_content = content.replace("domainname-replace", domain)

    with open(dst, 'w') as file:
        file.write(new_content)
