pragma solidity 0.7.5;
pragma abicoder v2;

contract multiSigWallet{

    address[] public owners;
    uint reqApprovals;

    constructor(address[] memory _owners, uint _reqApprovals){
        uint i;
        owners.push(msg.sender);
        for(i = 0; i < _owners.length; i++){
            owners.push(_owners[0]);
        }
        reqApprovals =  _reqApprovals;
    }

    modifier onlyOwners{
        bool _onlyOwners = false;
        uint i;
        for(i = 0; i < owners.length; i++){
            if(msg.sender == owners[i]){
                _onlyOwners = true;
            }
        }
        require(_onlyOwners);
        _;
    }

    struct Transfer {
        address creator;
        address payable to;
        uint amount;
        uint approvals;
        uint transferID;
    }

    Transfer[] public transferRequests;

    mapping(address => mapping(uint => bool)) approvals;

    function deposit() public payable returns(uint){
        return(msg.value);
    }

    function getBalance() public view returns(uint){
     return(address(this).balance);
    }

    function requestTransfer(address payable _to, uint _amount) public onlyOwners {
        approvals[msg.sender][transferRequests.length] = true;
        transferRequests.push(Transfer(msg.sender, _to, _amount, 1, transferRequests.length));
    }

    function approveTransfer(uint _transferID) public onlyOwners {
        require(approvals[msg.sender][_transferID] == false);
        approvals[msg.sender][_transferID] = true;
        transferRequests[_transferID].approvals += 1;

        if(transferRequests[_transferID].approvals == reqApprovals){
            transferRequests[_transferID].to.transfer(transferRequests[_transferID].amount);
        }
    }
}
