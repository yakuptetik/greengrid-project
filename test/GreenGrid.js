const chai = require("chai");
const expect = chai.expect;

describe("GreenGrid", function () {
    let GreenGrid;
    let greenGrid;
    let owner;
    let addr1;
    let addr2;

    beforeEach(async function () {
        GreenGrid = await ethers.getContractFactory("GreenGrid");
        [owner, addr1, addr2] = await ethers.getSigners();
        greenGrid = await GreenGrid.deploy();
        await greenGrid.deployed();
    });

    it("Should offer energy correctly", async function () {
        await greenGrid.offerEnergy(100, ethers.utils.parseEther("0.1"));
        const offer = await greenGrid.energyOffers(0);
        expect(offer.seller).to.equal(owner.address);
        expect(offer.amount).to.equal(100);
        expect(offer.price).to.equal(ethers.utils.parseEther("0.1"));
        expect(offer.active).to.equal(true);
    });

    it("Should purchase energy correctly", async function () {
        await greenGrid.offerEnergy(100, ethers.utils.parseEther("0.1"));
        await greenGrid
            .connect(addr1)
            .purchaseEnergy(0, 50, { value: ethers.utils.parseEther("5") });

        const offer = await greenGrid.energyOffers(0);
        expect(offer.amount).to.equal(50);

        const sellerBalance = await greenGrid.balances(owner.address);
        expect(sellerBalance).to.equal(ethers.utils.parseEther("5"));
    });
});
