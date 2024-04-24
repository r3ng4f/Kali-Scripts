#!/bin/bash
# Define o local do arquivo.
SCRIPT_PATH="/usr/local/bin/mount-vmware.sh"

# Script para montar automaticamente as pastas compartilhadas do VMware
cat << 'EOF' > $SCRIPT_PATH
#!/bin/bash
vmware-hgfsclient | while read folder; do
  echo "[i] Mounting ${folder}   (/media/hgfs/${folder})"
  mkdir -p "/media/hgfs/${folder}"
  umount -f "/media/hgfs/${folder}" 2>/dev/null
  vmhgfs-fuse -o allow_other -o auto_unmount ".host:/${folder}" "/media/hgfs/${folder}"
done
sleep 2s
EOF

# Torna o script executável
chmod +x $SCRIPT_PATH

# Define o local do arquivo no systemd
SERVICE_PATH="/etc/systemd/system/vmware-mount.service"

# Conteúdo do arquivo de serviço
cat << 'EOF' > $SERVICE_PATH
[Unit]
Description=Mount VMware Shared Folders
After=vmware-tools.service

[Service]
Type=oneshot
ExecStart=/usr/local/bin/mount-vmware.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

# Recarrega o systemd para reconhecer o novo serviço
systemctl daemon-reload

# Habilita o serviço para iniciar na inicialização
systemctl enable vmware-mount.service

# Inicia o serviço e exibe o status
systemctl start vmware-mount.service

exit 0
