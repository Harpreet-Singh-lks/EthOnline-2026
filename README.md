the start of the hackathon project and the main sponser are -> Privy, world and ENS 


 # Recommended demo format

  Build a web dashboard for the human administrator, plus a headless agent runner behind it.

  The frontend is where judges see and control everything. But the agent’s payments must be executed by the backend through its Privy wallet—not by the human’s connected browser wallet.

  Admin frontend
      │ creates/revokes agents
      ▼
  Control-plane backend
      ├── World verification
      ├── ENSv2 registry calls
      ├── Privy wallet management
      ├── Policy evaluation
      └── Agent/LLM task runner
               │
               ▼
         Privy agent wallet
               │
               ▼
         USDC vendor payment

  ———

  # Product concept

  Call it something like:

  > Beast — Corporate expense cards for AI agents

  A verified human administrator creates AI agents. Each agent gets:

  - An ENS identity: procurement.beast.eth
  - A Privy wallet
  - A daily budget
  - A per-transaction limit
  - Allowed merchants
  - An expiration time
  - A human-controlled revoke switch

  ———

  # Actors in the demo

  ## 1. Human administrator

  The person verified through World who creates and manages agents.

  ## 2. AI agent

  A backend process with access to a constrained Privy wallet. It does not receive an unrestricted private key.

  ## 3. Merchant

  A demo vendor accepting USDC.

  ## 4. Control plane

  Your backend coordinating ENS, Privy, World, policies, and the agent runner.

  ———

  # Frontend pages

  ## Page 1: Landing and onboarding

  ┌─────────────────────────────────────────────────────┐
  │ Beast                                               │
  │ Financial identities and expense controls for       │
  │ autonomous agents                                   │
  │                                                     │
  │ [Sign in with Privy]                                │
  └─────────────────────────────────────────────────────┘

  After authentication:

  Human verification required

  Every agent fleet must have a verified human controller.

  [Verify with World]

  World verification may:

  - Open a World verification widget
  - Display a QR code for the World App
  - Return a proof/nullifier to your backend
  - Mark the administrator as verified

  Do not claim “one human equals one agent.” Use:

  > One verified human administrator can control a fleet of agents.

  ———

  ## Page 2: Fleet dashboard

  ┌────────────────────────────────────────────────────────────┐
  │ Agent Fleet                                [+ Create Agent] │
  ├────────────────────────────────────────────────────────────┤
  │ Active agents: 2       Total balance: 35 USDC              │
  │ Daily spending: 8/25 USDC                                  │
  ├────────────────────────────────────────────────────────────┤
  │ procurement.beast.eth                         ACTIVE        │
  │ Wallet: 0x82...93AF       Balance: 20 USDC                  │
  │ Today: 5 / 20 USDC       Merchant: Acme Vendor             │
  │ [Open]                                                     │
  ├────────────────────────────────────────────────────────────┤
  │ research.beast.eth                            ACTIVE        │
  │ Wallet: 0x21...817C       Balance: 15 USDC                  │
  │ Today: 3 / 5 USDC        Merchant: Data Provider           │
  │ [Open]                                                     │
  └────────────────────────────────────────────────────────────┘

  This immediately establishes the B2B fleet story.

  ———

  # Create-agent flow

  Use a modal or four-step wizard.

  ## Step 1: Agent identity

  Agent name
  [ procurement ]

  Final name:
  procurement.beast.eth

  Purpose
  [ Purchase approved software and API services ]

  ## Step 2: Wallet policy

  Initial balance             20 USDC
  Daily spending limit        20 USDC
  Per-transaction limit       10 USDC
  Expiration                  7 days

  Allowed recipients:
  ✓ Acme Vendor       0x123...
  ✓ Data Provider     0x456...

  ## Step 3: Human controller

  Controller
  Harpreet — World verified

  Recovery wallet
  0xHumanController...

  ## Step 4: Creation progress

  After clicking Create Agent, show every real operation:

  ✓ World authorization validated
  ✓ Privy wallet created
  ✓ procurement.beast.eth registered
  ✓ ENS resource linked to wallet
  ✓ Wallet policy configured
  ✓ 20 USDC deposited

  Each successful step should have an explorer or transaction link.

  ### Actual backend ordering

  1. Confirm World verification.
  2. Create the Privy wallet.
  3. Obtain the wallet address.
  4. Register the ENS subname to that wallet.
  5. Store the stable ENS resource.
  6. Configure Privy/delegated-wallet policy.
  7. Fund the wallet with demo USDC.
  8. Save the agent record.

  Suggested data model:

  type Agent = {
    id: string;
    label: string;
    ensName: string;
    ensResource: string;
    currentTokenId: string;

    controllerAddress: string;

    privyWalletId: string;
    walletAddress: string;

    status: "active" | "revoked" | "expired";

    policy: {
      dailyLimit: string;
      perTransactionLimit: string;
      allowedRecipients: string[];
      expiresAt: number;
    };
  };

  Never expose the Privy wallet ID, authorization secret, or backend credentials to the browser.

  ———

  # Agent detail page

  procurement.beast.eth                       ● ACTIVE

  IDENTITY
  ENS resource:     0xabc...
  Current token ID: 0xdef...
  Owner:            0xAgentWallet...
  Expires:          September 16

  WALLET
  Address:          0xAgentWallet...
  Balance:          20 USDC
  Provider:         Privy
  Authority:        Delegated and policy constrained

  POLICY
  Daily limit:      20 USDC
  Per transaction:  10 USDC
  Spent today:      5 USDC
  Allowed vendors:  Acme Vendor

  [Run Agent Task]                 [Revoke Agent]

  Below this, show an activity feed:

  10:42  Paid Acme Vendor       5 USDC    Confirmed
  10:40  Payment rejected      25 USDC    Above transaction limit
  10:31  Agent created                    Confirmed

  ———

  # Demonstrating agent autonomy

  The best presentation is an “Agent Console” inside the frontend.

  Give procurement.beast.eth a task:

  [ Buy the $5 API package from Acme Vendor ]

  [Run autonomously]

  The backend can either:

  - Use an LLM with a tightly constrained payment tool, or
  - Use a deterministic task runner for reliability

  An LLM is optional. The important part is that the agent—not the human wallet—initiates the Privy transaction.

  Show its execution trace:

  1. Interpreting request
     Purchase $5 API package from Acme Vendor

  2. Resolving merchant
     Acme Vendor → 0x123...

  3. Checking ENS authorization
     procurement.beast.eth → authorized

  4. Checking wallet policy
     Recipient allowed       ✓
     Amount below 10 USDC    ✓
     Daily budget available  ✓
     Policy unexpired        ✓

  5. Submitting through Privy
     Wallet: 0xAgent...

  6. Payment confirmed
     Transaction: 0x789...

  This visualization helps judges understand that every component is load-bearing.

  ———

  # Financial-flow demonstration

  ## Successful purchase

  Run:

  Buy the $5 API package from Acme Vendor.

  Expected result:

  Payment successful

  Agent:       procurement.beast.eth
  From:        0xAgentWallet
  Recipient:   Acme Vendor
  Amount:      5 USDC
  Invoice:     INV-42
  Transaction: 0x...

  The transaction must originate from the agent’s Privy wallet.

  The human should not receive a MetaMask confirmation for the agent payment.

  ———

  ## Failed payment: amount limit

  Run:

  Buy the $25 enterprise package from Acme Vendor.

  Show:

  Payment blocked

  Reason: Per-transaction limit exceeded

  Requested: 25 USDC
  Maximum:   10 USDC
  No transaction was submitted.

  This failure is almost as important as the successful payment.

  ———

  ## Failed payment: unapproved recipient

  Run:

  Send 2 USDC to 0xUnapprovedAddress.

  Show:

  Payment blocked

  Reason: Recipient is not in the agent's allowlist.
  No transaction was submitted.

  Make sure these policies are truly enforced outside the UI. Hiding the button is not security.

  ———

  # Merchant view

  Add a simple /merchant route, ideally in another browser tab:

  Acme API Vendor

  Invoice INV-42
  Customer: procurement.beast.eth
  Package:  API Starter
  Amount:   5 USDC
  Status:   PAID

  Transaction: 0x...

  A tiny vendor contract could emit:

  event ServicePurchased(
      uint256 indexed agentResource,
      bytes32 indexed invoiceId,
      address indexed payer,
      uint256 amount
  );

  However, don’t add a complicated token-approval flow unless necessary. A real USDC transfer plus a backend invoice record is sufficient if time is limited.

  ———

  # Revocation demonstration

  On the agent page, click:

  [Revoke Agent]

  Show a confirmation modal:

  Revoke procurement.beast.eth?

  This will:
  • Remove the agent's ENS authority
  • Disable future wallet operations
  • Preserve the ENS registration record
  • Enable recovery of remaining funds

  Type REVOKE to continue.

  [Cancel] [Revoke]

  After confirmation:

  ✓ Controller authorization confirmed
  ✓ ENS roles revoked
  ✓ Token regenerated
  ✓ Wallet delegation disabled
  ✓ Agent marked inactive

  Then show the actual ENS distinction:

  ENS registration:       REGISTERED
  Current owner:          0xAgentWallet
  Agent authorization:    REVOKED
  Old token ID:           ...00000000
  Current token ID:       ...00000001

  This demonstrates your real technical discovery:

  > The name continues to exist, but its operational authority has been removed.

  Do not say the ENS name was burned or deregistered.

  ———

  # Post-revocation failure

  Run the original valid command again:

  Buy the $5 API package from Acme Vendor.

  Show:

  Payment blocked

  Reason: Agent authorization has been revoked on ENSv2.

  ENS name:      procurement.beast.eth
  Wallet:        0xAgentWallet
  Registration:  Registered
  Authorization: Revoked

  Privy transaction was not submitted.

  This is the most important moment in the entire demo. It proves the identity and wallet layers are coupled.

  Then make research.beast.eth perform a valid transaction to demonstrate that revoking one agent does not disable the fleet.

  ———

  # Fund recovery

  The cleanest architecture is:

  - The human controls the smart account/recovery authority.
  - The agent holds only a delegated/session authority.
  - Revocation disables the agent’s authority.
  - The human retains recovery authority.

  Then show:

  Remaining agent balance: 15 USDC

  [Recover to treasury]

  After recovery:

  15 USDC recovered to 0xHumanTreasury...

  If your Privy configuration cannot genuinely support separate agent and recovery authority, do not fake this. Mark recovery as pending rather than claiming self-custodial recovery.

  ———

  # Critical backend authorization flow

  Every agent payment should follow something like:

  async function executeAgentPayment(request) {
    const agent = await db.agents.find(request.agentId);

    // 1. Read live ENS state
    const state = await registry.getState(agent.ensResource);

    if (state.status !== REGISTERED) {
      throw new Error("ENS name is not registered");
    }

    if (state.expiry <= currentTimestamp()) {
      throw new Error("ENS registration expired");
    }

    if (state.latestOwner !== agent.walletAddress) {
      throw new Error("ENS owner no longer matches agent wallet");
    }

    // 2. Check live roles
    const authorized = await registry.hasRoles(
      state.resource,
      REQUIRED_AGENT_ROLES,
      agent.walletAddress
    );

    if (!authorized) {
      throw new Error("ENS authority revoked");
    }

    // 3. Check spending policy
    await policyEngine.assertAllowed({
      agent,
      token: USDC,
      recipient: request.recipient,
      amount: request.amount
    });

    // 4. Execute using Privy agent wallet
    return privy.wallets.sendTransaction({
      walletId: agent.privyWalletId,
      transaction: request.transaction
    });
  }

  Adapt this to Privy’s current SDK. The conceptual ordering is important: live ENS check first, financial policy second, Privy execution last.

  ———

  # Recommended technology split

  ## Frontend

  - Next.js
  - React
  - Tailwind/shadcn
  - Privy React authentication
  - World verification widget/QR flow
  - viem or wagmi for chain reads
  - Server-sent events or polling for task progress

  ## Backend

  - Next.js API routes or separate Node service
  - Privy server SDK
  - World proof verification
  - ENS contract integration through viem
  - Agent task runner
  - Policy evaluation
  - Transaction/indexing database

  ## Contracts

  - Existing ENSv2 child registry
  - Revised agent registrar/controller contract
  - Optional vendor/invoice contract
  - Optional wallet policy or smart-account validator

  ———

  # Suggested API routes

  POST /api/world/verify
  POST /api/agents
  GET  /api/agents
  GET  /api/agents/:id
  POST /api/agents/:id/tasks
  POST /api/agents/:id/revoke
  POST /api/agents/:id/recover
  GET  /api/agents/:id/activity

  The browser must never directly receive Privy server credentials.

  ———

  # Four-minute judge script

  ### 0:00–0:30 — Problem

  “Businesses want autonomous agents, but cannot give them unrestricted wallets.”

  ### 0:30–1:10 — Create agent

  Show verified administrator, name, wallet creation, and limits.

  ### 1:10–1:45 — Successful payment

  Agent autonomously pays an allowed merchant 5 USDC.

  ### 1:45–2:15 — Policy enforcement

  A 25 USDC transaction and unapproved recipient are blocked.

  ### 2:15–3:10 — Revocation

  Human revokes ENS authority. Show token regeneration and live role change.

  ### 3:10–3:40 — Coupling proof

  Retry the previously valid payment. Privy execution is rejected because ENS authorization is gone.

  ### 3:40–4:00 — Fleet isolation

  A second agent remains active, or show recovery of the revoked wallet’s funds.

  ———

  # What not to do

  - Don’t demonstrate everything through cast and terminal logs.
  - Don’t make the human sign the agent’s payment.
  - Don’t call a backend if statement a Privy-enforced policy.
  - Don’t expose the agent’s unrestricted private key.
  - Don’t claim ENS revocation disables Privy until you demonstrate it.
  - Don’t build six financial workflows. One polished purchase flow is enough.
  - Don’t let live testnet delays dominate the presentation; pre-create one agent and create another live.

  The frontend is the presentation layer, but the real product is the headless authorization and wallet-execution pipeline behind it.
 
 
