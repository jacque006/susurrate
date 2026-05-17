# susurrate
Onchain turn based game protoype

## requires

[Haxe (v4)](https://haxe.org/)
[Lime](https://lime.openfl.org/)

## setup
Make sure the needed scripts in the bin folder have execute permission (`chmod -R +x ./bin/`)

```sh
./bin/init_deps.sh
lime build html5
```

## run
`lime run html5`

### addiitonal flags
- `-debug`: debug build
- `-D play`: skip splash screens & menu to directly play game
- `-D isodebug`: enable debugging of isometric view
