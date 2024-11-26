
const { expect } = require("chai");
const hre = require("hardhat");
describe("FlashLoanArbitrage", function () {
  let FlashLoanArbitrage, flashLoanContract;
  let owner, addr1;
  let mockAavePool, mockUniswapRouter, mockToken;
  let validAaveAddress="0x2f39d218133AFaB8F2B819B1066c7E434Ad94E9e";
  let validUniswapAddress="0xE592427A0AEce92De3Edee1F18E0157C05861564";
  const ZERO_ADDRESS = '0x0000000000000000000000000000000000000000';

  beforeEach(async function () {
    // Mock dependencies
    const MockAavePoolAddressesProvider = await hre.ethers.getContractFactory("MockAavePoolAddressesProvider");
    mockAavePool = await MockAavePoolAddressesProvider.deploy();
    await mockAavePool.waitForDeployment();

    const MockUniswapRouter = await hre.ethers.getContractFactory("MockUniswapRouter");
    mockUniswapRouter = await MockUniswapRouter.deploy();
    await mockUniswapRouter.waitForDeployment();

    const MockToken = await hre.ethers.getContractFactory("MockToken");
    mockToken = await MockToken.deploy("MockToken", "MTK", 18,hre.ethers.parseEther("1000"));
    await mockToken.waitForDeployment();

    // Deploy FlashLoanArbitrage contract
    FlashLoanArbitrage = await hre.ethers.getContractFactory("FlashLoanArbitrageFinalV5");
    [owner, addr1] = await ethers.getSigners();
    flashLoanContract = await FlashLoanArbitrage.deploy(validAaveAddress,validUniswapAddress);
    await flashLoanContract.waitForDeployment();

    
  });


  describe("Deployment Requirement", function() {
    it("Should revert if Aave Pool Address is zero", async function () {
        await expect(
          FlashLoanArbitrage.deploy(ZERO_ADDRESS, validUniswapAddress)
        ).to.be.revertedWith("Aave Pool Address cannot be zero address");
      });
      
      it("Should revert if Uniswap Router Address is zero", async function () {
        await expect(
          FlashLoanArbitrage.deploy(validAaveAddress, ZERO_ADDRESS)
        ).to.be.revertedWith("Uniswap Router Address cannot be zero address");
      });
  })

  

  describe("Execute Arbitrage Requirement",function(){

    it("Should revert if caller is not the owner", async function () {
        await expect(
            flashLoanContract.connect(addr1).executeArbitrage(
            "0x0000000000000000000000000000000000000001",
            1000,
            900,
            "0x"
          )
        ).to.be.revertedWith("Only the contract owner can call this function");
      });

      it("Should revert if asset is the zero address", async function () {
        await expect(
            flashLoanContract.executeArbitrage(
            ZERO_ADDRESS, // Invalid asset
            1000,
            900,
            "0x"
          )
        ).to.be.revertedWith("Asset could not be zero address");
      });
  
      it("Should revert if amount is 0", async function () {
        await expect(
            flashLoanContract.executeArbitrage(
            "0x0000000000000000000000000000000000000001",
            0, // Invalid amount
            900,
            "0x"
          )
        ).to.be.revertedWith("Swap amount have to larger than 0");
      });
    });
  
  describe("Check account balance", function(){
    it("Should revert if target asset is zero address", async function(){
        await expect(
            flashLoanContract.getBalance(
                ZERO_ADDRESS
            )
        ).to.be.revertedWith("Asset address can not be zero address");
    })
   });

  describe("Withdrawl money from contract", function(){

    it("Should revert if caller is not the owner", async function(){
        await expect(
            flashLoanContract.connect(addr1).withdraw(
                "0x0000000000000000000000000000000000000001"
            )
        ).to.be.revertedWith("Only the contract owner can call this function");
    });
    
    it("Should revert if target asset is zero address", async function(){
        await expect(
            flashLoanContract.withdraw(
                ZERO_ADDRESS
            )
        ).to.be.revertedWith("Asset address can not be zero address");
    });
  });
});


