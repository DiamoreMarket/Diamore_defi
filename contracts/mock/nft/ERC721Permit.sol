// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./lib/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./lib/@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import "./lib/@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

import "./IERC721Permit.sol";

abstract contract ERC721Permit is ERC721, IERC721Permit {
    bytes32 public constant PERMIT_TYPEHASH =
        keccak256(
            "Permit(address owner,address spender,uint256 nonce,uint256 deadline)"
        );

    mapping(address => uint256) private _nonces;

    /**
     * This are save as immutable for cheap access
     * The chainId is also saved to be able to recompute domainSeparator in the case of fork
     */
    bytes32 private immutable _domainSeparator;
    uint256 private immutable _domainChainId;

    constructor() {
        uint256 chainId;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            chainId := chainid()
        }

        _domainChainId = chainId;
        _domainSeparator = _calculateDomainSeparator(chainId);
    }

    /**
     * @notice Builds the DOMAIN_SEPARATOR (eip712) at time of use
     * @dev This is not set as a constant, to ensure that the chainId will change in the event of a chain fork
     * @return the DOMAIN_SEPARATOR of eip712
     */
    function DOMAIN_SEPARATOR() public view override returns (bytes32) {
        uint256 chainId;

        //solhint-disable-next-line no-inline-assembly
        assembly {
            chainId := chainid()
        }

        return
            (chainId == _domainChainId)
                ? _domainSeparator
                : _calculateDomainSeparator(chainId);
    }

    function _calculateDomainSeparator(uint256 chainId)
        internal
        view
        returns (bytes32)
    {
        return
            keccak256(
                abi.encode(
                    keccak256(
                        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                    ),
                    keccak256(bytes(name())),
                    keccak256(bytes("1")),
                    chainId,
                    address(this)
                )
            );
    }

    /**
     * @dev See {IERC721WithPermitV1-nonces}
     */
    function nonces(address account) public view override returns (uint256) {
        return _nonces[account];
    }

    /**
     * @dev See {IERC721WithPermit-permit}
     */
    function permit(
        address owner,
        address spender,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public override {
        require(
            deadline >= block.timestamp,
            "ERC721WithPermit: permit deadline expired"
        );

        bytes32 digest = _buildDigest(owner, spender, _nonces[owner], deadline);

        (address recoveredAddress, ) = ECDSA.tryRecover(digest, v, r, s);

        require(
            recoveredAddress == owner,
            "ERC721WithPermit: invalid permit signature"
        );

        _nonces[owner]++;

        _setApprovalForAll(owner, spender, true);
    }

    /**
     * @notice Builds the permit digest to sign
     * @param owner the token owner
     * @param spender the token spender
     * @param nonce the nonce to make a permit for
     * @param deadline the deadline before when the permit can be used
     * @return the digest to sign
     */
    function _buildDigest(
        address owner,
        address spender,
        uint256 nonce,
        uint256 deadline
    ) public view returns (bytes32) {
        return
            ECDSA.toTypedDataHash(
                DOMAIN_SEPARATOR(),
                keccak256(
                    abi.encode(PERMIT_TYPEHASH, owner, spender, nonce, deadline)
                )
            );
    }

    /**
     * @notice Query if a contract implements an interface
     * @param interfaceId The interface identifier, as specified in ERC-165
     * @dev Overriden from ERC721 here in order to include the interface of this EIP
     * @return `true` if the contract implements `interfaceID` and `interfaceID` is not 0xffffffff, `false` otherwise
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return
            interfaceId == type(IERC721Permit).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
