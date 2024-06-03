import { useGlobalStore } from "@/store/global";

export const getImageLink = (
  itemName: string
) => {
  const store = useGlobalStore();

  if (store.baseData.useLocalImages) {
    return `nui://cw-crafting/images/${itemName}.png`;
  } else {
    if (store.baseData.oxInventory) {
      return `nui://ox_inventory/web/images/${itemName}.png`;
    } else {
      return `nui://qb-inventory/html/images/${itemName}`;
    }
  }
};
