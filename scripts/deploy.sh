#!/usr/bin/env bash 
# Uso:  ENV=prod ./scripts/deploy.sh     ou     ENV=dev ./scripts/deploy.sh 
set -euo pipefail 
  
ENV="${ENV:-prod}" 
PROJETO="final-equipe<N>" 
POOL="pool-final" 
IMAGEM="ubuntu:24.04" 
  
if [ "$ENV" = "prod" ]; then 
  REDE="net-prod"; SUBNET="10.10.10"; PORTA_HTTP=8081; PORTA_HTTPS=8444; PREFIXO="" 
else 
  REDE="net-dev";  SUBNET="10.10.20"; PORTA_HTTP=8082; PORTA_HTTPS=8445; PREFIXO="dev-" 
fi 
  
rede() { 
  lxc network show "$REDE" >/dev/null 2>&1 || \ 
    lxc network create "$REDE" ipv4.address="$SUBNET.1/24" ipv4.nat=true ipv6.address=none 
} 
  
storage() { 
  lxc storage show "$POOL" >/dev/null 2>&1 || lxc storage create "$POOL" dir 
  lxc storage volume show "$POOL" "${PREFIXO}vol-db" >/dev/null 2>&1 || \ 
    lxc storage volume create "$POOL" "${PREFIXO}vol-db" 
  # TODO: demais volumes da sua trilha (vol-uploads, vol-dados, vol-config) 
} 
  
perfis() { 
  for p in perfil-base perfil-proxy perfil-app perfil-db; do 
    lxc profile show "$p" >/dev/null 2>&1 || lxc profile create "$p" 
    lxc profile edit "$p" < "profiles/$p.yaml" 
  done 
} 
  
criar_instancia() {   # uso: criar_instancia nome ip perfil-papel 
  local nome="${PREFIXO}$1" ip="$2" papel="$3" 
  lxc delete -f "$nome" 2>/dev/null || true 
  lxc init "$IMAGEM" "$nome" -p perfil-base -p "$papel" 
  lxc config device override "$nome" eth0 network="$REDE" ipv4.address="$ip" 
} 
  
iniciar() {           # uso: iniciar nome 
  lxc start "${PREFIXO}$1" 
  lxc exec "${PREFIXO}$1" -- cloud-init status --wait >/dev/null 
} 
  
main() { 
  lxc project show "$PROJETO" >/dev/null 2>&1 || \ 
    lxc project create "$PROJETO" -c features.images=false -c features.profiles=false 
  lxc project switch "$PROJETO" 
  
  rede; storage; perfis 
  
  criar_instancia db "$SUBNET.12" perfil-db 
  lxc config device add "${PREFIXO}db" dados disk pool="$POOL" source="${PREFIXO}vol-db" 
path=/var/lib/mysql 
  iniciar db 
  # TODO: enviar e executar conf/config-mariadb.sh (ou config-postgres.sh)

criar_instancia app "$SUBNET.11" perfil-app 
  # TODO: anexar volumes da aplicação 
  iniciar app 
  # TODO: enviar e executar o script de instalação da sua trilha 
  
  criar_instancia app "$SUBNET.11" perfil-app 
  # TODO: anexar volumes da aplicação 
  iniciar app 
  # TODO: enviar e executar o script de instalação da sua trilha 
  
  criar_instancia proxy "$SUBNET.10" perfil-proxy 
  iniciar proxy 
  # TODO: enviar nginx-servico.conf, certificado e chave; recarregar o nginx 
  lxc config device add "${PREFIXO}proxy" porta-http  proxy listen=tcp:0.0.0.0:$PORTA_HTTP  
connect=tcp:127.0.0.1:80 
  lxc config device add "${PREFIXO}proxy" porta-https proxy listen=tcp:0.0.0.0:$PORTA_HTTPS 
connect=tcp:127.0.0.1:443 
  
  echo "Ambiente $ENV no ar: http://<IP-DA-VM>:$PORTA_HTTP" 
} 
  
main "$@"
