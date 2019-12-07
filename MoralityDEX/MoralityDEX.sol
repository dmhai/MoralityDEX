pragma solidity ^0.5.11;

contract IERC20 {
  uint256 public totalSupply;
  function balanceOf(address _owner) public view returns (uint256 balance);
  function transfer(address _to, uint256 _value) public returns (bool success);
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
  function approve(address _spender, uint256 _value) public returns (bool success);
  function allowance(address _owner, address _spender) public view returns (uint256 remaining);
  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

library SafeMath {  
  function mul(uint256 a, uint256 b) internal pure returns (uint256){
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b > 0);
    uint256 c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }  
}

library SafeERC20 {
    using SafeMath for uint256;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        require(token.transfer(to, value), "Token transfer failed");
    }  
}

contract Converter {
    function strConcat(string memory _a, string memory _b, string memory _c, string memory _d, string memory _e) internal pure returns (string memory){
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        bytes memory _bc = bytes(_c);
        bytes memory _bd = bytes(_d);
        bytes memory _be = bytes(_e);
        string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
        bytes memory babcde = bytes(abcde);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
        for (uint i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
        for (uint i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];
        for (uint i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];
        for (uint i = 0; i < _be.length; i++) babcde[k++] = _be[i];
        return string(babcde);
    }
   
    function strConcat(string memory _a, string memory _b, string memory _c, string memory _d) internal pure returns (string memory) {
        return strConcat(_a, _b, _c, _d, "");
    }
   
    function strConcat(string memory _a, string memory _b, string memory _c) internal pure returns (string memory) {
        return strConcat(_a, _b, _c, "", "");
    }
   
    function strConcat(string memory _a, string memory _b) internal pure returns (string memory) {
        return strConcat(_a, _b, "", "", "");
    }
   
    function toAsciiString(address x) internal pure returns (string memory) {
        bytes memory s = new bytes(40);
        for (uint i = 0; i < 20; i++) {
            byte b = byte(uint8(uint(x) / (2**(8*(19 - i)))));
            byte hi = byte(uint8(b) / 16);
            byte lo = byte(uint8(b) - 16 * uint8(hi));
            s[2*i] = char(hi);
            s[2*i+1] = char(lo);            
        }
        return string(s);
    }
   
    function char(byte b) internal pure returns (byte c) {
        if (uint8(b) < 10) return byte(uint8(b) + 0x30);
        else return byte(uint8(b) + 0x57);
    }
   
    function toString(uint _base)
        internal
        pure
        returns (string memory) {
        bytes memory _tmp = new bytes(32);
        uint i;
        for(i = 0;_base > 0;i++) {
            _tmp[i] = byte(uint8((_base % 10) + 48));
            _base /= 10;
        }
        bytes memory _real = new bytes(i--);
        for(uint j = 0; j < _real.length; j++) {
            _real[j] = _tmp[i--];
        }
        return string(_real);
    }
}

contract ReentrancyGuard {  
   bool private rentrancy_lock = false;

   modifier nonReentrant() {
     require(!rentrancy_lock, "Lock not available");
     rentrancy_lock = true;
     _;
     rentrancy_lock = false;
   }
}

contract Ownable {  
  address payable public owner;
  address payable public potentialNewOwner;
 
  event OwnershipTransferred(address payable indexed _from, address payable indexed _to);

  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner, "Only owner can use this function");
    _;
  }

  function transferOwnership(address payable _newOwner) external onlyOwner {
    potentialNewOwner = _newOwner;
  }
 
  function acceptOwnership() external {
    require(msg.sender == potentialNewOwner, "You are not the potential new owner");
    emit OwnershipTransferred(owner, potentialNewOwner);
    owner = potentialNewOwner;
  }
}

contract Breaker is Ownable {
    bool public inLockdown;

    constructor () internal {
        inLockdown = false;
    }

    modifier outOfLockdown() {
        require(inLockdown == false);
        _;
    }
   
    function updateLockdownState(bool state) external onlyOwner{
        inLockdown = state;
    }
}

