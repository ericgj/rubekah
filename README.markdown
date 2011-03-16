## Rubekah
### AKA irbbot

An experimental IRC front-end for the interactive ruby shell (irb).

An alternative to Kirby that doesn't depend on web service calls but runs against a locally running irb process (pseudo-terminal).

Written using the isaac bot framework.

Did I mention it is experimental?

**Try it at your own risk outside localhost.**  It runs in the highest taint mode available for irb which is `$SAFE=2`.

I'm not sure it even works yet outside of testing environment. 

Also, it depends on [my fork of isaac](https://github.com/ericgj/isaac)