<template>
  <v-app theme="dark" >
    <Transition name="fade">
      <DarkwebAppView v-if="globalStore.$state.appIsOpen"></DarkwebAppView>
    </Transition>
  </v-app>
</template>

<script lang="ts" setup>
import {
  onMounted,
  onUnmounted,
} from "vue";
import { useGlobalStore } from "./store/global";
import DarkwebAppView from "./views/DarkwebAppView.vue";

const globalStore = useGlobalStore();


const toggleApp = (show: boolean): void => {
  globalStore.$state.appIsOpen = show
};

const handleUpdateData = (itemData: any) => {
    globalStore.$state.availableAds = itemData.ads
    globalStore.$state.availablePickups = itemData.pickups
}

const handleMessageListener = (event: MessageEvent) => {
  const itemData: any = event?.data;
  if (itemData?.type) {
    switch (itemData.type) {
      case 'toggleUi':
        globalStore.$state.inventory = itemData.inventory
        toggleApp(itemData.toggle)
        break;
      case 'updateList':
        handleUpdateData(itemData)
        break;
      case 'baseData':
        globalStore.$state.baseData = itemData.baseData
        break;
      default:
        console.log('UNKNOWN TYPE FOR DARKWEB', itemData.type)
        break;
    }

  }
  
};

onMounted(() => {
  window.addEventListener("message", handleMessageListener);
  globalStore.$state.availableAds = [
    {
        title: "pizza slice",
        items: [
            { itemName : 'pep_pizza', amount : 1, metadata : undefined },
        ],
        price: 20,
        expires: 202020,
        description:'This is a pizza',
        id: '20',
    },
    {
        title: "10 pizza slices",
        items: [
            { itemName : 'pep_pizza', amount : 10, metadata : undefined },
        ],
        price: 20,
        expires: 202020,
        description:'This is 10 pizza slices',
        id: '21',
    },
    {
        title: "10 pizza slices but separate",
        items: [
            { itemName : 'pep_pizza', amount : 1, metadata : undefined },
            { itemName : 'pep_pizza', amount : 1, metadata : undefined },
            { itemName : 'pep_pizza', amount : 1, metadata : undefined },
            { itemName : 'pep_pizza', amount : 1, metadata : undefined },
            { itemName : 'pep_pizza', amount : 1, metadata : undefined },
            { itemName : 'pep_pizza', amount : 1, metadata : undefined },
            { itemName : 'pep_pizza', amount : 1, metadata : undefined },
            { itemName : 'pep_pizza', amount : 1, metadata : undefined },
            { itemName : 'pep_pizza', amount : 1, metadata : undefined },
            { itemName : 'pep_pizza', amount : 1, metadata : undefined },
        ],
        price: 20,
        expires: 202020,
        description:'This is a pizza',
        id: '22',
    },
    {
        title: "10 pizza slices but separate",
        items: [
            { itemName : 'pep_pizza', amount : 1, metadata : undefined },
            { itemName : 'pep_pizza', amount : 1, metadata : undefined },
            { itemName : 'pep_pizza', amount : 1, metadata : undefined },
            { itemName : 'pep_pizza', amount : 1, metadata : undefined },
            { itemName : 'pep_pizza', amount : 1, metadata : undefined },
            { itemName : 'pep_pizza', amount : 1, metadata : undefined },
            { itemName : 'pep_pizza', amount : 1, metadata : undefined },
            { itemName : 'pep_pizza', amount : 1, metadata : undefined },
            { itemName : 'pep_pizza', amount : 1, metadata : undefined },
            { itemName : 'pep_pizza', amount : 1, metadata : undefined },
        ],
        price: 20,
        expires: 202020,
        description:'This is a pizza',
        id: '23',
    },
    {
        title: "10 pizza slices but separate",
        items: [
            { itemName : 'pep_pizza', amount : 1, metadata : undefined },
            { itemName : 'pep_pizza', amount : 1, metadata : undefined },
            { itemName : 'pep_pizza', amount : 1, metadata : undefined },
            { itemName : 'pep_pizza', amount : 1, metadata : undefined },
            { itemName : 'pep_pizza', amount : 1, metadata : undefined },
            { itemName : 'pep_pizza', amount : 1, metadata : undefined },
            { itemName : 'pep_pizza', amount : 1, metadata : undefined },
            { itemName : 'pep_pizza', amount : 1, metadata : undefined },
            { itemName : 'pep_pizza', amount : 1, metadata : undefined },
            { itemName : 'pep_pizza', amount : 1, metadata : undefined },
        ],
        price: 20,
        expires: 202020,
        description:'This is a pizza',
        id: '24',
    },
  ]
});

onUnmounted(() => {
  window.removeEventListener("message", handleMessageListener, false);
});

</script>

<style>
@import './styles/global.scss';

::-webkit-scrollbar {
  width: 0;
  display: inline !important;
}
.v-application {
  background: rgb(0, 0, 0, 0.0) !important;
}

.fade-enter-active, .fade-leave-active {
  transition: opacity .5s;
}
.fade-enter, .fade-leave-to /* .fade-leave-active below version 2.1.8 */ {
  opacity: 0;
}
</style>
