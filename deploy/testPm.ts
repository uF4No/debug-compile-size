import { Provider, utils, Wallet, Contract } from "zksync-web3";
import * as ethers from "ethers";
import { HardhatRuntimeEnvironment } from "hardhat/types";

// Actual deployed paymaster
const PAYMASTER_ADDRESS = "0x231a2672996739351Bf25783b4883a1BAeAA5490";

// Insert a CMTAT address. You can deploy one via the other script with compiler 1.3.1
const cmtatAddress = "0xDF88835D7D30bD22a95FFea7E7e37c34262b0271";

// Private Key from the cmtat owner address
const EMPTY_WALLET_PRIVATE_KEY = "";

export default async function (hre: HardhatRuntimeEnvironment) {
  const provider = new Provider("https://zksync2-testnet.zksync.dev");
  const wallet = new Wallet(EMPTY_WALLET_PRIVATE_KEY, provider);

  const contract = new Contract(
    cmtatAddress,
    hre.artifacts.readArtifactSync("CMTAT").abi,
    wallet
  );

  // Encoding the "ApprovalBased" paymaster flow's input
  const paymasterParams = utils.getPaymasterParams(PAYMASTER_ADDRESS, {
    type: "ApprovalBased",
    token: cmtatAddress,
    // token: "0x7Dc4d10e1116eE90E9dFf9AA108684c974c9FB9c",
    // set minimalAllowance as we defined in the paymaster contract
    minimalAllowance: ethers.BigNumber.from(1),
    // empty bytes as testnet paymaster does not use innerInput
    innerInput: new Uint8Array(),
  });

  // With this you will get the same problems
  const gaslimit = await contract.estimateGas.setTerms("newTerms", {
    // paymaster info
    customData: {
      paymasterParams: paymasterParams,
      gasPerPubdata: utils.DEFAULT_GAS_PER_PUBDATA_LIMIT,
    },
  });

  // Seems now to have some problems with validation checks, if you use the paymaster data.
  // If you comment out everything to the customData it worked.
  // Just for you: Worked befor the regenesis (maybe 2 weeks befor it) so something seems to be changed here.
  await (
    await contract.setTerms("NEWTerms", {
      customData: {
        paymasterParams: paymasterParams,
        gasPerPubdata: utils.DEFAULT_GAS_PER_PUBDATA_LIMIT,
      },
    })
  ).wait();

  // Another test method with he same problem if you use the paymaster
  /*await (
    await contract.mint('0x1c79CDd9A04B7b6f7b1e7bd587f98423daF8300b', 10,
      {
        customData: {
          paymasterParams: paymasterParams,
          gasPerPubdata: utils.DEFAULT_GAS_PER_PUBDATA_LIMIT,
        },
      }
    )
  ).wait();*/

  console.log("script done");
}
