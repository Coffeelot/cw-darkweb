import { useGlobalStore } from "@/store/global";

export const translate = (key: string) => {
    const globalStore = useGlobalStore();
    return globalStore.baseData.translations[key] || key;
}