# CWA

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cwa'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cwa

## Usage
```
Commands:
  cwa alarms  --name ALARMNAME --regexp ALARMNAME --namespae NAMESPACE --dimensions KEY:VALUE  # show cloudwatch alms
  cwa disable --name ALARMNAME --regexp ALARMNAME --namespae NAMESPACE --dimensions KEY:VALUE  # disable cloudwatch alms
  cwa enable  --name ALARMNAME --regexp ALARMNAME --namespae NAMESPACE --dimensions KEY:VALUE  # enable cloudwatch alms
  cwa help [COMMAND]                                                                           # Describe available commands or one specific command

Options:
  [--verbose], [--no-verbose]
```
