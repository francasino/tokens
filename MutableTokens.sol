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


contract MutableTokens{


    struct Token {
        uint id;
		bool mutable;
        string name;
        string information;
		uint timestamp;
        uint [] pedigreetoken; // id of items that conform this token
        uint [] processestoken; // ids of processes than conform this token
		uint [] stakeholderstoken; // stakeholders involved
        address owner; // who created the token 
		bool active; // if necessary, to disable or enable it. 
        string hashIPFS; // hash of the elements of the struct, for auditing AND IPFS 
    }
    // key is a uint, later corresponding to the token id
    // what we store (the value) is a Car
    // the information of this mapping is the set of cars available in this SC.
    mapping(uint => Token) private tokens; // 


	struct Pedigree {
        uint id; // this especific tuple, containing id and quantity
        uint id_pedigree_token; // the product
        uint quantity; // amount of product
        string timestamp; // date of this tuple creation
        address maker; // who creates
		string hashIPFS; // hash of the elements of the struct, for auditing AND IPFS 
    }

    mapping(uint => Pedigree) private pedigreeChanges; // all the pedigree tuples
	
	
	struct Process {
        uint id; // this especific process, containing id and quantity
        uint id_process; // the product
		uint timestamp; // when it was applied, just in case it is not the same date than token creation
        address maker; // who applied this proces
		string hashIPFS; // hash of the elements of the struct, for auditing AND IPFS 
    }

    mapping(uint => Process) private processChanges; //

    
    uint private tokensCount;
    uint private pedigreeCount;
    uint private processCount;
	uint private stakeholdersCount;


    // events, since SC is for global accounts it does not have too much sense but is left here 
    event updateEvent ( // triggers update complete
    );
	
	event changeStatusEvent ( // triggers status change
    );

    address constant public stakeholder = 0xE0f5206BBD039e7b0592d8918820024e2a7437b9; // who registers the token into system. 
	address constant public stakeholder2 = 0xE0F5206bbd039e7b0592d8918820024E2A743222;

    constructor () public { // constructor, inserts new token in system. we map starting from id=1, hardcoded values of all
        addToken("Ketchup","Tomato based sauce",1130009112019,stakeholder); //
		
        changeStatusCar(1, true);
        // try addpedigree
    }
	
	function addToken (bool memory _mutable, string memory _name, string memory _information, uint _timestamp, address _owner) public {
        //require(msg.sender==manufacturer);

        tokensCount ++; // inc count at the beginning. represents ID also. 
        tokens[tokensCount].id = tokensCount; 
        tokens[tokensCount].name = _name;
		tokens[tokensCount].information = _information;
		tokens[tokensCount].timestamp = _timestamp; // mmhhDDMMYYYY
        tokens[tokensCount].owner = _owner;
        tokens[tokensCount].active = true;
        //tokens[tokensCount].hashIPFS = keccak256(abi.encodePacked(block.number,msg.data, tokens[_tokenId].id, tokens[_tokenId].name, tokens[_tokenId].information, tokens[_tokenId].timestamp, tokens[_tokenId].owner));
    }
	
	// add pedigree item to a token, updates hash
	function addPedigree (uint _tokenId, string memory _id_pedigree_token, uint memory _quantity, string memory _timestamp) public {
        /*require(_tokenId > 0 && _tokenId <= tokensCount);  // security check avoid memory leaks
        require(msg.sender == tokens[_tokenId].owner); //Only token creator can modify it. We can relax this after
		require(true==tokens[_tokenId].active); //  only if active
        */

		pedigreeCount++;
		
        pedigreeChanges[pedigreeCount] = Pedigree(pedigreeCount, _id_pedigree_token, _quantity,_timestamp, msg.sender); // the global struct
        tokens[_tokenId].pedigreetoken.push(pedigreeCount); //  we store the reference in the corresponding token
	
        // update hash
		//tokens[_tokenId].hashIPFS = keccak256(abi.encodePacked(block.number,msg.data, tokens[_tokenId].id, tokens[_tokenId].name, tokens[_tokenId].information, tokens[_tokenId].timestamp, tokens[_tokenId].owner));

        emit updateEvent(); // trigger event 
    }
	
	// add process item to a token, updates hash
	function addProcess (uint _tokenId, string memory _id_pedigree_token, uint memory _quantity, string memory _timestamp) public {
        /*require(_tokenId > 0 && _tokenId <= tokensCount);  // security check avoid memory leaks
        require(msg.sender == tokens[_tokenId].owner); //Only token creator can modify it. We can relax this after
		require(true==tokens[_tokenId].active); //  only if active
        */

		processCount++;
		
        processChanges[processCount] = Process(processCount, _id_process,_timestamp, msg.sender); // the global struct
        tokens[_tokenId].processtoken.push(processCount); // we store the reference in the corresponding token
	
        // update hash
		//tokens[_tokenId].hashIPFS = keccak256(abi.encodePacked(block.number,msg.data, tokens[_tokenId].id, tokens[_tokenId].name, tokens[_tokenId].information, tokens[_tokenId].timestamp, tokens[_tokenId].owner));

        emit updateEvent(); // trigger event 
    }
	
	// add process item to a token, updates hash
	function addStakeholder (uint _tokenId, string memory _id_pedigree_token, uint memory _quantity, string memory _timestamp) public {
        /*require(_tokenId > 0 && _tokenId <= tokensCount);  // security check avoid memory leaks
        require(msg.sender == tokens[_tokenId].owner); //Only token creator can modify it. We can relax this after
		require(true==tokens[_tokenId].active); //  only if active
        */

		stakeholdersCount++;

        tokens[_tokenId].stakeholderstoken.push(stakeholdersCount); // we store the reference in the corresponding token
	
        // update hash
		//tokens[_tokenId].hashIPFS = keccak256(abi.encodePacked(block.number,msg.data, tokens[_tokenId].id, tokens[_tokenId].name, tokens[_tokenId].information, tokens[_tokenId].timestamp, tokens[_tokenId].owner));

        emit updateEvent(); // trigger event 
    }
	
	function changeStatusToken (uint _tokenId, bool _active) public { 
        /*require(_tokenId > 0 && _tokenId <= tokensCount);  // security check avoid memory leaks
        require(msg.sender == tokens[_tokenId].owner); //Only token creator can modify it. We can relax this after
        */

		tokens[_tokenId].active = _active;	
        emit changeStatusEvent(); // trigger event 
    }
	
	function retrieveHash (uint _tokenId) public view returns (bytes32){ 
        //computehash according to unique characteristics
        // this example hashes a transaction as a whole and info of the car
		// we can also just hash the info of the car. 
        return keccak256(abi.encodePacked(block.number,msg.data, tokens[_tokenId].id, tokens[_tokenId].name, tokens[_tokenId].information, tokens[_tokenId].timestamp, tokens[_tokenId].owner));
    }
	
	// getters structs of a token
	
	// get the array of pedigrees of a product, later we can loop them using getters to obtain the data
    function getPedigreeToken (uint _tokenId) public view returns (uint [] memory)  {
        require(_tokenId > 0 && _tokenId <= tokensCount);  // security check avoid memory leaks
        require(msg.sender == tokens[_tokenId].owner); 
       

        return tokens[_tokenId].pedigreetoken;
    }
	
	// get the array of changes of a product, later we can loop them using getters to obtain the data
    function getProcessesToken (uint _tokenId) public view returns (uint [] memory)  {
        require(_tokenId > 0 && _tokenId <= tokensCount);  // security check avoid memory leaks
        require(msg.sender == tokens[_tokenId].owner); 
        
        return tokens[_tokenId].processtoken;
    }
	
	// get the array of changes of a product, later we can loop them using getters to obtain the data
    function getStakeholderToken (uint _tokenId) public view returns (uint [] memory)  {
        require(_tokenId > 0 && _tokenId <= tokensCount);  // security check avoid memory leaks
        require(msg.sender == tokens[_tokenId].owner); 
        
        return tokens[_tokenId].stakeholderstoken;
    }
	
	// getters specific number of story or status
	function getPedigree (uint _pedigreeId) public view returns (Pedigree memory)  {
        require(_pedigreeId > 0 && _pedigreeId <= pedigreeCount); 
        require(msg.sender==pedigreeChanges[_pedigreeId].maker); // only if he is the author of the content
        
        return pedigreeChanges[_pedigreeId];
    }

	function getProcess (uint _processId) public view returns (Process memory)  {
        require(_processId > 0 && _processId <= processCount); 
        require(msg.sender==processChanges[_processId].maker); // only if he is the author of the content
        
        return processChanges[_processId];
    }
	
    // getters global such as number of structs, for statistics
	// returns global number of cars, needed to iterate the mapping and to know info.
    function getNumberOfTokens () public view returns (uint){
        
        return tokensCount;
    }
	
	// returns global number of stories, needed to iterate the mapping and to know info.
    function getNumberOfProcesses () public view returns (uint){
        
        
        return processCount;
    }
	
	// returns global number of status, needed to iterate the mapping and to know info.
    function getNumberOfStakeholders () public view returns (uint){
        
        
        return stakeholdersCount;
    }

	
}
