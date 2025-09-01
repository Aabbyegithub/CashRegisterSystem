"use strict";
const common_vendor = require("../../common/vendor.js");
const common_assets = require("../../common/assets.js");
const utitl_request = require("../../utitl/request.js");
if (!Array) {
  const _easycom_u_button2 = common_vendor.resolveComponent("u-button");
  const _easycom_u_icon2 = common_vendor.resolveComponent("u-icon");
  const _easycom_u_popup2 = common_vendor.resolveComponent("u-popup");
  (_easycom_u_button2 + _easycom_u_icon2 + _easycom_u_popup2)();
}
const _easycom_u_button = () => "../../node-modules/uview-plus/components/u-button/u-button.js";
const _easycom_u_icon = () => "../../node-modules/uview-plus/components/u-icon/u-icon.js";
const _easycom_u_popup = () => "../../node-modules/uview-plus/components/u-popup/u-popup.js";
if (!Math) {
  (_easycom_u_button + _easycom_u_icon + _easycom_u_popup)();
}
const _sfc_main = /* @__PURE__ */ common_vendor.defineComponent({
  __name: "orderdetil",
  setup(__props) {
    const tableName = common_vendor.ref("A2桌");
    const oldtableId = common_vendor.ref(0);
    const storeId = common_vendor.ref(0);
    const mergedTable = common_vendor.ref("");
    const changeTable = common_vendor.ref("");
    const showMergeDialog = common_vendor.ref(false);
    const showChangeDialog = common_vendor.ref(false);
    const mergeTables = common_vendor.ref([]);
    const changeTables = common_vendor.ref([]);
    const mergeSelect = common_vendor.ref(0);
    const changeSelect = common_vendor.ref(0);
    const orderList = common_vendor.ref([]);
    const orderId = common_vendor.ref("0");
    const orderstatus = common_vendor.ref();
    const total = common_vendor.ref(71);
    const payType = common_vendor.ref("wechat");
    const coupons = common_vendor.ref([]);
    const selectcoupons = common_vendor.ref("");
    const couponsMoney = common_vendor.ref("");
    const selectcouponsId = common_vendor.ref("");
    const payList = common_vendor.ref([
      { value: "wechat", label: "微信支付", icon: "/static/Vector.png" },
      // { value: 'balance', label: '余额支付', icon: '/static/payFrame(1).png' },
      { value: "alipay", label: "支付宝", icon: "/static/payFrame(2).png" },
      { value: "bank", label: "银行卡", icon: "/static/payFrame(3).png" }
      // { value: 'cash', label: '现金', icon: '/static/payFrame(4).png' }
    ]);
    function handleCunpon() {
      let couponDiscount = 0;
      if (couponsMoney.value) {
        const match = couponsMoney.value.match(/\d+(\.\d+)?/);
        couponDiscount = match ? parseFloat(match[0]) : 0;
      }
      const availableTotal = total.value + couponDiscount;
      common_vendor.index.navigateTo({
        url: "../order/Coupon?total=" + availableTotal
      });
    }
    function selectPay(val) {
      payType.value = val;
    }
    function addDish() {
      common_vendor.index.switchTab({
        url: "../menu/index"
      });
    }
    async function checkout() {
      await utitl_request.request({
        url: "/api/Client/OrderCheckout",
        method: "POST",
        data: {
          orderId: orderId.value,
          type: payType.value,
          CouponsId: selectcouponsId.value || 0
        }
      }).then((res) => {
        if (res.start == 200) {
          common_vendor.index.showToast({ title: "结账成功", icon: "success" });
          common_vendor.index.removeStorageSync("selectedCoupon");
          common_vendor.index.navigateBack();
        } else {
          common_vendor.index.showToast({ title: res.message || "结账失败", icon: "none" });
        }
      }).catch(() => {
        common_vendor.index.showToast({ title: "结账失败", icon: "none" });
      });
      common_vendor.index.showToast({ title: "结账成功", icon: "success" });
    }
    async function confirmMerge() {
      if (!mergeSelect.value)
        return;
      await utitl_request.request({
        url: "/api/Client/MergeTables",
        method: "GET",
        data: {
          orderId: orderId.value,
          oldTableId: oldtableId.value,
          newTableId: mergeSelect.value
        }
      }).then((res) => {
        var _a;
        if (res.start == 200) {
          mergedTable.value = tableName.value;
          tableName.value = ((_a = mergeTables.value.find((item) => item.id == mergeSelect.value)) == null ? void 0 : _a.name) || "";
          showMergeDialog.value = false;
          mergeSelect.value = 0;
          common_vendor.index.showToast({ title: "并台成功", icon: "success" });
        } else {
          common_vendor.index.showToast({ title: "并台失败", icon: "none" });
        }
      }).catch(() => {
        common_vendor.index.showToast({ title: "并台失败", icon: "none" });
      });
    }
    async function confirmChange() {
      if (!changeSelect.value)
        return;
      await utitl_request.request({
        url: "/api/Client/ChangeTables",
        method: "GET",
        data: {
          orderId: orderId.value,
          oldTableId: oldtableId.value,
          newTableId: changeSelect.value
        }
      }).then((res) => {
        var _a;
        if (res.start == 200) {
          changeTable.value = tableName.value;
          tableName.value = ((_a = changeTables.value.find((item) => item.id == changeSelect.value)) == null ? void 0 : _a.name) || "";
          showChangeDialog.value = false;
          changeSelect.value = 0;
          common_vendor.index.showToast({ title: "换桌成功", icon: "success" });
        } else {
          common_vendor.index.showToast({ title: "换桌失败", icon: "none" });
        }
      }).catch(() => {
        common_vendor.index.showToast({ title: "换桌失败", icon: "none" });
      });
      GetTables(storeId.value);
    }
    common_vendor.onLoad(async (options) => {
      console.log("订单详情参数:", options);
      const { orderId: oid, orderstatus: ostatus } = options;
      orderId.value = oid;
      orderstatus.value = ostatus;
      await GetOrderDetail(oid);
      await getStoredCoupon();
    });
    common_vendor.onShow(() => {
      console.log("onShow订单详情");
      var selectedCoupon = common_vendor.index.getStorageSync("selectedCoupon");
      if (selectedCoupon && selectedCoupon.id) {
        selectcoupons.value = selectedCoupon.coupon_name + "满   " + selectedCoupon.min_consumption + "减" + selectedCoupon.value;
        couponsMoney.value = "已优惠￥" + selectedCoupon.value + "元";
        let orderTotal = 0;
        if (orderList.value && orderList.value.length > 0) {
          orderTotal = orderList.value.reduce((sum, item) => sum + Number(item.price), 0);
        } else {
          orderTotal = total.value;
        }
        total.value = orderTotal - selectedCoupon.value;
        selectcouponsId.value = selectedCoupon.id;
      }
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
          const sorted = res.response.filter((x) => total.value >= x.min_consumption).sort((a, b) => b.value - a.value);
          coupons.value = res.response;
          console.log("可用优惠券:", sorted);
          if (sorted.length > 0) {
            selectcoupons.value = sorted.length > 0 ? sorted[0].coupon_name + "满   " + sorted[0].min_consumption + "减" + sorted[0].value : "";
            couponsMoney.value = "已优惠￥" + sorted[0].value + "元";
            total.value = total.value - sorted[0].value;
            common_vendor.index.setStorageSync("selectedCoupon", sorted[0]);
            selectcouponsId.value = sorted[0].id;
          }
        }
      }).catch((err) => {
        console.error("Failed to fetch coupons:", err);
      });
    }
    async function GetOrderDetail(orderId2) {
      await utitl_request.request({
        url: "/api/Client/OrderDetails",
        method: "GET",
        data: {
          orderId: orderId2
        }
      }).then((res) => {
        console.log("获取订单详情", res);
        if (res.response) {
          orderList.value = res.response.orderDetails || [];
          oldtableId.value = res.response.tableId || 0;
          total.value = res.response.total || 0;
          tableName.value = res.response.tableName || "A2桌";
          mergedTable.value = res.response.mergedTable || "";
          changeTable.value = res.response.changeTable || "";
          storeId.value = res.response.storeId || 0;
          GetTables(storeId.value);
        }
      });
    }
    async function GetTables(store_id) {
      await utitl_request.request({
        url: "/api/Client/GetTableListInfo",
        method: "GET",
        data: {
          store_id
        }
      }).then((res) => {
        console.log("获取桌台数据", res);
        mergeTables.value = res.response.filter((item) => item.status === 2 && item.name != tableName.value) || [];
        changeTables.value = res.response.filter((item) => item.status === 1) || [];
      });
    }
    return (_ctx, _cache) => {
      return common_vendor.e({
        a: common_vendor.t(tableName.value),
        b: mergedTable.value
      }, mergedTable.value ? {
        c: common_vendor.t(mergedTable.value),
        d: common_vendor.t(tableName.value)
      } : {}, {
        e: changeTable.value
      }, changeTable.value ? {
        f: common_vendor.t(changeTable.value),
        g: common_vendor.t(tableName.value)
      } : {}, {
        h: common_assets._imports_0$3,
        i: common_vendor.o(($event) => showMergeDialog.value = true),
        j: common_vendor.p({
          size: "mini",
          ["custom-style"]: "margin-right:20rpx;background:#f5f5f5;color:#333;border:1px solid #eee"
        }),
        k: common_assets._imports_1$2,
        l: common_vendor.o(($event) => showChangeDialog.value = true),
        m: common_vendor.p({
          size: "mini",
          ["custom-style"]: "margin-right:20rpx;background:#f5f5f5;color:#333;border:1px solid #eee"
        }),
        n: common_vendor.f(orderList.value, (item, k0, i0) => {
          return {
            a: common_vendor.t(item.name),
            b: common_vendor.t(item.spec),
            c: common_vendor.t(item.price),
            d: item.id
          };
        }),
        o: coupons.value.length > 0
      }, coupons.value.length > 0 ? {
        p: common_vendor.t(selectcoupons.value),
        q: common_vendor.o(handleCunpon)
      } : {}, {
        r: couponsMoney.value
      }, couponsMoney.value ? {
        s: common_vendor.t(couponsMoney.value)
      } : {}, {
        t: common_vendor.t(total.value),
        v: common_vendor.f(payList.value, (pay, k0, i0) => {
          return common_vendor.e({
            a: pay.icon,
            b: common_vendor.t(pay.label),
            c: payType.value === pay.value
          }, payType.value === pay.value ? {
            d: "1930558e-2-" + i0,
            e: common_vendor.p({
              name: "checkmark-circle-fill",
              size: "28",
              ["custom-style"]: "color:#F04216"
            })
          } : {
            f: "1930558e-3-" + i0,
            g: common_vendor.p({
              name: "checkmark-circle",
              size: "28",
              ["custom-style"]: "color:#ccc"
            })
          }, {
            h: pay.value,
            i: common_vendor.o(($event) => selectPay(pay.value), pay.value)
          });
        }),
        w: orderstatus.value === "待支付"
      }, orderstatus.value === "待支付" ? {
        x: common_vendor.o(addDish),
        y: common_vendor.p({
          ["custom-style"]: "width:45%;border-radius: 50rpx;background:#fff;color:#333;border:1px solid #ccc"
        }),
        z: common_vendor.o(checkout),
        A: common_vendor.p({
          type: "primary",
          ["custom-style"]: "width:45%;border-radius: 50rpx;background:linear-gradient(90deg,#0E8A9E,#1CB5E0);color:#fff"
        })
      } : {}, {
        B: common_vendor.f(mergeTables.value, (table, k0, i0) => {
          return {
            a: common_vendor.t(table.name),
            b: table.id,
            c: mergeSelect.value === table.id ? 1 : "",
            d: common_vendor.o(($event) => mergeSelect.value = table.id, table.id)
          };
        }),
        C: common_vendor.o(($event) => showMergeDialog.value = false),
        D: common_vendor.p({
          ["custom-style"]: "width:45%;border-radius: 50rpx;background:#fff;color:#333;border:1px solid #ccc"
        }),
        E: common_vendor.o(confirmMerge),
        F: common_vendor.p({
          type: "primary",
          ["custom-style"]: "width:45%;border-radius: 50rpx;background:linear-gradient(90deg,#0E8A9E,#1CB5E0);color:#fff"
        }),
        G: common_vendor.o(($event) => showMergeDialog.value = false),
        H: common_vendor.p({
          show: showMergeDialog.value,
          mode: "center"
        }),
        I: common_vendor.f(changeTables.value, (table, k0, i0) => {
          return {
            a: common_vendor.t(table.name),
            b: table.id,
            c: changeSelect.value === table.id ? 1 : "",
            d: common_vendor.o(($event) => changeSelect.value = table.id, table.id)
          };
        }),
        J: common_vendor.o(($event) => showChangeDialog.value = false),
        K: common_vendor.p({
          ["custom-style"]: "width:45%;border-radius: 50rpx;background:#fff;color:#333;border:1px solid #ccc"
        }),
        L: common_vendor.o(confirmChange),
        M: common_vendor.p({
          type: "primary",
          ["custom-style"]: "width:45%;border-radius: 50rpx;background:linear-gradient(90deg,#0E8A9E,#1CB5E0);color:#fff"
        }),
        N: common_vendor.o(($event) => showChangeDialog.value = false),
        O: common_vendor.p({
          show: showChangeDialog.value,
          mode: "center"
        })
      });
    };
  }
});
wx.createPage(_sfc_main);
