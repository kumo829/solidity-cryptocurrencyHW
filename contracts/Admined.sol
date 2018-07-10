pragma solidity 0.4.24;

contract Admined{
    address public admin;

    constructor() public{
        admin = msg.sender;
    }

    modifier onlyAdmin(){
        require(admin == msg.sender, "admin required");
        _;
    }

    function transgerAdminship(address newAdmin) public  onlyAdmin{
        admin = newAdmin;
    }
}