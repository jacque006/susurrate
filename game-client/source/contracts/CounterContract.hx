package contracts;

import js.lib.Promise;

@:jsRequire("./assets/wasm/contracts_client", "CounterContract")
extern class CounterContract {
    public static function create(rpcUrl:String, contractAddress:String, privateKey:String):Promise<CounterContract>;
    public function get_value():Promise<String>;
    public function increment():Promise<Void>;
}
