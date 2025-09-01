"use strict";
const common_vendor = require("../../common/vendor.js");
const common_assets = require("../../common/assets.js");
if (!Array) {
  const _easycom_u_icon2 = common_vendor.resolveComponent("u-icon");
  _easycom_u_icon2();
}
const _easycom_u_icon = () => "../../node-modules/uview-plus/components/u-icon/u-icon.js";
if (!Math) {
  _easycom_u_icon();
}
const _sfc_main = /* @__PURE__ */ common_vendor.defineComponent({
  __name: "index",
  setup(__props) {
    function gobankcard() {
      common_vendor.index.navigateTo({
        url: "/pages/my/bankcard"
      });
    }
    return (_ctx, _cache) => {
      return {
        a: common_assets._imports_0$2,
        b: common_assets._imports_1$1,
        c: common_assets._imports_2,
        d: common_vendor.p({
          size: "24",
          name: "arrow-right",
          ["custom-style"]: "width:50px;float:right;color:#0E8A9E;margin-right:-40px;"
        }),
        e: common_vendor.o(gobankcard)
      };
    };
  }
});
wx.createPage(_sfc_main);
