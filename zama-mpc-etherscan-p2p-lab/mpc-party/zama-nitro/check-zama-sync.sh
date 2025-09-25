#!/bin/bash
# Check Zama Nitro node sync status against Zama Testnet public RPC

LOCAL_RPC="http://127.0.0.1:8547"
PUBLIC_RPC="https://rpc-zama-testnet-v2-m21djof69y.t.conduit.xyz/AWPbX3k4TSAUyDsooPun88t27MT4bakzC"

# === Helper: safe hex -> int ===
hex2int() {
  local hex=$1
  if [[ -z "$hex" || "$hex" == "null" ]]; then
    echo 0
  else
    echo $((16#${hex#0x}))
  fi
}

# === Get Chain ID ===
chain_local=$(curl -s $LOCAL_RPC \
  -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"eth_chainId","params":[],"id":1}' | jq -r .result)

# === Get local block height ===
block_local_hex=$(curl -s $LOCAL_RPC \
  -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' | jq -r .result)
block_local=$(hex2int "$block_local_hex")

# === Get public block height ===
block_public_hex=$(curl -s $PUBLIC_RPC \
  -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' | jq -r .result)
block_public=$(hex2int "$block_public_hex")

# === Get peers ===
peers_hex=$(curl -s $PUBLIC_RPC \
  -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"net_peerCount","params":[],"id":1}' | jq -r .result)
peers=$(hex2int "$peers_hex")

# === Calculate difference ===
diff=$((block_public - block_local))

# === Print results ===
echo "🔗 Chain ID:        ${chain_local:-unknown}"
echo "💻 Local block:     $block_local"
echo "🌐 Public block:    $block_public"
echo "👥 Peers:           $peers"
echo "📊 Difference:      $diff"

if [ "$peers" -eq 0 ]; then
  echo "⚠️  Node is not connected to any peers, likely producing blocks in isolation."
elif [ "$diff" -le 5 ]; then
  echo "✅ Node is in sync with the Zama Testnet."
else
  echo "❌ Node is behind by $diff blocks compared to the Zama Testnet."
fi
