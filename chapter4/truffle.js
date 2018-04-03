// Allows us to use ES6 in our migrations and tests.
require('babel-register')

module.exports = {
  networks: {
    development: {
      host: '127.0.0.1',
      port: 8545,
      network_id: '*' // Match any network id
    },
    ropsten:  {
      network_id: 3,
      host: "127.0.0.1",
      port:  8545,
      from: "0xd35db5027107f222566894caaf987e9051269ece",
      gas: 4612388
    },
    rinkeby: {
      host: "127.0.0.1",
      port: 8545,
      from: "0xd35db5027107f222566894caaf987e9051269ece",
      network_id: 4,
      gas: 4612388
    }
  }
}
