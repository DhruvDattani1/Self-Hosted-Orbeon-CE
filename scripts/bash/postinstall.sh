#!/bin/bash
set -e
LOGFILE="/home/ansible/postinstall.log"
log() {
echo "$(date '+%Y-%m-%d %H:%M:%S') | $1" | tee -a "$LOGFILE"
}
read -p "Enter hostname for this node (e.g., master, worker1): " HOSTNAME
log "Setting hostname to $HOSTNAME"
hostnamectl set-hostname "$HOSTNAME"
log "Creating ansible user (if not exists)"
if ! id ansible &>/dev/null; then
useradd ansible -G wheel -s /bin/bash
echo "ansible ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/ansible
log "Ansible user created"
else
log "Ansible user already exists"
fi
log "Setting up SSH key for ansible user"
mkdir -p /home/ansible/.ssh
cat <<EOF > /home/ansible/.ssh/authorized_keys
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIInLtKqzeA+MPhHWHu31K1kyC36PlJUdkxPysjGn6Uh/ dhruvd22@gmail.com
EOF
chown -R ansible:ansible /home/ansible/.ssh
chmod 700 /home/ansible/.ssh
chmod 600 /home/ansible/.ssh/authorized_keys
log "SSH key set for ansible user"
log "Installing packages"
dnf install -y \
vim git curl wget htop openssh-server NetworkManager \
nfs-utils net-tools bind-utils tmux bash-completion dnf-plugins-core rsync \
python3-pip python3-devel
log "Packages installed"
log "Installing Python libraries for Kubernetes automation"
pip3 install kubernetes PyYAML requests urllib3
log "Kubernetes Python libraries installed"
log "Configuring sshd_config"
grep -q '^PermitRootLogin' /etc/ssh/sshd_config \
 && sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config \
|| echo 'PermitRootLogin no' >> /etc/ssh/sshd_config
grep -q '^PubkeyAuthentication' /etc/ssh/sshd_config \
 && sed -i 's/^PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config \
|| echo 'PubkeyAuthentication yes' >> /etc/ssh/sshd_config
log "Reloading sshd"
systemctl reload sshd || log "Failed to reload sshd"
log "Disabling SELinux"
setenforce 0 || true
sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
log "Disabling firewalld"
systemctl disable --now firewalld || log "firewalld not active"
log "Enabling sshd and NetworkManager"
systemctl enable --now sshd NetworkManager
log "Locking root account"
passwd -l root || log "Failed to lock root"
log "Post-install completed on $HOSTNAME"
