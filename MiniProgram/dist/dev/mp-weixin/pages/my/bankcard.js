"use strict";
const common_vendor = require("../../common/vendor.js");
if (!Array) {
  const _easycom_u_icon2 = common_vendor.resolveComponent("u-icon");
  const _easycom_u_input2 = common_vendor.resolveComponent("u-input");
  const _easycom_u_button2 = common_vendor.resolveComponent("u-button");
  (_easycom_u_icon2 + _easycom_u_input2 + _easycom_u_button2)();
}
const _easycom_u_icon = () => "../../node-modules/uview-plus/components/u-icon/u-icon.js";
const _easycom_u_input = () => "../../node-modules/uview-plus/components/u-input/u-input.js";
const _easycom_u_button = () => "../../node-modules/uview-plus/components/u-button/u-button.js";
if (!Math) {
  (_easycom_u_icon + _easycom_u_input + _easycom_u_button)();
}
const _sfc_main = /* @__PURE__ */ common_vendor.defineComponent({
  __name: "bankcard",
  setup(__props) {
    const form = common_vendor.ref({
      name: "李美丽",
      idcard: "610481199526354236",
      banknum: "621356895456620",
      banktype: "招商银行",
      branch: "长安南路支行",
      email: "6548924156@qq.com"
    });
    function goBack() {
      common_vendor.index.navigateBack();
    }
    function submit() {
      common_vendor.index.showToast({ title: "保存成功", icon: "success" });
    }
    return (_ctx, _cache) => {
      return {
        a: common_vendor.p({
          name: "order",
          size: "22",
          ["custom-style"]: "margin-right:10rpx;color:#8fc1c7"
        }),
        b: common_vendor.o(($event) => form.value.name = $event),
        c: common_vendor.p({
          ["custom-style"]: "width:70%;background:#ffffff;border: 1px solid #666666;",
          modelValue: form.value.name
        }),
        d: common_vendor.o(($event) => form.value.idcard = $event),
        e: common_vendor.p({
          ["custom-style"]: "width:70%;border: 1px solid #666666;",
          placeholder: "请输入身份证号",
          modelValue: form.value.idcard
        }),
        f: common_vendor.o(($event) => form.value.banknum = $event),
        g: common_vendor.p({
          ["custom-style"]: "width:70%;border: 1px solid #666666;",
          placeholder: "请输入银行账号",
          modelValue: form.value.banknum
        }),
        h: common_vendor.o(($event) => form.value.banktype = $event),
        i: common_vendor.p({
          ["custom-style"]: "width:70%;border: 1px solid #666666;",
          placeholder: "请输入银行类别",
          modelValue: form.value.banktype
        }),
        j: common_vendor.o(($event) => form.value.branch = $event),
        k: common_vendor.p({
          ["custom-style"]: "width:70%;border: 1px solid #666666;",
          placeholder: "请输入开户支行",
          modelValue: form.value.branch
        }),
        l: common_vendor.o(($event) => form.value.email = $event),
        m: common_vendor.p({
          ["custom-style"]: "width:70%;border: 1px solid #666666;",
          placeholder: "请输入邮箱",
          modelValue: form.value.email
        }),
        n: common_vendor.o(goBack),
        o: common_vendor.p({
          ["custom-style"]: "width:45%;border-radius: 50rpx;background:#fff;color:#333;border:1px solid #ccc"
        }),
        p: common_vendor.o(submit),
        q: common_vendor.p({
          type: "primary",
          ["custom-style"]: "width:45%;border-radius: 50rpx;background:linear-gradient(90deg,#0E8A9E,#1CB5E0);color:#fff"
        })
      };
    };
  }
});
wx.createPage(_sfc_main);
