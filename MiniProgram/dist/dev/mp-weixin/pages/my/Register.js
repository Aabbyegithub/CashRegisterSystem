"use strict";
const common_vendor = require("../../common/vendor.js");
const common_assets = require("../../common/assets.js");
if (!Array) {
  const _easycom_u_input2 = common_vendor.resolveComponent("u-input");
  const _easycom_u_button2 = common_vendor.resolveComponent("u-button");
  (_easycom_u_input2 + _easycom_u_button2)();
}
const _easycom_u_input = () => "../../node-modules/uview-plus/components/u-input/u-input.js";
const _easycom_u_button = () => "../../node-modules/uview-plus/components/u-button/u-button.js";
if (!Math) {
  (_easycom_u_input + _easycom_u_button)();
}
const _sfc_main = /* @__PURE__ */ common_vendor.defineComponent({
  __name: "Register",
  setup(__props) {
    const form = common_vendor.ref({
      mobile: "",
      code: "",
      password: "",
      confirm: ""
    });
    function sendCode() {
    }
    function register() {
    }
    function goLogin() {
      common_vendor.index.navigateTo({ url: "/pages/my/Login" });
    }
    return (_ctx, _cache) => {
      return {
        a: common_assets._imports_0$4,
        b: common_vendor.o(goLogin),
        c: common_vendor.o(($event) => form.value.mobile = $event),
        d: common_vendor.p({
          placeholder: "请输入手机号",
          ["custom-style"]: "background:#f6fbfc;border-radius:8px;",
          modelValue: form.value.mobile
        }),
        e: common_vendor.o(($event) => form.value.code = $event),
        f: common_vendor.p({
          placeholder: "请输入短信验证码",
          ["custom-style"]: "background:#f6fbfc;border-radius:8px;",
          modelValue: form.value.code
        }),
        g: common_vendor.o(sendCode),
        h: common_vendor.p({
          type: "default",
          size: "mini",
          ["custom-style"]: "margin-left:10px;"
        }),
        i: common_vendor.o(($event) => form.value.password = $event),
        j: common_vendor.p({
          type: "password",
          placeholder: "请输入密码",
          ["custom-style"]: "background:#f6fbfc;border-radius:8px;",
          modelValue: form.value.password
        }),
        k: common_vendor.o(($event) => form.value.confirm = $event),
        l: common_vendor.p({
          type: "password",
          placeholder: "请再次输入密码",
          ["custom-style"]: "background:#f6fbfc;border-radius:8px;",
          modelValue: form.value.confirm
        }),
        m: common_vendor.o(register),
        n: common_vendor.p({
          type: "primary",
          ["custom-style"]: "width:90%;margin:40px auto 0;background:linear-gradient(90deg,#17b2c2,#0e8a9e);border-radius:8px;"
        })
      };
    };
  }
});
const MiniProgramPage = /* @__PURE__ */ common_vendor._export_sfc(_sfc_main, [["__scopeId", "data-v-32a5b8a0"]]);
wx.createPage(MiniProgramPage);
