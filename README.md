channels
========

License: WTFPL

This modification for Minetest adds a channel feature.

You can join and leave channels to create:

* Teamchats
* Silence because nobody else in the chat
* Ignoring people
* Annoy people who think you are evil because you don't answer

How to use
----------

There is one chat command to manage everything.

* Online players in your channel:  `/channel online`

* Join or switch your channel:     `/channel join <channel>`

* Leave the current channel:       `/channel leave`

Additionally, players with `basic_privs` priviledge can also use

* Send message to all players:     `/channel wall <message ...>`

Settings
--------

* `channels.allow_global_channel` - set to `true` to allow a global channel.
    * if not `true` then players can only chat through named channels
    * default is `true`
* `channels.disable_private_messages` - set to `true` to disable private messages.
    * default is `false`
