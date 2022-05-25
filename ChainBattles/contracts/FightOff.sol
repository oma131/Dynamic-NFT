// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract FightOff is ERC721URIStorage {
    using Strings for uint256;
    using Counters for Counters.Counter; 
    Counters.Counter private _tokenIds;

    struct Traits {
        uint level;
        uint speed;
        uint strength;
        uint life;
    }

    mapping(uint256 => Traits) public tokenIdToTraits;

    constructor() ERC721 ("FightOff", "FFS"){

    }

    function generateCharacter(uint256 tokenId) public view returns (string memory){

        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
                '<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>',
                '<rect width="100%" height="100%" fill="black" />',
                '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">',"Champion",'</text>',
                '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">', "Levels: ",getLevels(tokenId),'</text>',
                '<text x="50%" y="60%" class="base" dominant-baseline="middle" text-anchor="middle">', "Speed: ",getSpeed(tokenId),'</text>',
                '<text x="50%" y="65%" class="base" dominant-baseline="middle" text-anchor="middle">', "Strength: ",getStrength(tokenId),'</text>',
                '<text x="50%" y="70%" class="base" dominant-baseline="middle" text-anchor="middle">', "Life: ",getLife(tokenId),'</text>',
            '</svg>'
        );
        return string(
            abi.encodePacked(
                "data:image/svg+xml;base64,",
                Base64.encode(svg)
            )    
        );
    }

    function getLevels(uint256 tokenId) public view returns (string memory) {
        Traits memory _traits = tokenIdToTraits[tokenId];
        return _traits.level.toString();
    }
    function getSpeed(uint256 tokenId) public view returns (string memory) {
        Traits memory _traits = tokenIdToTraits[tokenId];
        return _traits.speed.toString();
    }
    function getStrength(uint256 tokenId) public view returns (string memory) {
        Traits memory _traits = tokenIdToTraits[tokenId];
        return _traits.strength.toString();
    }
    function getLife(uint256 tokenId) public view returns (string memory) {
        Traits memory _traits = tokenIdToTraits[tokenId];
        return _traits.life.toString();
    }

    function getTokenURI(uint256 tokenId) public returns (string memory){
        bytes memory dataURI = abi.encodePacked(
            '{',
                '"name": "Fight Off #', tokenId.toString(), '",',
                '"description": "Fights taking place on chain",',
                '"image": "', generateCharacter(tokenId), '"',
            '}'
        );
        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(dataURI)
            )
        );
    }

    function mint() public {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);
        Traits storage _traits = tokenIdToTraits[newItemId];
        _traits.level = 1;
        _traits.speed = 4;
        _traits.strength = 3;
        _traits.life = 5;
        _setTokenURI(newItemId, getTokenURI(newItemId));
    }

    function train(uint256 tokenId) public {
        require(_exists(tokenId));
        require(ownerOf(tokenId) == msg.sender, "You must own this NFT to train it!");
        
        Traits storage _traits = tokenIdToTraits[tokenId];
        uint256 currentLevel = _traits.level;
        _traits.level = currentLevel + 1;

        uint256 currentSpeed = _traits.speed;
        _traits.speed = currentSpeed + generateRandomNumber(currentSpeed);
        
        uint256 currentStrength = _traits.strength;
        _traits.speed = currentStrength + generateRandomNumber(currentStrength);
        
        uint256 currentLife = _traits.life;
        _traits.speed = currentLife + 1;

        _setTokenURI(tokenId, getTokenURI(tokenId));
    }

    function generateRandomNumber(uint256 max) public view returns (uint256) {
        bytes memory seed = abi.encodePacked(block.timestamp,block.difficulty,msg.sender);
        uint256 rand = random(seed,max);
        return rand;
    }

    function random(bytes memory _seed, uint256 max) private pure returns (uint256) {
        return uint256(keccak256(_seed)) % max;        
    }
    
}
