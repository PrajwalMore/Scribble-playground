pragma solidity 0.8.0;

contract Tournament {
    event eventTournamentCreated(uint _startTime, uint _endTime, uint256 _entryFee, uint256 _noOfParticipants, uint256 rewardToAdmin, uint256 rewardToParticipant);

    event eventTournamentJoined(uint256 tournamentId, uint256 entryFee, address Participant);

    event eventRewardSent(uint256 tournamentId, address winnerAddress, uint256 rewardToWinner, uint256 rewardToAdmin);

    event AssertionFailed(string message);

    struct tournamentInfo {
        uint startTime;
        uint endTime;
        uint256 entryFee;
        uint256 reward;
        uint256 rewardToAdmin;
        address tournamentAdmin;
        address winnerAddress;
        uint256 noOfParticipants;
    }

    struct vars0 {
        uint256 old_0;
    }

    struct vars1 {
        bool old_1;
        uint256 old_2;
    }

    struct vars2 {
        uint256 old_3;
        uint256 old_4;
    }

    struct vars3 {
        uint256 old_5;
    }

    /// #if_updates {:msg "Only this contract can update this variable"} msg.sender == address(this);
    uint256 public idCntr = 0;
    mapping(uint256 => tournamentInfo) public tournament;
    mapping(uint256 => mapping(address => bool)) public tournamentJoined;
    mapping(uint256 => address[]) internal participantsAddress;
    mapping(address => uint256[]) internal addressToTournament;

    function createTournament(uint _startTime, uint _endTime, uint256 _entryFee, uint256 _noOfParticipants) external {
        vars0 memory _v;
        unchecked {
            _v.old_0 = idCntr;
        }
        _original_Tournament_createTournament(_startTime, _endTime, _entryFee, _noOfParticipants);
        unchecked {
            if (!(idCntr >= _v.old_0)) {
                emit AssertionFailed("0: Tournament counter should not be <= that of previous one");
                assert(false);
            }
            if (!(tournament[idCntr].rewardToAdmin == (((tournament[idCntr].entryFee * tournament[idCntr].noOfParticipants) * 5) / 100))) {
                emit AssertionFailed("1: Reward to admin should be 5% of total entry fees");
                assert(false);
            }
        }
    }

    function _original_Tournament_createTournament(uint _startTime, uint _endTime, uint256 _entryFee, uint256 _noOfParticipants) private {
        require((_noOfParticipants >= 2) && (_noOfParticipants <= 4), "ERR: ENTER PARTICIPANTS BETWEEN >=2 AND <=4 !");
        require(_endTime >= block.timestamp, "ENTER TIMESTAMP GREATER THAN CURRENT TIME");
        require((_startTime >= block.timestamp) && (_startTime < _endTime), "ENTER TIMESTAMP GREATER THAN CURRENT TIME");
        uint256 totalReward = _entryFee * (_noOfParticipants);
        uint256 rewardToAdmin = (totalReward * 5) / 100;
        uint256 rewardToParticipant = totalReward - rewardToAdmin;
        tournament[idCntr] = tournamentInfo(_startTime, _endTime, _entryFee, rewardToParticipant, rewardToAdmin, msg.sender, address(0), _noOfParticipants);
        addressToTournament[msg.sender].push(idCntr);
        idCntr++;
        emit eventTournamentCreated(_startTime, _endTime, _entryFee, _noOfParticipants, rewardToAdmin, rewardToParticipant);
    }

    function joinTournament(uint256 _id) external payable {
        vars1 memory _v;
        unchecked {
            _v.old_1 = tournamentJoined[_id][msg.sender];
            _v.old_2 = address(this).balance;
        }
        _original_Tournament_joinTournament(_id);
        unchecked {
            if (!(msg.sender != tournament[idCntr].tournamentAdmin)) {
                emit AssertionFailed("2: New participant should not be admin");
                assert(false);
            }
            if (!(_v.old_1 == false)) {
                emit AssertionFailed("3: New participant should not be participated already");
                assert(false);
            }
            if (!(msg.sender != tournament[_id].tournamentAdmin)) {
                emit AssertionFailed("4: New joiner should not be the tournament admin");
                assert(false);
            }
            if (!(address(this).balance == (_v.old_2 + tournament[_id].entryFee))) {
                emit AssertionFailed("5: Contract should receive entry fee");
                assert(false);
            }
        }
    }

    function _original_Tournament_joinTournament(uint256 _id) private {
        require(block.timestamp >= tournament[_id].startTime, "ERR: CANT CALL BEFORE TOURNAMENT STARTS!");
        require(msg.sender != tournament[_id].tournamentAdmin, "ERR: ADMIN CAN'T JOIN OWN TOURNAMENT");
        require(_id <= idCntr, "ERR: TOURNAMENT DON'T EXISTS!");
        require(tournamentJoined[_id][msg.sender] == false, "ERR: YOU HAVE ALREADY JOINED!");
        require(participantsAddress[_id].length < tournament[_id].noOfParticipants, "ERR: PARTICIPATION ALREADY ENDED!");
        require(block.timestamp <= tournament[_id].endTime, "ERR: TOURNAMENT TIME ENDED");
        require(msg.value == tournament[_id].entryFee, "ERR: SENT ETH VALUE IS NOT EQUAL TO ENTRY FEE");
        participantsAddress[_id].push(msg.sender);
        tournamentJoined[_id][msg.sender] = true;
        emit eventTournamentJoined(_id, msg.value, msg.sender);
    }

    function sendReward(uint256 _id) external returns (bool RET_0, bool RET_1) {
        vars2 memory _v;
        unchecked {
            _v.old_3 = address(this).balance;
            _v.old_4 = block.timestamp;
        }
        (RET_0, RET_1) = _original_Tournament_sendReward(_id);
        unchecked {
            if (!(address(this).balance == (_v.old_3 - (tournament[_id].reward + tournament[_id].rewardToAdmin)))) {
                emit AssertionFailed("6: Correct rewards amount should be deducted from contract");
                assert(false);
            }
            if (!(msg.sender == tournament[_id].tournamentAdmin)) {
                emit AssertionFailed("7: caller should be tournament owner");
                assert(false);
            }
            if (!(_v.old_4 <= tournament[_id].endTime)) {
                emit AssertionFailed("8: End time should be greater than current timesstamp");
                assert(false);
            }
        }
    }

    function _original_Tournament_sendReward(uint256 _id) private returns (bool, bool) {
        require(block.timestamp >= tournament[_id].startTime, "ERR: CANT CALL BEFORE TOURNAMENT STARTS!");
        require(participantsAddress[_id].length == tournament[_id].noOfParticipants, "ERR: PARTICIPANTS ARE NOT ENOUGH!");
        require(msg.sender == tournament[_id].tournamentAdmin, "ERR: YOU ARE NOT TOURNAMENT ADMIN TO CALL THIS FUNCTION!");
        require(_id <= idCntr, "ERR: TOURNAMENT DON'T EXISTS!");
        require(tournament[_id].winnerAddress == address(0), "ERR: WINNER ALREADY ANNOUNCED AND TOURNAMENT IS OVER!");
        address winner = decideWinner(_id);
        tournament[_id].endTime = block.timestamp;
        tournament[_id].winnerAddress = winner;
        (bool success1, ) = payable(winner).call{value: tournament[_id].reward}("");
        (bool success2, ) = payable(tournament[_id].tournamentAdmin).call{value: tournament[_id].rewardToAdmin}("");
        emit eventRewardSent(_id, winner, tournament[_id].reward, tournament[_id].rewardToAdmin);
        return (success1, success2);
    }

    function decideWinner(uint256 _id) private view returns (address) {
        address[] memory arr = participantsAddress[_id];
        uint256 winner = uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, arr))) / (arr.length);
        return arr[winner];
    }

    function returnFees(uint256 _id) external {
        vars3 memory _v;
        unchecked {
            _v.old_5 = block.timestamp;
        }
        _original_Tournament_returnFees(_id);
        unchecked {
            if (!(address(this).balance == (tournament[_id].entryFee - tournament[_id].noOfParticipants))) {
                emit AssertionFailed("9: Correct rewards amount should be deducted from contract");
                assert(false);
            }
            if (!(msg.sender == tournament[_id].tournamentAdmin)) {
                emit AssertionFailed("10: caller should be tournament owner");
                assert(false);
            }
            if (!(_v.old_5 <= tournament[_id].endTime)) {
                emit AssertionFailed("11: End time should be greater than current timesstamp");
                assert(false);
            }
        }
    }

    function _original_Tournament_returnFees(uint256 _id) private {
        require(msg.sender == tournament[_id].tournamentAdmin, "ERR: YOU ARE NOT TOURNAMENT ADMIN TO OF THIS TOURNAMENT!");
        require(block.timestamp <= tournament[_id].endTime, "ERR: TOURNAMENT ALREADY ENDED!");
        tournament[_id].endTime = block.timestamp;
        for (uint256 i = 0; i < participantsAddress[_id].length; i++) {
            payable(participantsAddress[_id][i]).call{value: tournament[_id].entryFee}("");
        }
    }

    function isTournamentActive(uint256 _id) external view returns (bool) {
        if (tournament[_id].endTime <= block.timestamp) {
            return false;
        } else if (tournament[_id].startTime <= block.timestamp) {
            return true;
        } else {
            return false;
        }
    }

    function getParticipantList(uint256 _id) external view returns (address[] memory) {
        require(_id <= idCntr, "ERR: TOURNAMENT DON'T EXISTS!");
        return participantsAddress[_id];
    }

    function contractBal() external view returns (uint256) {
        return address(this).balance;
    }

    function callerBal() external view returns (uint256) {
        return msg.sender.balance;
    }

    function yourTournaments() external view returns (uint256[] memory) {
        uint256[] memory arr = addressToTournament[msg.sender];
        return arr;
    }
}