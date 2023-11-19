// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract LeagueX3 {
    struct leagueData {
        string name;
        string img;
        string metadata;
        string matchName;
        string teamA;
        string teamB;
        bool isRunning;
        bool isFinished;
        uint32 leaguePrice;
        uint8 squadLimit;
    }

    struct userLeagueData {
        string leagueName;
        string squads;
    }

    struct leaderboardData {
        address userAddress;
        uint32 totalPoints;
        uint32 position;
        bool isWinner;
        bool isRunnersUp;
        bool isSecondRunnersUp;
        bool isConsolationWinner;
        string title;
    }

    // this mapping is between the matchipfsLink obtained from datastore =>
    // to all the leagueData associated on keyed match
    mapping(string => leagueData[]) allLeagues;

    // internal mapping to store all the users participating in the given league.
    // leagueName => user_address array
    mapping(string => address[]) leagueUsers;

    // this mapping is between the user address =>
    // leagueParticipation data including leagueIpfsLink and the createdSquadLink
    // PS: SquadLink can contain multiple squads for participating in the same league
    mapping(address => userLeagueData[]) userParticipation;

    // this mapping is for maintaining the leagues' leaderboard with all users'
    // points, positions and winner status
    // leagueName => leaderboardData array
    mapping(string => leaderboardData[]) leagueLeaderboard;

    address eAddr = 0xDeC6Df558e198A7745AcBe881f61B3506D59CFC4;
    address payable escrowAddr = payable(eAddr);

    function SetFinalLeaderboard(
        string memory leagueName,
        string memory matchName,
        leaderboardData[] memory userLeaderboardData
    ) public returns (leaderboardData[] memory) {
        string memory finalNameSep = string.concat(leagueName, ";;;");
        string memory finalName = string.concat(finalNameSep, matchName);
        leaderboardData[] storage allLeaderboards = leagueLeaderboard[
            finalName
        ];
        for (uint8 j = 0; j < userLeaderboardData.length; j++) {
            for (uint256 i = 0; i < allLeaderboards.length; i++) {
                if (
                    allLeaderboards[i].userAddress ==
                    userLeaderboardData[j].userAddress
                ) {
                    allLeaderboards[i].position = userLeaderboardData[j]
                        .position;
                    allLeaderboards[i].isWinner = userLeaderboardData[j]
                        .isWinner;
                    allLeaderboards[i].isRunnersUp = userLeaderboardData[j]
                        .isRunnersUp;
                    allLeaderboards[i].isSecondRunnersUp = userLeaderboardData[
                        j
                    ].isSecondRunnersUp;
                    allLeaderboards[i].title = userLeaderboardData[j].title;
                    allLeaderboards[i]
                        .isConsolationWinner = userLeaderboardData[j]
                        .isConsolationWinner;
                }
            }
        }
        return allLeaderboards;
    }

    function CalculateLeaderboard(
        string memory leagueName,
        string memory matchName,
        leaderboardData[] memory userLeaderboardData
    ) public returns (leaderboardData[] memory) {
        string memory finalNameSep = string.concat(leagueName, ";;;");
        string memory finalName = string.concat(finalNameSep, matchName);
        leaderboardData[] storage allLeaderboards = leagueLeaderboard[
            finalName
        ];
        for (uint8 j = 0; j < userLeaderboardData.length; j++) {
            bool exists = false;
            for (uint256 i = 0; i < allLeaderboards.length; i++) {
                if (
                    allLeaderboards[i].userAddress ==
                    userLeaderboardData[j].userAddress
                ) {
                    allLeaderboards[i].totalPoints = userLeaderboardData[j]
                        .totalPoints;
                    allLeaderboards[i].position = 0;
                    allLeaderboards[i].isWinner = false;
                    allLeaderboards[i].isRunnersUp = false;
                    allLeaderboards[i].isSecondRunnersUp = false;
                    allLeaderboards[i].isConsolationWinner = false;
                    allLeaderboards[i].title = "";
                    exists = true;
                    break;
                }
            }
            if (exists) {
                continue;
            }
            leaderboardData memory lbData = leaderboardData(
                userLeaderboardData[j].userAddress,
                userLeaderboardData[j].totalPoints,
                0,
                false,
                false,
                false,
                false,
                ""
            );
            allLeaderboards.push(lbData);
            leagueLeaderboard[finalName] = allLeaderboards;
        }
        return allLeaderboards;
    }

    // function CalculateLeaderboard(
    //     string memory leagueName,
    //     string memory matchName,
    //     address[] memory user_address,
    //     uint32 finalPoints
    // ) public returns (leaderboardData[] memory) {
    //     string memory finalNameSep = string.concat(leagueName, ";;;");
    //     string memory finalName = string.concat(finalNameSep, matchName);
    //     leaderboardData[] storage allLeaderboards = leagueLeaderboard[
    //         finalName
    //     ];
    //     for (uint8 j = 0; j < user_address.length; j++) {
    //         for (uint256 i = 0; i < allLeaderboards.length; i++) {
    //             if (allLeaderboards[i].userAddress == user_address[j]) {
    //                 allLeaderboards[i].totalPoints = finalPoints;
    //                 continue;
    //             }
    //         }
    //         leaderboardData memory lbData = leaderboardData(
    //             user_address[j],
    //             finalPoints
    //         );
    //         allLeaderboards.push(lbData);
    //         leagueLeaderboard[finalName] = allLeaderboards;
    //     }
    //     return allLeaderboards;
    // }

    function GetLeagueLeaderboard(
        string memory leagueName,
        string memory matchName
    ) public view returns (leaderboardData[] memory) {
        string memory finalNameSep = string.concat(leagueName, ";;;");
        string memory finalName = string.concat(finalNameSep, matchName);
        return leagueLeaderboard[finalName];
    }

    function CreateUpdateLeague(
        string memory matchName,
        string memory name,
        string memory img,
        string memory metadata,
        string memory teamA,
        string memory teamB,
        bool isRunning,
        bool isFinished,
        uint32 leaguePrice,
        uint8 squadLimit
    ) public returns (leagueData memory) {
        leagueData[] storage addedLeagues = allLeagues[matchName];
        for (uint256 i = 0; i < addedLeagues.length; i++) {
            if (
                keccak256(bytes(addedLeagues[i].name)) == keccak256(bytes(name))
            ) {
                addedLeagues[i].name = name;
                addedLeagues[i].img = img;
                addedLeagues[i].metadata = metadata;
                addedLeagues[i].matchName = matchName;
                addedLeagues[i].teamA = teamA;
                addedLeagues[i].teamB = teamB;
                addedLeagues[i].isRunning = isRunning;
                addedLeagues[i].isFinished = isFinished;
                addedLeagues[i].leaguePrice = leaguePrice;
                addedLeagues[i].squadLimit = squadLimit;
                return (addedLeagues[i]);
            }
        }
        leagueData memory lData = leagueData(
            name,
            img,
            metadata,
            matchName,
            teamA,
            teamB,
            isRunning,
            isFinished,
            leaguePrice,
            squadLimit
        );
        addedLeagues.push(lData);
        allLeagues[matchName] = addedLeagues;
        return (lData);
    }

    function GetLeagues(string memory matchCid)
        public
        view
        returns (leagueData[] memory)
    {
        return (allLeagues[matchCid]);
    }

    function UserParticipate(
        address user_addr,
        string memory leagueName,
        string memory matchName,
        string memory squadLink
    ) public payable returns (address, userLeagueData memory) {
        (bool sent, bytes memory data) = escrowAddr.call{value: msg.value}("");
        require(sent, "Failed to Transfer leaguePrice");
        userLeagueData[] storage userLeagues = userParticipation[user_addr];
        string memory finalNameSep = string.concat(leagueName, ";;;");
        string memory finalName = string.concat(finalNameSep, matchName);
        for (uint256 i = 0; i < userLeagues.length; i++) {
            // Case for when the user is participating in the league with a subsequent squad
            if (
                keccak256(bytes(userLeagues[i].leagueName)) ==
                keccak256(bytes(finalName))
            ) {
                string memory userSquads = userLeagues[i].squads;
                string memory addedSep = string.concat(userSquads, ";;;");
                string memory newSquad = string.concat(addedSep, squadLink);
                userLeagues[i].squads = newSquad;
                return (user_addr, userLeagues[i]);
            }
        }
        // Case for when the user is participating in a new league with the first squad
        userLeagueData memory ul = userLeagueData(finalName, squadLink);
        userLeagues.push(ul);
        userParticipation[user_addr] = userLeagues;

        // push to leagueUsers mapping
        address[] storage allLeagueUsers = leagueUsers[finalName];
        allLeagueUsers.push(user_addr);

        // push to leagueLeaderboard mapping
        leaderboardData memory uleaderData = leaderboardData(
            user_addr,
            0,
            0,
            false,
            false,
            false,
            false,
            ""
        );
        leaderboardData[] storage leaderBoardData = leagueLeaderboard[
            finalName
        ];
        leaderBoardData.push(uleaderData);
        return (user_addr, ul);
    }

    function GetAllUserParticipation(address user_addr)
        public
        view
        returns (address, userLeagueData[] memory)
    {
        return (user_addr, userParticipation[user_addr]);
    }

    function GetAllUsersForLeague(
        string memory leagueName,
        string memory matchName
    ) public view returns (address[] memory) {
        string memory finalNameSep = string.concat(leagueName, ";;;");
        string memory finalName = string.concat(finalNameSep, matchName);
        return leagueUsers[finalName];
    }

    function GetUserLeagueParticipation(
        address user_addr,
        string memory leagueName
    ) public view returns (address u_addr, userLeagueData memory u_league) {
        userLeagueData[] storage userLeagues = userParticipation[user_addr];
        for (uint256 i = 0; i < userLeagues.length; i++) {
            if (
                keccak256(bytes(userLeagues[i].leagueName)) ==
                keccak256(bytes(leagueName))
            ) {
                return (user_addr, userLeagues[i]);
            }
        }
    }
}