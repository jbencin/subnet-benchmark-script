#!/bin/bash

set -euo pipefail

# Set up dependencies
sudo apt-get install -y git build-essential
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
. "$HOME/.cargo/env"

# Set up repository
parent_dir="$HOME/git"
mkdir -p "$parent_dir"
cd "$parent_dir"
[ -d stacks-subnets ] || git clone https://github.com/hirosystems/stacks-subnets
cd stacks-subnets
git checkout develop

# Run benchmarks
declare -a tests=( "test_15s_block" "test_max_block" "test_15s_block_stx_transfers_only" "test_max_block_stx_transfers_only" )
for test in "${tests[@]}"; do
    logfile="$test.log"
    cargo test --package stacks-subnets --lib -- "chainstate::stacks::bench::tests::$test" --exact --nocapture --ignored &> "$logfile"
    echo "----- RESULTS FOR $test -----"
    grep "Miner: mined anchored block" < "$logfile" | tail -n 1
    tail -n 3 "$logfile"
done

