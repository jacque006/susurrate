# client
Susurrate game client in Haxe using [haxe-flixel](https://haxeflixel.com/)

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

with all debug flags

`lime test html5 -debug -D play -D isodebug`

### flags
- `-debug`: debug build
- `-D play`: skip splash screens & menu to directly play game
- `-D isodebug`: enable debugging of isometric view
