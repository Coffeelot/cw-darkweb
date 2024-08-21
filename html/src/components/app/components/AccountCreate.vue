<template>
  <v-card variant="elevated" rounded="0" :title="isBanned ? translate('bannedAccount') : translate('missingAccount')" :text=" isBanned ? translate('youreBanned') : translate('needAccount')">
    <v-card-actions v-if="!reveal">
      <v-btn
        v-if="!isBanned"
        :text="translate('createAccount')"
        rounded="0"
        color="primary"
        variant="tonal"
        @click="reveal = true"
      ></v-btn>
    </v-card-actions>

    <v-expand-transition>
      <v-card
        v-if="reveal"
      >
        <v-card-text class="pb-0" :title="translate('createAccount')">
          <h3 class="mb-1">{{ translate('cost') }}: {{ globalStore.baseData.currency }}{{ globalStore.baseData.accountCost }}</h3>
          <v-text-field :error="!!error" rounded="0" :disabled="loadingCreation" v-model="nameInput" :label="translate('accountName')" :hint="translate('accountNameHint')" ></v-text-field>
          <v-alert v-if="error" type="error" :title="translate(error)"></v-alert>
        </v-card-text>
        
        <v-card-actions class="pt-0">
          <v-spacer></v-spacer>
          <v-btn @click="attemptCreation" size="large" :disabled="disableAccountNameCreation" rounded="0" color="primary" variant="tonal">{{ translate('create') }}</v-btn>
        </v-card-actions>
      </v-card>
    </v-expand-transition>
  </v-card>
        
</template>

<script setup lang="ts">
import { translate } from "@/translations/translate";
import { computed, ref } from "vue";
import { useGlobalStore } from "@/store/global";
const globalStore = useGlobalStore();

import api from "@/api/axios";
const nameInput = ref('')
const error = ref<string | undefined>(undefined)
const loadingCreation = ref(false)
const disableAccountNameCreation = computed(() => nameInput.value.length === 0 || loadingCreation.value )
const isBanned = computed(() => globalStore.playerData.account && globalStore.playerData.account.status === 'BANNED' )

const attemptCreation = async () => {
  loadingCreation.value = true
  const res = await api.post("UiCreateAccount", JSON.stringify(nameInput.value));
  loadingCreation.value = false
  if (res.data === 'OK') {
    error.value = undefined
  } else {
    error.value = res.data
  }
}

const reveal = ref(false)
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
