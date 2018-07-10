pragma solidity 0.4.24;

import "../contracts/BACoin.sol";
import "../contracts/Admined.sol";

contract AdminedBACoin is BACoin, Admined{

    uint256 public minimumBalanceForAccounts = 5 finney;
    uint256 public sellPrice;
    uint256 public buyPrice;
    mapping (address => bool) public frozenAccount;

    event FrozenFund(address target, bool frozen);

    constructor(uint256 initialSupply, string tokenName, string tokenSymbol, uint8 decimalUnits, 
    address centralAdmin) public BACoin(0, tokenName, tokenSymbol, decimalUnits){
        totalSupply = initialSupply;

        if(centralAdmin != 0){
            admin = centralAdmin;
        } else {
            admin = msg.sender;
        }

        balanceOf[admin] = initialSupply;
        totalSupply = initialSupply;
    }

    function mintToken(address target, uint256 mintedAmount) public onlyAdmin {
        balanceOf[target] += mintedAmount;
        totalSupply += mintedAmount;

        emit Transfer(0, this, mintedAmount);
        emit Transfer(this, target, mintedAmount); 
    }

    function freezeAccount(address target, bool freeze) public onlyAdmin{
        frozenAccount[target] = freeze;
        emit FrozenFund(target, freeze);
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success){
        require(!frozenAccount[_from], "Account is frozen");
        return transferFrom(_from, _to, _value);
    }

    function transfer(address _to, uint256 _value) public {
        require(!frozenAccount[msg.sender], "Account is frozen");
        if(msg.sender.balance < minimumBalanceForAccounts)
            sell((minimumBalanceForAccounts = msg.sender.balance) / sellPrice);
        transfer(_to, _value);
    }

    function setPrice(uint256 newSellPrice, uint256 newBuyPrice) public onlyAdmin {
        sellPrice = newSellPrice;
        buyPrice = newBuyPrice;
    }

    function buy() public payable {
        uint256 amount = (msg.value / (1 ether)) / buyPrice;

        require(balanceOf[this] >= amount, "Not enough balance");

        balanceOf[msg.sender] += amount;
        balanceOf[this] -= amount;
        emit Transfer(this, msg.sender, amount);
    }

    function sell(uint256 amount) public {
        require(balanceOf[msg.sender] >= amount);

        balanceOf[this] += amount;
        balanceOf[msg.sender] -= amount;

        msg.sender.transfer(amount * sellPrice * 1 ether);
        emit Transfer(msg.sender, this, amount);
    }
}