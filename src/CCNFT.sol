// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol"; 

contract CCNFT is ERC721Enumerable, Ownable, ReentrancyGuard {

//EVENTOS
// indexed: Permiten realizar búsquedas en los registros de eventos.

// Compra NFTs
    event Buy(address indexed buyer, uint256 indexed tokenId, uint256 value); 

    using Counters for Counters.Counter; 

    // State variables
    Counters.Counter private tokenIdTracker;
    mapping(uint256 => uint256) public values;
    mapping(uint256 => bool) public validValues;

    address public fundsCollector;
    address public feesCollector;
    bool public canBuy;//false
    uint256 public totalValue;
    uint256 public maxValueToRaise;//1M BUSD
    uint16 public buyFee;//2.5%
    uint16 public maxBatchCount;//10
    IERC20 public fundsToken;

    constructor() ERC721("CCNFT", "CCNFT") {
        tokenIdTracker.increment(); // Start from token ID 1
        canBuy = false;
        maxBatchCount = 10;
        buyFee = 250; // 2.5%
        maxValueToRaise = 1000000 * 10 ** 18; // 1M BUSD
    }

    // Buy function
    function buy(uint256 value, uint256 amount) external nonReentrant {
        require(canBuy, "Buy is not enabled");
        require(amount > 0 && amount <= maxBatchCount, "Invalid amount to buy");
        require(validValues[value], "Invalid value for NFT");
        require(totalValue + (value * amount) <= maxValueToRaise, "Max value to raise exceeded");

        totalValue += value * amount;

        for (uint256 i = 0; i < amount; i++) {
            uint256 currentTokenId = tokenIdTracker.current();
            values[currentTokenId] = value;
            _safeMint(_msgSender(), currentTokenId);
            emit Buy(_msgSender(), currentTokenId, value);
            tokenIdTracker.increment();
        }

        // Transfer funds to collector
        require(
            fundsToken.transferFrom(_msgSender(), fundsCollector, value * amount),
            "Cannot send funds tokens"
        );

        // Transfer fees to collector
        uint256 feeAmount = (value * amount * buyFee) / 10000;
        if (feeAmount > 0) {
            require(
                fundsToken.transferFrom(_msgSender(), feesCollector, feeAmount),
                "Cannot send fees tokens"
            );
        }
    }

    // Setter functions (only owner)
    function setFundsToken(address token) external onlyOwner {
        require(token != address(0), "Invalid token address");
        fundsToken = IERC20(token);
    }

    function setFundsCollector(address _address) external onlyOwner {
        require(_address != address(0), "Invalid address");
        fundsCollector = _address;
    }

    function setFeesCollector(address _address) external onlyOwner {
        require(_address != address(0), "Invalid address");
        feesCollector = _address;
    }

    function setCanBuy(bool _canBuy) external onlyOwner {
        canBuy = _canBuy;
    }

    function setMaxValueToRaise(uint256 _maxValueToRaise) external onlyOwner {
        maxValueToRaise = _maxValueToRaise;
    }
    
    function addValidValues(uint256 value) external onlyOwner {
        validValues[value] = true;
    }

    function setMaxBatchCount(uint16 _maxBatchCount) external onlyOwner {
        maxBatchCount = _maxBatchCount;
    }

    function setBuyFee(uint16 _buyFee) external onlyOwner {
        buyFee = _buyFee;
    }

    // desabilita la transf, las 3 sig
    function transferFrom(address, address, uint256) 
        public 
        pure
        override(ERC721, IERC721) 
    {
        revert("Not Allowed");
    }

    function safeTransferFrom(address, address, uint256) 
        public 
        pure 
        override(ERC721, IERC721) 
    {
        revert("Not Allowed");
    }

    function safeTransferFrom(address, address, uint256, bytes memory) 
        public 
        pure
        override(ERC721, IERC721) 
    {
        revert("Not Allowed");
    }

    // Required override
    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal 
        override(ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }
}
