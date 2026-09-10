package contracts;

import js.lib.*;

@:js.import("../game-client/dist/index.js", "CounterContract")
extern class CounterContract {
    @:native("constructor")
    public function new(rpcUrl:String, contractAddress:String, privateKey:String);
    @:native("getValue")
    public function getValue():Promise<String>;
    @:native("increment")
    public function increment():Promise<Void>;
}
