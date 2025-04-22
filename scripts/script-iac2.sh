#!/bin/bash

# Verifica se o script está sendo executado como root
if [ "$(id -u)" -ne 0 ]; then
    echo "Este script deve ser executado como root. Use sudo." >&2
    exit 1
fi

# Atualiza os pacotes do sistema
echo "Atualizando os pacotes do sistema..."
apt-get update -y && apt-get upgrade -y

# Instala o servidor web Apache
echo "Instalando o Apache..."
apt-get install apache2 -y

# Habilita e inicia o Apache
systemctl enable apache2
systemctl start apache2

# Instala o MySQL Server
echo "Instalando o MySQL Server..."
apt-get install mysql-server -y

# Executa o script de segurança do MySQL
echo "Configurando a segurança do MySQL..."
mysql_secure_installation <<EOF

n
y
y
y
y
EOF

# Instala o PHP e módulos necessários
echo "Instalando o PHP e módulos..."
apt-get install php libapache2-mod-php php-mysql -y

# Reinicia o Apache para carregar o PHP
systemctl restart apache2

# Cria um arquivo de teste PHP
echo "Criando arquivo de teste PHP..."
cat > /var/www/html/info.php <<EOF
<?php
phpinfo();
?>
EOF

# Instala o Git para controle de versão
echo "Instalando o Git..."
apt-get install git -y

# Configura o firewall (UFW)
echo "Configurando o firewall..."
apt-get install ufw -y
ufw allow ssh
ufw allow http
ufw allow https
ufw --force enable

# Resumo da instalação
echo ""
echo "============================================"
echo "Servidor Web provisionado com sucesso!"
echo "============================================"
echo "Apache: http://$(hostname -I | cut -d' ' -f1)"
echo "PHP Test: http://$(hostname -I | cut -d' ' -f1)/info.php"
echo "MySQL: Instalado e protegido"
echo "Firewall: Configurado para permitir SSH, HTTP e HTTPS"
echo ""
echo "Próximos passos:"
echo "1. Configure seus sites em /var/www/html/"
echo "2. Proteja seu servidor com certificados SSL (Let's Encrypt)"
echo "3. Considere instalar phpMyAdmin para gerenciar o MySQL"
echo "============================================"