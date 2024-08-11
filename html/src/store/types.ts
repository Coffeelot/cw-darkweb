export interface BaseData {
    currency: string,
    useLocalImages: boolean,
    oxInventory: boolean,
    useLevelsInsteadOfXp: boolean,
    playerRep?: Record<string, PlayerRep>,
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


