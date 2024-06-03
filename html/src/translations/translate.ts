import { useGlobalStore } from "@/store/global";
import { translations } from "./translations";

export const translate = (key: keyof typeof translations) => {
    const globalStore = useGlobalStore();
    return (globalStore.$state.translations[key] || translations[key]) || key
}