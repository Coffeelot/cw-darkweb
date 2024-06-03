<template>
  <div class="page-container">
    <div class="subheader">
      <v-tabs v-model="globalStore.$state.currentView.tab" bg-color="background" color="primary">
        <v-tab value="ads">{{ translate("Ads") }}</v-tab>
        <v-tab value="pickups">{{ translate("Pickups") }}</v-tab>
      </v-tabs>
      <v-text-field
        class="text-field"
        hideDetails
        :placeholder="translate('search')"
        density="compact"
        v-model="search"
      ></v-text-field>
    </div>
    <v-window class="window" v-model="globalStore.$state.currentView.tab">
      <v-window-item value="ads">
        <div class="available-ads-page" v-if="filteredAvailableAds.length > 0">
          <AvailableAdCard
            v-for="ad in filteredAvailableAds"
            :key="ad.id"
            :ad="ad"
          ></AvailableAdCard>
        </div>
        <InfoText v-else :title="translate('noAds')"></InfoText>
      </v-window-item>

      <v-window-item value="pickups">
        <div class="available-ads-page" v-if="globalStore.$state.availablePickups?.length > 0">
          <AvailablePickupCard
            v-for="ad in globalStore.$state.availablePickups"
            :key="ad.id"
            :ad="ad"
          ></AvailablePickupCard>
        </div>
        <InfoText v-else :title="translate('noPurchases')"></InfoText>
      </v-window-item>

    </v-window>
  </div>
</template>

<script setup lang="ts">
import { useGlobalStore } from "@/store/global";
import { computed, ref } from "vue";
import AvailableAdCard from "../items/AvailableAdCard.vue";
import { translate } from "@/translations/translate";
import InfoText from "../components/InfoText.vue";
import AvailablePickupCard from "../items/AvailablePickupCard.vue";
import { hasItem } from "@/helpers/hasItem";

const globalStore = useGlobalStore();
const search = ref("");

const filteredAvailableAds = computed(() => {
  const ads = globalStore.$state.availableAds
  return ads.filter((ad) => {
    if (ad.required) {
      const hasTheItem = hasItem(ad.required.item)
      return hasTheItem
    }
    return true
  })
})
</script>

<style scoped lang="scss">
.window {
  overflow-y: auto
}
.text-field {
  max-width: 50%;
}
.available-ads-page {
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
  overflow-y: auto;
  // max-height: 30vw;
  gap: 1em;
  margin-top: 1em;
}

.page-container {
  padding-top: 1em;
  margin-left: auto;
  margin-right: auto;
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
  justify-content: flex-start;
  overflow: auto;
}
</style>
