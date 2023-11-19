// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/utils/Strings.sol";

contract Datastore {
    struct playersData {
        string name;
        string metadata;
        uint16 rating;
        string role;
        bool inSquad;
        bool isPlaying;
    }

    struct matches {
        string name;
        string teamA;
        string teamB;
        uint256 startDateTime;
        uint256 endDateTime;
        string metadata;
        bool isRunning;
        bool isOpen;
        bool isFinished;
    }

    mapping(string => playersData[]) playersMapping;
    mapping(string => matches[]) matchesMapping;

    function CreateUpdateMatches(
        string memory date,
        string memory matchName,
        string memory teamA,
        string memory teamB,
        uint256 startTs,
        uint256 endTs,
        string memory matchMeta,
        bool isRunning,
        bool isOpen,
        bool isFinished
    ) public returns (matches memory) {
        matches[] storage allMatches = matchesMapping[date];
        for (uint256 i = 0; i < allMatches.length; i++) {
            if (
                keccak256(bytes(allMatches[i].name)) ==
                keccak256(bytes(matchName))
            ) {
                allMatches[i].name = matchName;
                allMatches[i].teamA = teamA;
                allMatches[i].teamB = teamB;
                allMatches[i].startDateTime = startTs;
                allMatches[i].endDateTime = endTs;
                allMatches[i].metadata = matchMeta;
                allMatches[i].isRunning = isRunning;
                allMatches[i].isOpen = isOpen;
                allMatches[i].isFinished = isFinished;
                return allMatches[i];
            }
        }
        matches memory m = matches(
            matchName,
            teamA,
            teamB,
            startTs,
            endTs,
            matchMeta,
            isRunning,
            isOpen,
            isFinished
        );
        allMatches.push(m);
        matchesMapping[date] = allMatches;
        return m;
    }

    function GetMatches(string memory date)
        public
        view
        returns (matches[] memory)
    {
        return (matchesMapping[date]);
    }

    // function GetMatchesForDates(string[] memory dates)
    //     public
    //     view
    //     returns (matches[] memory)
    // {
    //     if (dates.length > 0) {
    //         matches[] storage allMatches = matchesMapping[dates[0]];
    //         for (uint32 i = 1; i < dates.length; i++) {
    //             matches[] storage m = matchesMapping[dates[i]];
    //             for (uint32 j = 0; j < m.length; j++) {
    //                 allMatches.push(m[j]);
    //             }
    //         }
    //     }

    //     // return (matchesMapping[date]);
    // }

    function CreateUpdateTeam(
        string memory team,
        string memory pName,
        string memory pMetadata,
        uint16 pRating,
        string memory pRole,
        bool inSquad,
        bool isPlaying
    ) public returns (playersData memory) {
        playersData[] storage allPlayers = playersMapping[team];
        for (uint256 i = 0; i < allPlayers.length; i++) {
            if (
                keccak256(bytes(allPlayers[i].name)) == keccak256(bytes(pName))
            ) {
                allPlayers[i].name = pName;
                allPlayers[i].metadata = pMetadata;
                allPlayers[i].rating = pRating;
                allPlayers[i].role = pRole;
                allPlayers[i].inSquad = inSquad;
                allPlayers[i].isPlaying = isPlaying;
                return allPlayers[i];
            }
        }
        playersData memory p = playersData(
            pName,
            pMetadata,
            pRating,
            pRole,
            inSquad,
            isPlaying
        );
        allPlayers.push(p);
        playersMapping[team] = allPlayers;
        return p;
    }

    function GetTeamPlayers(string memory team)
        public
        view
        returns (playersData[] memory)
    {
        return playersMapping[team];
    }
}