// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/BUSD.sol";
import "../src/CCNFT.sol";

contract Deploy is Script {
    
    function run() external {
        // Start broadcasting transactions
        vm.startBroadcast();

        // 1. Deploy BUSD token first
        BUSD busd = new BUSD();
        console.log("BUSD deployed at:", address(busd));

        // 2. Deploy CCNFT contract
        CCNFT ccnft = new CCNFT();
        console.log("CCNFT deployed at:", address(ccnft));

        // 3. Configure CCNFT to use BUSD as payment token
        ccnft.setFundsToken(address(busd));
        console.log("CCNFT configured to accept BUSD payments");

        // 4. Set the deployer as funds and fees collector
        ccnft.setFundsCollector(msg.sender);
        ccnft.setFeesCollector(msg.sender);
        console.log("Deployer set as funds and fees collector");

        // 5. Add some valid values for NFTs (example: 100, 500, 1000 BUSD)
        ccnft.addValidValues(100 * 10**18);     // 100 BUSD
        ccnft.addValidValues(500 * 10**18);     // 500 BUSD  
        ccnft.addValidValues(1000 * 10**18);    // 1000 BUSD
        console.log("Valid NFT values added: 100, 500, 1000 BUSD");

        // 6. Enable buying
        ccnft.setCanBuy(true);
        console.log("NFT buying enabled");

        // 7. Enable trading
        ccnft.setCanTrade(true);
        console.log("NFT trading enabled");

        // 8. Enable claiming
        ccnft.setCanClaim(true);
        console.log("NFT claiming enabled");

        // 9. Set trading fee (2.5% = 250 basis points)
        ccnft.setTradeFee(250);
        console.log("Trading fee set to 2.5%");

        // 10. Set profit to pay (10% = 1000 basis points)
        ccnft.setProfitToPay(1000);
        console.log("Profit to pay set to 10%");

        // 11. Approve CCNFT contract to transfer BUSD for claims
        busd.approve(address(ccnft), 100000000 * 10**18);  // 100M BUSD allowance
        console.log("Owner approved CCNFT to transfer BUSD for claims");

        vm.stopBroadcast();

        console.log("========================================");
        console.log("DEPLOYMENT SUMMARY:");
        console.log("BUSD Token:", address(busd));
        console.log("CCNFT Contract:", address(ccnft));
        console.log("Trading Functions: ENABLED");
        console.log("Claims: READY TO USE");
        console.log("========================================");
    }
}
