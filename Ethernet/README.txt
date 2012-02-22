This is a modified version of the Arduino Twitter library.

I didn't want to use a Twitter proxy that's external to my system (because I'm paranoid about security) so I pulled a copy of Mohammed Sameer's twitter-proxy.py from http://foolab.org/node/7890 which uses OAuth on the twitter side and HTTP basic auth (yes I know how insecure that is but it's OK on my private LAN).

I've modified the Twitter.cpp program to connect to that proxy and pass a basic auth userid:password. 
