use alloy::{
    primitives::{
        address,
        utils::{format_ether, Unit},
        U256,
    },
    providers::{ext::AnvilApi, ProviderBuilder},
    signers::local::PrivateKeySigner,
    sol,
};
use std::error::Error;

sol! { 
    #[sol(rpc)] 
    contract Counter { 
        uint256 public number;

        function setNumber(uint256 newNumber) external;
    } 
} 

#[wasm_bindgen]
async fn increment() -> Result<(), Box<dyn Error>> {
    // Initialize a random signer and get address from it
    let signer = PrivateKeySigner::random(); 
    let from_address = signer.address();
 
    // Instantiate a provider with the signer
    let provider = ProviderBuilder::new() 
        .wallet(signer) 
        .connect_anvil_with_config(|a| a.fork("https://ethereum.reth.rs/rpc"));
 
    // Fund the random signer on the local Anvil fork
    provider 
        .anvil_set_balance( 
            from_address, 
            Unit::ETHER.wei().saturating_mul(U256::from(100)), 
        ) 
        .await?; 
 
    // Setup WETH contract instance
    let weth_address = address!("0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2");
    let weth = Counter::new(weth_address, provider.clone()); 
 
    // Read initial balance
    let initial_balance = weth.balanceOf(from_address).call().await?; 
    println!("Initial WETH balance: {} WETH", format_ether(initial_balance));
 
    // Write: Deposit ETH to get WETH
    let deposit_amount = Unit::ETHER.wei().saturating_mul(U256::from(10));
    let deposit_tx = weth.deposit().value(deposit_amount).send().await?; 
    let deposit_receipt = deposit_tx.get_receipt().await?; 
    println!(
        "Deposited ETH in block {}",
        deposit_receipt.block_number.expect("Failed to get block number")
    );
 
    // Read: Check updated balance after deposit
    let new_balance = weth.balanceOf(from_address).call().await?;
    println!("New WETH balance: {} WETH", format_ether(new_balance));
 
    // Write: Withdraw some WETH back to ETH
    let withdraw_amount = Unit::ETHER.wei().saturating_mul(U256::from(5));
    let withdraw_tx = weth.withdraw(withdraw_amount).send().await?; 
    let withdraw_receipt = withdraw_tx.get_receipt().await?; 
    println!(
        "Withdrew ETH in block {}",
        withdraw_receipt.block_number.expect("Failed to get block number")
    );
 
    // Read: Final balance check
    let final_balance = weth.balanceOf(from_address).call().await?; 
    println!("Final WETH balance: {} WETH", format_ether(final_balance));
 
    Ok(())
}