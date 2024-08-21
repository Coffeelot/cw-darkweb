// Utilities
import { defineStore } from 'pinia'
import { Ad, BaseData, BoughtAd, ItemType, PlayerAd, PlayerData } from './types'

export const useGlobalStore = defineStore('global', {
  state: () => ({
    appIsOpen: false,
    currentView: { page: 'ads', tab: 'ads' },
    inventory: [] as (null | ItemType)[],
    showOnlyCurated: true,
    availableAds: [] as Ad[],
    availablePickups: [] as BoughtAd[],
    availablePlayerAds: [] as PlayerAd[],
    baseData: { 
      translations: {},
      useLocalImages: false,
      oxInventory: false,
      currency: '$',
      accountCost: 10,
      useLevelsInsteadOfXp: false,
      noAccountBlocksPublicTrades: false,
      playerCitizenId: 'UNDEFINED',
      auctionTimes: [],
    } as BaseData,
    playerData: {
      playerRep: undefined,
      account: undefined,
    } as PlayerData,
    translations: [] as any,
    error: undefined as undefined | string
  })
})
