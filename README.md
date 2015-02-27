# Castful

Easily record podcasts on your iPhone and host them on [Contentful][1].

## Usage

1. Create a space on [Contentful][1] which should contain all your beautiful content™.

1. The iOS app needs an OAuth client ID and Amazon S3 credentials, put them into the application
delegate for now (will use [cocoapods-keys][3] in the future).

1. Run `make setup` to install the correct version of [CocoaPods][2], etc.

1. The app allows to login, select your space and upload some recorded audio.

1. *Web/index.html* contains a silly little page which displays all casts as `<audio>` tags.
Make sure to put the right space credentials there if you end up using it.

## Acknowledgements

The used logo is licensed under a Creative Commons Attribution-ShareAlike 2.0 Germany License, 
more information can be found [here][4]. The audio recording is done via the [EZAudio][5]
library.

[1]: https://www.contentful.com/
[2]: http://cocoapods.org
[3]: https://github.com/orta/cocoapods-keys
[4]: http://podcastlogo.lemotox.de
[5]: https://github.com/syedhali/EZAudio
