var calatrava = calatrava || {};
calatrava.bridge = calatrava.bridge || {};

calatrava.bridge.args = (function() {
  var nextArgId = 0, argStore = {};

  var store = function(argArray) {
    var argId = nextArgId;

    argStore[argId] = argArray;
    nextArgId += 1;
    
    return argId;
  };

  var retrieve = function(argId) {
    var args = argStore[argId];
    delete argStore[argId];
    return args;
  };

  return {
    store: store,
    retrieve: retrieve
  };
}());

calatrava.bridge.native = {

  getArgs: function(argId) {
    return JSON.stringify(calatrava.bridge.args.retrieve(argId));
  },

  call: function(target) {
    var argId = calatrava.bridge.args.store(_.toArray(arguments).slice(1));
    var callFrame = document.createElement('iframe');
    callFrame.setAttribute('id', 'callback_iframe' + argId);
    callFrame.setAttribute('style', 'display:none;');
    callFrame.setAttribute('height', '0px');
    callFrame.setAttribute('width', '0px');
    callFrame.setAttribute('frameborder', '0');
    callFrame.setAttribute('src', 'native-call:' + target + '&' + argId);

    document.documentElement.appendChild(callFrame);
    document.documentElement.removeChild(callFrame);
  },

  load: function(path) {
    var scriptEl = document.createElement('script');
    scriptEl.type = "text/javascript";
    scriptEl.src = path;
    scriptEl.onload = calatrava.bridge.native.loadComplete;
    document.body.appendChild(scriptEl);
    return "successful load of '" + path + "'";
  },
  
  loadComplete: function() {
    calatrava.bridge.native.call('loadComplete');
  }
  
};

calatrava.bridge.runtime = {
  renderProxy: function(viewObject, proxyId) {
    // Clean off properties that cause problems when marshalling
    if (viewObject.hasOwnProperty('toJSONString')) {
      viewObject.toJSONString = null;
    }
    if (viewObject.hasOwnProperty('parseJSON')) {
      viewObject.parseJSON = null;
    }

    // Delete any keys that have a null value to avoid the Obj-C JSON
    // serialization failure
    if (viewObject != undefined) {
      calatrava.bridge.support.cleanValues(viewObject);
    }

    calatrava.bridge.native.call("renderProxy", viewObject, proxyId);
  },

  issueRequest: function(options) {
    calatrava.bridge.native.call("issueRequest",
      options.requestId,
      options.url,
      options.method,
      options.body,
      options.headers
    );
  }
};

var methods = ["log",
  "changePage",
  "registerProxyForPage",
  "attachProxyEventHandler",
  "valueOfProxyField",
  "startTimerWithTimeout",
  "openUrl",
  "callPlugin"];

for (m in methods) {
  if (methods.hasOwnProperty(m)) {
    (function(method) {
      calatrava.bridge.runtime[method] = function() {
        var callArgs = [method].concat(_.toArray(arguments));
        calatrava.bridge.native.call.apply(calatrava.bridge.native, callArgs);
      };
    }(methods[m]));
  }
}

calatrava.bridge.support = {
  cleanValues: function(jsObject) {
    _.each(_.keys(jsObject), function(key) {
      if (jsObject[key] === null || jsObject[key] === undefined) {
        delete jsObject[key];
      } else if (jsObject[key] === false) {
        jsObject[key] = 0;
      } else {
        if (jsObject[key] instanceof Object) {
          calatrava.bridge.support.cleanValues(jsObject[key]);
        }
      }
    });
  }
};
