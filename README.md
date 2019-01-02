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

* Invite player to you channel:    `/channel invite <playername>`

Additionally, players with `basic_privs` priviledge can also use

* Send message to all players:     `/channel wall <message ...>`

Settings
--------

* `channels.allow_global_channel` - set to `true` to allow a global channel.
    * if `false`, and `suggested_channel` is not nil, a reminder is sent by chat every 5 minutes to players suggesting a main channel
        * else no reminder is sent
    * default is `true`
* `channels.suggested_channel` - suggests a channel for everybody to chat in
    * default is nil
* `channels.disable_private_messages` - set to `true` to disable private messages.
    * default is `false`
