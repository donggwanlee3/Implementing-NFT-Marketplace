# NFT Marketplace

Welcome to the NFT Marketplace project! This smart contract enables users to mint, buy, sell, and resell NFTs in a decentralized marketplace built on Ethereum using Solidity.

## Features

- **Minting NFTs:** Mint new NFTs and list them in the marketplace.
- **Buying NFTs:** Purchase listed NFTs at specified prices.
- **Reselling NFTs:** Relist purchased NFTs for sale.
- **Marketplace Views:** View all unsold items, items you've listed, and items you've purchased.
- **Listing Price Management:** Contract owner can update the listing price.


## Usage

### Deploying the Contract

Deploy the contract using Truffle after setting up a local blockchain (e.g., Ganache).

### Minting and Listing NFTs

Mint new NFTs by calling the `createToken` function with a token URI and price:
```javascript
function createToken(string memory tokenURI, uint256 price) public payable returns (uint)
```

### Buying and Reselling NFTs

- **Buying:** Call `createMarketSale` with the token ID and send the required ETH.
```javascript
function createMarketSale(uint256 tokenId) public payable
```

- **Reselling:** Call `resellToken` with the token ID and new price.
```javascript
function resellToken(uint256 tokenId, uint256 price) public payable
```

### Fetching Marketplace Items

- **Fetch Listed Items:**
```javascript
function fetchItemsListed() public view returns (MarketItem[] memory)
```

- **Fetch Purchased Items:**
```javascript
function fetchMyNFTs() public view returns (MarketItem[] memory)
```

- **Fetch Unsold Items:**
```javascript
function fetchMarketItems() public view returns (MarketItem[] memory)
```

## Code Structure

- **`NFTMarketplace.sol`**: Main contract file implementing the marketplace logic.
- **`NFT.sol`**: Contract for minting and managing NFTs.
- **`migrations/`**: Deployment scripts for the contracts.
- **`test/`**: Test files for testing contract functionality using Truffle.

