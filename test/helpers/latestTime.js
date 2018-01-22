// Returns the time of the last mined block in seconds
export default function latestTime() {
  return new Promise((resolve, reject) => {
    web3.eth.getBlock('latest', (error, result) => {
      if (error) reject(error);
      resolve(result.timestamp);
    });
  });
}
