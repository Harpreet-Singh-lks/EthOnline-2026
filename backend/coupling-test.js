require('dotenv').config();
const { createPublicClient, http, encodeFunctionData } = require('viem');
const { sepolia } = require('viem/chains');

const client = createPublicClient({ chain: sepolia, transport: http(process.env.RPC_URL) });

const REGISTRAR_ABI = [
  {
    name: 'isAuthorized',
    type: 'function',
    stateMutability: 'view',
    inputs: [
      { name: 'label', type: 'string' },
      { name: 'agentWallet', type: 'address' },
    ],
    outputs: [{ type: 'bool' }],
  },
];

const ERC20_ABI = [
  {
    name: 'transfer',
    type: 'function',
    stateMutability: 'nonpayable',
    inputs: [
      { name: 'recipient', type: 'address' },
      { name: 'amount', type: 'uint256' },
    ],
    outputs: [{ type: 'bool' }],
  },
];

async function requestPayment(label, agentWallet, merchant, amount) {
  const isAuthorized = await client.readContract({
    address: process.env.REGISTRAR_ADDRESS,
    abi: REGISTRAR_ABI,
    functionName: 'isAuthorized',
    args: [label, agentWallet],
  });

  console.log(`isAuthorized(${label}, ${agentWallet}) = ${isAuthorized}`);

  if (!isAuthorized) {
    console.log('BLOCKED: agent is not authorized. No Privy call made.');
    return;
  }

  const data = encodeFunctionData({
    abi: ERC20_ABI,
    functionName: 'transfer',
    args: [merchant, amount],
  });

  const auth = Buffer.from(`${process.env.PRIVY_APP_ID}:${process.env.PRIVY_APP_SECRET}`).toString('base64');

  const res = await fetch(`https://api.privy.io/v1/wallets/${process.env.WALLET_ID}/rpc`, {
    method: 'POST',
    headers: {
      Authorization: `Basic ${auth}`,
      'privy-app-id': process.env.PRIVY_APP_ID,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      method: 'eth_sendTransaction',
      caip2: 'eip155:11155111',
      chain_type: 'ethereum',
      params: { transaction: { to: process.env.USDC_ADDRESS, data } },
    }),
  });

  const result = await res.json();
  console.log('Privy response:', result);
}

// Test call — adjust args to match a real registered agent
requestPayment('agent4', '0x25D1edaf817EAF5d90F62c88BEAf06373d074774', '0x4d520A22c47DfF92C56DAf6E819e466F4fE866E1', 3000000n);

