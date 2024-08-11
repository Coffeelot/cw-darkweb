// Utilities
import { defineStore } from 'pinia'
import { Ad, BaseData, BoughtAd, ItemType } from './types'

export const useGlobalStore = defineStore('global', {
  state: () => ({
    appIsOpen: false,
    currentView: { page: 'ads', tab: 'ads' },
    inventory: [] as (null | ItemType)[],
    showOnlyCurated: true,
    availableAds: [] as Ad[],
    availablePickups: [] as BoughtAd[],
    baseData: { 
      useLocalImages: false,
      oxInventory: false,
      currency: '$',
      useLevelsInsteadOfXp: false,
      playerRep: undefined
    } as BaseData,
    translations: [] as any,
    error: undefined as undefined | string
  })
})
