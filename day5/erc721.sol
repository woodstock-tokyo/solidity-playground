// SPDX-License-Indentifier: ISC
pragma solidity ^0.7.0;

library AddressUtils {
    function isContract(address _addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(_addr)
        } // solhint-disable-line
        return size > 0;
    }
}

/* is ERC165 */
interface ERC721 {
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 indexed _tokenId
    );
    event Approval(
        address indexed _owner,
        address indexed _approved,
        uint256 indexed _tokenId
    );
    event ApprovalForAll(
        address indexed _owner,
        address indexed _operator,
        bool _approved
    );

    function balanceOf(address _owner) external view returns (uint256);

    function ownerOf(uint256 _tokenId) external view returns (address);

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes calldata data
    ) external payable;

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external payable;

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external payable;

    function approve(address _approved, uint256 _tokenId) external payable;

    function setApprovalForAll(address _operator, bool _approved) external;

    function getApproved(uint256 _tokenId) external view returns (address);

    function isApprovedForAll(address _owner, address _operator)
        external
        view
        returns (bool);
}

/// @dev Note: the ERC-165 identifier for this interface is 0x150b7a02.
interface ERC721TokenReceiver {
    function onERC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes calldata _data
    ) external returns (bytes4);
}

contract ERC721Token is ERC721 {
    using AddressUtils for address;
    // isContract(address) x
    // address.isContract() o

    mapping(address => uint256) private ownerToTokenAmount;
    mapping(uint256 => address) private idToOwner;
    mapping(uint256 => address) private idToApproved;
    mapping(address => mapping(address => bool)) private ownerToOperators;

    bytes4 private constant MAGIC_ON_ERC721_RECEIVED = 0x150b7a02;

    function balanceOf(address _owner)
        external
        view
        override
        returns (uint256)
    {
        return ownerToTokenAmount[_owner];
    }

    function ownerOf(uint256 _tokenId)
        external
        view
        override
        returns (address)
    {
        return idToOwner[_tokenId];
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes calldata _data
    ) external payable override {
        _safeTransferFrom(_from, _to, _tokenId, _data);
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external payable override {
        _safeTransferFrom(_from, _to, _tokenId, "");
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external payable override {
        _transfer(_from, _to, _tokenId);
    }

    function approve(address _approved, uint256 _tokenId)
        external
        payable
        override
    {
        address owner = idToOwner[_tokenId];
        require(msg.sender == owner, "Not authorized");
        idToApproved[_tokenId] = _approved;
        emit Approval(owner, _approved, _tokenId);
    }

    function setApprovalForAll(address _operator, bool _approved)
        external
        override
    {
        ownerToOperators[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function getApproved(uint256 _tokenId)
        external
        view
        override
        returns (address)
    {
        return idToApproved[_tokenId];
    }

    function isApprovedForAll(address _owner, address _operator)
        external
        view
        override
        returns (bool)
    {
        return ownerToOperators[_owner][_operator];
    }

    function _safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory _data
    ) internal {
        _transfer(_from, _to, _tokenId);
        if (_to.isContract()) {
            bytes4 retval =
                ERC721TokenReceiver(_to).onERC721Received(
                    msg.sender,
                    _from,
                    _tokenId,
                    _data
                );
            require(
                retval == MAGIC_ON_ERC721_RECEIVED,
                "recipient smart contract cannot handle ERC721 tokens"
            );
        }
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _tokenId
    ) internal canTransfer(_tokenId) {
        ownerToTokenAmount[_from] -= 1;
        ownerToTokenAmount[_to] += 1;
        idToOwner[_tokenId] = _to;
        emit Transfer(_from, _to, _tokenId);
    }

    modifier canTransfer(uint256 _tokenId) {
        // msg.sender is operator (can be non-owner)
        address owner = idToOwner[_tokenId];
        require(
            owner == msg.sender ||
                idToApproved[_tokenId] == msg.sender ||
                ownerToOperators[owner][msg.sender],
            "Transfer not authorized"
        );
        _;
    }
}
