<template>
      <v-card
        rounded="0"
        min-width="1000"
      >
        <v-card-title class="d-flex">
          {{ translate('createPosting') }}
          <v-spacer></v-spacer>
          <v-btn @click="$emit('close')" variant="text" icon="mdi-close"></v-btn>
        </v-card-title>
        <v-card-text>
          <v-alert
            class="mb-2"
            type="info"
            rounded="0"
            density="compact"
            >
              {{ translate('creationNotice') }}
            </v-alert>
          <v-container>
            <v-row class="ga-2 mb-1">
                <v-text-field
                  rounded="0"
                  v-model="adCreation.title"
                  :error="formErrors.title"
                  :label="translate('title')"
                  hide-details
                  required
                ></v-text-field>
                <v-text-field
                  rounded="0"
                  v-model="adCreation.price"
                  :error="formErrors.price"
                  type="number"
                  :label="translate('price')"
                  hide-details
                  required
                ></v-text-field>
            </v-row>
            <v-row>
                <v-textarea
                  rounded="0"
                  v-model="adCreation.description"
                  :error="formErrors.description"
                  :label="translate('description')"
                  :hint="translate('adDescriptionHint')"
                  required
                ></v-textarea>
            </v-row>
            <v-row>
                <v-text-field
                  rounded="0"
                  v-model="adCreation.message"
                  :error="formErrors.message"
                  :label="translate('postMessage')"
                  :hint="translate('postMessageHint')"
                  required
                ></v-text-field>
            </v-row>
            <v-row>
              <v-select
                rounded="0"
                :label="translate('adLife')"                
                v-model="adCreation.minutesUntilEnd" 
                :error="formErrors.minutesUntilEnd"
                :items="globalStore.baseData.auctionTimes"
                item-title="label" item-value="minutes"></v-select>
            </v-row>
          </v-container>
        </v-card-text>
        <template v-slot:actions>
          <v-alert 
            v-if="errorMessage"
            type="error"
            rounded="0"
            density="compact"
            >
               {{ translate(errorMessage) }}
          </v-alert>
          <v-btn
            class="ms-auto"
            rounded="0"
            variant="tonal"
            color="green"
            size="x-large"
            :text="translate('confirmAd')"
            @click="confirmCreate"
          ></v-btn>
        </template>
      </v-card>
</template>

<script setup lang="ts">
import { useGlobalStore } from "@/store/global";
import { computed, ref } from 'vue';
import { translate } from "@/translations/translate";
import api from "@/api/axios";

const globalStore = useGlobalStore();
const emits = defineEmits(['close'])

const defaultErrors = {
  title: false,
  description: false,
  auction: false,
  price: false,
  minutesUntilEnd: false,
  message: false
}

const errorMessage = ref(undefined)
const formErrors = ref(defaultErrors)

const adCreation = ref({
  title: undefined,
  description: undefined,
  auction: true,
  price: 0,
  minutesUntilEnd: globalStore.baseData.auctionTimes[0]?.minutes,
  message: undefined
})

const verifyInput = () => {
  formErrors.value = {
    title: !!!adCreation.value.title,
    description: !!!adCreation.value.description,
    auction: !!!adCreation.value.auction,
    price: !!!adCreation.value.price,
    minutesUntilEnd: !!!adCreation.value.minutesUntilEnd,
    message: !!!adCreation.value.message
  }
}

const hasErrors = computed(() => {
  return Object.values(formErrors.value).some(error => error === true);
});

const confirmCreate = async () => {
    formErrors.value = defaultErrors
    verifyInput()
    if (!hasErrors.value) {
      const res = await api.post("UiCreateAd", JSON.stringify(adCreation.value));
      if (res.data !== 'OK') {
        errorMessage.value = res.data
      } else {
        errorMessage.value = undefined
        emits('close')
      }

    }
}

</script>

<style scoped lang="scss">
.infotext {
  width: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
}
</style>
