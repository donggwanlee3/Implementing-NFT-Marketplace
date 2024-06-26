// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "./NFT.sol";


contract NFTMarketplace is NFT {
    using Counters for Counters.Counter;
    Counters.Counter public _tokenIds;
    Counters.Counter private _itemsSold;

    uint256 listingPrice = 0.025 ether;

    mapping(uint256 => MarketItem) private idToMarketItem;

    struct MarketItem {
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }

    event MarketItemCreated (
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold
    );

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _baseURI
    ) NFT(_name, _symbol, _baseURI) Ownable() {
    }

    /* Mints a token and lists it in the marketplace */
    function createToken(string memory tokenURI, uint256 price) public payable returns (uint) {
      _tokenIds.increment();
      uint256 newTokenId = _tokenIds.current();

      _mint(msg.sender, newTokenId);
      _setTokenURI(newTokenId, tokenURI);
      createMarketItem(newTokenId, price);
      return newTokenId;
    }


    function createMarketItem(uint256 tokenId, uint256 price) private {
      require(price > 0, "Price must be at least 1 wei");
    //   emit log_named_int("Msg.value is: ", msg.value);
      require(msg.value == listingPrice, "Price must be equal to listing price");

      idToMarketItem[tokenId] =  MarketItem(
        tokenId,
        payable(msg.sender),
        payable(address(this)),
        price,
        false
      );

      _transfer(msg.sender, address(this), tokenId);
      payable(msg.sender).transfer(msg.value - listingPrice);
      emit MarketItemCreated(
        tokenId,
        msg.sender,
        address(this),
        price,
        false
      );
    }

    /* Creates the sale of a marketplace item */
    /* Transfers ownership of the item, as well as funds between parties */
    function createMarketSale( uint256 tokenId) public payable {
      uint price = idToMarketItem[tokenId].price;
      address seller = idToMarketItem[tokenId].seller;
      require(msg.value == price, "Please submit the asking price in order to complete the purchase");
      idToMarketItem[tokenId].owner = payable(msg.sender);
      idToMarketItem[tokenId].sold = true;
      idToMarketItem[tokenId].seller = payable(address(0));
      _itemsSold.increment();
      _transfer(address(this), msg.sender, tokenId);
      payable(owner()).transfer(listingPrice);
      payable(seller).transfer(msg.value);
    }

    /* allows someone to resell a token they have purchased */
    function resellToken(uint256 tokenId, uint256 price) public payable {
      require(idToMarketItem[tokenId].owner == msg.sender, "Only item owner can perform this operation");
      require(msg.value == listingPrice, "Price must be equal to listing price");
      idToMarketItem[tokenId].sold = false;
      idToMarketItem[tokenId].price = price;
      idToMarketItem[tokenId].seller = payable(msg.sender);
      idToMarketItem[tokenId].owner = payable(address(this));
      _itemsSold.decrement();

      _transfer(msg.sender, address(this), tokenId);
    }

    /* Updates the listing price of the contract */
    function updateListingPrice(uint _listingPrice) public payable{
        // TODO: Change the listing price
        require(msg.sender == owner(), "Only contract owner can update listing price.");
        listingPrice = _listingPrice; 
    }

    /* Returns the listing price of the contract */
    function getListingPrice() public view returns (uint256) {
        return listingPrice;
    }

    /* Returns only items a user has listed */
    function fetchItemsListed() public view returns (MarketItem[] memory) {
        // Number of NFTs
        uint totalItemCount = _tokenIds.current();
        // The amount of NFTs owned by the user
        uint itemCount = 0;

        for (uint i = 1; i <= totalItemCount; i++) {

            MarketItem storage item = idToMarketItem[i];
            if (item.seller == msg.sender) {
                itemCount++;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        // Keeping track of the index of the return array
        uint currentIndex = 0;

        for (uint i = 1; i <= totalItemCount; i++) {
            MarketItem storage item = idToMarketItem[i];
            if (item.seller == msg.sender) {
                MarketItem storage currentItem = item;
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    /* Returns only items that a user has purchased */
    function fetchMyNFTs() public view returns (MarketItem[] memory) {
        uint totalItemCount = _tokenIds.current();
        uint itemCount = 0;
        for (uint i = 1; i <= totalItemCount; i++) {
            MarketItem storage item = idToMarketItem[i];
            if (item.owner == msg.sender) {
                itemCount++;
            }
        }
        MarketItem[] memory items = new MarketItem[](itemCount);
        uint currentIndex = 0;
        for (uint i = 1; i <= totalItemCount; i++) {
            // TODO: Same as before
            MarketItem storage item = idToMarketItem[i];
            if (item.owner == msg.sender) {
                MarketItem storage currentItem = item;
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    /* Returns all unsold market items */
    function fetchMarketItems() public view returns (MarketItem[] memory) {
        // Number of NFTs
        uint totalItemCount = _tokenIds.current();
        uint unsoldItemCount = totalItemCount - _itemsSold.current();
        uint currentIndex = 0;
        MarketItem[] memory items = new MarketItem[](unsoldItemCount);
        for (uint i = 1; i <= totalItemCount; i++) {
            MarketItem storage item = idToMarketItem[i];
            if (item.sold == false) {
                MarketItem storage currentItem = item;
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }
}