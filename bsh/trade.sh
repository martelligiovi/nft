#!/bin/bash

# Direcciones de contrato actualizadas
CCNFT_CONTRACT="0x745847a89C8b755846e6d1ecbABDCCDac89ecc46"
BUSD_CONTRACT="0x305735A771372C1845c8a4fa31fb58699d2b7cd4"
TU_PRIVATE_KEY="0x865a5b2e0780ce93fe01fa5a81859915decf00fdd69d16080e00a7a4c4829d83"
RPC_URL="https://sepolia.gateway.tenderly.co"

# Variables para el trade
TOKEN_ID=1
PRICE_BUSD=1200  # Precio que el vendedor puso
FEE_BUSD=30      # 2.5% de 1200 = 30 BUSD
TOTAL_BUSD=$((PRICE_BUSD + FEE_BUSD))

PRICE_WEI="${PRICE_BUSD}000000000000000000"
FEE_WEI="${FEE_BUSD}000000000000000000"
TOTAL_WEI="${TOTAL_BUSD}000000000000000000"

echo "Comprando NFT #$TOKEN_ID por $PRICE_BUSD BUSD + $FEE_BUSD BUSD fee = $TOTAL_BUSD BUSD total"
echo "Precio: $PRICE_WEI wei"
echo "Fee: $FEE_WEI wei" 
echo "Total: $TOTAL_WEI wei"

# Primero verificar que el NFT esté en venta
echo "Verificando que el NFT #$TOKEN_ID esté en venta..."
SALE_INFO=$(cast call $CCNFT_CONTRACT "tokensOnSale(uint256)" $TOKEN_ID --rpc-url $RPC_URL)
echo "Info de venta: $SALE_INFO"

# Aprobar el gasto total (precio + fee)
echo "Aprobando gasto de $TOTAL_BUSD BUSD..."
cast send $BUSD_CONTRACT "approve(address,uint256)" $CCNFT_CONTRACT $TOTAL_WEI --private-key $TU_PRIVATE_KEY --rpc-url $RPC_URL

# Ejecutar el trade
echo "Ejecutando trade del NFT #$TOKEN_ID..."
cast send $CCNFT_CONTRACT "trade(uint256)" $TOKEN_ID --private-key $TU_PRIVATE_KEY --rpc-url $RPC_URL 