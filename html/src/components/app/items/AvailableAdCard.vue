<template>
    <Transition name="slide">
        <v-card v-if="ad" width="100%" variant="elevated" rounded="0" class="available-card" density="compact">
            <v-card-title class="card-title">
                <span>
                    {{ ad.title}} ({{ globalStore.$state.baseData.currency }}{{ ad.price }})
                </span>
                <v-chip variant="flat" v-if="ad.rep && ad.rep.name && ad.rep.required" :color="meetsRep ? 'primary' : 'error'">
                    {{ translate('rep') }}: {{ playerRep }}/{{ ad.rep.required }} ({{ ad.rep.label? ad.rep.label : repLabel }})
                </v-chip>
            </v-card-title>
            <v-card-subtitle style="white-space: pre-line" v-if="ad.description">
                {{ ad.description }}
            </v-card-subtitle>
            <v-card-text>
                <div v-if="ad.items && ad.items.length > 0" class="items">
                    <h3>{{ translate('items') }}:</h3>
                    <div class="item-list">
                        <v-chip label size="large" color="primary" variant="flat" v-for="item in ad.items"> 
                            <v-avatar start v-if="item.itemName">
                                <v-img :src="getImageLink(item.itemName)"></v-img>
                            </v-avatar>
                            <span class="bold white">{{ item.label }} x {{ item.amount }} </span>
                        </v-chip>
                    </div>
                </div>
            </v-card-text>
            <v-card-actions>
                <v-spacer></v-spacer>
                <v-btn size="large" :disabled="!meetsRep" rounded="0" color="primary" variant="tonal" @click='openModal()'>{{ translate('buy') }}</v-btn>
            </v-card-actions>
            <v-expand-transition>
                <v-card
                    v-if="modalIsOpen"
                    class="available-card position-absolute w-100"
                    height="100%"
                    style="bottom: 0;"
                    width="100%"
                    variant="elevated"
                    rounded="0"
                    density="compact"
                    :loading="loadingPurchase"
                >
                    <v-card-title>{{ translate('purchaseTitle') }}: {{ ad.title }}</v-card-title>
                    <v-card-text>
                        <p>{{ translate('price') }}: {{globalStore.$state.baseData.currency}}{{ad.price}}</p>
                        <small>{{ translate('purchaseWarning') }}</small>
                    </v-card-text>

                    <v-card-actions>
                        <v-spacer />
                        <v-btn rounded="0" :loading="loadingPurchase" color="warning" variant="tonal" @click='closeModal()'>{{ translate('close') }}</v-btn>
                        <v-btn rounded="0" :loading="loadingPurchase" color="primary" variant="tonal" @click='purchase()'>{{ translate('confirm') }}</v-btn>
                    </v-card-actions>
                </v-card>
            </v-expand-transition>
        </v-card>
    </Transition>
</template>

<script setup lang="ts">
import api from "@/api/axios";
import { getImageLink } from "@/helpers/getImageLink";
import { useGlobalStore } from "@/store/global";
import { Ad } from "@/store/types";
import { translate } from "@/translations/translate";
import { computed } from "vue";
import { ref } from "vue";

const props = defineProps<{
  ad: Ad
}>()

const globalStore = useGlobalStore();
const modalIsOpen = ref(false)
const loadingPurchase = ref(false)

const repLabel = computed(() => {
    if (props.ad.rep && globalStore.playerData.playerRep) {
        return globalStore.playerData.playerRep[props.ad.rep.name].label || globalStore.playerData.playerRep[props.ad.rep.name].name
    }
    return 'REPUTATION LABEL MISSING'
})

const playerRep = computed(() => {
    if (props.ad.rep && globalStore.playerData.playerRep) {
        return globalStore.baseData.useLevelsInsteadOfXp ? globalStore.playerData.playerRep[props.ad.rep.name].level :globalStore.playerData.playerRep[props.ad.rep.name].current
    }
    return 0
})

const meetsRep = computed(() => {
    if (props.ad.rep && globalStore.playerData.playerRep) {
        return playerRep.value > props.ad.rep.required
    }
    return true
})

const openModal = () => {
    modalIsOpen.value = true
}

const closeModal = () => {
    modalIsOpen.value = false
    globalStore.$state.error = undefined
}

const purchase = async () => {
    loadingPurchase.value = true
    const res = await api.post("UiAttemptPurchase", JSON.stringify(props.ad.id));
    if (res.data) {
        globalStore.$state.currentView.tab = 'pickups'
        globalStore.$state.error = undefined
    } else {
        loadingPurchase.value = false
        globalStore.$state.error = 'purchaseError'
    }
    
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
