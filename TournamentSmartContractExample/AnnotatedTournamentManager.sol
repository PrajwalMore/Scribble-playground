//SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

contract Tournament{
    /// #if_updates {:msg "Only this contract can update this variable"} msg.sender == address(this);
    uint256 public idCntr=0;

    struct tournamentInfo{
        uint startTime;
        uint endTime;
        uint256 entryFee;
        uint256 reward;
        uint256 rewardToAdmin;
        address tournamentAdmin;
        address winnerAddress;
        uint256 noOfParticipants;
    }

    mapping (uint256=>tournamentInfo) public tournament;
    
    mapping (uint256=>mapping(address=> bool)) public tournamentJoined;
    
    mapping (uint256=>address[]) participantsAddress;
    
    mapping(address=>uint256[]) addressToTournament;
    
    event eventTournamentCreated(uint _startTime,uint _endTime,uint256 _entryFee,uint256 _noOfParticipants,uint256 rewardToAdmin,uint256 rewardToParticipant);
    event eventTournamentJoined(uint256 tournamentId,uint256 entryFee,address Participant);
    event eventRewardSent(uint256 tournamentId,address winnerAddress,uint256 rewardToWinner,uint256 rewardToAdmin);

    //Creates tournament.
    //admin should add tournament reward to contract while calling function.

    /// #if_succeeds {:msg "Tournament counter should not be <= that of previous one"} idCntr >= old(idCntr);
    /// #if_succeeds {:msg "Reward to admin should be 5% of total entry fees"} tournament[idCntr].rewardToAdmin == ((tournament[idCntr].entryFee * tournament[idCntr].noOfParticipants)* 5 )/100 ;
    /// #if_suceesds {:msg "Reward to participant should `total reward - reward to admin` "} tournament[idCntr].reward == ((tournament[idCntr].entryFee * tournament[idCntr].noOfParticipants) - ((tournament[idCntr].entryFee * tournament[idCntr].noOfParticipants)* 5 )/100);
    function createTournament(uint _startTime,uint _endTime,uint256 _entryFee,uint256 _noOfParticipants) external{
        require(_noOfParticipants>= 2 && _noOfParticipants<=4, "ERR: ENTER PARTICIPANTS BETWEEN >=2 AND <=4 !");
        require(_endTime >= block.timestamp,"ENTER TIMESTAMP GREATER THAN CURRENT TIME");
        require(_startTime >= block.timestamp && _startTime < _endTime,"ENTER TIMESTAMP GREATER THAN CURRENT TIME");
        
        //Reward calculation.
        uint256 totalReward=_entryFee*(_noOfParticipants);
        uint256 rewardToAdmin = ( totalReward*5)/100;
        uint256 rewardToParticipant =totalReward-rewardToAdmin;
        
        tournament[idCntr]=tournamentInfo(
            _startTime,
            _endTime,
            _entryFee,
            rewardToParticipant,
            rewardToAdmin,
            msg.sender, //as a admin.
            address(0),
            _noOfParticipants
        );
        addressToTournament[msg.sender].push(idCntr);
        
        idCntr++;
        emit eventTournamentCreated(_startTime,_endTime,_entryFee,_noOfParticipants,rewardToAdmin,rewardToParticipant);
    }

    // Allows users to join tournament.
    /// #if_succeeds {:msg "New participant should not be admin"} participantsAddress[idCntr][-1] != tournament[idCntr].tournamentAdmin;
    /// #if_succeeds {:msg "New participant should not be participated already"} old(tournamentJoined[_id][msg.sender]) == false;
    /// #if_succeeds {:msg "New joiner should not be the tournament admin"} msg.sender != tournament[_id].tournamentAdmin;
    /// #if_succeeds {:msg "Contract should receive entry fee"} address(this).balance == (old(address(this).balance) + tournament[_id].entryFee);
    function joinTournament(uint256 _id) external payable{
        require(block.timestamp>=tournament[_id].startTime,"ERR: CANT CALL BEFORE TOURNAMENT STARTS!");
        require(msg.sender!=tournament[_id].tournamentAdmin,"ERR: ADMIN CAN'T JOIN OWN TOURNAMENT");
        require(_id <= idCntr,"ERR: TOURNAMENT DON'T EXISTS!");
        require(tournamentJoined[_id][msg.sender] == false,"ERR: YOU HAVE ALREADY JOINED!");
        require(participantsAddress[_id].length< tournament[_id].noOfParticipants,"ERR: PARTICIPATION ALREADY ENDED!");
        require(block.timestamp <= tournament[_id].endTime,"ERR: TOURNAMENT TIME ENDED");
        require(msg.value == tournament[_id].entryFee,"ERR: SENT ETH VALUE IS NOT EQUAL TO ENTRY FEE");
        
        //participantsAddress[_id].participantsArr.push(msg.sender);
        participantsAddress[_id].push(msg.sender);
        tournamentJoined[_id][msg.sender]=true;
        emit eventTournamentJoined(_id,msg.value,msg.sender);
    }

    // Sends reward to winner address and sets it as a winner of that tournament.
    // Callable only by tournament owner.

    /// #if_succeeds {:msg "Correct rewards amount should be deducted from contract"} address(this).balance == (old(address(this).balance) - (tournament[_id].reward + tournament[_id].rewardToAdmin));
    /// #if_succeeds {:msg "caller should be tournament owner"} msg.sender == tournament[_id].tournamentAdmin;
    /// #if_succeeds {:msg "End time should be greater than current timesstamp"} old(block.timestamp)<= tournament[_id].endTime;
    function sendReward(uint256 _id) external returns(bool,bool){
        require(block.timestamp>=tournament[_id].startTime,"ERR: CANT CALL BEFORE TOURNAMENT STARTS!");
        require(participantsAddress[_id].length == tournament[_id].noOfParticipants,"ERR: PARTICIPANTS ARE NOT ENOUGH!");
        require(msg.sender == tournament[_id].tournamentAdmin,"ERR: YOU ARE NOT TOURNAMENT ADMIN TO CALL THIS FUNCTION!");
        require(_id <= idCntr,"ERR: TOURNAMENT DON'T EXISTS!");
        require(tournament[_id].winnerAddress == address(0),"ERR: WINNER ALREADY ANNOUNCED AND TOURNAMENT IS OVER!");
        
        address winner=decideWinner(_id);
        
        //setting tournament is over.
        tournament[_id].endTime=block.timestamp;
        tournament[_id].winnerAddress=winner;
        
        (bool success1,)=payable(winner).call{value: tournament[_id].reward}("");
        (bool success2,)=payable(tournament[_id].tournamentAdmin).call{value: tournament[_id].rewardToAdmin}("");
        emit eventRewardSent(_id,winner,tournament[_id].reward,tournament[_id].rewardToAdmin);
        return (success1,success2);
    }
    
    // Function is vulnerable. Using only for testing.
    function decideWinner(uint256 _id) view private returns(address){
        address[] memory arr=participantsAddress[_id];
        
        uint256 winner= uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, arr)))/(arr.length) ;
        
        return arr[winner];
    }
    
    
    // Return fees to participated users in case there are no enough participants.
    // Callable only by tournament owner.
    /// #if_succeeds {:msg "Correct rewards amount should be deducted from contract"} address(this).balance == (tournament[_id].entryFee - tournament[_id].noOfParticipants);
    /// #if_succeeds {:msg "caller should be tournament owner"} msg.sender == tournament[_id].tournamentAdmin;
    /// #if_succeeds {:msg "End time should be greater than current timesstamp"} old(block.timestamp)<= tournament[_id].endTime;
    function returnFees(uint256 _id) external{
        require(msg.sender == tournament[_id].tournamentAdmin,"ERR: YOU ARE NOT TOURNAMENT ADMIN TO OF THIS TOURNAMENT!");
        require(block.timestamp <= tournament[_id].endTime,"ERR: TOURNAMENT ALREADY ENDED!");
        tournament[_id].endTime=block.timestamp;
        for (uint256 i = 0; i < participantsAddress[_id].length; i++) {
            payable(participantsAddress[_id][i]).call{value:tournament[_id].entryFee}("");
        }
        
    }

    // Returns boolean value for tournament is active or not.
    function isTournamentActive(uint256 _id) view external returns(bool){
        if(tournament[_id].endTime <= block.timestamp){
            return false;
        }
        else if(tournament[_id].startTime <= block.timestamp){ 
            return true;
        }
        else{
            return false;
        }
        
    }
    
    // Returns list of participants.
    function getParticipantList(uint256 _id) view external returns(address[] memory){
        require(_id <= idCntr,"ERR: TOURNAMENT DON'T EXISTS!");
        return participantsAddress[_id];
    }

    // Returns balance of this contract.
    function contractBal() view external returns(uint256){
        return address(this).balance;
    }

    // Returns balance of msg.sender.
    function callerBal() view external returns(uint256){
        return msg.sender.balance;
    }
    
    // Returns msg.sender's tournament.
    function yourTournaments() view external returns(uint256[] memory){
        uint256[] memory arr=addressToTournament[msg.sender];
        return arr;
        // if(arr.length==0){
            
        // }
    }
    
    
}
