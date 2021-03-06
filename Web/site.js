#!/usr/bin/env node

var contentful = require('contentful')

var client = contentful.createClient({
  space: 'crvcnjrd7aj2',
  accessToken: 'b462462df9d7049e7ce5679a523f1a1dc5e248f9d11e9a6c8f89d20d0d1def00'
});

client.assets({ include: 1 }, function(err, assets) {
  if (err) {
  	console.log(err);
  	return;
  }

  for (var i = 0; i < assets.length; i++) {
    var contentType = assets[i].fields.file.contentType
    var title = assets[i].fields.title
    var url = assets[i].fields.file.url

  	//console.log(assets[i])
    
    if (contentType != 'audio/x-m4a') {
      continue
    }

    var cast = '<div>\n' +
      '<h3>' + title + '</h3>\n' +
      '<audio controls>\n' + 
      '<source src="https:' + url + '" type="' + contentType + '">\n' +
      '</audio>\n' +
    '</div>\n'

    console.log(cast)
    //document.write(cast)
  }
});
