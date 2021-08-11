const anchoring = artifacts.require("anchoringSC");

module.exports = function (deployer) {
  deployer.deploy(anchoring);
};
