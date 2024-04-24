#!/bin/bash
##############
# Lista os pacotes que precisam ser atualizados
sudo apt update
echo "############################################"
echo "###  Atualização dos pacotes concluída."
sleep 2s

# Instala os pacotes open-vm-tools vim htop ttf-mscorefonts-installer offsec-pen300 offsec-pwk kali-wallpapers-all
sudo apt install open-vm-tools vim htop ttf-mscorefonts-installer offsec-pen300 offsec-pwk kali-wallpapers-all burpsuite zaproxy feroxbuster -y
echo "#####################################################"
echo "###  Instação das ferramentas básicas concluída."
sleep 2s

# Atualiza todo o sistema
sudo apt full-upgrade -y
echo "################################"
echo "###  Atualização concluída."
sleep 2s
##############

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
echo "####################################################################"
echo "###  Arquivo $SCRIPT_PATH criado com sucesso."

sleep 2s

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
echo "##############################################################################"
echo "###  Arquivo $SERVICE_PATH criado com sucesso."

sleep 2s

# Recarrega o systemd para reconhecer o novo serviço
systemctl daemon-reload
echo "##############################"
echo "###  Reiniciando o Deamon."
sleep 2s
# Habilita o serviço para iniciar na inicialização
systemctl enable vmware-mount.service
echo "#########################################"
echo "###  Serviço habilitado com sucesso."
sleep 2s

# Inicia o serviço e exibe o status
systemctl start vmware-mount.service
echo "##################################"
echo "###  Sistema pronto para uso."
sleep 2s
exit 0
