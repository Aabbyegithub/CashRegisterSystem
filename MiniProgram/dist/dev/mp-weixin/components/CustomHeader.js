"use strict";
const common_vendor = require("../common/vendor.js");
const common_assets = require("../common/assets.js");
const _sfc_main = /* @__PURE__ */ common_vendor.defineComponent({
  __name: "CustomHeader",
  props: {
    title: { type: String, default: "标题" },
    searchValue: { type: String, default: "" },
    searchPlaceholder: { type: String, default: "搜索" },
    icon: { type: String, default: "/src/static/Frame.png" }
  },
  emits: ["update:searchValue", "search"],
  setup(__props, { emit: __emit }) {
    const emit = __emit;
    function onInput(e) {
      emit("update:searchValue", e.detail.value);
      emit("search", e.detail.value);
    }
    return (_ctx, _cache) => {
      return {
        a: common_assets._imports_0$5,
        b: __props.searchValue,
        c: __props.searchPlaceholder,
        d: common_vendor.o(onInput),
        e: common_vendor.t(__props.title)
      };
    };
  }
});
const Component = /* @__PURE__ */ common_vendor._export_sfc(_sfc_main, [["__scopeId", "data-v-8942cb99"]]);
wx.createComponent(Component);
