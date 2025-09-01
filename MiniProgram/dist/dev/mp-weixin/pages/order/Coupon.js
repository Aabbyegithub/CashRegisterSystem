"use strict";
const common_vendor = require("../../common/vendor.js");
const utitl_request = require("../../utitl/request.js");
if (!Array) {
  const _easycom_u_button2 = common_vendor.resolveComponent("u-button");
  _easycom_u_button2();
}
const _easycom_u_button = () => "../../node-modules/uview-plus/components/u-button/u-button.js";
if (!Math) {
  _easycom_u_button();
}
const _sfc_main = /* @__PURE__ */ common_vendor.defineComponent({
  __name: "Coupon",
  setup(__props) {
    const coupons = common_vendor.ref([
      { id: 1, title: "消费券", limit: 100, value: 5, date: "2025.09.01-2025.09.30" },
      { id: 2, title: "会员专享", limit: 200, value: 15, date: "2025.09.01-2025.09.30" },
      { id: 3, title: "新客专享", limit: 50, value: 2, date: "2025.09.01-2025.09.30" }
    ]);
    const total = common_vendor.ref(0);
    common_vendor.onLoad((options) => {
      if (options.total) {
        total.value = parseFloat(options.total);
        console.log("传递的总价参数:", total.value);
      }
    });
    common_vendor.onShow(async () => {
      await getStoredCoupon();
    });
    async function getStoredCoupon() {
      await utitl_request.request({
        url: "/api/Client/GetCouponList",
        method: "GET",
        data: {
          storeId: common_vendor.index.getStorageSync("TableInfo").storeId || 0
        }
      }).then((res) => {
        if (res.start === 200 && res.response) {
          coupons.value = res.response.map((c) => ({
            id: c.coupon_id,
            title: c.coupon_name,
            limit: c.min_consumption,
            value: c.value,
            date: `${common_vendor.dayjs(c.valid_start).format("YYYY.MM.DD")} - ${common_vendor.dayjs(c.valid_end).format("YYYY.MM.DD")}`
          }));
        }
      }).catch((err) => {
        console.error("Failed to fetch coupons:", err);
      });
    }
    const selectedCoupon = common_vendor.ref(null);
    function useCoupon(coupon) {
      selectedCoupon.value = coupon.id;
      common_vendor.index.setStorageSync("selectedCoupon", coupon);
      common_vendor.index.navigateBack();
    }
    return (_ctx, _cache) => {
      return {
        a: common_vendor.f(coupons.value, (coupon, k0, i0) => {
          return {
            a: common_vendor.t(coupon.value),
            b: common_vendor.s(coupon.limit > total.value ? "color:#bbb;" : selectedCoupon.value === coupon.id ? "color:#F6A623;" : "color:#F04216;"),
            c: common_vendor.t(coupon.limit),
            d: common_vendor.t(coupon.value),
            e: common_vendor.s(coupon.limit > total.value ? "color:#bbb;" : selectedCoupon.value === coupon.id ? "color:#F6A623;" : "color:#0E8A9E;"),
            f: common_vendor.t(coupon.title),
            g: common_vendor.s(coupon.limit > total.value ? "color:#bbb;" : selectedCoupon.value === coupon.id ? "color:#F6A623;" : ""),
            h: common_vendor.t(coupon.date),
            i: common_vendor.s(coupon.limit > total.value ? "color:#bbb;" : selectedCoupon.value === coupon.id ? "color:#888;" : ""),
            j: coupon.limit > total.value ? 1 : "",
            k: common_vendor.o(($event) => useCoupon(coupon), coupon.id),
            l: "e6428028-0-" + i0,
            m: common_vendor.p({
              type: "primary",
              size: "mini",
              ["custom-style"]: "width:100rpx;height:48rpx;border-radius: 24rpx;background: #F6A623;color:#fff;font-size:24rpx;",
              disabled: selectedCoupon.value === coupon.id || coupon.limit > total.value
            }),
            n: coupon.id,
            o: selectedCoupon.value === coupon.id ? 1 : ""
          };
        })
      };
    };
  }
});
wx.createPage(_sfc_main);
