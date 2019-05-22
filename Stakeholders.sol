pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

/*
COPYRIGHT FRAN CASINO. 2019.
SECURITY CHECKS ARE COMMENTED FOR AN EASY USE TEST.
UNCOMMENT THE CODE FOR A FULLY FUNCTIONAL VERSION. 
YOU WILL NEED TO USE METAMASK OR OTHER EXTENSIONS TO USE THE REQUIRED ADDRESSES


ACTUALLY DATA ARE STORED IN THE SC. TO ENABLE IPFS, FUNCTIONS WILL NOT STORE the values and just the hash in the structs.
This can be changed in the code by calling the hash creation function. 
Nevertheless, the code is kept clear for the sake of understanding. 


TODO - Add into the hash algorithm the structs of the token. Now only initial info is hashed. 
*/

contract Stakeholders{
 
    struct Stakeholder{
        uint id; // this especific process, containing id and quantity
        string name; // the product
        string timestamp; // when it was applied, just in case it is not the same date than token creation
        uint [] involvedtokens; // tokens used by stakeholder
        string description; // other info
        address maker; // who applied this proces
        bool active;
        string hashIPFS; // hash of the elements of the struct, for auditing AND IPFS 
    }

    mapping(uint => Stakeholder) private stakeholderChanges; //

    uint private tokensCount;
    uint private stakeholderCount;

    // events, since SC is for global accounts it does not have too much sense but is left here 
    event updateEvent ( // triggers update complete
    );
    
    event changeStatusEvent ( // triggers status change
    );

    address constant public stakeholder = 0xE0f5206BBD039e7b0592d8918820024e2a7437b9; // who registers the token into system. 
    address constant public stakeholder2 = 0xE0F5206bbd039e7b0592d8918820024E2A743222;

    constructor () public { // constructor, inserts new token in system. we map starting from id=1, hardcoded values of all
        addStakeholder("Manufacturer","1130009112019","Local producer of vegetables"); //
        
    }
    
    // add stakeholder to the list
    function addStakeholder (string memory _name, string memory _timestamp, string memory _description) public {
        /*require(_tokenId > 0 && _tokenId <= tokensCount);  // security check avoid memory leaks
        require(msg.sender == tokens[_tokenId].owner); //Only token creator can modify it. We can relax this after
        require(true==tokens[_tokenId].active); //  only if active
        */
        stakeholderCount++;
        stakeholderChanges[stakeholderCount].id = stakeholderCount;
        stakeholderChanges[stakeholderCount].name = _name; 
        stakeholderChanges[stakeholderCount].timestamp = _timestamp; 
        stakeholderChanges[stakeholderCount].description = _description; 
        stakeholderChanges[stakeholderCount].active = true; 
        stakeholderChanges[stakeholderCount].maker = msg.sender;
        emit updateEvent(); // trigger event 
    }

    function addStakeholderToken(uint memory _id) public {

        stakeholderChanges[stakeholderCount].involvedtokens.push(_id);
        emit updateEvent(); // trigger event 
    }
    
    // get the products managed by the stakeholder
    function getStakeholdersToken (uint memory _id) public view returns (uint [] memory)  {
        require(_id > 0 && _id <= stakeholderCount);  // security check avoid memory leaks
        require(msg.sender == stakeholderChanges[_id].maker);
        
        return stakeholderChanges[_id].involvedtokens;
    }

    function changeStatus (uint memory _id, bool memory _active) public {
        require(_id > 0 && _id <= stakeholderCount); 
        stakeholderChanges[stakeholderCount].active = _active;
        emit changeStatusEvent(); // trigger event 
    }

    function getStakeholder (uint memory _id) public view returns (Stakeholder memory)  {
        require(_id > 0 && _id <= stakeholderCount);  
        require(msg.sender == stakeholderChanges[_id].maker); // only if he is the author of the content
        
        return stakeholderChanges[_id];
    }
    
    // returns global number of status, needed to iterate the mapping and to know info.
    function getNumberOfStakeholders () public view returns (uint){    
        //tx.origin
        return stakeholdersCount;
    }

}
