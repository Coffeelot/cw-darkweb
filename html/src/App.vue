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
      case 'playerData':
        globalStore.$state.playerData = itemData.playerData
        break;
      case 'updatePlayerList':
        globalStore.$state.availablePlayerAds = itemData.availablePlayerAds
        break;
      default:
        console.log('UNKNOWN TYPE FOR DARKWEB', itemData.type)
        break;
    }

  }
  
};

onMounted(() => {
  window.addEventListener("message", handleMessageListener);

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
