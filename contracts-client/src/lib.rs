use alloy::{
    network::EthereumWallet,
    providers::{Provider, ProviderBuilder, RootProvider},
    signers::local::PrivateKeySigner,
    sol,
};
use js_sys::{BigInt, JsString};
use std::str::FromStr;
use wasm_bindgen::prelude::*;

sol! {
    #[sol(rpc)]
    contract Counter {
        uint256 public value;

        function increment() external;
    }
}

#[wasm_bindgen]
pub struct CounterContract {
    inner: Counter::CounterInstance<RootProvider>,
}

#[wasm_bindgen]
impl CounterContract {
    pub async fn create(
        rpc_url: &str,
        contract_address: &str,
        private_key: &str,
    ) -> Result<CounterContract, JsError> {
        let contract_addr = contract_address
            .parse()
            .map_err(|e| JsError::new(&format!("invalid address: {}", e)))?;

        let signer = PrivateKeySigner::from_str(private_key)
            // TODO Probably shouldn't bubble this up since it will likely expose key
            .map_err(|e| JsError::new(&format!("invalid private key format: {}", e)))?;
        let wallet = EthereumWallet::from(signer);

        let provider = ProviderBuilder::new()
            .wallet(wallet)
            .connect(rpc_url)
            .await
            .map_err(|e| JsError::new(&format!("failed to connect: {}", e)))?;

        Ok(CounterContract {
            inner: Counter::new(contract_addr, provider.root().clone()),
        })
    }

    pub async fn get_value(&self) -> Result<BigInt, JsError> {
        let val = self
            .inner
            .value()
            .call()
            .await
            .map_err(|e| JsError::new(&format!("rpc read failed: {}", e)))?;
        // U256 -> decimal string -> JS BigInt
        BigInt::new(&JsString::from(val.to_string()))
            .map_err(|e| JsError::new(&format!("overflow: {:?}", e)))
    }

    pub async fn increment(&self) -> Result<(), JsError> {
        let tx = self
            .inner
            .increment()
            .send()
            .await
            .map_err(|e| JsError::new(&format!("rpc send failed: {}", e)))?;
        tx.get_receipt()
            .await
            .map_err(|e| JsError::new(&format!("txn failed {}", e)))?;
        Ok(())
    }
}
