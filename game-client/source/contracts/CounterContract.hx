package contracts;

import js.lib.*;

@:native("CounterContract")
extern class CounterContract {
    public static function create(rpcUrl:String, contractAddress:String, privateKey:String):Promise<CounterContract>;
    public function get_value():Promise<String>;
    public function increment():Promise<Void>;
    public function free(): Void;
}
