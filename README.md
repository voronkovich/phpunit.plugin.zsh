# phpunit.plugin.zsh

A zsh plugin for the [PHPUnit](https://phpunit.de/) with usefull commands and an actual autocompletion.

## Installation

Antigen:

    antigen bundle voronkovich/phpunit.plugin.zsh

Or clone this repo and add this into your .zshrc:

    source path/to/cloned/repo/phpunit.plugin.zsh

## Usage

This plugin provides a `pu` command to invoke a correct local PHPUnit script.

    # Always you launches phpunit like this (Symfony project):
    vendor/bin/phpunit -c app

    # 'pu' finds appropriate phpunit script and phpunit.xml or phpunit.xml.dist for you:
    pu

## License

Copyright (c) Voronkovich Oleg. Distributed under the MIT.
