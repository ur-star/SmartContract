//SPDX-License-Identifire: UNLICENSED
pragma solidity >=0.5.0<=0.8.7;

contract CrowdFunding{
    mapping(address=>uint) public contributors;
    address public manager;
    uint public minumumContri;
    uint public deadline;
    uint public target;
    uint public raisedAmount;
    uint public noOfContributors;
    
    struct Request{
        string reason;
        address payable recipient;
        uint value;
        bool completed;
        uint noOfVoters;
        mapping(address=>bool) voters;
    }
    mapping(uint=>Request) public requests;
    uint public numRequests;

    constructor(uint _target, uint _deadline){
        target = _target;
        deadline = block.timestamp+_deadline;
        minumumContri = 100 wei;
        manager = msg.sender;
    }

    function sendEth() public payable {
        require(block.timestamp<deadline,"deadline has passed");
        require(msg.value>=minumumContri,"Minimum amount not met");

        if (contributors[msg.sender]==0){
            noOfContributors++;
        }
        contributors[msg.sender]+= msg.value;
        raisedAmount += msg.value;
    }
    function getContractBalance() public view returns(uint){
        return address(this).balance;
    }
    function refund() public{
        require(block.timestamp>deadline && raisedAmount<target,"You are not eligible");
        require(contributors[msg.sender]>0);
        address payable user = payable(msg.sender);
        user.transfer(contributors[msg.sender]);
        contributors[msg.sender]=0;
    }
    modifier onlyManager(){
        require(msg.sender==manager,"Only manager can call this function");
        _;
    }
    function createRequests(string memory _reason, address payable _recipient,uint _value) public onlyManager{
               Request storage newRequest = requests[numRequests];
                newRequest.reason=_reason;
        newRequest.recipient=_recipient;
        newRequest.value=_value;
        newRequest.completed=false;
        newRequest.noOfVoters=0;

    }
     function voteRequest(uint _requestNo) public{
        require(contributors[msg.sender]>0,"YOu must be contributor");
        Request storage thisRequest=requests[_requestNo];
        require(thisRequest.voters[msg.sender]==false,"You have already voted");
        thisRequest.voters[msg.sender]=true;
        thisRequest.noOfVoters++;
    }
    function makePayment(uint _requestNo) public onlyManager{
        require(raisedAmount>=target);
        Request storage thisRequest=requests[_requestNo];
        require(thisRequest.completed==false,"The request has been completed");
        require(thisRequest.noOfVoters > noOfContributors/2,"Majority does not support");
        thisRequest.recipient.transfer(thisRequest.value);
        thisRequest.completed=true;
    }


}
