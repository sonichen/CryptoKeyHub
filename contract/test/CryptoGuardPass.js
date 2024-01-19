const {expect} =require('chai');
const {ethers} =require('hardhat');

describe('CryptoGuardPass', function(){
   let cryptoGuardPass;

   beforeEach(async () => {
     const CryptoGuardPass = await ethers.getContractFactory("CryptoGuardPass");
     cryptoGuardPass = await CryptoGuardPass.deploy();
   });

   it("Add a key", async function () {
      const url = "https://github.com/";
      const account = "Lily";
      const password = "123456";
      const comment = "test_comment";
  
      await cryptoGuardPass.addKey(url, account, password, comment);
      const keys = await cryptoGuardPass.getAllMyKeys();
  
      expect(keys.length).to.equal(1);
      expect(keys[0].url).to.equal(url);
      expect(keys[0].account).to.equal(account);
      expect(keys[0].password).to.equal(password);
      expect(keys[0].comment).to.equal(comment);
    });
    it("Update key information", async function () {
      const url = "https://github.com/";
      const account = "Lucy";
      const password = "123456";
      const comment = "test_comment";
  
      await cryptoGuardPass.addKey(url, account, password, comment);
  
      const newAccount = "Lucy";
      const newPassword = "654321";
      const newComment = "updated_comment";
  
      const keysBeforeUpdate = await cryptoGuardPass.getAllMyKeys();
      const keyIdToUpdate = keysBeforeUpdate[0].keyId;
  
      await cryptoGuardPass.updateInfo(keyIdToUpdate, newAccount, newPassword, newComment);
  
      const keysAfterUpdate = await cryptoGuardPass.getAllMyKeys();
      const updatedKey = keysAfterUpdate.find((key) => key.keyId === keyIdToUpdate);
  
      expect(updatedKey.account).to.equal(newAccount);
      expect(updatedKey.password).to.equal(newPassword);
      expect(updatedKey.comment).to.equal(newComment);
    });
    it("Remove a key", async function () {
      // add three keys
      // key1
      const url1 = "https://github.com/";
      const account1 = "Lily";
      const password1 = "123456";
      const comment1 = "test_comment";
  
      await cryptoGuardPass.addKey(url1, account1, password1, comment1);
 
      
      // key2
      const url2 = "https://github.com/";
      const account2 = "Lucy";
      const password2 = "123456";
      const comment2 = "test_comment";
  
      await cryptoGuardPass.addKey(url2, account2, password2, comment2);
  

      // key3
      const url3 = "https://github.com/";
      const account3 = "Jack";
      const password3 = "123456";
      const comment3 = "test_comment";
  
      await cryptoGuardPass.addKey(url3, account3, password3, comment3);

      // handle
      const keysBeforeRemoval = await cryptoGuardPass.getAllMyKeys();
      const keyIdToRemove = keysBeforeRemoval[1].keyId;
  
      await cryptoGuardPass.removeKey(keyIdToRemove);
  
      const keysAfterRemoval = await cryptoGuardPass.getAllMyKeys();
      const removedKey = keysAfterRemoval.find((key) => key.keyId === keyIdToRemove);
      expect(keysAfterRemoval.length).to.equal(2);
      expect(removedKey).to.be.undefined;
    });
})
