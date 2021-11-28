const zyptoken = artifacts.require("zyptoken");

module.exports = function (deployer) {
  deployer.deploy(zyptoken);
};
