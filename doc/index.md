# com.telerik.sendgrid

The plugin allows you to quickly and easily send email through SendGrid javascript.

The plugin defines a global `sendgrid` object, which defines the method necessary for sending email via SendGrid web api.

Although the object is in the global scope, it is not available until after the `deviceready` event.

    document.addEventListener("deviceready", onDeviceReady, false);
    function onDeviceReady() {
        console.log(device.cordova);
    }

## Installation

You need to create an account. Once completed use the folloiwng from cordova CLI to install the plugin:

    cordova plugin add url --variable API_USER="SendGrid Username" --variable API_KEY=SendGrid Password

If you are using telerik AppBuilder then checkout the [plugins.telerik.com](http://plugins.telerik.com) for details on how to install it.

## Methods

- sendgrid.send


# sendgrid.send

Create a new SendGrid email object, and customize the paratmers of your message.

    var email = {
      to = 'steve.forte@telerik.com',
      from = 'admin@telerik.com',
      subject = 'Checkout this Awesome Plugin',
      html = '<h1> My first emial through SendGrid </h1>',
      text = 'My first email through SendGrid'
    }


Send it and additionally handle the callbacks for details:

    sendgrid.send(email, function(result){
        // TODO: add your logic
    }, function(error){
        // TODO: gracefully handle error.
    });


## Supported Platforms

- iOS

## Resources

For more information, please refer to the [SendGrid Web API Overview](https://sendgrid.com/docs/API_Reference/Web_API/index.html).
