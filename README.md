# Bright Context iOS SDK

Sign up
[http://www.brightcontext.com](http://www.brightcontext.com)

Documentation
[http://brightcontext.com/docs/ios/](http://brightcontext.com/docs/ios/)

Questions
[http://www.brightcontext.com/about/contact/](http://www.brightcontext.com/about/contact/)

# Usage

## Option A: Download a pre-baked framework

1. From the downloads tab, fetch the one of the pre-built release packages
2. Link `libbrightcontext-ios-sdk.a` into your project under the "Build Phases" tab of your project settings
3. Adjust your project build settings and add path to the `headers` directory to the "Header Search Paths" setting.
4. Adjust your project build settings and add `-ObjC` and `-all_load` to your "Other Linker Flags" setting.  See [Technical Q&A QA1490](http://developer.apple.com/library/mac/#qa/qa1490/_index.html) for more info.


## Option B: Build from source

For various reasons, it may be easier or preferred to build from source as a
linked library. First, clone the repo.

    git clone --depth 1 git://github.com/BrightContext/ios-sdk.git bcc
    cd bcc

A known-working snapshot of both
[SBJSON](http://stig.github.com/json-framework/) and
[SocketRocket](https://github.com/square/SocketRocket/) are provided, but if
you are already using either of these frameworks in your project, you may want
to make the versions match up during the build process.

    tar xfvz json-framework-3.0.3-objcarc.tgz
    tar xfvz SocketRocket.tar.gz

With the libraries extracted, we can 

    cd brightcontext-ios-sdk
    ./makefatlib.sh

This will perform both a device and simulator build, then make a
'Debug-universal' library that can be linked to and used from both device and
simulator. The headers are also copied to the Debug-universal directory,
finish by linking into your project as described above.


## Option C: Include directly into your project as source.

In some cases, it might be necessary to include the entire project directly
into your app as source with no frameworks or linking. In this case, extract
the SBJSON and SocketRocket dependencies or download them separately, and
include all three libraries into your project.

## More info

### Automatic Reference Counting (ARC)

Know that SocketRocket requires ARC, but SBJSON and BrightContext do not. You
can adjust these build parameters from the build tab using the `-fno-objc-arc`
`-fobjc-arc` build flags. So, if you are using ARC in your project by default,
you will need to force it OFF for brightcontext-ios-sdk, if you are not using
it, then you will need to force it ON for SocketRocket.


### A note about OS X support

Full OS X support is on the roadmap, but currently our focus is on iOS. There
are no UIKit dependencies other than the provided diagnostic tool. If you need
desktop support, contact us and we'll be happy to help you out in the interim.
