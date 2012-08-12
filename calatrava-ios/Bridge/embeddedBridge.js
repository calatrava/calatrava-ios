var tw = tw || {};
tw.bridge = tw.bridge || {};

tw.bridge.runtime = {

  log: EmbeddedRuntime.nativeBridge.log,

  changePage: EmbeddedRuntime.nativeBridge.changeToPage,
  registerProxyForPage: EmbeddedRuntime.nativeBridge.registerProxy_forPage,
  attachProxyEventHandler: EmbeddedRuntime.nativeBridge.attachHandlerTo_forEvent,
  renderProxy: EmbeddedRuntime.nativeBridge.render_onProxy,
  valueOfProxyField: function(proxyId, field) {
    return EmbeddedRuntime.nativeBridge.valueFrom_forField(field, proxyId).valueOf();
  },

  issueRequest: function(options) {
    return EmbeddedRuntime.nativeBridge.requestFrom_url_as_with_andHeaders(
      options.requestId,
      options.url,
      options.method,
      options.body,
      options.headers
    );
  },

  startTimerWithTimeout: EmbeddedRuntime.nativeBridge.startTimer_timeout,

  openUrl: EmbeddedRuntime.nativeBridge.openUrl

};