let AutocraticVoting = artifacts.require("AutocraticVoting");
let Legislator = artifacts.require("Legislator");
let NormCorpus = artifacts.require("NormCorpus");
let NormCorpusProxy = artifacts.require("NormCorpusProxy");
let Valid = artifacts.require("Valid");

module.exports = function (deployer) {
  deployer.deploy(NormCorpus)
    .then(() => console.log(`\n\nNormCorpus deployed at: ${NormCorpus.address}`))
    .then(() => deployer.deploy(NormCorpusProxy, NormCorpus.address))
    .then(() => console.log(`NormCorpusProxy deployed at: ${NormCorpusProxy.address}`))
    .then(() => deployer.deploy(AutocraticVoting))
    .then(() => console.log(`AutocraticVoting deployed at: ${AutocraticVoting.address}`))
    .then(() => deployer.deploy(Legislator, NormCorpusProxy.address, AutocraticVoting.address))
    .then(() => console.log(`Legislator deployed at: ${Legislator.address}`))
    .then(() => NormCorpus.at(NormCorpus.address).insert(Legislator.address))
    .then(() => console.log(`Legislator ${Legislator.address} inserted into NormCorpus ${NormCorpus.address}`))
};