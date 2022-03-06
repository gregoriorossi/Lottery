// SPDX-License-Identifier: GPL3.0

pragma solidity ^0.8.0;

// improvements method to dump wins to enabled account (modifiers)
contract LotteryContract {

    uint private WinByFactor;
    uint private randNonce = 0;

    constructor(uint winByFactor) {
        WinByFactor = winByFactor;
    }

    receive() external payable { }

    function play(uint8 luckyNumber) public payable canAffordWin(msg.value) returns (string memory) {
        // receive the money in the contract 
        payable(address(this)).transfer(msg.value);

        uint drawnNumber = PickUpRandomNumber();

        if (drawnNumber == luckyNumber) {
            uint prizeAmount = CalculatePrizeAmount(msg.value);
            bool sent = payable(msg.sender).send(prizeAmount);

            if (sent) {
                return "You won motherfucker!";
            } else {
                return "You won but something went wrong, sorry!";
            }
        }

        return "You lost motherfucker!";
    }

    function chargeLottery() public payable returns (string memory) {
        
        payable(address(this)).transfer(msg.value);

        return "Recharged!";
    }

    modifier canAffordWin(uint userBet) {
        uint balance = address(this).balance;
        uint winningPrize = CalculatePrizeAmount(userBet);
        uint maxBetAmount = CalculateMaxBetAmount();

        // "The bet amount is too large, you can bet at most " + maxBetAmount + " ether, in order to win " + winningPrize + " ether!"
        require(balance >= winningPrize, "The bet amount is too large"); 
        _;       
    }

    function CalculatePrizeAmount(uint userBet) private view returns (uint)
    {
        return userBet * WinByFactor;
    }

    function CalculateMaxBetAmount() private view returns (uint)
    {
        return address(this).balance / WinByFactor;
    }

    // check again https://www.sitepoint.com/solidity-pitfalls-random-number-generation-for-ethereum/#:~:text=Solidity%20is%20not%20capable%20of,more%20basic%20solutions%20are%20used.
    function PickUpRandomNumber() private view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce))) % 100;
    }
}