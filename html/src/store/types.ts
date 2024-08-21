
export interface Account {
    name: string,
    rating: number,
    citizenId: string,
    sales: number,
    purchases: number,
    moneyHeld: number,
    status: string
}

export interface PlayerData {
    playerRep?: Record<string, PlayerRep>,
    account?: Account,
}

export interface AuctionTime {
    minutes: number
    label: string
}
export interface BaseData {
    currency: string,
    useLocalImages: boolean,
    oxInventory: boolean,
    useLevelsInsteadOfXp: boolean,
    noAccountBlocksPublicTrades: boolean,
    accountCost: number,
    auctionTimes: AuctionTime[],
    playerCitizenId: string,
    translations: Record<string,string>
}

export interface AdItem {
    label?: string,
    itemName: string,
    amount: number,
    metadata: any,
}

export interface Requirement {
    item: string
    metadata: Record<string, any>[]
}

export interface Rep {
    name: string,
    required: number,
    label?: string
}

export interface AdAccount extends Account {
    amount: number
}

export interface Bid {
    name: string,
    rating: number,
    purchases: number
    sales: number
    citizenId: string
    amount: number
}
export interface PlayerAd {
    price: number,
    expires: number,
    auction: boolean
    id: string,
    title: string,
    description: string,
    seller: Account,
    buyer?: AdAccount,
    bids: Bid[],
    endtime?: number,
    status: 'AVAILABLE' | 'INTREST' | 'WAITING' |'ACCEPTED' | 'AWAITING_RATING' | 'DONE',
    message: string
    coords: [],
}

export interface Ad {
    price: number,
    expires: number,
    id: string,
    title: string,
    description: string,
    required?: Requirement,  
    items: AdItem[],
    rep?: Rep
}

export interface Pickup {
    price: number,
    expires: number,
    id: string,
    title: string,
    description: string,
    items: AdItem[],
    coords: [],
    locationDescription: string,
}

export interface BoughtAd extends Ad {
    coords: { x: number, y: number, z: number },
    purchaseTime: number,
    locationDescription: string
}

type MetadataType = 
  | { [key: string]: string | number | undefined }
  | [];

export interface ItemType {
    description?: string;
    close: boolean;
    stack: boolean;
    metadata: MetadataType;
    name: string;
    weight: number;
    slot: number;
    label: string;
    count: number;
  }

  export interface PlayerRep {
    name: string
    current: number
    level: number
    icon?: string
    label?: string
  }


