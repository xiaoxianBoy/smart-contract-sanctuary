pragma solidity ^0.4.23;

interface ERC20 {
    function decimals() external view returns(uint);
}

contract GetDecimals {
    function getDecimals(ERC20 token) external view returns (uint){
        bytes memory data = abi.encodeWithSignature(&quot;decimals()&quot;);
        if(!address(token).call(data)) {
            // call failed
            return 18;
        }
        else {
            return token.decimals();
        }
    }
    
    function testRevert() public pure returns(string) {
        revert(&quot;ilan is the king&quot;);
        return &quot;hello world&quot;;
    }
    
    function testRevertTx() public returns(string) {
        return testRevert();
    }    
}