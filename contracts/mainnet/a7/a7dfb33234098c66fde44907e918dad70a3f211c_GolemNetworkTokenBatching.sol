pragma solidity ^0.4.21;

contract ReceivingContract {
    function onTokenReceived(address _from, uint _value, bytes _data) public;
}

contract Gate {
    ERC20Basic private TOKEN;
    address private PROXY;

    /// Gates are to be created by the TokenProxy.
    function Gate(ERC20Basic _token, address _proxy) public {
        TOKEN = _token;
        PROXY = _proxy;
    }

    /// Transfer requested amount of tokens from Gate to Proxy address.
    /// Only the Proxy can request this and should request transfer of all
    /// tokens.
    function transferToProxy(uint256 _value) public {
        require(msg.sender == PROXY);

        require(TOKEN.transfer(PROXY, _value));
    }
}

contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  /**
  * @dev total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}

contract BurnableToken is BasicToken {

  event Burn(address indexed burner, uint256 value);

  /**
   * @dev Burns a specific amount of tokens.
   * @param _value The amount of token to be burned.
   */
  function burn(uint256 _value) public {
    require(_value <= balances[msg.sender]);
    // no need to require value <= totalSupply, since that would imply the
    // sender&#39;s balance is greater than the totalSupply, which *should* be an assertion failure

    address burner = msg.sender;
    balances[burner] = balances[burner].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    emit Burn(burner, _value);
    emit Transfer(burner, address(0), _value);
  }
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn&#39;t hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender&#39;s allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    require(allowed[msg.sender][_spender] == 0);
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

contract TokenProxy is StandardToken, BurnableToken {

    ERC20Basic public TOKEN;

    mapping(address => address) private gates;


    event GateOpened(address indexed gate, address indexed user);

    event Mint(address indexed to, uint256 amount);

    function TokenProxy(ERC20Basic _token) public {
        TOKEN = _token;
    }

    function getGateAddress(address _user) external view returns (address) {
        return gates[_user];
    }

    /// Create a new migration Gate for the User.
    function openGate() external {
        address user = msg.sender;

        // Do not allow creating more than one Gate per User.
        require(gates[user] == 0);

        // Create new Gate.
        address gate = new Gate(TOKEN, this);

        // Remember User - Gate relationship.
        gates[user] = gate;

        emit GateOpened(gate, user);
    }

    function transferFromGate() external {
        address user = msg.sender;

        address gate = gates[user];

        // Make sure the User&#39;s Gate exists.
        require(gate != 0);

        uint256 value = TOKEN.balanceOf(gate);

        Gate(gate).transferToProxy(value);

        // Handle the information about the amount of migrated tokens.
        // This is a trusted information becase it comes from the Gate.
        totalSupply_ += value;
        balances[user] += value;

        emit Mint(user, value);
    }

    function withdraw(uint256 _value) external {
        withdrawTo(_value, msg.sender);
    }

    function withdrawTo(uint256 _value, address _destination) public {
        require(_value > 0 &amp;&amp; _destination != address(0));
        burn(_value);
        TOKEN.transfer(_destination, _value);
    }
}

contract GolemNetworkTokenBatching is TokenProxy {

    string public constant name = &quot;Golem Network Token Batching&quot;;
    string public constant symbol = &quot;GNTB&quot;;
    uint8 public constant decimals = 18;


    event BatchTransfer(address indexed from, address indexed to, uint256 value,
        uint64 closureTime);

    function GolemNetworkTokenBatching(ERC20Basic _gntToken) TokenProxy(_gntToken) public {
    }

    function batchTransfer(bytes32[] payments, uint64 closureTime) external {
        require(block.timestamp >= closureTime);

        uint balance = balances[msg.sender];

        for (uint i = 0; i < payments.length; ++i) {
            // A payment contains compressed data:
            // first 96 bits (12 bytes) is a value,
            // following 160 bits (20 bytes) is an address.
            bytes32 payment = payments[i];
            address addr = address(payment);
            require(addr != address(0) &amp;&amp; addr != msg.sender);
            uint v = uint(payment) / 2**160;
            require(v <= balance);
            balances[addr] += v;
            balance -= v;
            emit BatchTransfer(msg.sender, addr, v, closureTime);
        }

        balances[msg.sender] = balance;
    }

    function transferAndCall(address to, uint256 value, bytes data) external {
      // Transfer always returns true so no need to check return value
      transfer(to, value);

      // No need to check whether recipient is a contract, this method is
      // supposed to used only with contract recipients
      ReceivingContract(to).onTokenReceived(msg.sender, value, data);
    }
}