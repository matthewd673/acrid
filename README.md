# acrid

Acrid is a highly-modular, terminal-based text editor written in Ruby.

## Features

- Incredibly modular (see `/config/mods/`)
- Almost entirely event-based (like a game engine might be)
- Theming and RegEx-based syntax highlighting (see `/config/syntax/`)
- Modal: press <kbd>Esc</kbd> to toggle to the CLI
- Commands evalutated as RegEx
- Highly customizable footer (see `/config/footer.rb`)

**What about [Maple](https://github.com/matthewd673/maple)?**

Maple is huge and fancy, Acrid is tiny and written in < 1 week. There are pros and cons to both approaches.

There are notable technology differences as well:
- Maple is written in C#, Acrid is written in Ruby.
- Maple could be cross-platform but currently relies heavily on deprecated `windows.h` API. Acrid uses Ruby's `curses` binding.
- Acrid is designed around events and event handlers.
- Acrid was built to be modular from the start (e.g.: the footer and mods). Maple is customizable but has no modularity (right now).

## Run

Acrid uses `rbenv` to manage its Ruby version according to the `.ruby-version` file.

To start using Acrid:
```
bundle install
chmod +x ./lib/acrid.rs
./lib/acrid.rs lib/acrid.rs
```