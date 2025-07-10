#!/bin/bash

# Direcciones de contrato actualizadas
CCNFT_CONTRACT="0x745847a89C8b755846e6d1ecbABDCCDac89ecc46"
TU_PRIVATE_KEY="0x865a5b2e0780ce93fe01fa5a81859915decf00fdd69d16080e00a7a4c4829d83"
RPC_URL="https://sepolia.gateway.tenderly.co"

# Variables para el claim
TOKEN_ID=2

echo "Reclamando NFT #$TOKEN_ID (1000 BUSD + 10% ganancia = 1100 BUSD)"

cast send $CCNFT_CONTRACT "claim(uint256[])" [$TOKEN_ID] --private-key $TU_PRIVATE_KEY --rpc-url $RPC_URL 