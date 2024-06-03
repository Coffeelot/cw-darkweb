<template>
    <Transition name="slide">
        <v-card v-if="ad" width="100%" variant="elevated" rounded="0" class="available-card" density="compact">
            <v-card-title class="primary">{{ ad.title}} ({{ globalStore.$state.baseData.currency }}{{ ad.price }})</v-card-title>
            <v-card-subtitle v-if="ad.description">
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
                <v-btn size="large" rounded="0" color="primary" variant="tonal" @click='openModal()'>{{ translate('buy') }}</v-btn>
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
import { ref } from "vue";

const props = defineProps<{
  ad: Ad
}>()

const globalStore = useGlobalStore();
const emits = defineEmits(['select'])
const modalIsOpen = ref(false)
const loadingPurchase = ref(false)

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
</style>
