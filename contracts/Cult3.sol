// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Cult3 {
    struct cultData {
        string name;
        string img;
        string metadata;
        string matchName;
        string teamA;
        string teamB;
        bool isRunning;
        bool isFinished;
        uint32 cultPrice;
        uint8 squadLimit;
    }

    struct userLeagueData {
        string cultName;
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
    // to all the cultData associated on keyed match
    mapping(string => cultData[]) allLeagues;

    // internal mapping to store all the users participating in the given cult.
    // cultName => user_address array
    mapping(string => address[]) cultUsers;

    // this mapping is between the user address =>
    // cultParticipation data including cultIpfsLink and the createdSquadLink
    // PS: SquadLink can contain multiple squads for participating in the same cult
    mapping(address => userLeagueData[]) userParticipation;

    // this mapping is for maintaining the cults' leaderboard with all users'
    // points, positions and winner status
    // cultName => leaderboardData array
    mapping(string => leaderboardData[]) cultLeaderboard;

    address eAddr = 0xDeC6Df558e198A7745AcBe881f61B3506D59CFC4;
    address payable escrowAddr = payable(eAddr);

    function SetFinalLeaderboard(
        string memory cultName,
        string memory matchName,
        leaderboardData[] memory userLeaderboardData
    ) public returns (leaderboardData[] memory) {
        string memory finalNameSep = string.concat(cultName, ";;;");
        string memory finalName = string.concat(finalNameSep, matchName);
        leaderboardData[] storage allLeaderboards = cultLeaderboard[
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
        string memory cultName,
        string memory matchName,
        leaderboardData[] memory userLeaderboardData
    ) public returns (leaderboardData[] memory) {
        string memory finalNameSep = string.concat(cultName, ";;;");
        string memory finalName = string.concat(finalNameSep, matchName);
        leaderboardData[] storage allLeaderboards = cultLeaderboard[
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
            cultLeaderboard[finalName] = allLeaderboards;
        }
        return allLeaderboards;
    }

    // function CalculateLeaderboard(
    //     string memory cultName,
    //     string memory matchName,
    //     address[] memory user_address,
    //     uint32 finalPoints
    // ) public returns (leaderboardData[] memory) {
    //     string memory finalNameSep = string.concat(cultName, ";;;");
    //     string memory finalName = string.concat(finalNameSep, matchName);
    //     leaderboardData[] storage allLeaderboards = cultLeaderboard[
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
    //         cultLeaderboard[finalName] = allLeaderboards;
    //     }
    //     return allLeaderboards;
    // }

    function GetLeagueLeaderboard(
        string memory cultName,
        string memory matchName
    ) public view returns (leaderboardData[] memory) {
        string memory finalNameSep = string.concat(cultName, ";;;");
        string memory finalName = string.concat(finalNameSep, matchName);
        return cultLeaderboard[finalName];
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
        uint32 cultPrice,
        uint8 squadLimit
    ) public returns (cultData memory) {
        cultData[] storage addedLeagues = allLeagues[matchName];
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
                addedLeagues[i].cultPrice = cultPrice;
                addedLeagues[i].squadLimit = squadLimit;
                return (addedLeagues[i]);
            }
        }
        cultData memory lData = cultData(
            name,
            img,
            metadata,
            matchName,
            teamA,
            teamB,
            isRunning,
            isFinished,
            cultPrice,
            squadLimit
        );
        addedLeagues.push(lData);
        allLeagues[matchName] = addedLeagues;
        return (lData);
    }

    function GetLeagues(string memory matchCid)
        public
        view
        returns (cultData[] memory)
    {
        return (allLeagues[matchCid]);
    }

    function UserParticipate(
        address user_addr,
        string memory cultName,
        string memory matchName,
        string memory squadLink
    ) public payable returns (address, userLeagueData memory) {
        (bool sent, bytes memory data) = escrowAddr.call{value: msg.value}("");
        require(sent, "Failed to Transfer cultPrice");
        userLeagueData[] storage userLeagues = userParticipation[user_addr];
        string memory finalNameSep = string.concat(cultName, ";;;");
        string memory finalName = string.concat(finalNameSep, matchName);
        for (uint256 i = 0; i < userLeagues.length; i++) {
            // Case for when the user is participating in the cult with a subsequent squad
            if (
                keccak256(bytes(userLeagues[i].cultName)) ==
                keccak256(bytes(finalName))
            ) {
                string memory userSquads = userLeagues[i].squads;
                string memory addedSep = string.concat(userSquads, ";;;");
                string memory newSquad = string.concat(addedSep, squadLink);
                userLeagues[i].squads = newSquad;
                return (user_addr, userLeagues[i]);
            }
        }
        // Case for when the user is participating in a new cult with the first squad
        userLeagueData memory ul = userLeagueData(finalName, squadLink);
        userLeagues.push(ul);
        userParticipation[user_addr] = userLeagues;

        // push to cultUsers mapping
        address[] storage allLeagueUsers = cultUsers[finalName];
        allLeagueUsers.push(user_addr);

        // push to cultLeaderboard mapping
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
        leaderboardData[] storage leaderBoardData = cultLeaderboard[
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
        string memory cultName,
        string memory matchName
    ) public view returns (address[] memory) {
        string memory finalNameSep = string.concat(cultName, ";;;");
        string memory finalName = string.concat(finalNameSep, matchName);
        return cultUsers[finalName];
    }

    function GetUserLeagueParticipation(
        address user_addr,
        string memory cultName
    ) public view returns (address u_addr, userLeagueData memory u_cult) {
        userLeagueData[] storage userLeagues = userParticipation[user_addr];
        for (uint256 i = 0; i < userLeagues.length; i++) {
            if (
                keccak256(bytes(userLeagues[i].cultName)) ==
                keccak256(bytes(cultName))
            ) {
                return (user_addr, userLeagues[i]);
            }
        }
    }
}