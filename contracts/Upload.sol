// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract Upload {

     struct Access {
         address user;
         bool access;  // true, or false
     }

     struct User{
        address add;
        uint256 id;
        uint256 lenOfData;
     }

     struct buyRequest{
         uint256 id;
         address user;
         uint256 dealAmount; 
         bool closed;  // true of false
     }

     User[] userArray;
     uint256 numUsers = 0;
     mapping (address => uint256) addressIdMapping;
     

     mapping(address => string[]) dataList;   // stores an array of ipfs urls uploaded by a particular address

     mapping(address => mapping(address=> bool)) ownershipData;
     mapping(address => Access[]) accessList;

     mapping(address => mapping(address=> bool)) previousPushedData;

     mapping(address => buyRequest[]) buyRequestList;


     // upload urls from an account 
     function add(address _user, string memory _url) external {
        if(dataList[_user].length == 0)
        {
            addressIdMapping[_user] = numUsers;
            dataList[_user].push(_url);
            userArray.push(User(_user,  numUsers,  1));

            numUsers++;
        }
        else 
        {
            dataList[_user].push(_url);
            userArray[addressIdMapping[_user]].lenOfData++;
        }

         
     }


     // 1) Owner's activity 
     // 1.1) give access
     function allow(address _user) public {
         require(ownershipData[msg.sender][_user] == false, "user is alredy allowed to access data");
         ownershipData[msg.sender][_user] = true;
         if(previousPushedData[msg.sender][_user])
         {
             for(uint i = 0; i < accessList[msg.sender].length; i++)
             {
                 if(accessList[msg.sender][i].user == _user)
                 {
                       accessList[msg.sender][i].access = true;
                       break;
                 }
             }
         }
         else
         {
                accessList[msg.sender].push(Access(_user, true));
                previousPushedData[msg.sender][_user] = true; // once pushed set the flag as true so as to avoid pushing next time
         }
     }

     // 1.2) revoke access 
     function disallow ( address _user) public {
         require(ownershipData[msg.sender][_user] == true, "user is alredy not allowed to access data");
         ownershipData[msg.sender][_user] = false;
         for(uint i =0 ; i< accessList[msg.sender].length; i++)
         {
             if(accessList[msg.sender][i].user == _user)
             {
                  accessList[msg.sender][i].access = false;
                  break;
             }
         }
     }

     // 1.3) return all the addressses who have access to datapoints of sender's account
     function displayAccess () public view returns( Access[] memory ){
         return accessList[msg.sender];
     }

     // 1.4) return all the buy requests to msg.sender
     function displayBuyRequests() public view returns( buyRequest[] memory ){
         return buyRequestList[msg.sender];
     }

    // 1.5) approve a particular buy request, the msg.sender will allow an address using this function
    function approveBuyRequest(uint256 id) payable public {
        require(id < buyRequestList[msg.sender].length, "the fetched buy request doesn not exist");
        require(buyRequestList[msg.sender][id].closed == false, "buy request already approved");

        uint256 amountToSend =  buyRequestList[msg.sender][id].dealAmount;

        // Ensure that the contract has enough balance to send
        require(address(this).balance >= amountToSend, "Contract balance is insufficient");
        
        allow(buyRequestList[msg.sender][id].user);
        // Transfer the amount in wei from the contract to msg.sender
        payable(msg.sender).transfer(amountToSend);

        buyRequestList[msg.sender][id].closed = true;

    }
    // 2) Buyer's activity
     
    // 2.1)  Place buy request to buy all the datapoints/ipfs urls of _owner's account (this is irreversible)
    function placeBuyRequest(address _owner) payable public {
        require(_owner != msg.sender, "requester cant be the owner");
        uint256 len = displayDataLength(_owner);
        uint256 minAmount = (len+1) * 1e16; // Calculate the amount of eth the buy requester must send to 
        // the minAmount of eth comes in contract balance
        require(msg.value >= minAmount, "the amount of eth sent with function call should be greater than the cost of purchase");

        uint256 amountToSend = (len) * 1e16; // in wei
        

        buyRequestList[_owner].push(buyRequest(buyRequestList[_owner].length, msg.sender, amountToSend, false));
    }

    // 2.2) return all the datapoints that (msg.sender) can access from account of (_user)
    function displayData(address _user) public view returns( string[] memory ){
         require(_user == msg.sender || ownershipData[_user][msg.sender] == true, "You don't have access");

         return dataList[_user];
    }

    // 2.3) return the length of datapoints present in the account of (_user)
    function displayDataLength(address _user) public view returns( uint256 ){
         return dataList[_user].length;
    }

    function displayUsers () public view returns (User[] memory)
    {
        return userArray;
    }
     
    function chk () public view returns( uint ){
         return accessList[msg.sender].length;
    }
    
}