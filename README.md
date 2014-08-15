<<<<<<< HEAD
An IRC bot for dice rolling and initiative tracking, written in perl.
=====================================================================

While its not beautiful, the code should certainly be easy to take and hack, if something strikes you.  I may return to it and tweak it someday, though I no longer use IRC for gaming.  This was my first non-trivial perl project... this is some *old* code. Not all features work, but it does handle rolling n-sided dice, basic math, and tracking initiative.

#### Usage: ####
dbot.pl \[server\] [port]

dbot auto-joins a server (127.0.0.1:6667) unless specified at the command line and joins #wegame.  You can edit this default in code, or /msg Dicey` with the admin password to get a list of commands, one of which is to join another channel.

#### Rolling: ####
In the channel, anyone can type 'd20+7' and get a random result, likewise 3d6, 88d88, etc.  Natural 1's are placed in quotation marks (d20+3 == "4") and Natural 20's (or whatever the max of that die is) are placed in underscores (d20+3 == _23_).  Rolling for example 6#d20 with print out each roll along with the sum.

#### Initiative: ####
To track initiative, DM simply types 'init' in the channel. The players then type 'init d20+n'.  When all players have rolled, the dm types endinit, and dbot will print out the initiative order.  The admin has access via private message to commands that allow arbitrary adds/removals/changes of initiative, in the event of a bad roll.

#### Requirements: ####
It requires perl 5.
It uses the following modules (usually just an apt-get/yum/cpan away). These are the packages on Fedora, at least.

* perl-Switch
* perl-Net-IRC
* perl-Text-Wrapper
=======
dbot
====

An IRC bot for use with chat-based RPG's
>>>>>>> 28f46e356d79505908c821048df51947b7afe707
