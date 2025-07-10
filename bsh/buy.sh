#!/bin/bash

# Direcciones de contrato actualizadas
BUSD_CONTRACT="0x305735A771372C1845c8a4fa31fb58699d2b7cd4"
CCNFT_CONTRACT="0x745847a89C8b755846e6d1ecbABDCCDac89ecc46"
TU_PRIVATE_KEY="0x865a5b2e0780ce93fe01fa5a81859915decf00fdd69d16080e00a7a4c4829d83"
RPC_URL="https://sepolia.gateway.tenderly.co"

# Variables para compra
VALUE_BUSD=1000
AMOUNT=1
VALUE_WEI="${VALUE_BUSD}000000000000000000"
FEE_WEI="25000000000000000000"  # 2.5% de 1000 BUSD = 25 BUSD
TOTAL_WEI=$(($VALUE_BUSD + 25))000000000000000000

echo "Comprando $AMOUNT NFT de $VALUE_BUSD BUSD cada uno (Total: $TOTAL_WEI wei)"

# Primero aprobar el gasto
echo "Aprobando gasto de BUSD..."
cast send $BUSD_CONTRACT "approve(address,uint256)" $CCNFT_CONTRACT $TOTAL_WEI --private-key $TU_PRIVATE_KEY --rpc-url $RPC_URL

# Luego comprar el NFT
echo "Comprando NFT..."
cast send $CCNFT_CONTRACT "buy(uint256,uint256)" $VALUE_WEI $AMOUNT --private-key $TU_PRIVATE_KEY --rpc-url $RPC_URL
