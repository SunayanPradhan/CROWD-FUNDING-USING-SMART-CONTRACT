//SPDX-License-Identifier: GPL-3.0
pragma solidity >= 0.5.0 <0.9.0;

contract CrowdFunding{

mapping(address=>uint) public contributors;
address public manager;
uint public minimunContribution;
uint public deadLine;
uint public target;
uint public raisedAmount;
uint public noOfContributers;

struct Request{
    string description;
    address payable recipient;
    uint value;
    bool completed;
    uint noOfVoters;
    mapping(address=>bool) voters;
}

mapping(uint=>Request) public requests;

uint public numRequests;



constructor(uint _target,uint _deadLineInSeconds,uint min_value){

target = _target;
deadLine=block.timestamp+_deadLineInSeconds;
minimunContribution= min_value+0 ether;
manager= msg.sender;
}

function sendEather() public payable{

require(block.timestamp<deadLine,"DeadLine Passed");
require(msg.value>=minimunContribution,"Ammount is less than minimum contribution");

if(contributors[msg.sender]==0){
    noOfContributers++;
}
contributors[msg.sender]+=msg.value;
raisedAmount+=msg.value;

}

function getContractBalance() public view returns(uint){
    return address(this).balance;
}

function refund() public {

    require(raisedAmount<target && deadLine<block.timestamp,"You are not eligible for refund");
    require(contributors[msg.sender]>0,"You have not donated any amount");

    address payable user=payable(msg.sender);
    user.transfer(contributors[msg.sender]);

    contributors[msg.sender]=0;

}

modifier onlyManager(){
    require(msg.sender==manager,"Only Manager can access this");
    _;
}

 function createRequests(string memory _description,address payable _recipient,uint _value) public onlyManager{
     Request storage newRequest= requests[numRequests];
     numRequests++;
     newRequest.description=_description;
     newRequest.recipient=_recipient;
     newRequest.value=_value;
     newRequest.completed=false;
     newRequest.noOfVoters=0;

 }

 function voteRequest(uint _requestNo) public{
     require(contributors[msg.sender]>0,"You are not a contributer");
     Request storage thisRequest=requests[_requestNo];
     require(thisRequest.voters[msg.sender]=false,"Already Voted by this Acount");
     thisRequest.voters[msg.sender]= true;
     thisRequest.noOfVoters++;

 }

 function makePayment(uint _requestNo) public onlyManager
 {
     require(raisedAmount>=target);
     Request storage thisRequest=requests[_requestNo];
     require(thisRequest.completed==false,"The request has been completed");
     require(thisRequest.noOfVoters>noOfContributers/2,"Majority does not support");
     thisRequest.recipient.transfer(thisRequest.value);
     thisRequest.completed=true;
 }


}