"use strict";
const common_vendor = require("../../common/vendor.js");
const common_assets = require("../../common/assets.js");
const utitl_request = require("../../utitl/request.js");
if (!Array) {
  const _easycom_u_image2 = common_vendor.resolveComponent("u-image");
  const _easycom_u_icon2 = common_vendor.resolveComponent("u-icon");
  const _easycom_u_button2 = common_vendor.resolveComponent("u-button");
  const _easycom_u_popup2 = common_vendor.resolveComponent("u-popup");
  (_easycom_u_image2 + _easycom_u_icon2 + _easycom_u_button2 + _easycom_u_popup2)();
}
const _easycom_u_image = () => "../../node-modules/uview-plus/components/u-image/u-image.js";
const _easycom_u_icon = () => "../../node-modules/uview-plus/components/u-icon/u-icon.js";
const _easycom_u_button = () => "../../node-modules/uview-plus/components/u-button/u-button.js";
const _easycom_u_popup = () => "../../node-modules/uview-plus/components/u-popup/u-popup.js";
if (!Math) {
  (CustomHeader + _easycom_u_image + _easycom_u_icon + _easycom_u_button + _easycom_u_popup)();
}
const CustomHeader = () => "../../components/CustomHeader.js";
const _sfc_main = /* @__PURE__ */ common_vendor.defineComponent({
  __name: "index",
  setup(__props) {
    const showSpecDialog = common_vendor.ref(false);
    const selectedDish = common_vendor.ref(null);
    const specList = common_vendor.ref(["约1000克"]);
    const spicyList = common_vendor.ref(["不辣", "正常", "中辣", "重辣"]);
    const selectedSpec = common_vendor.ref(specList.value[0]);
    const selectedSpicy = common_vendor.ref(spicyList.value[0]);
    const qty = common_vendor.ref(1);
    const TableId = common_vendor.ref(0);
    function openSpecDialog(dish) {
      var _a, _b;
      const specArr = ((_a = dishes.value.find((d) => d.id === dish.id)) == null ? void 0 : _a.dish_spec.filter((d) => d.spec_type === "分量")) || [];
      specList.value = specArr.map((item) => item.spec_name);
      const specyArr = ((_b = dishes.value.find((d) => d.id === dish.id)) == null ? void 0 : _b.dish_spec.filter((d) => d.spec_type === "辣度")) || [];
      spicyList.value = specyArr.map((item) => item.spec_name);
      selectedDish.value = dish;
      showSpecDialog.value = true;
      selectedSpec.value = specList.value[0];
      selectedSpicy.value = spicyList.value[0];
      qty.value = 1;
    }
    function changeQty(val) {
      if (qty.value + val >= 1)
        qty.value += val;
    }
    const searchValue = common_vendor.ref("");
    const categories = common_vendor.ref([]);
    const dishes = common_vendor.ref([]);
    function selectCategory(id) {
      categories.value.forEach((item) => item.active = item.id === id);
      setTimeout(() => {
        const dishIndex = dishes.value.findIndex((d) => d.dishCategoryType === id);
        if (dishIndex > -1) {
          const selector = `.dish-item:nth-child(${dishIndex + 1})`;
          common_vendor.index.createSelectorQuery().select(selector).boundingClientRect((rect) => {
            if (rect && typeof rect.top === "number") {
              common_vendor.index.pageScrollTo({
                scrollTop: rect.top - 80,
                // 80为header高度，可根据实际调整
                duration: 300
              });
            }
          }).exec();
        }
      }, 50);
    }
    function handleSearch(val) {
    }
    function getCartQty(id) {
      const item = cartList.value.find((i) => i.id === id && (!i.spec && !i.spicy));
      return item ? item.qty : 0;
    }
    function changeCartQtySimple(dish, val) {
      const idx = cartList.value.findIndex((i) => i.id === dish.id && (!i.spec && !i.spicy));
      if (idx > -1) {
        cartList.value[idx].qty += val;
        if (cartList.value[idx].qty <= 0)
          cartList.value.splice(idx, 1);
      } else if (val > 0) {
        cartList.value.push({
          id: dish.id,
          name: dish.name,
          img: dish.img,
          price: dish.price,
          qty: 1
        });
      }
      calcCartTotal();
    }
    const showCartDialog = common_vendor.ref(false);
    const cartList = common_vendor.ref([]);
    const cartTotal = common_vendor.ref(0);
    function addToCart() {
      const dish = selectedDish.value;
      if (!dish)
        return;
      const idx = cartList.value.findIndex((item) => item.id === dish.id && item.spec === selectedSpec.value && item.spicy === selectedSpicy.value);
      if (idx > -1) {
        cartList.value[idx].qty += qty.value;
      } else {
        cartList.value.push({
          id: dish.id,
          name: dish.name,
          img: dish.img,
          price: dish.price,
          spec: selectedSpec.value,
          spicy: selectedSpicy.value,
          qty: qty.value
        });
      }
      calcCartTotal();
      showSpecDialog.value = false;
      common_vendor.index.showToast({ title: "已加入购物车", icon: "success" });
    }
    function changeCartQty(item, val) {
      item.qty += val;
      if (item.qty <= 0) {
        cartList.value = cartList.value.filter((i) => i !== item);
      }
      calcCartTotal();
    }
    function calcCartTotal() {
      cartTotal.value = cartList.value.reduce((sum, item) => sum + item.price * item.qty, 0);
    }
    async function submitOrder() {
      if (cartList.value.length === 0) {
        common_vendor.index.showToast({ title: "购物车为空", icon: "none" });
        return;
      }
      var sourceType = 2;
      var UserInfo = common_vendor.index.getStorageSync("UserInfo");
      if (!UserInfo) {
        sourceType = 1;
      }
      const { tableId, storeId, people } = common_vendor.index.getStorageSync("TableInfo") || {};
      const orderId = common_vendor.index.getStorageSync("OrderId");
      await utitl_request.request({
        url: `/api/Client/SaveOrder?store_id=${storeId}&table_id=${tableId}&sourceType=${sourceType}&people=${people}&orderId=${orderId}`,
        method: "POST",
        data: cartList.value.map((item) => ({
          ...item,
          price: String(item.price),
          spec: String(item.spec || ""),
          spicy: String(item.spicy || ""),
          qty: Number(item.qty)
        }))
      }).then((res) => {
        if (res.start == 200) {
          common_vendor.index.showToast({ title: "下单成功", icon: "success" });
          cartList.value = [];
          cartTotal.value = 0;
          showCartDialog.value = false;
        } else {
          common_vendor.index.showToast({ title: res.message || "下单失败", icon: "none" });
        }
      }).catch(() => {
        common_vendor.index.showToast({ title: "网络错误，请稍后再试", icon: "none" });
      });
    }
    common_vendor.onLoad(() => {
      const { tableId, storeId, people } = common_vendor.index.getStorageSync("TableInfo") || {};
      if (tableId) {
        TableId.value = tableId;
      } else {
        common_vendor.index.showToast({ title: "未指定桌台", icon: "none" });
      }
      getmenuType(storeId);
      getmenuList(storeId);
    });
    async function getmenuType(storeId) {
      await utitl_request.request({
        url: "/api/Client/GetDishType",
        method: "GET",
        data: {
          store_id: storeId
        }
      }).then((res) => {
        categories.value = res.response || [];
      });
    }
    async function getmenuList(storeId) {
      await utitl_request.request({
        url: "/api/Client/GetDish",
        method: "GET",
        data: {
          store_id: storeId
        }
      }).then((res) => {
        dishes.value = res.response || [];
      });
    }
    return (_ctx, _cache) => {
      var _a, _b, _c;
      return common_vendor.e({
        a: common_vendor.o((val) => searchValue.value = val),
        b: common_vendor.o(handleSearch),
        c: common_vendor.p({
          title: "A2桌点餐",
          searchValue: searchValue.value,
          searchPlaceholder: "搜索"
        }),
        d: common_vendor.f(categories.value, (item, k0, i0) => {
          return {
            a: common_vendor.t(item.name),
            b: item.id,
            c: common_vendor.n(item.active ? "active" : ""),
            d: common_vendor.o(($event) => selectCategory(item.id), item.id)
          };
        }),
        e: common_vendor.f(dishes.value, (dish, k0, i0) => {
          return common_vendor.e({
            a: "6d2f30b2-1-" + i0,
            b: common_vendor.p({
              src: dish.img,
              width: "80px",
              height: "80px",
              radius: "10rpx",
              ["lazy-load"]: true
            }),
            c: common_vendor.t(dish.name),
            d: common_vendor.t(dish.desc),
            e: common_vendor.t(dish.price),
            f: dish.spece == 0
          }, dish.spece == 0 ? common_vendor.e({
            g: getCartQty(dish.id) > 0
          }, getCartQty(dish.id) > 0 ? {
            h: common_vendor.o(($event) => changeCartQtySimple(dish, -1), dish.id),
            i: "6d2f30b2-2-" + i0,
            j: common_vendor.p({
              size: "24",
              name: "minus-circle",
              ["custom-style"]: "width:50px;float:right;color:#0E8A9E;margin-right:-40px;margin-bottom:-60px"
            }),
            k: common_vendor.t(getCartQty(dish.id)),
            l: common_vendor.o(($event) => changeCartQtySimple(dish, 1), dish.id),
            m: "6d2f30b2-3-" + i0,
            n: common_vendor.p({
              size: "24",
              name: "plus-circle-fill",
              ["custom-style"]: "width:50px;float:right;color:#0E8A9E;margin-right:-30px;margin-bottom:-60px"
            })
          } : {
            o: common_vendor.o(($event) => changeCartQtySimple(dish, 1), dish.id),
            p: "6d2f30b2-4-" + i0,
            q: common_vendor.p({
              size: "24",
              name: "plus-circle-fill",
              ["custom-style"]: "width:50px;float:right;color:#0E8A9E;margin-right:-30px;margin-bottom:-60px"
            })
          }) : {}, {
            r: dish.spece == 1
          }, dish.spece == 1 ? {
            s: common_vendor.o(($event) => openSpecDialog(dish), dish.id),
            t: "6d2f30b2-5-" + i0,
            v: common_vendor.p({
              size: "mini",
              ["custom-style"]: "width:50px;float:right;color:#ffffff;background:#0E8A9E;border-radius: 20rpx;margin-bottom:-60px"
            })
          } : {}, {
            w: dish.id
          });
        }),
        f: (_a = selectedDish.value) == null ? void 0 : _a.img,
        g: common_vendor.t((_b = selectedDish.value) == null ? void 0 : _b.name),
        h: common_vendor.t(selectedSpec.value),
        i: spicyList.value.length > 0 && specList.value.length > 0
      }, spicyList.value.length > 0 && specList.value.length > 0 ? {} : {}, {
        j: common_vendor.t(selectedSpicy.value),
        k: common_vendor.t((_c = selectedDish.value) == null ? void 0 : _c.price),
        l: specList.value.length > 0
      }, specList.value.length > 0 ? {
        m: common_vendor.f(specList.value, (spec, k0, i0) => {
          return {
            a: common_vendor.t(spec),
            b: spec,
            c: common_vendor.n(selectedSpec.value === spec ? "active" : ""),
            d: common_vendor.o(($event) => selectedSpec.value = spec, spec)
          };
        })
      } : {}, {
        n: spicyList.value.length > 0
      }, spicyList.value.length > 0 ? {
        o: common_vendor.f(spicyList.value, (spicy, k0, i0) => {
          return {
            a: common_vendor.t(spicy),
            b: spicy,
            c: common_vendor.n(selectedSpicy.value === spicy ? "active" : ""),
            d: common_vendor.o(($event) => selectedSpicy.value = spicy, spicy)
          };
        })
      } : {}, {
        p: common_vendor.o(($event) => changeQty(-1)),
        q: common_vendor.p({
          name: "minus",
          size: "20",
          ["custom-style"]: "margin-right:10px"
        }),
        r: common_vendor.t(qty.value),
        s: common_vendor.o(($event) => changeQty(1)),
        t: common_vendor.p({
          name: "plus",
          size: "20",
          ["custom-style"]: "margin-left:10px"
        }),
        v: common_vendor.o(addToCart),
        w: common_vendor.p({
          ["custom-style"]: "width:90%;margin:30px auto 0;border-radius: 50rpx;background:#0E8A9E;color:#ffffff;"
        }),
        x: common_vendor.o(($event) => showSpecDialog.value = false),
        y: common_vendor.p({
          show: showSpecDialog.value,
          mode: "bottom"
        }),
        z: common_assets._imports_0$1,
        A: cartList.value.length > 0
      }, cartList.value.length > 0 ? {
        B: common_vendor.t(cartList.value.length)
      } : {}, {
        C: cartList.value.length === 0
      }, cartList.value.length === 0 ? {} : {
        D: common_vendor.f(cartList.value, (item, k0, i0) => {
          return {
            a: item.img,
            b: common_vendor.t(item.name),
            c: common_vendor.t(item.spec),
            d: common_vendor.t(item.spicy),
            e: common_vendor.t(item.price),
            f: common_vendor.o(($event) => changeCartQty(item, -1), item.id + item.spec + item.spicy),
            g: "6d2f30b2-11-" + i0 + ",6d2f30b2-10",
            h: common_vendor.t(item.qty),
            i: common_vendor.o(($event) => changeCartQty(item, 1), item.id + item.spec + item.spicy),
            j: "6d2f30b2-12-" + i0 + ",6d2f30b2-10",
            k: item.id + item.spec + item.spicy
          };
        }),
        E: common_vendor.p({
          name: "minus",
          size: "20",
          ["custom-style"]: "margin-right:10px"
        }),
        F: common_vendor.p({
          name: "plus",
          size: "20",
          ["custom-style"]: "margin-left:10px"
        })
      }, {
        G: common_vendor.t(cartTotal.value),
        H: common_vendor.o(submitOrder),
        I: common_vendor.p({
          type: "primary",
          ["custom-style"]: "border-radius: 50rpx;background:#0E8A9E;color:#fff;width:120px;height:40px;font-size:28rpx;margin-right:40rpx"
        }),
        J: common_vendor.o(($event) => showCartDialog.value = false),
        K: common_vendor.p({
          show: showCartDialog.value,
          mode: "bottom"
        }),
        L: common_vendor.s("height: calc(100vh - 93px" + (cartList.value.length > 0 ? " - 60px" : "") + ");"),
        M: cartList.value.length > 0
      }, cartList.value.length > 0 ? common_vendor.e({
        N: common_assets._imports_0$1,
        O: cartList.value.length > 0
      }, cartList.value.length > 0 ? {
        P: common_vendor.t(cartList.value.length)
      } : {}, {
        Q: common_vendor.t(cartTotal.value),
        R: common_vendor.o(submitOrder),
        S: common_vendor.p({
          type: "primary",
          ["custom-style"]: "border-radius: 50rpx;background:#0E8A9E;color:#fff;width:120px;height:40px;font-size:28rpx;margin-right:40rpx"
        }),
        T: common_vendor.o(() => {
        }),
        U: common_vendor.o(($event) => showCartDialog.value = true)
      }) : {});
    };
  }
});
wx.createPage(_sfc_main);
