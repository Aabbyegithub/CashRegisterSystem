"use strict";
const common_vendor = require("../common/vendor.js");
const config = require("../config.js");
function request(options) {
  return new Promise((resolve, reject) => {
    common_vendor.index.request({
      url: config.BASE_URL + options.url,
      method: options.method || "GET",
      data: options.data || {},
      header: { ...config.DEFAULT_HEADERS, ...options.headers || {} },
      timeout: options.timeout || config.TIMEOUT,
      success: (res) => {
        if (res.statusCode === 200) {
          resolve(res.data);
        } else if (res.statusCode === 401) {
          common_vendor.index.showToast({ title: "登录失效，请重新登录", icon: "none" });
          setTimeout(() => {
            common_vendor.index.redirectTo({ url: "/pages/login/index" });
          }, 1500);
        } else {
          common_vendor.index.showToast({ title: res.data.message || "请求失败", icon: "none" });
        }
      },
      fail: (err) => {
        reject(err);
      }
    });
  });
}
exports.request = request;
