//SPDX License Identifier: MIT License

pragma solidity >= 0.7.0 < 0.9.0 ;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol" ;
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

contract NewToken is ERC20 {
    IUniswapV2Router02 public uniswapRouter = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    IUniswapV2Factory public uniswapFactory ;
    address public uniswapPair ;
    address payable internal sources ;

    constructor () ERC20("TestingTKN", "TKN") {
        _mint(msg.sender, 1000000 * 10 ** 18); // mint new token for deployer/msg.sender
        sources = payable(msg.sender) ;
     
    }

    function createPair(address newToken, address etherUniswap) public {
        uniswapFactory = IUniswapV2Factory(uniswapRouter.factory());
        uniswapPair = uniswapFactory.createPair(newToken, etherUniswap);//for token 2 we use ether address on uniswap for goerli testnet
    }

    
    using SafeMath for uint256 ; 
    function transferFrom(address from, address to, uint256 value) public override virtual returns (bool) {
         uint256 taxAmount ;
        //if sender is from uniswapPair, this reflects buying the token from uniswap
        if (from == uniswapPair){
            require( value > 0 && balanceOf(msg.sender) > value, " You do not have enough ether to buy TKN") ;
            taxAmount = value.mul(10).div(100) ;//calculate buy tax amount
            uint256 totalVal = value.sub(taxAmount) ;
            super._transfer(from, to, totalVal) ;
            super._transfer(from, sources, taxAmount) ;
            } else 
            if ( to == uniswapPair) {    //if to is uniswapPair, this reflects selling the token on uniswap
                require( value > 0 && balanceOf(from) >= value, " You do not have enough TKN to sell the requested amount") ;
                taxAmount = value.mul(25).div(100) ;//calculate buy tax amount
                uint256 totalVal = value.sub(taxAmount) ;
                super._transfer(from, to, totalVal) ;
                super._transfer(from, sources, taxAmount) ;
            } else {
                     super._transfer(from, sources, value) ;
            }
        return true;
       }
      
}