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

// Reclamamo NFTs.
    event Claim(address indexed claimer, uint256 indexed tokenId);

// Transferencia de NFT de un usuario a otro.
    event Trade(address indexed buyer, address indexed seller, uint256 indexed tokenId, uint256 value);

// Venta de un NFT.
    event PutOnSale(uint256 indexed tokenId, uint256 price); 

    using Counters for Counters.Counter; 

    // Estructura del estado de venta de un NFT.
    struct TokenSale {
        bool onSale;    // Indicamos si el NFT está en venta.
        uint256 price;  // Indicamos el precio del NFT si está en venta.
    }

    // State variables
    Counters.Counter private tokenIdTracker;
    mapping(uint256 => uint256) public values;
    mapping(uint256 => bool) public validValues;
    mapping(uint256 => TokenSale) public tokensOnSale;
    uint256[] public listTokensOnSale;

    address public fundsCollector;
    address public feesCollector;
    bool public canBuy;//false
    bool public canClaim;
    bool public canTrade;
    uint256 public totalValue;
    uint256 public maxValueToRaise;//1M BUSD
    uint16 public buyFee;//2.5%
    uint16 public tradeFee;
    uint16 public maxBatchCount;//10
    uint32 public profitToPay;
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

    function setProfitToPay(uint32 _profitToPay) external onlyOwner {
        profitToPay = _profitToPay;
    }

    function setCanClaim(bool _canClaim) external onlyOwner {
        canClaim = _canClaim;
    }

    function setCanTrade(bool _canTrade) external onlyOwner {
        canTrade = _canTrade;
    }

    function setTradeFee(uint16 _tradeFee) external onlyOwner {
        tradeFee = _tradeFee;
    }

    // Función para poner en venta un NFT.
    function putOnSale(uint256 tokenId, uint256 price) external {
        require(canTrade, "Trading no esta permitido");
        require(_exists(tokenId), "Token no existe");
        require(ownerOf(tokenId) == _msgSender(), "Solo el owner puede vender");
        require(price > 0, "Precio debe ser mayor a 0");

        TokenSale storage tokenSale = tokensOnSale[tokenId];
        tokenSale.onSale = true;
        tokenSale.price = price;

        addToArray(listTokensOnSale, tokenId);
        
        emit PutOnSale(tokenId, price);
    }

    // Función para ver todos los tokens en venta
    function getTokensOnSale() external view returns (uint256[] memory) {
        return listTokensOnSale;
    }

    // ARRAYS - Funciones auxiliares para manejo de arrays

    // Verificar duplicados en el array antes de agregar un nuevo valor.
    function addToArray(uint256[] storage list, uint256 value) private {
        uint256 index = find(list, value);
        if (index == list.length) {
            list.push(value);
        }
    }

    // Eliminar un valor del array.
    function removeFromArray(uint256[] storage list, uint256 value) private {
        uint256 index = find(list, value);
        if (index < list.length) {
            list[index] = list[list.length - 1];
            list.pop();
        }
    }

    // Buscar un valor en un array y retornar su índice o la longitud del array si no se encuentra.
    function find(uint256[] storage list, uint256 value) private view returns(uint256) {
        for (uint256 i = 0; i < list.length; i++) {
            if (list[i] == value) {
                return i;
            }
        }
        return list.length;
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
