#!/bin/bash

#script: cambio_mac.sh

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

INTERFACE="wlan0"
DEFAULT_MAC="12:34:56:78:9a:bc"

# Función para validar formato MAC
valid_mac() {
    [[ $1 =~ ^([0-9A-Fa-f]{2}:){5}([0-9A-Fa-f]{2})$ ]]
}

# Verificar existencia de la interfaz
if ! ip link show "$INTERFACE" &> /dev/null; then
    echo -e "${RED}Error: La interfaz $INTERFACE no existe.${NC}"
    exit 1
fi

# Verificar que macchanger está instalado
if ! command -v macchanger &> /dev/null; then
    echo -e "${RED}Error: macchanger no está instalado.${NC}"
    exit 1
fi

echo -e "${YELLOW}¿Quieres usar la MAC predeterminada? [${DEFAULT_MAC}] (s/n):${NC} "
read -r usar_predeterminada

if [[ "$usar_predeterminada" == "s" || "$usar_predeterminada" == "S" ]]; then
    MAC_TO_USE="$DEFAULT_MAC"
else
    read -rp "Ingresa la MAC personalizada (formato XX:XX:XX:XX:XX:XX): " input_mac
    if valid_mac "$input_mac"; then
        MAC_TO_USE="$input_mac"
    else
        echo -e "${RED}Error: Formato de MAC inválido.${NC}"
        exit 1
    fi
fi

echo "🔽 Bajando interfaz $INTERFACE..."
sudo ip link set "$INTERFACE" down

echo "🎨 Cambiando MAC a $MAC_TO_USE ..."
sudo macchanger -m "$MAC_TO_USE" "$INTERFACE"

echo "🔼 Subiendo interfaz $INTERFACE..."
sudo ip link set "$INTERFACE" up

echo "🔍 Verificando MAC actual:"
ip link show "$INTERFACE" | grep ether

echo -e "${GREEN}✔ Cambio de MAC completado.${NC}"

