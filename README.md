# Slisp

Slisp is an experimental string templating library for Godot written (at the moment) in GDScript. The current code is proof of concept and likely to change but should work if anyone would like to try it out.

Slisp is currently unoptised and designed for playing around with text adventures. I wouldn't reccomend it for high performance use. If it gets traction I might port it to C gode via GDNative.

Slisp supports
- Templating strings with variables
- Conditional logic (if and when)
- Simple equality testing
- Preserving whitespace

## Installation

Download the `slisp.gd` file and drop it into `addons/slisp` (or where ever your like) in your Godot project.

## Syntax

Slisp works by adding s-expressions to a string using `<` and `>`. Whitespace outside of expressions is preserved.

```
This is an example slisp template.

<put foo> is the value of foo

<when hello "world"> will print world when hello is truthy

<if bar "zap" "pow"> will print zap if bar is true,
otherwise it will print "pow".

<when this <str "t" "h" "a" "t">> you can next expressions,
this will print "that" when this is true
```

## Usage

```gdscript
var Slisp = ResourceLoader.load("res://addons/slisp.gd")

var template = Slisp.new('Ya<when super_pirate "aaaaaa">r')

var state = { 'super_pirate': true }

var result = template.render(state) # use this in a text node or something
```

## TODO list

- [ ] Better error handling
- [ ] Ability to escape characters with `\`
- [ ] Debug/profiling mode
- [ ] Ability to customise expression start and end tokens
- [ ] Ability to distinguish between function names and variables (e.g. prefix one or the other with `$` to avoid name collisions)
- [ ] Turn this repo into a valid Godot project
- [ ] Install slisp plus a 'playground' via an addon
