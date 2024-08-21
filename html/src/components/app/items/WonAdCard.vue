<template>
    <Transition name="slide">
        <v-card v-if="ad" width="100%" variant="elevated" rounded="0" class="available-card" density="compact">
            <v-card-title class="card-title">
                <span>
                    {{ ad.title}} 
                </span>
                <span v-if="ad.buyer">
                    {{ translate('toPay') }} : {{ globalStore.baseData.currency }}{{ ad.buyer.amount }}
                </span>
            </v-card-title>
            <v-card-subtitle>
                {{ translate('wonInstructions') }}
            </v-card-subtitle>
            <v-card-text style="white-space: pre-line">
                {{ ad.description }}
                <v-divider class="mt-1 mb-1" ></v-divider>
                <h3>{{ translate('messageFromSeller') }}: {{ ad.message }}</h3>
            </v-card-text>
            <v-card-actions>
                <v-spacer></v-spacer>
                <div class="d-flex align-center ga-1" v-if="ad.auction && ad.status === 'AWAITING_RATING'">
                    {{ translate('rateSeller') }}:
                    <v-btn size="large" rounded="0" color="red" variant="tonal" @click='markBad()'>{{  translate('sellerBad') }}</v-btn>
                    <v-btn size="large" rounded="0" color="primary" variant="tonal" @click='markGood()'>{{  translate('sellerGood') }}</v-btn>
                </div>
                <v-btn v-else size="large" rounded="0" color="primary" variant="tonal" @click="markWaypoint" >{{  translate('waypoint') }}</v-btn>
            </v-card-actions>
        </v-card>
    </Transition>
</template>

<script setup lang="ts">
import api from "@/api/axios";
import { useGlobalStore } from "@/store/global";
import { PlayerAd } from "@/store/types";
import { translate } from "@/translations/translate";
import { ref } from "vue";

const props = defineProps<{
  ad: PlayerAd
}>()

const globalStore = useGlobalStore();
const loadingPurchase = ref(false)

const markWaypoint = async () => {
    loadingPurchase.value = true
    const res = await api.post("UiSetWaypoint", JSON.stringify(props.ad.coords));
}

const markBad = async () => {
    loadingPurchase.value = true
    const res = await api.post("UiRateSeller", JSON.stringify({ adId: props.ad.id, change: -1 }));
}
const markGood = async () => {
    loadingPurchase.value = true
    const res = await api.post("UiRateSeller", JSON.stringify({ adId: props.ad.id, change: 1 }));
}

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
