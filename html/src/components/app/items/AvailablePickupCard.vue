<template>
    <Transition name="slide">
        <v-card v-if="ad" width="100%" variant="elevated" rounded="0" class="available-card" density="compact">
            <v-card-title class="primary">{{ translate('pickupReady') }}</v-card-title>
            <v-card-text>
                <h3>{{ translate('areaDescription') }}:</h3>
                <p> {{ ad.locationDescription }} </p>
                <h3>{{ translate('coordinates') }}:</h3>
                <p> x: {{ Math.floor(ad.coords.x) }}, y: {{ Math.floor(ad.coords.y) }}, z: {{ Math.floor(ad.coords.z) }} </p>
            </v-card-text>
            <v-card-actions>
                <v-spacer></v-spacer>
                <v-btn size="large" rounded="0" color="primary" variant="tonal" @click='setWaypoint()'>{{ translate('waypoint') }}</v-btn>
            </v-card-actions>
        </v-card>
    </Transition>
</template>

<script setup lang="ts">
import api from "@/api/axios";
import { closeApp } from "@/helpers/closeApp";
import { useGlobalStore } from "@/store/global";
import { BoughtAd } from "@/store/types";
import { translate } from "@/translations/translate";

const props = defineProps<{
  ad: BoughtAd
}>()

const setWaypoint = () => {
    api.post("UiSetWaypoint", JSON.stringify(props.ad.coords));
    closeApp()
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
</style>
