// SPDX-License-Identifier: ISC
pragma solidity ^0.7.0;

interface ERC20Interface {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    // indexed
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );
}

contract ERC20Token is ERC20Interface {
    string public tokenName;
    string public tokenSymbol;
    uint8 public decimals;
    uint256 public supply;

    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowances;

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _totalSupply
    ) {
        tokenName = _name;
        tokenSymbol = _symbol;
        decimals = _decimals;
        supply = _totalSupply;

        balances[msg.sender] = _totalSupply;
    }

    function transfer(address to, uint256 amount)
        external
        override(ERC20Interface)
        returns (bool success)
    {
        require(balances[msg.sender] >= amount, "not enough balance");
        balances[msg.sender] -= amount;
        balances[to] += amount;
        // fire event to notify front end
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external override(ERC20Interface) returns (bool success) {
        uint256 _allowance = allowances[from][msg.sender];
        require(
            balances[from] >= amount && _allowance >= amount,
            "not enough balance"
        );

        allowances[from][msg.sender] -= amount;
        balances[from] -= amount;
        balances[to] += amount;

        emit Transfer(from, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount)
        external
        override(ERC20Interface)
        returns (bool success)
    {
        require(spender != msg.sender, "cannot self approve");
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function allowance(address owner, address spender)
        external
        view
        override(ERC20Interface)
        returns (uint256 amount)
    {
        return allowances[owner][spender];
    }

    function balanceOf(address owner)
        external
        view
        override(ERC20Interface)
        returns (uint256 amount)
    {
        return balances[owner];
    }

    function name()
        external
        view
        override(ERC20Interface)
        returns (string memory)
    {
        return tokenName;
    }

    function symbol()
        external
        view
        override(ERC20Interface)
        returns (string memory)
    {
        return tokenSymbol;
    }

    function totalSupply()
        external
        view
        override(ERC20Interface)
        returns (uint256 amount)
    {
        return supply;
    }
}
