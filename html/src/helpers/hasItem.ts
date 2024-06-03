import { useGlobalStore } from "@/store/global";

export const hasItem = (name: string) => {
    const store = useGlobalStore()
    const inventory = store.inventory
    const foundItem = inventory.find(item => item?.name === name);

    return !!foundItem

}
