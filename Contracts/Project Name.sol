// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Simple Voting
 * @dev A basic voting system with candidate registration and vote counting
 */
contract SimpleVoting {
    
    struct Candidate {
        uint id;
        string name;
        uint voteCount;
        bool exists;
    }
    
    mapping(uint => Candidate) public candidates;
    mapping(address => bool) public hasVoted;
    
    uint public candidateCount;
    address public owner;
    bool public votingActive;
    
    event CandidateRegistered(uint candidateId, string name);
    event VoteCasted(uint candidateId, address voter);
    event VotingStatusChanged(bool active);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    modifier votingOpen() {
        require(votingActive, "Voting is not active");
        _;
    }
    
    modifier hasNotVoted() {
        require(!hasVoted[msg.sender], "You have already voted");
        _;
    }
    
    constructor() {
        owner = msg.sender;
        votingActive = false;
        candidateCount = 0;
    }
    
    /**
     * @dev Register a new candidate for voting
     * @param _name Name of the candidate
     */
    function registerCandidate(string memory _name) public onlyOwner {
        require(bytes(_name).length > 0, "Candidate name cannot be empty");
        
        candidateCount++;
        candidates[candidateCount] = Candidate({
            id: candidateCount,
            name: _name,
            voteCount: 0,
            exists: true
        });
        
        emit CandidateRegistered(candidateCount, _name);
    }
    
    /**
     * @dev Cast a vote for a candidate
     * @param _candidateId ID of the candidate to vote for
     */
    function vote(uint _candidateId) public votingOpen hasNotVoted {
        require(_candidateId > 0 && _candidateId <= candidateCount, "Invalid candidate ID");
        require(candidates[_candidateId].exists, "Candidate does not exist");
        
        hasVoted[msg.sender] = true;
        candidates[_candidateId].voteCount++;
        
        emit VoteCasted(_candidateId, msg.sender);
    }
    
    /**
     * @dev Get vote count for a specific candidate
     * @param _candidateId ID of the candidate
     * @return Vote count for the candidate
     */
    function getVoteCount(uint _candidateId) public view returns (uint) {
        require(_candidateId > 0 && _candidateId <= candidateCount, "Invalid candidate ID");
        require(candidates[_candidateId].exists, "Candidate does not exist");
        
        return candidates[_candidateId].voteCount;
    }
    
    /**
     * @dev Start or stop voting
     * @param _active True to start voting, false to stop
     */
    function setVotingStatus(bool _active) public onlyOwner {
        votingActive = _active;
        emit VotingStatusChanged(_active);
    }
    
    /**
     * @dev Get all candidates with their vote counts
     * @return Arrays of candidate IDs, names, and vote counts
     */
    function getAllCandidates() public view returns (uint[] memory, string[] memory, uint[] memory) {
        uint[] memory ids = new uint[](candidateCount);
        string[] memory names = new string[](candidateCount);
        uint[] memory voteCounts = new uint[](candidateCount);
        
        for (uint i = 1; i <= candidateCount; i++) {
            ids[i-1] = candidates[i].id;
            names[i-1] = candidates[i].name;
            voteCounts[i-1] = candidates[i].voteCount;
        }
        
        return (ids, names, voteCounts);
    }
    
    /**
     * @dev Get the winning candidate
     * @return Winner's ID, name, and vote count
     */
    function getWinner() public view returns (uint, string memory, uint) {
        require(candidateCount > 0, "No candidates registered");
        
        uint winningVoteCount = 0;
        uint winningCandidateId = 0;
        
        for (uint i = 1; i <= candidateCount; i++) {
            if (candidates[i].voteCount > winningVoteCount) {
                winningVoteCount = candidates[i].voteCount;
                winningCandidateId = i;
            }
        }
        
        require(winningCandidateId > 0, "No winner found");
        
        return (
            winningCandidateId,
            candidates[winningCandidateId].name,
            winningVoteCount
        );
    }
}
