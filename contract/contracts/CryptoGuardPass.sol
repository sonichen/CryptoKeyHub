// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract CryptoGuardPass{
    address public owner;
    
    struct Key{
        uint256 keyId;
        address owner;
        string url;
        string account;
        string password;
        string comment;
    }

    // keyId->key
    mapping (uint256=>Key) keyOfId;
    Key [] public keys;

    // keyId->index in keys
    mapping (uint256=>uint256) public idToKeyIndex;

    event KeyAdd(address owner,string url,string account);
    event KeyUpdate(address owner,uint256 keyId);
    event KeyRemove(address owner,string url,string account);

    modifier NotZeroId(uint256 _keyId){
        require(_keyId>0,"KeyId Wrong!");
        _;
    }
    modifier NotNullInfo(string memory _account,string memory _password){
        require(!isStringEmpty(_account)&&!isStringEmpty(_password),"Account and Password cannot be empty!");
        _;
    }
    function addKey(string memory _url,string memory _account,string memory _password,string memory _comment) external NotNullInfo(_account,_password){
        require(!isStringEmpty(_url),"URL cannot be empty!");
        uint256 keyId=generateHashId(_url, _account, _password,_comment);
        Key memory item=Key(keyId,msg.sender,_url,_account,_password,_comment);
        keyOfId[keyId]=item;
        keys.push(item);
        idToKeyIndex[keyId]=keys.length-1;
        emit KeyAdd(msg.sender, _url, _account);
    }

    function updateInfo(uint256 _keyId,string memory _account,string memory _password,string memory _comment) external NotNullInfo(_account,_password) NotZeroId(_keyId) {
        Key storage item=keyOfId[_keyId];
        require(msg.sender==item.owner,"Only owner can call this!");
        item.password=_password;
        item.account=_account;
        item.comment=_comment;

        keyOfId[_keyId]=item;
        uint256 index=idToKeyIndex[_keyId];
        keys[index]=item;
        emit KeyUpdate(msg.sender, _keyId);
    }

    function removeKey(uint256 _keyId) external {
        uint256 index=idToKeyIndex[_keyId];
        uint256 lastIndex=keys.length-1;
        string memory deletedUrl;
        string memory deletedAccount;
        if(index!=lastIndex){
            Key storage lastItem=keys[lastIndex];
            deletedUrl=lastItem.url;
            deletedAccount=lastItem.account;
            keys[index]=lastItem;
            idToKeyIndex[lastItem.keyId]=index;
        }
        keys.pop();
        delete keyOfId[_keyId];
        delete idToKeyIndex[_keyId];
        emit KeyRemove(msg.sender, deletedUrl, deletedAccount);
    }
    function getAllMyKeys() public view returns (Key[]memory,uint256){
        Key []memory myKeys=new Key[](keys.length);
        uint256 count=0;
        for(uint256 i=0;i<keys.length;i++){
            if(keys[i].owner==msg.sender&&keys[i].owner!=address(0)){
                myKeys[count]=keys[i];
                count++;
            }
        }
        return (myKeys,count);
    }
    // function getAllMyKeysCount() external view returns (uint256){
    //     return getAllMyKeys().length;
    // }
    function generateHashId(string memory _url, string memory _account, string memory _password,string memory _comment) internal view returns (uint256) {
        bytes32 hash = keccak256(abi.encodePacked(msg.sender, _url, _account, _password,_comment));
        return uint256(hash);
    }

    function isStringEmpty(string memory str) internal  pure returns (bool) {
        bytes memory strBytes = bytes(str);
        return strBytes.length == 0;
    }
 }