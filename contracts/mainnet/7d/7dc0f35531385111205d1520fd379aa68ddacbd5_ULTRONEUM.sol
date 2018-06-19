pragma solidity ^0.4.16;
// Ultroneum tokens Smart contract based on the full ERC20 Token standard
// https://github.com/ethereum/EIPs/issues/20
// Verified Status: ERC20 Verified Token
// Ultroneum tokens Symbol: XUM


contract ULTRONEUMToken { 
    /* This is a slight change to the ERC20 base standard.
    function totalSupply() constant returns (uint256 supply);
    is replaced with:
    uint256 public totalSupply;
    This automatically creates a getter function for the totalSupply.
    This is moved to the base contract since public getter functions are not
    currently recognised as an implementation of the matching abstract
    function by the compiler.
    */
    /// total amount of tokens
    uint256 public totalSupply;
    
    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) constant returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) returns (bool success);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);

    /// @notice `msg.sender` approves `_addr` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of wei to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}


/**
 * Ultroneum tokens Math operations with safety checks to avoid unnecessary conflicts
 */

library ABCMaths {
// Saftey Checks for Multiplication Tasks
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }
// Saftey Checks for Divison Tasks
  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b &gt; 0);
    uint256 c = a / b;
    assert(a == b * c + a % b);
    return c;
  }
// Saftey Checks for Subtraction Tasks
  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b &lt;= a);
    return a - b;
  }
// Saftey Checks for Addition Tasks
  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c&gt;=a &amp;&amp; c&gt;=b);
    return c;
  }
}

contract Ownable {
    address public owner;
    address public newOwner;

    /** 
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    function Ownable() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

   // validates an address - currently only checks that it isn&#39;t null
    modifier validAddress(address _address) {
        require(_address != 0x0);
        _;
    }

    function transferOwnership(address _newOwner) onlyOwner {
        if (_newOwner != address(0)) {
            owner = _newOwner;
        }
    }

    function acceptOwnership() {
        require(msg.sender == newOwner);
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
    event OwnershipTransferred(address indexed _from, address indexed _to);
}


contract XUMStandardToken is ULTRONEUMToken, Ownable {
    
    using ABCMaths for uint256;
    mapping (address =&gt; uint256) balances;
    mapping (address =&gt; mapping (address =&gt; uint256)) allowed;
    mapping (address =&gt; bool) public frozenAccount;

    event FrozenFunds(address target, bool frozen);
     
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function freezeAccount(address target, bool freeze) onlyOwner {
        frozenAccount[target] = freeze;
        FrozenFunds(target, freeze);
    }

    function transfer(address _to, uint256 _value) returns (bool success) {
        if (frozenAccount[msg.sender]) return false;
        require(
            (balances[msg.sender] &gt;= _value) // Check if the sender has enough
            &amp;&amp; (_value &gt; 0) // Don&#39;t allow 0value transfer
            &amp;&amp; (_to != address(0)) // Prevent transfer to 0x0 address
            &amp;&amp; (balances[_to].add(_value) &gt;= balances[_to]) // Check for overflows
            &amp;&amp; (msg.data.length &gt;= (2 * 32) + 4)); //mitigates the ERC20 short address attack
            //most of these things are not necesary

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (frozenAccount[msg.sender]) return false;
        require(
            (allowed[_from][msg.sender] &gt;= _value) // Check allowance
            &amp;&amp; (balances[_from] &gt;= _value) // Check if the sender has enough
            &amp;&amp; (_value &gt; 0) // Don&#39;t allow 0value transfer
            &amp;&amp; (_to != address(0)) // Prevent transfer to 0x0 address
            &amp;&amp; (balances[_to].add(_value) &gt;= balances[_to]) // Check for overflows
            &amp;&amp; (msg.data.length &gt;= (2 * 32) + 4) //mitigates the ERC20 short address attack
            //most of these things are not necesary
        );
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        /* To change the approve amount you first have to reduce the addresses`
         * allowance to zero by calling `approve(_spender, 0)` if it is not
         * already 0 to mitigate the race condition described here:
         * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729 */
        
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));
        allowed[msg.sender][_spender] = _value;

        // Notify anyone listening that this approval done
        Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }
  
}
contract ULTRONEUM is XUMStandardToken {

    /* Public variables of the token */
    /*
    NOTE:
    The following variables are OPTIONAL vanities. One does not have to include them.
    They allow one to customise the token contract &amp; in no way influences the core functionality.
    Some wallets/interfaces might not even bother to look at this information.
    */
    
    uint256 constant public decimals = 8;
    uint256 public totalSupply = 15 * (10**7) * 10**8 ; // 150 million tokens, 8 decimal places, 
    string constant public name = &quot;Ultroneum Token&quot;;
    string constant public symbol = &quot;XUM&quot;;
    
    function ULTRONEUM(){
        balances[msg.sender] = totalSupply;               // Give the creator all initial tokens
    }

    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        //call the receiveApproval function on the contract you want to be notified. This crafts the function signature manually so one doesn&#39;t have to include a contract in here just for this.
        //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)
        //it is assumed that when does this that the call *should* succeed, otherwise one would use vanilla approve instead.
        require(_spender.call(bytes4(bytes32(sha3(&quot;receiveApproval(address,uint256,address,bytes)&quot;))), msg.sender, _value, this, _extraData));
        return true;
    }
}