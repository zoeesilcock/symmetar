# Symmetar

A tool for exploring symmetry by creating and editing shapes that are repeated according to some specific type of symmetry. The name aims to be a verb form of the word symmetry and I pronounce it the same as the word scimitar.


## Concepts

### Document
The top level which holds all state regarding the document and which is charge of spawning elements. In its state it holds all elements in the document as well as some document settings. This is where we store all previous permutations so undo/redo works even after exiting and loading a document.

### Element
An element represents a repeating shape and holds the settings for position, pivot, rotation and look. Elements are in charge of spawning slices based on the repeat settings. Currently the logic for generating symmetries lives here, but to support multiple symmetries we will likely break that out into it's own class.

### Slice
A slice represents one repetition within an element. It holds no state of it's own, instead the state is calculated by its element. It's main purpose is to hold the visual representation and the UI widgets for moving, rotating and pivoting the slice.

### Shape
The visual representation of each individual slice. It is a separate scene so that we can implement multiple shapes or even use sprites in the future. Currently there is only one shape, a triangle.


## Motivation
The main motivation for making this project is my fascination with symmetry and repeating patterns. In learning Godot I needed something bigger than small hello world type projects to work on. This idea allows me to develop my skills in Godot with a relatively small scope. It also helps strengthen my understanding of geometry, trigonometry and maths in general.


## Future functionality
Some general ideas that I hope to implement in the future.

* Export to image.
* More symmetries/repeating patterns.
* More shapes.
* Changes slice values throughout the series according to some pattern (eg. increasing scale or distance from center).
* Animation.


## Reference

### Art
* https://en.wikipedia.org/wiki/Symmetry
* https://en.wikipedia.org/wiki/Tessellation
* https://en.wikipedia.org/wiki/Kaleidoscope
* https://en.wikipedia.org/wiki/Fractal_art
* https://en.wikipedia.org/wiki/Paisley_(design)

### Math
* https://en.wikipedia.org/wiki/Trigonometry
* https://en.wikipedia.org/wiki/Geometry
