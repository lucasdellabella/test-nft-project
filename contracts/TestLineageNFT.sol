//Contract based on https://docs.openzeppelin.com/contracts/3.x/erc721
// SPDX-License-Identifier: MIT
pragma solidity ^0.7.3;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract TestLineageNFT is ERC721, Ownable {

    // mapping from family/animal to the valid modifiers
    mapping(string => string[]) private familyModifiers;

    string[] private familyColors = [
        "chrome",
        "gold",
        "silver"
        "scarlet",
        "sapphire",
        "emerald"
    ];

    string[] private families = [
        "dragon",
        "griffin",
        "lion"
    ];

    string[] private locations = [
        "below the setting sun",
        "below the rising sun",
        "below the noonday sun",
        "below a waxing moon",
        "below a waning moon",
        "below a new moon"
    ];

    // TODO: Probably need a better random function that can't be predicted / reverse engineered
    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    function pickFromList(uint256 tokenId, string memory keyPrefix, string[] memory sourceArray) internal view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked(keyPrefix, intToString(tokenId))));
        return sourceArray[rand % sourceArray.length];
    }

    function getFamilyModifier(uint256 tokenId) public view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked("FAMILYMODIFIER", intToString(tokenId))));
        string[] modifiers = familyModifiers[getFamilyAnimal(tokenId)];
        return modifiers[rand % modifiers.length];
    }

    function getFamilyColor(uint256 tokenId) public view returns (string memory) {
        return pickFromList(tokenId, "FAMILYCOLOR", familyColors);
    }

    function getFamilyAnimal(uint256 tokenId) public view returns (string memory) {
        return pickFromList(tokenId, "FAMILYANIMAL", families);
    }

    function getFamilyLocation(uint256 tokenId) public view returns (string memory) {
        return pickFromList(tokenId, "LOCATION", locations);
    }


    function getFirstLine(uint256 tokenId) public view returns (string memory) {
        string memory firstLine = "A";
        firstLine = abi.encodePacked(firstLine, " ", getFamilyModifier(tokenId));
        firstLine = abi.encodePacked(firstLine, " ", getFamilyColor(tokenId));
        firstLine = abi.encodePacked(firstLine, " ", getFamilyAnimal(tokenId));
        firstLine = abi.encodePacked(firstLine, " ", getFamilyLocation(tokenId));
        return firstLine;
    }

    function tokenURI(uint256 tokenId) override public view returns (string memory) {
        string[17] memory parts;
        parts[0] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: black; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="white" /><text x="10" y="20" class="base">';

        parts[1] = getFirstLine(tokenId);

        parts[16] = '</text></svg>';

        string memory output = string(abi.encodePacked(parts[0], parts[1], parts[2], parts[3], parts[4], parts[5], parts[6], parts[7], parts[8]));
        output = string(abi.encodePacked(output, parts[9], parts[10], parts[11], parts[12], parts[13], parts[14], parts[15], parts[16]));

        string memory json = Base64.encode(bytes(string(abi.encodePacked('{"name": "Bag #', intToString(tokenId), '", "description": "Loot is randomized adventurer gear generated and stored on chain. Stats, images, and other functionality are intentionally omitted for others to interpret. Feel free to use Loot in any way you want.", "image": "data:image/svg+xml;base64,', Base64.encode(bytes(output)), '"}'))));
        output = string(abi.encodePacked('data:application/json;base64,', json));

        return output;
    }

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    function mintNFT(address recipient)
        public onlyOwner
        returns (uint256)
    {
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _mint(recipient, newItemId);

        return newItemId;
    }

    constructor() public ERC721("LineageTest", "LINEAGETEST1") {
        familyModifiers["Dragon"] = [
            "One-winged",
            "Eyeless",
            "Two-tailed"
        ];
        familyModifiers["Griffin"] = [
            "One-winged",
            "Eyeless",
            "Two-tailed"
        ];
        familyModifiers["Lion"] = [
            "Eyeless",
            "Two-tailed"
        ];
    }

    /** Library Fns I copy-pasted **/
    function intToString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /// [MIT License]
/// @title Base64
/// @notice Provides a function for encoding some bytes in base64
/// @author Brecht Devos <brecht@loopring.org>
library Base64 {
    bytes internal constant TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    /// @notice Encodes some bytes to the base64 representation
    function encode(bytes memory data) internal pure returns (string memory) {
        uint256 len = data.length;
        if (len == 0) return "";

        // multiply by 4/3 rounded up
        uint256 encodedLen = 4 * ((len + 2) / 3);

        // Add some extra buffer at the end
        bytes memory result = new bytes(encodedLen + 32);

        bytes memory table = TABLE;

        assembly {
            let tablePtr := add(table, 1)
            let resultPtr := add(result, 32)

            for {
                let i := 0
            } lt(i, len) {

            } {
                i := add(i, 3)
                let input := and(mload(add(data, i)), 0xffffff)

                let out := mload(add(tablePtr, and(shr(18, input), 0x3F)))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(12, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(6, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(input, 0x3F))), 0xFF))
                out := shl(224, out)

                mstore(resultPtr, out)

                resultPtr := add(resultPtr, 4)
            }

            switch mod(len, 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }

            mstore(result, encodedLen)
        }

        return string(result);
    }

}
