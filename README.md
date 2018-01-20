# CanCanCan System

[![Gem Version](https://badge.fury.io/rb/cancancan-system.svg)](https://badge.fury.io/rb/cancancan-system) <img src="https://travis-ci.org/jonhue/cancancan-system.svg?branch=master" />

Conventions & helpers simplifying the use of CanCanCan in complex Rails applications. CanCanCan System simplifies authorizing collaborations, memberships and more across a complex structure of models.

To describe complex abilities CanCanCan System relies on two different constructs: ActiveRecord **objects**, and **relationships** of users to those objects.

CanCanCan System uses two attributes on *objects* to describe abilities:

* **ability:** Describes the default ability of users without a special relationship with an object.
* **visiblity:** Specifies whether an object is visible to other users than the creator.

CanCanCan System uses one attribute on *relationships* to describe abilities:

* **ability:** Describes the ability of a user with the related object.

`ability` can have any CanCanCan permission, `'admin'` (`:manage`), `'user'` (`:modify`) or `'guest'` (`:read`) as value while `visiblity` is limited to `public` and `private`.

---

## Table of Contents

* [Installation](#installation)
* [Usage](#usage)
    * [Defining abilities](#defining-abilities)
        * [Public abilities](#public-abilities)
        * [acts_as_belongable abilities](#acts_as_belongable-abilities)
        * [Membership abilities](#membership-abilities)
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

To get started add CanCanCan System to your `Ability` class (`app/models/ability.rb`) and add the required `:modify` alias:

```ruby
class Ability

    include CanCan::Ability
    include CanCanCan::System::Ability

    def initialize user
        modify [:create, :read, :update, :destroy]
    end

end
```

**Note:** The aliases (`:create, :read, :update, :destroy`) can be custom.

### Defining Abilities

CanCanCan System makes an `abilities` method available which simplifies setting up common abilities:

```ruby
def initialize user
    abilities Post, user
end
```

This is equivalent to:

```ruby
def initialize user
    public_abilities Post
    can :manage, Post, user_id: user.id if user
end
```

You can also use the `abilities` method with custom column names and polymorphic associations. This comes in handy when using the [NotificationsRails gem](https://github.com/jonhue/notifications-rails):

```ruby
def initialize user
    abilities Notification, user, column: 'target', polymorphic: true, public_abilities: false
end
```

This is equivalent to:

```ruby
def initialize user
    can :manage, Notification, target_id: user.id, target_type: user.class.name if user
end
```

Learn more about the `public_abilities` method [here](#public-abilities).

#### Public abilities

The `public_abilities` method defines the object-abilities without a `user` being present:

```ruby
def initialize user
    public_abilities Post
end
```

This is equivalent to:

```ruby
def initialize user
    can :manage, Post, ability: 'admin', visibility: 'public'
    can :modify, Post, ability: 'user', visibility: 'public'
    can :read, Post, ability: 'guest', visibility: 'public'
end
```

#### acts_as_belongable abilities

CanCanCan System integrates with the [acts_as_belongable gem](https://github.com/jonhue/acts_as_belongable) to make defining abilities for relationships dead simple.

Let's say our users can be a member of multiple organizations:

```ruby
class User < ApplicationRecord
    acts_as_belongable
    belongable :member_of_organizations, 'Organization', scope: :membership
    has_many :organizations
end

class Organization < ApplicationRecord
    acts_as_belonger
    belonger :members, 'User', scope: :membership
    belongs_to :user
end
```

We would then just do:

```ruby
def initialize user
    abilities Organization, user do
        belonger_abilities Organization, user, scope: :membership
    end
end
```

**Note:** This can be done in the same way with `belongable_abilities` for `belongable` relationships.

Now we are able to add members to our organizations and set their abilities:

```ruby
Organization.first.add_belongable User.first, scope: :membership, ability: 'admin'
```

**Note:** The `scope` option is optional. If omitted, the defined abilities will apply to all belongings regardless of their scope.

#### Membership abilities

Now, let us assume that we have another model: `Post`.

```ruby
class User < ApplicationRecord
    acts_as_belongable
    belongable :member_of_organizations, 'Organization', scope: :membership
    has_many :posts
    has_many :organizations
end

class Organization < ApplicationRecord
    acts_as_belonger
    belonger :members, 'User', scope: :membership
    has_many :posts
    belongs_to :user
end

class Post < ApplicationRecord
    belongs_to :user
    belongs_to :organization
end
```

You want the posts of an organization to be accessible for its members. It doesn't get any simpler than this:

```ruby
def initialize user
    abilities Post, user do
        organization_abilities Post, user, scope: :membership
    end
end
```

**Note:** The `scope` option is optional. If omitted, the defined abilities will apply to all belongings regardless of their scope.

You are also able to perform some customization:

```ruby
class Post < ApplicationRecord
    belongs_to :user
    belongs_to :object, polymorphic: true
end
```

```ruby
def initialize user
    abilities Post, user do
        organization_abilities Post, user, scope: :membership, column: 'object', polymorphic: true
    end
end
```

Another option is to use the [acts_as_belongable gem](https://github.com/jonhue/acts_as_belongable) to associate posts with organizations:

```ruby
class Organization < ApplicationRecord
    acts_as_belonger
    belonger :members, 'User', scope: :membership
    belonger :posts, 'Post'
    has_many :posts
    belongs_to :user
end

class Post < ApplicationRecord
    acts_as_belongable
    belongable :organizations, 'Organization'
    belongs_to :user
end
```

```ruby
def initialize user
    abilities Post, user do
        organization_abilities Post, user, scope: :membership, acts_as_belongable: true
    end
end
```

**Note:** If your `acts_as_belongable` association in the `Post` model is not following the CanCanCan System naming convention, you can override it by passing the `column` option.

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
