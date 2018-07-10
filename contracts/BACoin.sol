pragma solidity ^0.4.24;

contract BACoin {
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    string public standard = "BACoin V1.0";
    string public name;
    string public symbol;
    uint8 public decimal;
    uint256 public totalSupply;
    bytes32 public currentChallenge;
    uint public timeOfLastProof;
    uint public difficulty = 10**32;

    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor(uint256 initialSupply, string tokenName, string tokenSymbol, uint8 decimalUnits) public {
        balanceOf[msg.sender] = initialSupply;
        totalSupply = initialSupply;
        symbol = tokenSymbol;
        decimal = decimalUnits;
        name = tokenName;
    }

    function transfer (address _to, uint256 _value) public { 
        require(balanceOf[msg.sender] >= _value, "Not enought supply");
        require(balanceOf[_to] + _value >= balanceOf[_to],"Too much supply");

        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
    }

    function approve(address _spender, uint256 _value) public returns (bool success){
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success){
        require(balanceOf[_from] >= _value, "Not enught supply");
        require(balanceOf[_to] + _value >= balanceOf[_to],"Too much supply");
        require(_value <= allowance[_from][msg.sender]);

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _value);

        return true;
    }

    function giveBlockReward() public{
        balanceOf[block.coinbase] += 1;
    }

    function proofOfWork(uint nonce) public {
        bytes8 n = bytes8(keccak256(nonce));

        require(n >= bytes8(difficulty));

        uint timeOfLastBlock = (now - timeOfLastProof);

        require(timeOfLastBlock >= 5);

        balanceOf[msg.sender] += timeOfLastBlock / 60 seconds;
        difficulty = difficulty * 10 minutes / timeOfLastProof + 1;
        timeOfLastProof = now;

        currentChallenge = keccak256(nonce, currentChallenge, block.blockhash(block.number-1));
    }
}
