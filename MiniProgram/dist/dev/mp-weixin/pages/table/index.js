"use strict";
const common_vendor = require("../../common/vendor.js");
const utitl_request = require("../../utitl/request.js");
if (!Array) {
  const _easycom_u_icon2 = common_vendor.resolveComponent("u-icon");
  const _easycom_u_button2 = common_vendor.resolveComponent("u-button");
  const _easycom_u_popup2 = common_vendor.resolveComponent("u-popup");
  (_easycom_u_icon2 + _easycom_u_button2 + _easycom_u_popup2)();
}
const _easycom_u_icon = () => "../../node-modules/uview-plus/components/u-icon/u-icon.js";
const _easycom_u_button = () => "../../node-modules/uview-plus/components/u-button/u-button.js";
const _easycom_u_popup = () => "../../node-modules/uview-plus/components/u-popup/u-popup.js";
if (!Math) {
  (_easycom_u_icon + _easycom_u_button + _easycom_u_popup)();
}
const _sfc_main = /* @__PURE__ */ common_vendor.defineComponent({
  __name: "index",
  setup(__props) {
    const tables = common_vendor.ref([]);
    const showOpenDialog = common_vendor.ref(false);
    const selectedTable = common_vendor.ref(null);
    const selectStoreId = common_vendor.ref(0);
    const openPeople = common_vendor.ref(1);
    function handleTableClick(table) {
      if (table.status === 1) {
        selectedTable.value = table;
        openPeople.value = 1;
        showOpenDialog.value = true;
      }
    }
    function changePeople(val) {
      if (!selectedTable.value)
        return;
      const max = selectedTable.value.max;
      const min = 1;
      let next = openPeople.value + val;
      if (next < min)
        next = min;
      if (next > max)
        next = max;
      openPeople.value = next;
    }
    function confirmOpen() {
      if (!selectedTable.value)
        return;
      selectedTable.value.status = 2;
      selectedTable.value.people = openPeople.value;
      showOpenDialog.value = false;
      common_vendor.index.setStorageSync("TableInfo", {
        tableId: selectedTable.value.id,
        storeId: selectStoreId.value,
        people: openPeople.value
      });
      common_vendor.index.switchTab({
        url: "../menu/index"
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
        tables.value = res.response || [];
      });
    }
    common_vendor.onLoad((options) => {
      const { tableId, storeId } = options;
      let actualStoreId = storeId;
      if (!actualStoreId) {
        actualStoreId = common_vendor.index.getStorageSync("UserInfo").store_id || 2;
      }
      selectStoreId.value = actualStoreId;
      GetTables(actualStoreId);
      if (tableId) {
        const table = tables.value.find((t) => String(t.id) === String(tableId) && t.status === 1);
        if (table) {
          selectedTable.value = table;
          openPeople.value = 1;
          showOpenDialog.value = true;
        }
      }
    });
    common_vendor.onShow(() => {
      GetTables(selectStoreId.value);
    });
    return (_ctx, _cache) => {
      var _a;
      return {
        a: common_vendor.f(tables.value, (table, k0, i0) => {
          var _a2;
          return common_vendor.e({
            a: common_vendor.t(table.name),
            b: common_vendor.t(table.status === 1 ? "空闲" : table.status === 2 ? "使用中" : table.status === 3 ? "预订" : "清洁中"),
            c: common_vendor.t(table.people),
            d: common_vendor.t(table.max),
            e: table.status === 3
          }, table.status === 3 ? {
            f: common_vendor.t(table.bookedTime)
          } : {}, {
            g: table.id,
            h: common_vendor.n(table.status === 2 ? "used-red" : table.status),
            i: common_vendor.n(((_a2 = selectedTable.value) == null ? void 0 : _a2.id) === table.id ? "selected" : ""),
            j: common_vendor.o(($event) => handleTableClick(table), table.id)
          });
        }),
        b: common_vendor.t((_a = selectedTable.value) == null ? void 0 : _a.name),
        c: common_vendor.o(($event) => changePeople(-1)),
        d: common_vendor.p({
          name: "arrow-left",
          size: "28",
          ["custom-style"]: "margin-right:20px"
        }),
        e: common_vendor.t(openPeople.value),
        f: common_vendor.o(($event) => changePeople(1)),
        g: common_vendor.p({
          name: "arrow-right",
          size: "28",
          ["custom-style"]: "margin-left:20px"
        }),
        h: common_vendor.o(($event) => showOpenDialog.value = false),
        i: common_vendor.p({
          ["custom-style"]: "width:40%;margin-right:20px;border-radius: 50rpx;"
        }),
        j: common_vendor.o(confirmOpen),
        k: common_vendor.p({
          type: "primary",
          ["custom-style"]: "width:40%;background:#0E8A9E;border-radius: 50rpx;"
        }),
        l: common_vendor.o(($event) => showOpenDialog.value = false),
        m: common_vendor.p({
          show: showOpenDialog.value,
          mode: "center"
        })
      };
    };
  }
});
wx.createPage(_sfc_main);
