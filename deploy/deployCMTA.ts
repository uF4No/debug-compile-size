import { Wallet, Provider } from "zksync-web3";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { Deployer } from "@matterlabs/hardhat-zksync-deploy";

const walletPrivateKey_ToDeploy = "";

// Actual deployed simple paymaster, see contract code
const paymasterAddress = "0x231a2672996739351Bf25783b4883a1BAeAA5490";

// put your address here
const OWNER_OF_THE_CONTRACT = "";

export default async function (hre: HardhatRuntimeEnvironment) {
  console.log(`Running deploy script for CMTAT`);

  const provider = new Provider("https://zksync2-testnet.zksync.dev");
  const wallet = new Wallet(walletPrivateKey_ToDeploy).connect(provider);

  const deployer = new Deployer(hre, wallet);
  const artifact = await deployer.loadArtifact("CMTAT");
  const artifactRuleEngine = await deployer.loadArtifact("RuleEngine");
  const artifactRule = await deployer.loadArtifact("Rule");

  const cmtatContract = await deployer.deploy(
    artifact,
    [paymasterAddress],
    {},
    [artifactRuleEngine.bytecode, artifactRule.bytecode]
  );

  // Show the contract info.
  const contractAddress = cmtatContract.address;
  console.log(`${artifact.contractName} was deployed to ${contractAddress}`);

  const contractName = "DLT";
  const contractSymbol = "CMTAT";
  const TOKEN_ID = "Daura";
  const contractTerms = "test.de";
  const contractTermsHash =
    "0x0000000000000000000000000000000000000000000000000000000000000000";
  const isSecurityDLT = true;
  const globalListAddress = "0x18812102aDb9ECaE0aB12F5cca4A8503F0efA148";
  const dauraWalletAddress = "0x11307B101C800d40cb20bC09CEe25ea3897Ca6fc";
  const useRuleEngine = true;
  const guardianAddresses = [];

  // Can be commented out ifyou want. The real problem is in the deploy part above.
  // But this will work without needing more data from your side besides the owner address
  await (
    await cmtatContract.initialize(
      OWNER_OF_THE_CONTRACT,
      contractName,
      contractSymbol,
      TOKEN_ID,
      contractTerms,
      contractTermsHash,
      isSecurityDLT,
      globalListAddress,
      dauraWalletAddress,
      useRuleEngine,
      guardianAddresses
    )
  ).wait();

  console.log(`Script finished`);
}
