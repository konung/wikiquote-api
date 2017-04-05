[![Gem Version](https://badge.fury.io/rb/wikiquote-api.svg)](https://badge.fury.io/rb/wikiquote-api)

# Wikiquote-api
This gem was created in order to simplify use of wikiquote.org in your ruby or rails apps.

## Installation
You can install it simply by running in the terminal the following command :

`gem install wikiquote-api`

You can also add it to your gemfile :

`gem 'wikiquote-api'`

## Usage
At this moment there is only a few methods, but don't hesitate to open issues or PR with your idea in order to improve this gem.
Take a look in the doc folder to have the full list of avalaible methods and their explanations.

Note that you can change the language of wikiquote by doing `Wikiquote.setLang("locale")` where "locale" is a the locale corresponding to the language you want to use.
By default, locale is "en" for english.

## Version history
* 0.2.0 : Uniformized methods return values

* 0.1.2 : Fixed a bug with unicode characters

* 0.1.1 :  First version ever

## Important note
Be carefull when updating the gem. Check the method parameters and returns, they may change between release (0.x.x to 1.x.x etc...)

## Support
Don't hesitate to open issues for any question.
