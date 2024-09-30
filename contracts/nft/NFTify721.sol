// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "contracts/nft/lib/@openzeppelin/contracts/security/Pausable.sol";
import "contracts/nft/lib/@openzeppelin/contracts/access/Ownable.sol";
import "contracts/nft/lib/@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

import "./ERC721Permit.sol";

contract NFTify721 is Ownable, Pausable, ERC721Permit, ERC721Enumerable {
    string public baseURI;
    address public controller;

    /// Mapping that contains status of token ids if they are transferable or not.
    mapping(uint256 => bool) public tokenIdTransferAllowed;
    // Mapping that contains admin list to set nft transferable or not
    mapping(address => bool) public adminList;

    /// This event emitted when 'allowTransfer' function is executed.
    event TransferAllowed(uint256 indexed tokenId, bool indexed value);
    /// This event emitted when 'setTokenURI' function is executed.
    event BaseURIChanged(string indexed baseURI);

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _uri,
        address _controller
    ) ERC721(_name, _symbol) {
        controller = _controller;
        baseURI = _uri;
    }

    function isAdmin(address _admin) public view returns (bool) {
        return adminList[_admin];
    }
    
    function setAdminList(address _admin, bool _status) external onlyOwner {
        adminList[_admin] = _status;
    }

    /**
     * @notice This function set status of particular tokenId to be transferable or not.
     * By default, all tokens are not transferable.
     * Can be called only by owner of the contract or account with "MINTER_ROLE".
     * @param tokenId tokenId.
     * @param value boolean value of new status. True - transferable, false - not transferable.
     */
    function allowTransfer(uint256 tokenId, bool value) external {
        // require(
        //     _msgSender() == controller || _msgSender() == owner() || isAdmin(_msgSender()),
        //     "NFTify721: only owner|controller|admin"
        // );
        tokenIdTransferAllowed[tokenId] = value;

        emit TransferAllowed(tokenId, value);
    }

    /**
     * @dev See {ERC721-_beforeTokenTransfer}
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal virtual override(ERC721, ERC721Enumerable) {
        if (from != address(0)) {
            require(tokenIdTransferAllowed[tokenId], "ERC721: transfer of locked token id");
        }
        super._beforeTokenTransfer(from, to, tokenId, batchSize);

        require(!paused(), "NFTify721: token transfer while paused");
    }

    /**
     * @dev See {ERC721-_baseURI}
     */
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string memory newURI) public onlyOwner {
        baseURI = newURI;
        emit BaseURIChanged(newURI);
    }

    /**
     * @dev Approve the controller for minting
     */
    function setController(address _newController) public onlyOwner {
        controller = _newController;
    }

    /**
     * @dev Handle mint request
     *
     * Requirement:
     * - caller must be owner or controller
     *
     */
    function mint(
        address account,
        uint256 id,
        bytes memory data
    ) public {
        // require(
        //     _msgSender() == controller || _msgSender() == owner(),
        //     "NFTify721: only owner or controller"
        // );
        _safeMint(account, id, data);
    }

    /**
     * @dev Handle burn request
     *
     * Requirement:
     * - caller must be owner or approved
     *
     */
    function burn(uint256 id) public virtual {
        require(
            _isApprovedOrOwner(_msgSender(), id),
            "NFTify721: caller is not owner nor approved"
        );
        _burn(id);
    }

    /**
     * @dev Pause all transfers in the contract
     */
    function pause() external virtual onlyOwner {
        _pause();
    }

    /**
     * @dev Unpause all transfers in the contract
     */
    function unpause() external virtual onlyOwner {
        _unpause();
    }

    /**
     * @dev See {ERC721Permit-supportsInterface, ERC721Enumerable-supportsInterface}
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721Enumerable, ERC721Permit)
        returns (bool)
    {
        return
            ERC721Enumerable.supportsInterface(interfaceId) ||
            ERC721Permit.supportsInterface(interfaceId);
    }
}
