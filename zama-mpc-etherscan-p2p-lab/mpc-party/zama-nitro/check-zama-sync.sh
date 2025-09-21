#!/bin/bash
# Check Zama Nitro node sync status against Zama Testnet public RPC

# === Config === 
# Please run "kubectl port-forward svc/zama-nitro 8547:8547 -n arbitrum" in another terminal first
LOCAL_RPC="http://127.0.0.1:8547" 
PUBLIC_RPC="https://rpc-zama-testnet-v2-m21djof69y.t.conduit.xyz/AWPbX3k4TSAUyDsooPun88t27MT4bakzC"

# === Get Chain ID ===
chain_local=$(curl -s $LOCAL_RPC \
  -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"eth_chainId","params":[],"id":1}' | jq -r .result)

# === Get local block height ===
block_local_hex=$(curl -s $LOCAL_RPC \
  -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' | jq -r .result)
block_local=$((block_local_hex))

# === Get public block height ===
block_public_hex=$(curl -s $PUBLIC_RPC \
  -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' | jq -r .result)
block_public=$((block_public_hex))

# === Get peers safely ===
peers=$(curl -s $LOCAL_RPC/net_info | jq -r '.result.n_peers // .n_peers // "0"')
# Force integer
peers=${peers//[^0-9]/}

# === Calculate difference ===
diff=$((block_public - block_local))

# === Print results ===
echo "🔗 Chain ID:        $chain_local"
echo "💻 Local block:     $block_local"
echo "🌐 Public block:    $block_public"
echo "👥 Peers:           ${peers:-0}"
echo "📊 Difference:      $diff"

if [ -z "$peers" ] || [ "$peers" -eq 0 ]; then
  echo "⚠️  Node is not connected to any peers, likely producing blocks in isolation."
elif [ "$diff" -le 5 ]; then
  echo "✅ Node is in sync with the Zama Testnet."
else
  echo "❌ Node is behind by $diff blocks compared to the Zama Testnet."
fi