contract MoralityDEX is Breaker, ReentrancyGuard, Converter {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
   
    // The token - the contract can have many
    struct Token {
        // How many tokens per eth
        uint rate;
        // The token contracts address
        address tokenAddress;
        // The date that the token was added
        uint dateAdded;
        // Flag to see if token exists - set to true on creation
        bool exists;
    }
   
    struct Trade{
        // The owner of the trade (token sender)
        address payable owner;
        // Unique id of the trade
        uint256 id;
        // The total amount of tokens sent with the trade
        uint amount;
        // The tokens symbol (FK) that the trade is for
        string symbol;
        // The date the trade is added
        uint dateAdded;
        // If the trade is valid - for searching purposes
        bool valid;
        // If the trade has been used in a part buy, this number will differ from the "amount" - if not equals it
        uint256 amountLeftToSell;
        // Flag for if the trade is involved in a part buy or not
        bool isBeingUsedInPartBuy;
        // Lock so no 2 FIFO requests can use the same trade
        bool isBeingUsed;
    }
   
    // The open trades mapped by trade
    mapping(string => Trade[]) private _openTrades;
    // List of held tokens mapped by symbol
    mapping(string => uint) private _heldTokens;
    // This is used as a hacky way of getting new dynamic arrays by passing a unique id
    mapping(uint => uint[]) private _tradeLocations; 
   
    // Tokens mapped by symbol 
    mapping(string => Token) private _tokens;
    // The owners wallet (used for withdraw) - if any erroneous eth is sent to contract
    address payable private _exchangeWallet;
    uint _minimumEthPerTrade = 0;
    
    // Id counter for getting the dynamic arrays
    uint private tradeLocationIdCount = 1;
    // Id counter for the new trades
    uint private tradeIdCount = 1;

    // Event fired when a token is added Morality DEX
    event AddedToken(address token, uint256 rate);
    // Event fired when trade is added to open trades
    event AddTrade(address sender, uint256 id, uint256 amount, string symbol, uint256 dateAdded);
    // Event fired when a trade has been part bought
    event PartBuy(address sender, uint amount, uint256 tradeId, string symbol);

    // To create the contract we need an admin address
    constructor (address payable exchangeWallet, uint minimumEthPerTrade) public {
        require(exchangeWallet != address(0), "Cannot use address 0x");
        _exchangeWallet = exchangeWallet;
        _minimumEthPerTrade = minimumEthPerTrade;
    }
    
    // Gets the minimum eth per trade
    function getMinimumEthPerTrade() external view returns(uint){
         return _minimumEthPerTrade;
    }
    
    // Enables admin to change the minimum trade value in eth (stops lots of little trades)
    function setMinimumEthPerTrade(uint minimumEthPerTrade) external onlyOwner{
        _minimumEthPerTrade = minimumEthPerTrade;
    }
    
    // Returns a token as a json string if it exists
    function getToken(string calldata symbol) external view returns (string memory) {
        // Get the token from the list and require it to exist
        Token memory token = _tokens[symbol];
        require(token.exists = true, "Not matching token was found");
        // Build the json response
        return _buildTokenResponse(token.tokenAddress, token.rate);
    }
    
    // Gets how many tokens are held by Morality DEX (if it exists)
    function getAmountOfTokensHeldByContract(string calldata symbol) external view returns(uint){
        // Get the token and require it to exist
        Token memory token = _tokens[symbol];
        require(token.exists = true, "Not matching token was found");
        // Return the token count (if any)
        return _heldTokens[symbol];
    }
    
    // This is to add a new or update an existing token rate or address
    function addOrUpdateToken(string calldata symbol, uint256 rate, address tokenAddress) external onlyOwner {
        require(tokenAddress != address(0), "Cannot use address 0x");
        require(rate > 0, "Rate must be greater than 0");
        // Create token
        Token memory token = Token(rate, tokenAddress, now, true);
        // Set in place in map
        _tokens[symbol] = token;
    }

    // Get the DEXs external wallet
    function getExchangeWallet() external onlyOwner view returns (address) {
        return _exchangeWallet;
    }
   
    // Set a new wallet address
    function setExchangeWallet(address payable newWallet) external onlyOwner {
        require(newWallet != address(0), "Cannot use address 0x");
       _exchangeWallet = newWallet;
    }
   
    // Add a new trade to open trades
    function addTrade(string calldata symbol, uint amount) external nonReentrant outOfLockdown returns (uint256 id){
        // Check we are actually getting tokens
        require(amount > 0, "Amount to add to trader must be greater than 0");
        // Retrieve the token
        Token memory token = _tokens[symbol];
        require(token.exists == true, "No matching token was found");
        // Check trade is bigger than our minimum
        require(getMinimumTradeTokenValue(symbol) <= amount);
        // Take payment (must be approved first)
        require(IERC20(token.tokenAddress).transferFrom(msg.sender, address(this), amount) == true, "Token transfer to Morality DEX failed");
        // Add new trade
        Trade memory trade = Trade(msg.sender, id = tradeIdCount++, amount, symbol, now, true, amount, true, false);
        _openTrades[symbol].push(trade);
        // Add the event
        emit AddTrade(msg.sender, id, amount, symbol, now);
        // Add to total held in contract
        _heldTokens[symbol] += amount;
        // Return the unique id
        return id;
    }
   
    // Gets an open trade index for a specified id
    function _getOpenTradeIndexById(string memory symbol, uint id) public view returns(uint){
        for(uint i=0;i<_openTrades[symbol].length;i++){
            // If we match an id - return it (we don't need to continue looping)
            if(_openTrades[symbol][i].id == id){
                return i;
            }
        }
        // If we don't get the index, we revert (otherwise a potentially false index - 0 gets returned)
        require(false);
    }
   
    // Gets an open trade json string for a specified id
    function getOpenTradeByIdResult(string memory symbol, uint id) public view returns(string memory result){
         result = '{trades:[';
         uint index = _getOpenTradeIndexById(symbol, id);
         return strConcat(_buildTrade(symbol, result, index), "]}");
    }
   
    // So admin can return funds
    function deleteTrade(string calldata symbol, uint256 id) external onlyOwner nonReentrant returns(bool){
        // Retrieve the token
        Token memory token = _tokens[symbol];
        require(token.exists == true, "No token matching that symbol exists");
        // Retrieve the trade
        uint index = _getOpenTradeIndexById(symbol, id);
        Trade memory trade = _openTrades[symbol][index];
        // Require it is owners trade
        require(trade.id == id, "Open trade does not exist");
        require(trade.valid == true, "Trade is not valid");
        require(trade.isBeingUsed == true, "Cannot delete, trade is being used");
        uint amountToSendBack = trade.amountLeftToSell;
        // Delete the trade
        delete _openTrades[symbol][index];
        // Send it back to the owner
        require(IERC20(token.tokenAddress).transfer(msg.sender, amountToSendBack));
        return true;
    }
   
    // Get a page of open trades for a specified token symbol - max 30 per page
    function getTrades(string calldata symbol, uint256 pageNum, uint256 perPage) external view returns (string memory){
        // Check for max per page
        require(perPage <= 30, "30 is the max page size");
        string memory page = '{ "trades":[';
        require(pageNum > 0, "Page number starts from 1");
        // Create indexes
        uint256 startIndex = pageNum.sub(1);
        uint256 phantomEndIndex = startIndex.add(perPage);
        uint256 endIndex = 0;
        // Find the end of the array
        if(phantomEndIndex > _openTrades[symbol].length){ endIndex = _openTrades[symbol].length; }
        else{ endIndex = phantomEndIndex; }
        // Build the page (json)
        for(uint256 i=startIndex; i<endIndex;i++){
            // Check for deleted row
            if(_openTrades[symbol][i].valid){
                page = _buildTrade(symbol, page, i);
            }
            // If not add to index (if possible)
            else { if((endIndex + 1) < _openTrades[symbol].length) { endIndex++; }}
        }
        page = strConcat(page, "]},");
        return page;
    }
    
    // This allows users to purchase tokens (if the open trades are available) FIFO 
    function purchaseCurrencyFIFO(string calldata symbol) payable external nonReentrant outOfLockdown returns(bool){
        // Validate amount sent
        require(msg.value > 0, "Value sent must be greater than 0");
        // Retrieve the token
        Token memory token = _tokens[symbol];
        require(token.exists == true, "Token doesn't exist");
        // Retrieve trades that equal amount
        uint requiredTokenCount = token.rate.mul(msg.value);
        uint[] memory indexs = _getTradesThatEqualOrAreGreaterThan(symbol, requiredTokenCount);
        // Make sure we met requirements
        require(indexs.length > 0, "Cannot make a trade with 0 open trades");
        // Make the trades
        _makeTrades(symbol, requiredTokenCount, token.tokenAddress, token.rate, indexs);
        // Remove from token amount
        _heldTokens[symbol] -= msg.value;
        // End of execution
        return true;
    }
    
    // Gets the minimum amount of tokens needed to open a trade
    function getMinimumTradeTokenValue(string memory symbol) public view returns(uint){
        Token memory token = _tokens[symbol];
        require(token.exists == true, "Token doesn't exist");
        return token.rate.mul(_minimumEthPerTrade);
    }
    
    // Allows us to withdraw eth from the contract if someone erroneously sends it
    function withdrawFunds(uint amount) onlyOwner external{
        _exchangeWallet.transfer(amount);
    }
    
    // Allows us to withdraw tokens from the contract if someone erroneously sends it
    function withdrawFunds(address tokenAddress, uint amount) onlyOwner external{
        require(IERC20(tokenAddress).transfer(msg.sender, amount));
    }

    // Allows admin to remove the contract from the network
    function deprecateContract() onlyOwner external{
        selfdestruct(owner);
    }
    
        // Takes trades to be used and marks them as being used if the requiredTokenCount can be matched - then returns the ids
    function _getTradesThatEqualOrAreGreaterThan(string memory symbol, uint requiredTokenCount) internal returns(uint[] memory){
        uint runningCount = 0;
        uint id = tradeLocationIdCount++;
        for(uint256 i=0; i<_openTrades[symbol].length;i++){
            Trade memory trade = _openTrades[symbol][i];
            // Check for deleted row (and rows with less than 0)
            if(trade.valid == true && trade.amountLeftToSell > 0 && trade.isBeingUsed == false){
                // Take it from general population
                trade.isBeingUsed = true;
                _openTrades[symbol][i] = trade;
                runningCount += trade.amountLeftToSell;
                // No matter what add the id
                _tradeLocations[id].push(i);
                // Check to see if we have reached the value we have come for
                if(runningCount >= requiredTokenCount){
                     i = _openTrades[symbol].length;   
                }
            }
        }
        // If we dont meet the requirements, revert taking the trades & throw
        require(runningCount >= requiredTokenCount, "Not enough tokens to meet requirement");
        return _tradeLocations[id];
    }
    
    // A helper method to build the json representation of a token
    function _buildTokenResponse(address tokenAddress, uint rate) internal pure returns(string memory response){
        response = strConcat('{"address":"', toAsciiString(tokenAddress) , '","rate":"', toString(rate) , '"}');
    }
   
    // This builds a single trade (json string)
    function _buildTrade(string memory symbol, string memory page, uint256 i) internal view returns (string memory){
        // Get trade and turn all non string values to strings
        Trade memory trade = _openTrades[symbol][i];
        string memory id = toString(trade.id);
        string memory amount = toString(trade.amount);
        string memory owner = toAsciiString(trade.owner);
        string memory amountLeftToSell = toString(trade.amountLeftToSell);
        string memory dateAdded = toString(trade.dateAdded);
        // Build up json string
        page = strConcat(page, '{');
        page = strConcat(page, '"id":"', id, '",');
        page = strConcat(page, '"owner":"', owner, '",');
        page = strConcat(page, '"amount":', amount, ',');
        page = strConcat(page, '"amountLeftToSell":', amountLeftToSell, ',');
        page = strConcat(page, '"symbol":"', trade.symbol, '",');
        page = strConcat(page, '"dateAdded":"', dateAdded, '"},');
        // Return the page
        return page;
    }
    
    // Make trades that equal amount requested - this means we can end up part buying from an open trade 
    function _makeTrades(string memory symbol,  uint requiredTokenCount, address tokenAddress, uint tokenRate, uint[] memory indexs) internal returns(bool){
        uint tokensPaid = 0;
        uint valueToSend = 0;
        for(uint i = 0; i<indexs.length;i++){
            Trade memory trade = _openTrades[symbol][indexs[i]];
            // Take what we need based on whats already been paid - we only take what is required
            if (tokensPaid.add(trade.amountLeftToSell) > requiredTokenCount)
            { valueToSend = requiredTokenCount.sub(tokensPaid); }
            else { valueToSend = trade.amountLeftToSell; }
            // Pay towards/ the whole open trade
            _tradeFunds(tokenAddress, msg.sender, trade.owner, valueToSend, valueToSend.div(tokenRate));
            // Update the trade state (remove or put back up for purchase  - the part left)
            _updateTradeState(symbol, indexs[i], valueToSend, trade.amountLeftToSell);
             tokensPaid += valueToSend; 
        }
        // Check everything has been paid (revert if not) - we shouldn't be this far if it wasn't paid
        require(tokensPaid == requiredTokenCount);
        // If we got here, the trade has been completed
        return true;
    }
    
    // Updates the trades state - either removes or puts up the amount not sold back up for purchase
    function _updateTradeState(string memory symbol, uint index, uint tokensTaken, uint amountLeftToSell) internal returns(bool){
        // If only part of trade was sold then update the trade as part sold
        if(tokensTaken < amountLeftToSell){
            //Release the lock, mark as part buy and remove the sold tokens 
            Trade memory existingTrade = _openTrades[symbol][index];
            existingTrade.isBeingUsed = false;
            existingTrade.isBeingUsedInPartBuy = true;
            existingTrade.amountLeftToSell -= tokensTaken;
            // Update
            _openTrades[symbol][index] = existingTrade;
        }
        // If the whole trade was sold then delete the trade
        else { delete _openTrades[symbol][index]; }
    }
   
   // This is used to transfer eth to the seller of a token and transfer the purchased tokens to the buyer
    function _tradeFunds(address tokenAddress, address tokenReciever, address payable moneyReciever, uint tokensToSend, uint moneyToSend) internal returns(bool){
        moneyReciever.transfer(moneyToSend);
        require(IERC20(tokenAddress).transfer(tokenReciever, tokensToSend));
        return true;
    }
}