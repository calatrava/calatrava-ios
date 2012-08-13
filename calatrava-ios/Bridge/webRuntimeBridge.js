var tw = tw || {};
tw.bridge = tw.bridge || {};

tw.bridge.native = {

  args: [],

  getArgs: function() {
    return JSON.stringify(tw.bridge.native.args);
  },

  call: function(target) {
    tw.bridge.native.args = _.toArray(arguments).slice(1);
    window.location.href = "native-call:" + target;
  },

  load: function(path) {
    scriptFile = document.createElement('<script type="text/javascript" src="' + path + '"></script>');
    document.body.appendChild(scriptFile);
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

methods = ["log",
  "changePage",
  "registerProxyForPage",
  "attachProxyEventHandler",
  "renderProxy",
  "valueOfProxyField",
  "startTimerWithTimeout",
  "openUrl"];

for (m in methods) {
  if (methods.hasOwnProperty(m)) {
    function(method) {
      tw.bridge.runtime[method] = function() {
        var callArgs = [method] + _.toArray(arguments);
        tw.bridge.native.call.apply(tw.bridge.native, callArgs);
      };
    }(m);
  }
}