// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GreenGrid {
    struct EnergyOffer {
        address seller;
        uint256 amount; // kWh cinsinden
        uint256 price; // Wei cinsinden, kWh başına
        bool active;
    }

    EnergyOffer[] public energyOffers;
    mapping(address => uint256) public balances;

    event EnergyOffered(uint256 offerId, address seller, uint256 amount, uint256 price);
    event EnergyPurchased(uint256 offerId, address buyer, uint256 amount, uint256 totalPrice);

    function offerEnergy(uint256 _amount, uint256 _price) public {
        energyOffers.push(EnergyOffer({
            seller: msg.sender,
            amount: _amount,
            price: _price,
            active: true
        }));
        emit EnergyOffered(energyOffers.length - 1, msg.sender, _amount, _price);
    }

    function purchaseEnergy(uint256 _offerId, uint256 _amount) public payable {
        EnergyOffer storage offer = energyOffers[_offerId];
        require(offer.active, "Teklif artik aktif degil");
        require(_amount <= offer.amount, "Yetersiz enerji miktari");
        
        uint256 totalPrice = _amount * offer.price;
        require(msg.value >= totalPrice, "Yetersiz odeme");

        offer.amount -= _amount;
        if (offer.amount == 0) {
            offer.active = false;
        }

        balances[offer.seller] += totalPrice;
        
        if (msg.value > totalPrice) {
            payable(msg.sender).transfer(msg.value - totalPrice);
        }

        emit EnergyPurchased(_offerId, msg.sender, _amount, totalPrice);
    }

    function withdrawBalance() public {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "Cekilecek bakiye yok");
        
        balances[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }
}