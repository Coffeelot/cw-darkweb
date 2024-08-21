<template>
    <Transition name="slide">
        <v-card v-if="ad" width="100%" variant="elevated" rounded="0" class="available-card" density="compact">
            <v-card-title class="card-title">
                <span>
                    {{ ad.title}} 
                </span>
            </v-card-title>
            <v-card-subtitle class="d-flex ga-1">
                <v-chip v-if="timeRemaining">{{ translate('endsIn') }}: {{  timeRemaining }}</v-chip>
                <v-chip v-if="ad.auction" :color="isTopBidder ? 'green':'yellow'  "> {{ translate('highestBid') }}: {{ globalStore.$state.baseData.currency }} {{ highestBid }} </v-chip>
                <span v-else> ({{ globalStore.$state.baseData.currency }} {{ ad.price }})</span>
            </v-card-subtitle>
            <v-card-text style="white-space: pre-line">
                {{ ad.description }}
            </v-card-text>
            <v-card-actions>
                <div class="d-flex align-center flex-wrap ga-1">
                    <v-chip>{{ translate('seller') }}: {{ ad.seller.name }}</v-chip>
                    <v-chip> {{ translate('rating') }}: {{ad.seller.rating}} </v-chip>
                    <v-chip> {{ translate('sales') }}: {{ad.seller.sales}} </v-chip>
                </div>
                <v-spacer></v-spacer>
                <div class="d-flex align-center ga-1" v-if="ad.auction">
                    <v-text-field v-model="myBid" type="number" hide-details density="compact" :placeholder="highestBid.toString()" ></v-text-field>
                    <v-btn size="large" :disabled="disableBid" rounded="0" color="primary" variant="tonal" @click='doBid()'>{{  translate('bid') }}</v-btn>
                </div>
                <v-btn v-else size="large" :disabled="disableBuy" rounded="0" color="primary" variant="tonal" @click='openModal()'>{{  translate('buy') }}</v-btn>
            </v-card-actions>
        </v-card>
    </Transition>
</template>

<script setup lang="ts">
import api from "@/api/axios";
import { useGlobalStore } from "@/store/global";
import { getTimeRemaining } from "@/helpers/getTimeRemaining";
import { PlayerAd } from "@/store/types";
import { translate } from "@/translations/translate";
import { computed, onMounted, onUnmounted } from "vue";
import { ref } from "vue";

const props = defineProps<{
  ad: PlayerAd
}>()

const globalStore = useGlobalStore();
const modalIsOpen = ref(false)
const loadingPurchase = ref(false)

const myBid = ref(0)

const disableBuy = computed(() => {
    if (isExpired.value) return true
    if (props.ad.seller.citizenId === globalStore.baseData.playerCitizenId) return true
})

const disableBid = computed(() => {
    if (isExpired.value) return true
    if (props.ad.seller.citizenId === globalStore.baseData.playerCitizenId) return true
    if (myBid.value <= highestBid.value) return true
    if (myBid.value < 0) return true
})

const highestBid = computed(() => {
    return Number(props.ad.bids.length > 0 ? props.ad.bids?.reduce((highest, current) => 
        current.amount > highest.amount ? current : highest
    ).amount : props.ad.price);
})

const isTopBidder = computed(() => {
    return props.ad.bids.length > 0 ? props.ad.bids.reduce((highest, current) => 
        current.amount > highest.amount ? current : highest
    ).citizenId === globalStore.baseData.playerCitizenId : false;
})

const isExpired = computed(() => props.ad.endtime ? timeRemaining.value === 'Expired' : false)

const openModal = () => {
    modalIsOpen.value = true
}

const timeRemaining = ref()
const doBid = async () => {
    loadingPurchase.value = true
    const res = await api.post("UiAttemptBid", JSON.stringify({ adId: props.ad.id, amount: myBid.value }));
}

const updateRemainingTime = () => {
  timeRemaining.value = props.ad.endtime ? getTimeRemaining(props.ad.endtime) : undefined;
};

let intervalId: ReturnType<typeof setInterval> | null = null;

onMounted(() => {
  updateRemainingTime(); // Initial call to set the time remaining
  intervalId = setInterval(updateRemainingTime, 1000); // Update every second
});

onUnmounted(() => {
  if (intervalId) {
    clearInterval(intervalId);
  }
});
</script>

<style scoped lang="scss">
.v-overlay--active {
    backdrop-filter: saturate(200%) blur(10px);
}
.v-overlay__scrim {
    background: none
}
.available-card {
    flex-grow: 1;
    height: fit-content;
}
.items {
    display: flex;
    flex-direction: column;
    gap: 0.5em;
}
.item-list {
    display: flex;
    gap: 0.5em;
    flex-wrap: wrap;
}
.card-title {
    display: flex;
    gap: 1em;
}
</style>
