Murdoc — a ruby documenter
==============================

Murdoc is a doccu-style annotated documentation generator.

Rationale
---------

Sometimes it makes sense to create a guide, a story told by code and comments side by side. Murdoc generates a pretty html for such a story.

Example
-------

Demo at [GH.pages](http://jsus.github.io/murdoc).

See also:

* [example](http://jsus.github.io/murdoc/docs) of integration with [jsus](http://github.com/jsus/jsus)

Usage
-----

* `gem install murdoc`
* `murdoc <input file> <output html file>` **or**
* `murdoc <input file 1> <input file 2> ... <output html file>`


Dependencies
------------

* Haml
* Either RDiscount (for MRI rubies) or Kramdown (for non-mri rubies)


License
-------

Public domain, see UNLICENSE file.

See also
--------

* [docco.coffee](http://jashkenas.github.io/docco/)
* [Rocco](http://rtomayko.github.io/rocco/)
