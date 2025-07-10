#!/bin/bash

# Direcciones de contrato actualizadas
CCNFT_CONTRACT="0x745847a89C8b755846e6d1ecbABDCCDac89ecc46"
BUSD_CONTRACT="0x305735A771372C1845c8a4fa31fb58699d2b7cd4"
TU_PRIVATE_KEY="0x744f79d180e9c2bd90c0908724c6c053226f4896a815752bcd5375c97de404e9"
RPC_URL="https://sepolia.gateway.tenderly.co"

# Variables para facilitar modificaciones
TOKEN_ID=1
PRICE_BUSD=1200
PRICE_WEI="${PRICE_BUSD}000000000000000000"

echo "Poniendo en venta NFT #$TOKEN_ID por $PRICE_BUSD BUSD ($PRICE_WEI wei)"

cast send $CCNFT_CONTRACT "putOnSale(uint256,uint256)" $TOKEN_ID $PRICE_WEI --private-key $TU_PRIVATE_KEY --rpc-url $RPC_URL
