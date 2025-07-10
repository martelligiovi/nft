// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/CCNFT.sol";
import "../src/BUSD.sol";

contract DeployReal is Script {
    
    function run() external {
        // Cargar clave privada de cuenta 1 (deployer)
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_ACCOUNT1");
        address deployer = vm.addr(deployerPrivateKey);
        
        // Direcciones de configuración
        address account2 = vm.envAddress("FUNDS_COLLECTOR"); // Tu cuenta 2
        address feesCollector = vm.envAddress("FEES_COLLECTOR"); // Tu cuenta 2
        
        console.log("=== DEPLOYING TO SEPOLIA ===");
        console.log("Deployer (Account 1):", deployer);
        console.log("Account 2 (Buyer):", account2);
        console.log("Funds Collector:", account2);
        console.log("Fees Collector:", feesCollector);
        
        vm.startBroadcast(deployerPrivateKey);
        
        // 1. Deploy BUSD
        console.log("\n1. Deploying BUSD...");
        BUSD busd = new BUSD();
        console.log("BUSD deployed at:", address(busd));
        
        // 2. Deploy CCNFT
        console.log("\n2. Deploying CCNFT...");
        CCNFT nft = new CCNFT();
        console.log("CCNFT deployed at:", address(nft));
        
        // 3. Configurar CCNFT
        console.log("\n3. Configuring CCNFT...");
        nft.setFundsToken(address(busd));
        nft.setFundsCollector(account2);
        nft.setFeesCollector(feesCollector);
        nft.setCanBuy(true);
        nft.setCanTrade(true);
        nft.setCanClaim(true);
        
        // Configurar valores válidos para NFTs
        uint256 nftValue1 = 1000 * 10**18;  // 1000 BUSD
        uint256 nftValue2 = 2000 * 10**18;  // 2000 BUSD
        uint256 nftValue3 = 5000 * 10**18;  // 5000 BUSD
        
        nft.addValidValues(nftValue1);
        nft.addValidValues(nftValue2);
        nft.addValidValues(nftValue3);
        
        // Configurar fees
        nft.setBuyFee(250);    // 2.5%
        nft.setTradeFee(300);  // 3%
        nft.setProfitToPay(750); // 7.5% ganancia en claim
        
        // Configurar límites
        nft.setMaxBatchCount(10);
        nft.setMaxValueToRaise(1000000 * 10**18); // 1M BUSD
        
        console.log("CCNFT configured successfully");
        
        // 4. Transferir BUSD a cuenta 2 para que pueda comprar
        console.log("\n4. Transferring BUSD to Account 2...");
        uint256 busdAmount = 50000 * 10**18; // 50,000 BUSD
        busd.transfer(account2, busdAmount);
        console.log("Transferred", busdAmount / 10**18, "BUSD to Account 2");
        
        // 5. Preparar fondos para claims (fundsCollector necesita BUSD)
        console.log("\n5. Preparing funds for claims...");
        uint256 claimFunds = 100000 * 10**18; // 100,000 BUSD para claims
        // Como account2 es fundsCollector, no necesitamos transferir más
        
        // 6. Aprobar al contrato NFT para manejar BUSD del fundsCollector
        console.log("\n6. Setting up approvals...");
        // Esto se debe hacer desde la cuenta 2 posteriormente
        
        vm.stopBroadcast();
        
        console.log("\n=== DEPLOYMENT COMPLETE ===");
        console.log("BUSD Address:", address(busd));
        console.log("CCNFT Address:", address(nft));
        console.log("Account 2 BUSD Balance:", busd.balanceOf(account2) / 10**18, "BUSD");
        
        console.log("\n=== NEXT STEPS ===");
        console.log("1. Account 2 needs to approve CCNFT to spend BUSD:");
        console.log("   busd.approve(", address(nft), ", amount)");
        console.log("2. Account 2 can buy NFTs:");
        console.log("   nft.buy(1000e18, 1) // Buy 1 NFT of 1000 BUSD");
        console.log("3. Valid NFT values: 1000, 2000, 5000 BUSD");
        
        // Guardar direcciones en archivo
        vm.writeFile(
            "deployed-addresses.txt",
            string.concat(
                "BUSD=", vm.toString(address(busd)), "\n",
                "CCNFT=", vm.toString(address(nft)), "\n",
                "ACCOUNT2=", vm.toString(account2), "\n"
            )
        );
        
        console.log("\nAddresses saved to deployed-addresses.txt");
    }
} 