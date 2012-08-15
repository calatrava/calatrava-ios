var tw = tw || {};
tw.bridge = tw.bridge || {};

tw.bridge.args = (function() {
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

tw.bridge.native = {

  getArgs: function(argId) {
    return JSON.stringify(tw.bridge.args.retrieve(argId));
  },

  call: function(target) {
    var argId = tw.bridge.args.store(_.toArray(arguments).slice(1));
    var callFrame = document.createElement('iframe');
    callFrame.setAttribute('id', 'callback_iframe');
    callFrame.setAttribute('style', 'display:none;');
    callFrame.setAttribute('height', '0px');
    callFrame.setAttribute('width', '0px');
    callFrame.setAttribute('frameborder', '0');
    callFrame.setAttribute('src', 'native-call:' + target + '&' + argId);

    document.documentElement.appendChild(callFrame);
  },

  load: function(path) {
    var scriptEl = document.createElement('script');
    scriptEl.type = "text/javascript";
    scriptEl.src = path;
    document.body.appendChild(scriptEl);
    return "successful load of '" + path + "'";
  }
  
};

tw.bridge.runtime = {
  issueRequest: function(options) {
    tw.bridge.native.call("issueRequest",
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
  "renderProxy",
  "valueOfProxyField",
  "startTimerWithTimeout",
  "openUrl"];

for (m in methods) {
  if (methods.hasOwnProperty(m)) {
    (function(method) {
      tw.bridge.runtime[method] = function() {
        var callArgs = [method].concat(_.toArray(arguments));
        tw.bridge.native.call.apply(tw.bridge.native, callArgs);
      };
    }(methods[m]));
  }
}