"use strict";
const common_vendor = require("../../common/vendor.js");
const common_assets = require("../../common/assets.js");
const utitl_request = require("../../utitl/request.js");
if (!Array) {
  const _easycom_u_button2 = common_vendor.resolveComponent("u-button");
  _easycom_u_button2();
}
const _easycom_u_button = () => "../../node-modules/uview-plus/components/u-button/u-button.js";
if (!Math) {
  (CustomHeader + _easycom_u_button)();
}
const CustomHeader = () => "../../components/CustomHeader.js";
const _sfc_main = /* @__PURE__ */ common_vendor.defineComponent({
  __name: "index",
  setup(__props) {
    const searchValue = common_vendor.ref("");
    const sourceType = common_vendor.ref(2);
    var UserInfo = common_vendor.index.getStorageSync("UserInfo");
    if (!UserInfo) {
      sourceType.value = 1;
    }
    const { tableId, storeId, people } = common_vendor.index.getStorageSync("TableInfo") || {};
    const orders = common_vendor.ref([]);
    const urgeOrder = async (id) => {
      console.log("催单:", id);
      await utitl_request.request({
        url: `/api/Client/OrderReminder?orderId=${id}`,
        method: "GET"
      }).then(() => {
        common_vendor.index.showToast({ title: "催单成功", icon: "success" });
      }).catch(() => {
        common_vendor.index.showToast({ title: "催单失败", icon: "none" });
      });
    };
    const addDish = (id) => {
      console.log("加菜:", id);
      common_vendor.index.setStorageSync("OrderId", id);
      common_vendor.index.switchTab({
        url: `../menu/index`
      });
    };
    const checkout = (id, orderstatus) => {
      console.log("结账:", id);
      common_vendor.index.navigateTo({ url: `/pages/order/orderdetil?orderId=${id}&orderstatus=${orderstatus}` });
    };
    const viewDetails = (id, orderstatus) => {
      console.log("查看详情:", id);
      common_vendor.index.navigateTo({ url: `/pages/order/orderdetil?orderId=${id}&orderstatus=${orderstatus}` });
    };
    const handleSearch = (value) => {
      console.log("搜索:", value);
      orders.value = orders.value.filter((order) => order.tableNumber.includes(value));
    };
    common_vendor.onShow(() => {
      getOrders();
    });
    const getOrders = async () => {
      await utitl_request.request({
        url: `/api/Client/GetTableOrder?store_id=${storeId}&table_id=${tableId}&sourceType=${sourceType.value}`,
        method: "GET"
      }).then((res) => {
        console.log("获取订单数据", res);
        if (res.start === 200) {
          orders.value = res.response.map((order) => ({
            ...order,
            id: order.order_id,
            tableNumber: order.table.table_no,
            orderTime: common_vendor.dayjs(order.start_time).format("YYYY-MM-DD HH:mm:ss"),
            diningTime: common_vendor.dayjs(order.start_time).format("YYYY-MM-DD HH:mm:ss"),
            status: order.status === 1 || order.status == 2 ? "待支付" : "已结清",
            peopleCount: order.table_capacity,
            amount: order.payable_amount
          }));
        } else {
          common_vendor.index.showToast({ title: res.message, icon: "none" });
        }
      }).catch((error) => {
        console.error("获取订单数据失败", error);
        common_vendor.index.showToast({ title: "获取订单数据失败", icon: "none" });
      });
    };
    return (_ctx, _cache) => {
      return {
        a: common_vendor.o((val) => searchValue.value = val),
        b: common_vendor.o(handleSearch),
        c: common_vendor.p({
          title: "订单管理",
          searchValue: searchValue.value,
          searchPlaceholder: "桌号"
        }),
        d: common_vendor.f(orders.value, (order, k0, i0) => {
          return common_vendor.e({
            a: common_vendor.t(order.tableNumber),
            b: order.status === "待支付"
          }, order.status === "待支付" ? {
            c: common_assets._imports_0
          } : {
            d: common_assets._imports_1
          }, {
            e: common_vendor.t(order.peopleCount),
            f: common_vendor.t(order.orderTime),
            g: common_vendor.t(order.amount),
            h: common_vendor.t(order.diningTime),
            i: order.status === "待支付"
          }, order.status === "待支付" ? {
            j: common_vendor.o(($event) => urgeOrder(order.id), order.id),
            k: "3ab28c9c-1-" + i0,
            l: common_vendor.p({
              type: "default",
              size: "mini",
              ["custom-style"]: "margin:5rpx;border:none;box-shadow:none;background-color:transparent;width:30px;font-size: 28rpx;"
            })
          } : {}, {
            m: order.status === "待支付"
          }, order.status === "待支付" ? {
            n: common_vendor.o(($event) => addDish(order.id), order.id),
            o: "3ab28c9c-2-" + i0,
            p: common_vendor.p({
              type: "default",
              size: "mini",
              ["custom-style"]: "margin:5rpx;border:none;box-shadow:none;background-color:transparent;width:30px;font-size: 28rpx;"
            })
          } : {}, {
            q: order.status === "待支付"
          }, order.status === "待支付" ? {
            r: common_vendor.o(($event) => checkout(order.id, order.status), order.id),
            s: "3ab28c9c-3-" + i0,
            t: common_vendor.p({
              type: "default",
              size: "mini",
              ["custom-style"]: "margin:5rpx;border:none;box-shadow:none;background-color:transparent;width:30px;font-size: 28rpx;"
            })
          } : {}, {
            v: order.status === "已结清"
          }, order.status === "已结清" ? {
            w: common_vendor.o(($event) => viewDetails(order.id, order.status), order.id),
            x: "3ab28c9c-4-" + i0,
            y: common_vendor.p({
              type: "default",
              size: "mini",
              ["custom-style"]: "margin:5rpx;border:none;box-shadow:none;background-color:transparent;width:30px;font-size: 28rpx;"
            })
          } : {}, {
            z: order.id
          });
        })
      };
    };
  }
});
wx.createPage(_sfc_main);
