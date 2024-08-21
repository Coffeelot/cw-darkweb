<template>
  <div ref="window" class="page-container">
    <v-dialog
      v-model="creationModalIsOpen"
      width="auto"
      contained
    >
      <AdCreationMenu @close="()=>creationModalIsOpen = false"></AdCreationMenu>
    </v-dialog>
    <div class="subheader">
      <v-tabs v-model="globalStore.$state.currentView.tab" bg-color="background" color="primary">
        <v-tab value="ads">{{ translate("ads") }}</v-tab>
        <v-tab value="pickups">{{ translate("pickups") }}</v-tab>
        <v-tab value="market">{{ translate("market") }}</v-tab>
        <v-tab value="user" v-if="globalStore.playerData.account">{{ translate("user") }}</v-tab>
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
      <v-window-item class="page-content" value="ads">
        <AccountCreate v-if="globalStore.baseData.noAccountBlocksPublicTrades && (!globalStore.playerData.account || globalStore.playerData.account.status === 'BANNED')"></AccountCreate>
        <div v-else>
          <div class="available-ads-page" v-if="filteredAvailableAds.length > 0">
            <AvailableAdCard
              v-for="ad in filteredAvailableAds"
              :key="ad.id"
              :ad="ad"
            ></AvailableAdCard>
          </div>
          <InfoText v-else :title="translate('noAds')"></InfoText>
        </div>
      </v-window-item>

      <v-window-item class="page-content" value="market">
        <AccountCreate v-if="!globalStore.playerData.account || globalStore.playerData.account.status === 'BANNED'"></AccountCreate>
        <div v-else>
          <div class="available-ads-page">
            <h3 v-if="myAds.length>0" >{{ translate('selling') }}</h3>
            <MyAdCard
              v-if="myAds.length>0"
              v-for="ad in myAds"
              :key="ad.id"
              :ad="ad"
            ></MyAdCard>
            <div class="w-100 d-flex" v-else> 
              <v-spacer></v-spacer>
              <v-btn @click="openModal" rounded="0" color="primary" variant="tonal">{{ translate('createPosting') }}</v-btn>
               </div>
            <h3 v-if="buyingAds.length>0">{{ translate('buying') }}</h3>
            <WonAdCard
              v-for="ad in buyingAds"
              :key="ad.id"
              :ad="ad"
            ></WonAdCard>
          </div>
          <v-divider class="mt-2 mb-2"></v-divider>
          <div class="available-ads-page" v-if="filteredAvailablePlayerAds?.length > 0">
            <h3>{{ translate('available') }}</h3>
            <AvailablePlayerAdCard
              v-for="ad in filteredAvailablePlayerAds"
              :key="ad.id"
              :ad="ad"
            ></AvailablePlayerAdCard>
          </div>
          <InfoText v-else :title="translate('noAds')"></InfoText>
        </div>
      </v-window-item>
      <v-window-item class="page-content" value="pickups">
        <div class="available-ads-page" v-if="globalStore.availablePickups.length > 0">
            <AvailablePickupCard
              v-for="ad in globalStore.availablePickups"
              :key="ad.id"
              :ad="ad"
            ></AvailablePickupCard>
          </div>
        <InfoText v-else :title="translate('noPurchases')"></InfoText>
      </v-window-item>

      <v-window-item class="page-content" value="user">
        <div v-if="globalStore.playerData.account" class="available-ads-page">
            <div class="user-page">
            <v-card :title="globalStore.playerData.account.name">
              <v-card-text class="d-flex flex-wrap ga-1">
                <v-chip> {{ translate('rating') }}: {{globalStore.playerData.account.rating}} </v-chip>
                <v-chip> {{ translate('sales') }}: {{globalStore.playerData.account.sales}} </v-chip>
                <v-chip> {{ translate('purchases') }}: {{globalStore.playerData.account.purchases}} </v-chip>
                <v-chip :color="isBanned ? 'red': 'green'" > {{ translate('status') }}: {{globalStore.playerData.account.status}} </v-chip>
              </v-card-text>
            </v-card>
          </div>
        </div>
      </v-window-item>

    </v-window>
  </div>
</template>

<script setup lang="ts">
import { useGlobalStore } from "@/store/global";
import { computed, ref } from "vue";
import AvailableAdCard from "../items/AvailableAdCard.vue";
import MyAdCard from "../items/MyAdCard.vue";
import WonAdCard from "../items/WonAdCard.vue";
import AvailablePlayerAdCard from "../items/AvailablePlayerAdCard.vue";
import { translate } from "@/translations/translate";
import InfoText from "../components/InfoText.vue";
import AdCreationMenu from "../components/AdCreationMenu.vue";
import AccountCreate from "../components/AccountCreate.vue";
import AvailablePickupCard from "../items/AvailablePickupCard.vue";
import { hasItem } from "@/helpers/hasItem";

const globalStore = useGlobalStore();
const search = ref("");
const creationModalIsOpen = ref(false);
const isBanned = computed(() => globalStore.playerData.account && globalStore.playerData.account.status === 'BANNED' )

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

const myAds = computed(() => {
  const ads = globalStore.$state.availablePlayerAds
  return ads.filter((ad) => {
    if (ad.seller.citizenId === globalStore.baseData.playerCitizenId && ad.status !== 'DONE' && ad.status !== 'AWAITING_RATING') return true
    return false
  })
})

const buyingAds = computed(() => {
  const ads = globalStore.$state.availablePlayerAds
  return ads.filter((ad) => {
    if (ad.buyer?.citizenId === globalStore.baseData.playerCitizenId && (ad.status === 'WAITING' || ad.status === 'ACCEPTED' || ad.status === 'AWAITING_RATING')) return true
    return false
  })
})

const filteredAvailablePlayerAds = computed(() => {
  const ads = globalStore.$state.availablePlayerAds
  return ads.filter((ad) => {
    if (ad.seller.citizenId !== globalStore.baseData.playerCitizenId && ad.status === 'AVAILABLE') return true
    return false
  })
})

const openModal = () => {
  creationModalIsOpen.value = true
}
</script>

<style scoped lang="scss">
.window {
  overflow-y: auto
}
.user-page {
  display: flex;
  flex-direction: column;
  gap: 1em;
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
