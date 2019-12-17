all:
  hosts:
%{ for addr in default_ip_address ~}
    ${addr}:
%{ endfor ~}