<template>
    <Transition name="slide">
        <v-card v-if="ad" width="100%" variant="elevated" rounded="0" class="available-card" density="compact">
            <v-card-title class="card-title">
                <span>
                    {{ ad.title}} 
                </span>
                <v-chip>{{ timeRemaining }}</v-chip>
            </v-card-title>
            <v-card-subtitle>
                {{ translate('acceptedInstructions') }}
            </v-card-subtitle>
            <v-card-text style="white-space: pre-line">
                {{ ad.description }}
                <v-divider color="white"></v-divider>
                <v-list lines="one" v-if="ad.bids && ad.bids.length>0">
                    <v-list-subheader>{{translate('bids')}}</v-list-subheader>
                    <v-list-item
                        v-for="(bid, index) in bids"
                        :key="index"
                        variant="tonal"
                        :title="`${bid.name} (${translate('rating')}:${bid.rating})`"
                        :subtitle="globalStore.baseData.currency + bid.amount"
                    ></v-list-item>
                </v-list>
            </v-card-text>
            <v-card-actions>
                <v-spacer></v-spacer>
                <div class="d-flex align-center ga-1" v-if="ad.auction && ad.status === 'AVAILABLE'">
                    <v-btn size="large" rounded="0" color="primary" variant="tonal" @click='acceptBid()'>{{  translate('endNow') }}</v-btn>
                </div>
                <div class="d-flex align-center ga-1" v-else-if="ad.auction && ad.status === 'ACCEPTED'">
                    <v-btn size="large" rounded="0" color="red" variant="tonal" @click='markNoShow()'>{{  translate('buyerNoShow') }}</v-btn>
                    <v-btn size="large" rounded="0" color="primary" variant="tonal" @click='markConfirm()'>{{  translate('confirmDelivery') }}</v-btn>
                </div>
                <v-btn v-else size="large" rounded="0" color="primary" variant="tonal" @click="acceptBid()">{{  translate('acceptPurchase') }}</v-btn>
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
const loadingPurchase = ref(false)

const myBid = ref(0)

const bids = computed(() => {
    return props.ad.bids?.sort((ad, otherAd) => ad.amount < otherAd.amount ? 1 : -1 )
})

const disableBid = computed(() => {
    if (isExpired.value) return true
    if (props.ad.seller.citizenId === globalStore.baseData.playerCitizenId) return true
    if (myBid.value <= highestBid.value) return true
})

const highestBid = computed(() => {
    return props.ad.bids?.reduce((highest, current) => 
        current.amount > highest.amount ? current : highest
    ).amount || props.ad.price;
})

const isExpired = computed(() => props.ad.endtime ? timeRemaining.value === 'Expired' : false)

const timeRemaining = ref()
const acceptBid = async () => {
    loadingPurchase.value = true
    const res = await api.post("UiAcceptBid", JSON.stringify(props.ad.id));
}
const markNoShow = async () => {
    loadingPurchase.value = true
    const res = await api.post("UiNoShow", JSON.stringify(props.ad.id));
}
const markConfirm = async () => {
    loadingPurchase.value = true
    const res = await api.post("UiConformDelivery", JSON.stringify(props.ad.id));
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
