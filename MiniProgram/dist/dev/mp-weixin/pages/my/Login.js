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
  __name: "Login",
  setup(__props) {
    const activeTab = common_vendor.ref(0);
    const form = common_vendor.ref({
      account: "",
      password: "",
      mobile: "",
      code: ""
    });
    function login() {
    }
    function loginSms() {
    }
    function sendCode() {
    }
    function goForget() {
    }
    return (_ctx, _cache) => {
      return common_vendor.e({
        a: common_assets._imports_0$4,
        b: common_vendor.n(activeTab.value === 0 ? "active" : ""),
        c: common_vendor.o(($event) => activeTab.value = 0),
        d: common_vendor.n(activeTab.value === 1 ? "active" : ""),
        e: common_vendor.o(($event) => activeTab.value = 1),
        f: activeTab.value === 0
      }, activeTab.value === 0 ? {
        g: common_vendor.o(($event) => form.value.account = $event),
        h: common_vendor.p({
          placeholder: "请输入账号",
          ["custom-style"]: "background:#f6fbfc;border-radius:8px;",
          modelValue: form.value.account
        }),
        i: common_vendor.o(($event) => form.value.password = $event),
        j: common_vendor.p({
          type: "password",
          placeholder: "请输入密码",
          ["custom-style"]: "background:#f6fbfc;border-radius:8px;",
          modelValue: form.value.password
        }),
        k: common_vendor.o(goForget),
        l: common_vendor.o(login),
        m: common_vendor.p({
          type: "primary",
          ["custom-style"]: "width:90%;margin:40px auto 0;background:linear-gradient(90deg,#17b2c2,#0e8a9e);border-radius:8px;"
        })
      } : {
        n: common_vendor.o(($event) => form.value.mobile = $event),
        o: common_vendor.p({
          placeholder: "请输入手机号",
          ["custom-style"]: "background:#f6fbfc;border-radius:8px;",
          modelValue: form.value.mobile
        }),
        p: common_vendor.o(($event) => form.value.code = $event),
        q: common_vendor.p({
          placeholder: "请输入验证码",
          ["custom-style"]: "background:#f6fbfc;border-radius:8px;",
          modelValue: form.value.code
        }),
        r: common_vendor.o(sendCode),
        s: common_vendor.p({
          type: "default",
          size: "mini",
          ["custom-style"]: "margin-left:10px;"
        }),
        t: common_vendor.o(loginSms),
        v: common_vendor.p({
          type: "primary",
          ["custom-style"]: "width:90%;margin:40px auto 0;background:linear-gradient(90deg,#17b2c2,#0e8a9e);border-radius:8px;"
        })
      });
    };
  }
});
const MiniProgramPage = /* @__PURE__ */ common_vendor._export_sfc(_sfc_main, [["__scopeId", "data-v-32f86892"]]);
wx.createPage(MiniProgramPage);
