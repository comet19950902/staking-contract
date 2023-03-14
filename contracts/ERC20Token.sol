// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

library SafeMath {
    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

contract RewardToken {
    using SafeMath for uint256;

    string public _name = "RewardToken";
    string public _symbol = "rt";
    uint256 public _totalSupply;
    uint8 public _decimals = 18;
    uint256 public mintingReductionInterval = 7776000; // 3 months would be approximately 3 * 30 * 24 * 60 * 60 = 7776000 seconds.
    uint256 public currentMintingRate = 100;
    uint256 public lastReductionTimestamp;

    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowed;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Burn(address indexed burner, uint256 value);

    constructor(uint256 initialSupply) {
        _totalSupply = initialSupply * 10 ** uint256(_decimals);
        balances[msg.sender] = _totalSupply;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function approve(
        address owner,
        address spender,
        uint256 amount
    ) public returns (bool success) {
        require(amount > 0, "amount must be more than 0");
        allowed[owner][spender] = amount;
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view returns (uint256) {
        return allowed[owner][spender];
    }

    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    function transfer(address recipient, uint256 amount) public {
        require(recipient != address(0), "can't transfer to 0x0");
        require(amount > 0, "amount must be more than 0");
        require(balances[msg.sender] >= amount, "Not enough balance.");
        require(
            balances[recipient] + amount >= balances[recipient],
            "Overflow."
        );

        balances[msg.sender] = balances[msg.sender].sub(amount);
        balances[recipient] = balances[recipient].add(amount);

        emit Transfer(msg.sender, recipient, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public {
        require(recipient != address(0), "can't transfer to 0x0");
        require(amount > 0, "amount must be more than 0");
        require(balances[sender] >= amount, "Not enough balance.");
        require(
            balances[recipient] + amount >= balances[recipient],
            "Overflow."
        );
        require(allowed[sender][msg.sender] >= amount, "Not enough allowance.");

        balances[sender] = balances[sender].sub(amount);
        balances[recipient] = balances[msg.sender].add(amount);
        allowed[sender][msg.sender] = allowed[sender][msg.sender].sub(amount);

        emit Transfer(sender, recipient, amount);
    }

    function mint(
        address account,
        uint256 amount
    ) public returns (bool success) {
        require(account != address(0));

        _totalSupply = _totalSupply.add(amount);
        balances[msg.sender] = balances[msg.sender].add(amount);

        emit Transfer(address(0), msg.sender, amount);

        return true;
    }

    // call burn function through the house edge reduction function LINE: 59
    function burn(uint256 amount) public returns (bool success) {
        require(balances[msg.sender] >= amount, "Not enough balance.");
        require(amount > 0, "amount must be more than 0");

        balances[msg.sender] = balances[msg.sender].sub(amount);
        _totalSupply = _totalSupply.sub(amount);

        emit Burn(msg.sender, amount);

        return true;
    }
}
