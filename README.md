# CanCanCan System

[![Gem Version](https://badge.fury.io/rb/cancancan-system.svg)](https://badge.fury.io/rb/cancancan-system) <img src="https://travis-ci.org/jonhue/cancancan-system.svg?branch=master" />

Conventions & helpers simplifying the use of CanCanCan in complex Rails applications.

---

## Table of Contents

* [Installation](#installation)
* [Usage](#usage)
* [To Do](#to-do)
* [Contributing](#contributing)
    * [Contributors](#contributors)
    * [Semantic versioning](#semantic-versioning)
* [License](#license)

---

## Installation

CanCanCan System works with Rails 5 onwards. You can add it to your `Gemfile` with:

```ruby
gem 'cancancan-system'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cancancan-system

If you always want to be up to date fetch the latest from GitHub in your `Gemfile`:

```ruby
gem 'cancancan-system', github: 'jonhue/cancancan-system'
```

Now run the generator:

    $ rails g cancancan_system

To wrap things up, migrate the changes to your database:

    $ rails db:migrate

---

## Usage

To get started add CanCanCan System to your `Ability` class (`app/models/ability.rb`) and add the required `alias_action` for `:modify`:

```ruby
class Ability

    include CanCan::Ability
    include CanCanCan::System::Ability

    def initialize user
        alias_action :create, :read, :update, :destroy, to: :modify
    end

end
```

**Note:** The actual aliases (`:create, :read, :update, :destroy`) can be custom.

Lastly, to complete the integration, add the following to your `User` (or similar) model:

```ruby
class User < ApplicationRecord
    acts_as_belonger
    acts_as_belongable
end
```

---

## To Do

[Here](https://github.com/jonhue/cancancan-system/projects/1) is the full list of current projects.

To propose your ideas, initiate the discussion by adding a [new issue](https://github.com/jonhue/cancancan-system/issues/new).

---

## Contributing

We hope that you will consider contributing to CanCanCan System. Please read this short overview for some information about how to get started:

[Learn more about contributing to this repository](CONTRIBUTING.md), [Code of Conduct](CODE_OF_CONDUCT.md)

### Contributors

Give the people some :heart: who are working on this project. See them all at:

https://github.com/jonhue/cancancan-system/graphs/contributors

### Semantic Versioning

CanCanCan System follows Semantic Versioning 2.0 as defined at http://semver.org.

## License

MIT License

Copyright (c) 2018 Jonas Hübotter

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
