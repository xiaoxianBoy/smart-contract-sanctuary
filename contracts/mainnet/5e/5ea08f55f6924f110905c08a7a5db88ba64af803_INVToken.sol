pragma solidity ^0.4.23;
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b &gt; 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn&#39;t hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b &lt;= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c &gt;= a);
    return c;
  }
}


contract owned {
    address public owner;
    
    constructor () public {
      owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        require(newOwner != 0x0);
        require(newOwner != owner);
        owner = newOwner;
    }
    
   
}


contract TokenERC20 {
    
    using SafeMath for uint256;
    
    // Public variables of the token
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    // This creates an array with all balances
    mapping (address =&gt; uint256) public balanceOf;
    mapping (address =&gt; mapping (address =&gt; uint256)) public allowance;

    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);


    /**
     * Constrctor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    constructor () public {}

    /**
     * Internal transfer, only can be called by this contract
     */
    function _transfer(address _from, address _to, uint _value) internal {
        // Prevent transfer to 0x0 address. Use burn() instead
        require(_to != 0x0);
        // Check if the sender has enough
        require(balanceOf[_from] &gt;= _value);
        // Check for overflows
        require(balanceOf[_to].add(_value) &gt; balanceOf[_to]);
        // Save this for an assertion in the future
        uint previousBalances = balanceOf[_from].add(balanceOf[_to]);
        // Subtract from the sender
        balanceOf[_from] = balanceOf[_from].sub(_value);
        // Add the same to the recipient
        balanceOf[_to] = balanceOf[_to].add(_value);
        emit Transfer(_from, _to, _value);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(balanceOf[_from].add(balanceOf[_to]) == previousBalances);
    }

    /**
     * Transfer tokens
     *
     * Send `_value` tokens to `_to` from your account
     *
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }

    /**
     * Transfer tokens from other address
     *
     * Send `_value` tokens to `_to` in behalf of `_from`
     *
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value &lt;= allowance[_from][msg.sender]);     // Check allowanc
        allowance[_from][msg.sender] =allowance[_from][msg.sender].sub(_value);
        _transfer(_from, _to, _value);
        return true;
    }

    /**
     * Set allowance for other address
     *
     * Allows `_spender` to spend no more than `_value` tokens in your behalf
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     */
    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        require(_spender != 0x0);    
        allowance[msg.sender][_spender] = _value;
        return true;
    }

   
}

/******************************************/
/*       INV TOKEN STARTS HERE       */
/******************************************/

contract INVToken is owned,TokenERC20 {

    string public name = &quot;INVESTACOIN&quot;;
    string public symbol = &quot;INV&quot;;
    uint8 public decimals = 18;
    address private paymentAddress = 0x75B42A1AB0e23e24284c8E0E8B724472CF8623Cd;
    
    
    uint256 public buyPrice;
    uint256 public totalSupply = 50000000e18;  
    
    
    mapping (address =&gt; bool) public frozenAccount;

    /* This generates a public event on the blockchain that will notify clients */
    event FrozenFunds(address target, bool frozen);

    /* Initializes contract with initial supply tokens to the creator of the contract */
   constructor () public owned() TokenERC20()  {
        balanceOf[msg.sender] = totalSupply;
        
    }
    
    
    function () payable {
        buy();
    }
    
    /**
   * Transfer given number of tokens from given owner to given recipient.
   *
   * @param _from address to transfer tokens from the owner of
   * @param _to address to transfer tokens to the owner of
   * @param _value number of tokens to transfer from given owner to given
   *        recipient
   * @return true if tokens were transferred successfully, false otherwise
   */
  function transferFrom(address _from, address _to, uint256 _value)
    returns (bool success) {
	require(!frozenAccount[_from]);
    return TokenERC20.transferFrom(_from, _to, _value);
  }
  
  /**
   * Transfer given number of tokens from message sender to given recipient.
   * @param _to address to transfer tokens to the owner of
   * @param _value number of tokens to transfer to the owner of given address
   * @return true if tokens were transferred successfully, false otherwise
   */
  function transfer(address _to, uint256 _value) public {
    require(!frozenAccount[msg.sender]);
    return TokenERC20.transfer(_to, _value);
  }


    /// @notice `freeze? Prevent | Allow` `target` from sending &amp; receiving tokens
    /// @param target Address to be frozen
    /// @param freeze either to freeze it or not
    
    function freezeAccount(address target, bool freeze) onlyOwner public {
        frozenAccount[target] = freeze;
        emit FrozenFunds(target, freeze);
    }

    /// @notice Allow users to buy tokens for `newBuyPrice` eth and sell tokens for `newSellPrice` eth
    /// @param newBuyPrice Price users can buy from the contract
    function setbuyPrice( uint256 newBuyPrice) onlyOwner public {
        require(newBuyPrice &gt; 0);
        buyPrice = newBuyPrice;
    }
    
    function transferPaymentAddress(address newPaymentAddress) onlyOwner public {
        require(newPaymentAddress != 0x0);
        require(newPaymentAddress != paymentAddress);
        paymentAddress = newPaymentAddress;
    }
    
	
    /// @notice Buy tokens from contract by sending ether
    function buy() payable public {
        require(msg.value &gt; 0);
        require(buyPrice &gt; 0);
        paymentAddress.transfer(msg.value);     // withdraw the ether to payment address
     
    }


}