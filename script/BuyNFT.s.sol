// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/CCNFT.sol";
import "../src/BUSD.sol";

contract BuyNFT is Script {
    
    function run() external {
        // Cargar clave privada de cuenta 2
        uint256 account2PrivateKey = vm.envUint("PRIVATE_KEY_ACCOUNT2");
        address account2 = 0xAf992234bd8606B459eEB57f4Eb01Da8D845cB84; // Dirección correcta de cuenta 2
        
        // Direcciones de los contratos en Sepolia
        address busdAddress = 0x2007185B366b1d8b7d4D79F770bA6D6a3D760583;
        address nftAddress = 0x0f087BE77a6Be9bCC202d4689Fb3f82823A68A24;
        
        console.log("=== CUENTA 2 COMPRANDO NFT ===");
        console.log("Buyer:", account2);
        
        // Conectar a los contratos
        BUSD busd = BUSD(busdAddress);
        CCNFT nft = CCNFT(nftAddress);
        
        // Balance inicial
        console.log("BUSD inicial:", busd.balanceOf(account2) / 10**18);
        console.log("NFTs iniciales:", nft.balanceOf(account2));
        
        vm.startBroadcast(account2PrivateKey);
        
        // Configuración de compra - 1 NFT de 1000 BUSD
        uint256 nftValue = 1000 * 10**18;
        uint256 totalCost = nftValue + (nftValue * 250 / 10000); // NFT + 2.5% fee
        
        console.log("Costo total:", totalCost / 10**18, "BUSD");
        
        // 1. Aprobar gasto
        busd.approve(nftAddress, totalCost);
        console.log("BUSD aprobado");
        
        // 2. Comprar NFT
        nft.buy(nftValue, 1);
        console.log("NFT comprado!");
        
        vm.stopBroadcast();
        
        // Verificar resultado
        console.log("BUSD final:", busd.balanceOf(account2) / 10**18);
        console.log("NFTs finales:", nft.balanceOf(account2));
        console.log("[SUCCESS] Compra completada!");
    }
} 